import 'dart:async';

import 'package:daily_todo/action_message_widget.dart';
import 'package:daily_todo/loading_widget.dart';
import 'package:daily_todo/login_widget.dart';
import 'package:daily_todo/main_app_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Todo',
      // theme: getAppTheme(context, true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Stream<User?> _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _user,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ActionMessageWidget(
            message: snapshot.error.toString(),
            actionLabel: "",
            onPressed: null,
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const LoadingWidget();
        }

        final User? user = snapshot.data;

        if (user != null) {
          // LOGGED IN
          return MainAppWidget(user);
        } else {
          // LOGGED OUT
          return const LoginWidget();
        }
      },
    );
  }
}
