import 'package:daily_todo/functions.dart';
import 'package:flutter/material.dart';

extension ShowAlertDialog on BuildContext {
  Future<T?> showAlertDialog<T>({
    required String title,
    String? message,
    List<AlertDialogAction> actions = const [],
  }) async {
    return showDialog<T>(
      context: this,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        final List<Widget> widgets = actions
            .map(
              (action) => TextButton(
                onPressed: action.onPressed,
                child: Text(
                  action.label,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            )
            .toList();

        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message ?? ""),
          ),
          actions: widgets,
        );
      },
    );
  }
}

class AlertDialogAction {
  final String label;
  final ActionFunc onPressed;

  AlertDialogAction({
    required this.label,
    required this.onPressed,
  });
}
