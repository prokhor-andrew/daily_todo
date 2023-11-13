import 'package:daily_todo/action_message_widget.dart';
import 'package:daily_todo/build_context_show_alert_dialog.dart';
import 'package:daily_todo/change_email_widget.dart';
import 'package:daily_todo/change_password_widget.dart';
import 'package:daily_todo/create_note_widget.dart';
import 'package:daily_todo/loading_widget.dart';
import 'package:daily_todo/note.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MainAppWidget extends StatefulWidget {
  final User user;

  const MainAppWidget(this.user, {super.key});

  @override
  State<MainAppWidget> createState() => _MainAppWidgetState();
}

class _MainAppWidgetState extends State<MainAppWidget> {
  late DatabaseReference _ref;

  late Stream<List<Note>> _stream;

  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance.ref("users").child(widget.user.uid);
    _stream = _ref.onValue.map((event) => event.snapshot.value).map((event) => noteMapToNoteList(event));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateNoteWidget(widget.user.uid),
            ),
          );
        },
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              context.showAlertDialog<bool>(
                title: "Do you want to delete all notes?",
                message: "This action cannot be undone.",
                actions: [
                  AlertDialogAction(label: "Cancel", onPressed: () => Navigator.pop(context, false)),
                  AlertDialogAction(label: "Delete", onPressed: () {

                    _ref.remove();

                    Navigator.pop(context, true);
                  },),
                ],
              );
            },
            icon: const Icon(Icons.delete_outlined),
            tooltip: "Delete all",
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: StreamBuilder<List<Note>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ActionMessageWidget(message: "${snapshot.error}", actionLabel: "", onPressed: null);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          final List<Note> notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return ActionMessageWidget(
              message: "No notes",
              actionLabel: "Add first note",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateNoteWidget(widget.user.uid)));
              },
            );
          }

          return ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              if (oldIndex == newIndex) {
                return;
              }
              final element = notes[oldIndex];
              notes.removeAt(oldIndex);
              notes.insert(oldIndex > newIndex ? newIndex : newIndex - 1, element);

              final List<Object?> savable = notes.map((note) {
                return {
                  "id": note.id,
                  "done": note.done,
                  "timestamp": note.date.millisecondsSinceEpoch,
                  "contents": note.contents,
                };
              }).toList();

              _ref.set(savable).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated position")));
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update note: $error")));
              });
            },
            itemCount: notes.length,
            itemBuilder: (_, index) {
              final Note note = notes[index];

              return Dismissible(
                key: ValueKey(note.id),
                confirmDismiss: (_) async {
                  final bool? shouldDelete = await context.showAlertDialog<bool>(
                    title: "Do you want to delete this note?",
                    message: "This action cannot be undone.",
                    actions: [
                      AlertDialogAction(label: "Cancel", onPressed: () => Navigator.pop(context, false)),
                      AlertDialogAction(label: "Delete", onPressed: () => Navigator.pop(context, true)),
                    ],
                  );

                  if (shouldDelete == null || !shouldDelete) {
                    return false;
                  }

                  notes.removeAt(index);

                  final List<Object?> savable = notes.map((note) {
                    return {
                      "id": note.id,
                      "done": note.done,
                      "timestamp": note.date.millisecondsSinceEpoch,
                      "contents": note.contents,
                    };
                  }).toList();

                  return await _ref.set(savable).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note deleted")));
                    return Future.value(true);
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete note: $error")));
                    return Future.value(false);
                  });
                },
                direction: DismissDirection.endToStart,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                  child: Card(
                    color: Theme.of(context).cardColor,
                    child: InkWell(
                      onTap: () {
                        _checkNote(note, index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8, right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Checkbox(
                              value: note.done,
                              onChanged: (_) {
                                _checkNote(note, index);
                              },
                            ),
                            Expanded(
                              child: Text(
                                note.contents,
                                style: TextStyle(
                                  decoration: note.done ? TextDecoration.lineThrough : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _checkNote(Note note, int index) {
    _ref
        .child("$index")
        .update({
          "done": !note.done,
        })
        .then((value) {})
        .catchError((error) {
          final String message = "Failed to update: $error";
          final SnackBar snackBar = SnackBar(content: Text(message));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
  }
}

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late Stream<User?> _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.userChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        body: SafeArea(
          child: StreamBuilder<User?>(
            stream: _user,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ActionMessageWidget(
                  message: snapshot.error.toString(),
                  actionLabel: "",
                  onPressed: null,
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget();
              }

              final User? user = snapshot.data;
              return ListView(
                children: [
                  ListTile(
                    title: Text(
                      "${user?.email ?? ""} ${user?.emailVerified ?? false ? "" : "non verified"}",
                    ),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.dark_mode),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeEmailWidget(user?.email ?? "")));
                    },
                    child: const ListTile(
                      leading: Icon(Icons.email),
                      title: Text("Change email"),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordWidget()));
                    },
                    child: const ListTile(
                      leading: Icon(Icons.lock),
                      title: Text("Change password"),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      context.showAlertDialog<void>(
                        title: "Do you want to log out?",
                        message: "Logging out of the app will hide all of your notes until logged back in.",
                        actions: [
                          AlertDialogAction(label: "Cancel", onPressed: () => Navigator.pop(context)),
                          AlertDialogAction(
                            label: "Log out",
                            onPressed: () {
                              Navigator.pop(context);
                              FirebaseAuth.instance.signOut();
                            },
                          ),
                        ],
                      );
                    },
                    child: const ListTile(
                      leading: Icon(Icons.logout),
                      title: Text("Log out"),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      context.showAlertDialog<void>(
                        title: "Do you want to delete account?",
                        message:
                            "You are deleting your account with all of its notes.This action cannot be undone and in order to use the app in the future you must create a new account.",
                        actions: [
                          AlertDialogAction(label: "Cancel", onPressed: () => Navigator.pop(context)),
                          AlertDialogAction(
                            label: "Delete",
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);

                              final String? id = user?.uid;
                              if (id == null) {
                                return;
                              }

                              FirebaseDatabase.instance.ref("users").child(id).remove().then((_) {
                                return FirebaseAuth.instance.currentUser?.delete();
                              }).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete account: $error")));
                                return Future(() {});
                              });
                            },
                          ),
                        ],
                      );
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.person_off,
                        color: Colors.red,
                      ),
                      title: Text(
                        "Delete account",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
