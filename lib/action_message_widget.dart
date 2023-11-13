import 'package:daily_todo/functions.dart';
import 'package:flutter/material.dart';

class ActionMessageWidget extends StatelessWidget {
  final String message;
  final String actionLabel;
  final ActionFunc? onPressed;

  const ActionMessageWidget({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text(message, style: const TextStyle(color: Colors.black),)),
            Center(child: MaterialButton(onPressed: onPressed, child: Text(actionLabel))),
          ],
        ),
      ),
    );
  }
}
