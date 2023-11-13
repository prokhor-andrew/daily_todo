import 'package:daily_todo/build_context_show_alert_dialog.dart';
import 'package:daily_todo/keyboard_container.dart';
import 'package:daily_todo/lodable_button_widget.dart';
import 'package:daily_todo/my_text_field.dart';
import 'package:daily_todo/pass_recovery_widget.dart';
import 'package:daily_todo/sign_up_widget.dart';
import 'package:daily_todo/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
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
    return SafeArea(
      child: Scaffold(
        body: KeyboardContainer(
          children: [
            const Text(
              "Log in",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            MyTextField(
              hint: "Email",
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enabled: !_isLoading,
              controller: _emailController,
              error: _emailError,
            ),
            MyTextField(
              hint: "Password",
              enabled: !_isLoading,
              keyboardType: TextInputType.text,
              autocorrect: false,
              isSecure: true,
              controller: _passController,
              error: _passError,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: MaterialButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PassRecoveryWidget()));
                },
                child: const Text("Forgot password?"),
              ),
            ),
            const Spacer(),
            LoadableButtonWidget(
              title: "Log in",
              isLoading: _isLoading,
              onPressed: () {
                final String email = _emailController.text;
                final String password = _passController.text;

                setState(() {
                  _emailError = validateEmail(email);
                  _passError = validatePasswordExcludeLength(password);
                });

                if (_emailError != null || _passError != null) {
                  return;
                }

                setState(() {
                  _isLoading = true;
                  _emailError = null;
                  _passError = null;
                });

                authenticate(email: email, pass: password).then((_) {
                  setState(() {
                    _isLoading = false;
                  });
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
            Center(
              child: MaterialButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpWidget()));
                },
                child: const Text("Create account"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> authenticate({
    required String email,
    required String pass,
  }) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
  }
}
