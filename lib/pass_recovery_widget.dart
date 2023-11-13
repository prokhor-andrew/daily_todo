import 'package:daily_todo/build_context_show_alert_dialog.dart';
import 'package:daily_todo/keyboard_container.dart';
import 'package:daily_todo/lodable_button_widget.dart';
import 'package:daily_todo/my_text_field.dart';
import 'package:daily_todo/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PassRecoveryWidget extends StatefulWidget {
  const PassRecoveryWidget({super.key});

  @override
  State<PassRecoveryWidget> createState() => _PassRecoveryWidgetState();
}

class _PassRecoveryWidgetState extends State<PassRecoveryWidget> {
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  String? _emailError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
          "Recover password",
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
          const Spacer(),
          LoadableButtonWidget(
            title: "Send",
            isLoading: _isLoading,
            onPressed: () {
              final String email = _emailController.text;

              setState(() {
                _emailError = validateEmail(email);
              });

              if (_emailError != null) {
                return;
              }

              setState(() {
                _isLoading = true;
                _emailError = null;
              });

              sendRecoveryLetter(email: email).then((_) {
                setState(() {
                  _isLoading = false;
                });

                context.showAlertDialog<void>(
                  title: "Email was sent",
                  message: "A recovery email was sent. Please check your inbox",
                  actions: [
                    AlertDialogAction(
                      label: "Ok",
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              }).catchError(
                (error) {
                  setState(() {
                    _isLoading = false;
                  });

                  context.showAlertDialog<void>(
                    title: "Something went wrong",
                    message: "$error",
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

  Future<void> sendRecoveryLetter({
    required String email,
  }) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
