import 'package:daily_todo/build_context_show_alert_dialog.dart';
import 'package:daily_todo/keyboard_container.dart';
import 'package:daily_todo/lodable_button_widget.dart';
import 'package:daily_todo/my_text_field.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CreateNoteWidget extends StatefulWidget {
  final String userId;

  const CreateNoteWidget(this.userId, {super.key});

  @override
  State<CreateNoteWidget> createState() => _CreateNoteWidgetState();
}

class _CreateNoteWidgetState extends State<CreateNoteWidget> {
  final TextEditingController _controller = TextEditingController();

  String? _error;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: KeyboardContainer(
        children: [
          MyTextField(
            hint: "Contents",
            keyboardType: TextInputType.multiline,
            autocorrect: true,
            enabled: !_isLoading,
            controller: _controller,
            error: _error,
            maxLines: null,
          ),
          const Spacer(),
          LoadableButtonWidget(
            title: "Create",
            isLoading: _isLoading,
            onPressed: () {
              final String contents = _controller.text;

              setState(() {
                if (contents.isEmpty) {
                  _error = "Please enter some text to create note";
                } else if (contents.length > 500) {
                  _error = "The length of the text must not be more than 500 symbols. Current length: ${contents.length}";
                } else {
                  _error = null;
                }
              });

              if (_error != null) {
                return;
              }

              setState(() {
                _isLoading = true;
              });

              final ref = FirebaseDatabase.instance.ref("users").child(widget.userId);

              ref.get().then((snapshot) {
                final List<Object?> list = (snapshot.value as List<Object?>? ?? []).toList();

                list.insert(0, {
                  "contents": contents,
                  "done": false,
                  "timestamp": ServerValue.timestamp,
                  "id": ref.push().key,
                });

                return ref.set(list);
              }).then((_) {
                Navigator.pop(context);
              }).catchError((error) {
                setState(() {
                  _isLoading = false;

                  context.showAlertDialog<void>(
                    title: "Something went wrong",
                    message: error,
                    actions: [AlertDialogAction(label: "Ok", onPressed: () => Navigator.pop(context))],
                  );
                });
              });
            },
          ),
        ],
      ),
    );
  }
}
