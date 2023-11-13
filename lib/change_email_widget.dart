import 'package:daily_todo/build_context_show_alert_dialog.dart';
import 'package:daily_todo/keyboard_container.dart';
import 'package:daily_todo/lodable_button_widget.dart';
import 'package:daily_todo/my_text_field.dart';
import 'package:daily_todo/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangeEmailWidget extends StatefulWidget {
  final String email;

  const ChangeEmailWidget(this.email, {super.key});

  @override
  State<ChangeEmailWidget> createState() => _ChangeEmailWidgetState();
}

class _ChangeEmailWidgetState extends State<ChangeEmailWidget> {
  late TextEditingController _controller;

  bool _isLoading = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _controller.dispose();
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
            hint: "Email",
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            controller: _controller,
            error: _emailError,
          ),

          const Spacer(),

          LoadableButtonWidget(
            title: "Change",
            onPressed: () {

              setState(() {
                _emailError = validateEmail(_controller.text);
              });

              if (_emailError != null) {
                return;
              }

              setState(() {
                _isLoading = true;
                _emailError = null;
              });

              final user = FirebaseAuth.instance.currentUser;
              user?.verifyBeforeUpdateEmail(_controller.text).then((_) {
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
