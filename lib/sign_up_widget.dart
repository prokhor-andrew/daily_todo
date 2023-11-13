import 'package:daily_todo/build_context_show_alert_dialog.dart';
import 'package:daily_todo/keyboard_container.dart';
import 'package:daily_todo/lodable_button_widget.dart';
import 'package:daily_todo/my_text_field.dart';
import 'package:daily_todo/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isLoading = false;

  String? _emailError;
  String? _passError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Sign Up",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: KeyboardContainer(
        children: [
          MyTextField(
            hint: "Email",
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            controller: _emailController,
            error: _emailError,
            enabled: !_isLoading,
          ),
          MyTextField(
            hint: "Password",
            keyboardType: TextInputType.text,
            autocorrect: false,
            isSecure: true,
            enabled: !_isLoading,
            controller: _passController,
            error: _passError,
          ),
          const Spacer(),
          LoadableButtonWidget(
            title: "Sign up",
            isLoading: _isLoading,
            onPressed: () {
              final String email = _emailController.text;
              final String password = _passController.text;

              setState(() {
                _emailError = validateEmail(email);
                _passError = validatePasswordIncludeLength(password);
              });

              if (_emailError != null || _passError != null) {
                return;
              }

              setState(() {
                _isLoading = true;
                _emailError = null;
                _passError = null;
              });

              signUp(email: email, pass: password).then((_) {
                FirebaseAuth.instance.currentUser?.sendEmailVerification();

                setState(() {
                  _isLoading = false;
                });

                Navigator.pop(context);
              }).catchError(
                (error) {
                  setState(() {
                    _isLoading = false;
                  });

                  final String msg;
                  if (error is FirebaseAuthException) {
                    msg = error.message ?? "Unknown auth error";
                  } else {
                    msg = "$error";
                  }

                  context.showAlertDialog<void>(
                    title: "Something went wrong",
                    message: msg,
                    actions: [AlertDialogAction(label: "Ok", onPressed: () => Navigator.pop(context))],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> signUp({
    required String email,
    required String pass,
  }) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
  }
}
