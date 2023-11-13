import 'package:daily_todo/functions.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String? error;
  final bool autocorrect;
  final TextInputType keyboardType;
  final bool enabled;
  final bool isSecure;
  final String hint;

  final bool autofocus;
  final TextEditingController? controller;
  final Handler<String>? onChanged;

  final int? maxLines;

  final IconButton? action;

  const MyTextField({
    super.key,
    required this.hint,
    required this.keyboardType,
    this.autocorrect = false,
    this.controller,
    this.autofocus = false,
    this.error,
    this.enabled = true,
    this.isSecure = false,
    this.onChanged,
    this.action,
    this.maxLines = 1,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool isHidden;

  @override
  void initState() {
    isHidden = widget.isSecure;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isHidden,
      // cursorColor: Colors.black,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      autocorrect: widget.autocorrect,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.hint,
        errorText: widget.error,
        // floatingLabelStyle: const TextStyle(color: Colors.black),
        focusedBorder: focusedBorder(),
        errorBorder: errorBorder(),
        disabledBorder: border(),
        enabledBorder: border(),
        border: border(),
        enabled: widget.enabled,
        // suffixIconColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.focused) ? Colors.black : Colors.grey),
        suffixIcon: widget.action ??
            (widget.isSecure
                ? IconButton(
                    icon: isHidden ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
                    onPressed: () => setState(() => isHidden = !isHidden),
                  )
                : const SizedBox(height: 0, width: 0)),
      ),
    );
  }

  OutlineInputBorder errorBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(
        // color: Colors.red,
        width: 2,
      ),
      borderRadius: BorderRadius.all(Radius.circular(4)),
    );
  }

  OutlineInputBorder focusedBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(
        // color: Colors.black,
        width: 2,
      ),
      borderRadius: BorderRadius.all(Radius.circular(4)),
    );
  }

  OutlineInputBorder border() {
    return const OutlineInputBorder(
      borderSide: BorderSide(
        // color: Colors.black,
        width: 2,
      ),
      borderRadius: BorderRadius.all(Radius.circular(4)),
    );
  }
}
