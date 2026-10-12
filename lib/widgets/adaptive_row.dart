import 'package:flutter/material.dart';

/// Lays its children out by side when there's room, and stacks them
/// when there isn't.
/// 
/// "Room" is measured, not guessed: the width actually available, against
/// how wide each child needs to be at the user's chosen text size. Large
/// text, a narrow phone and an enlarged display all produce the same
/// shortage, so one check covers all three.
/// 
/// How much the user's text-size setting enlarges body-size text.
/// 
/// Android scales font non-linearly - small text grows far more than large
/// text - so the factor is read off a typical body size rather than applied
/// to whatever number happens to be at hand.
double bodyTextScale(BuildContext context) => MediaQuery.textScalerOf(context).scale(14) / 14;
class AdaptiveRow extends StatelessWidget {
  const AdaptiveRow({
    super.key,
    required this.children,
    this.minChildWidth = 96,
    this.spacing = 10,
  });

  final List<Widget> children;

  /// How wide one child needs to be at normal text size.
  final double minChildWidth;

  final double spacing;

  @override
  Widget build(BuildContext context) {
    // How much the user's settings enlarges *body-size* text. Android scales
    // non-linearly - small text grows far more than large text - so we read
    // the factor off a typical font size, then apply it to the width.
    final needed = minChildWidth * bodyTextScale(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final gaps = spacing * (children.length - 1);
        final perChild = (constraints.maxWidth - gaps) / children.length;

        if (perChild >= needed) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) SizedBox(width: spacing),
                  Expanded(child: children[i]),
                ],
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              children[i],
            ],
          ],
        );
      },
    );
  }
}