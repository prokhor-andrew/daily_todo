import 'package:daily_todo/build_context_show_alert_dialog.dart';
import 'package:daily_todo/keyboard_container.dart';
import 'package:daily_todo/lodable_button_widget.dart';
import 'package:daily_todo/my_text_field.dart';
import 'package:daily_todo/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({super.key});

  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isLoading = false;
  String? _passError;
  String? _confirmPassError;

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: KeyboardContainer(
        children: [
          MyTextField(
            hint: "Enter new password",
            keyboardType: TextInputType.text,
            isSecure: true,
            enabled: !_isLoading,
            controller: _passController,
            error: _passError,
          ),
          MyTextField(
            hint: "Confirm new password",
            keyboardType: TextInputType.text,
            isSecure: true,
            enabled: !_isLoading,
            controller: _confirmPassController,
            error: _confirmPassError,
          ),

          const Spacer(),

          LoadableButtonWidget(
            title: "Change",
            onPressed: () {
              final String pass = _passController.text;
              final String confirmPass = _confirmPassController.text;

              setState(() {
                _passError = validatePasswordIncludeLength(_passController.text);
              });

              if (_passError != null) {
                return;
              }

              setState(() {
                if (pass != confirmPass) {
                  _confirmPassError = "Passwords must be identical";
                } else {
                  _confirmPassError = null;
                }
              });

              if (_confirmPassError != null) {
                return;
              }

              setState(() {
                _isLoading = true;
                _passError = null;
                _confirmPassError = null;
              });

              FirebaseAuth.instance.currentUser?.updatePassword(pass).then((_) {
                Navigator.pop(context);
                setState(() {
                  _isLoading = false;
                });
              }).catchError((error) {
                context.showAlertDialog<void>(
                  title: "Something went wrong",
                  message: error.toString(),
                  actions: [AlertDialogAction(label: "Ok", onPressed: () => Navigator.pop(context))],
                );
                setState(() {
                  _isLoading = false;
                });
              });
            },
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
