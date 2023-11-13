import 'package:flutter/material.dart';

class KeyboardContainer extends StatelessWidget {
  final double spacing;
  final List<Widget> children;

  const KeyboardContainer({
    super.key,
    this.spacing = 16,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> result = [];
    for (final item in children) {
      result.add(SizedBox(height: spacing));
      result.add(item);
    }

    result.add(SizedBox(height: spacing));

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result,
            ),
          ),
        ),
      ],
    );
  }
}
