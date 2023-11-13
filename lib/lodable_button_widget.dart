import 'package:daily_todo/functions.dart';
import 'package:flutter/material.dart';

class LoadableButtonWidget extends StatelessWidget {
  final double height;
  final double width;
  final double indicatorHeight;
  final double indicatorWidth;
  final bool isLoading;
  final String title;
  final ActionFunc? onPressed;

  const LoadableButtonWidget({
    super.key,
    required this.title,
    this.indicatorHeight = 24,
    this.indicatorWidth = 24,
    this.height = 48,
    this.width = double.infinity,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: MaterialButton(
        onPressed: isLoading ? null : onPressed,
        color: Theme.of(context).primaryColor,
        textColor: Theme.of(context).colorScheme.onPrimary,
        child: isLoading
            ? SizedBox(
                height: indicatorHeight,
                width: indicatorWidth,
                child: const CircularProgressIndicator(),
              )
            : Text(title),
      ),
    );
  }
}
