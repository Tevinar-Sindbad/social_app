import 'package:flutter/material.dart';
import 'package:social_app/core/theme/app_pallete.dart';

/// A loader widget.
class Loader extends StatelessWidget {
  /// Creates a [Loader].
  const Loader({super.key, this.size, this.color = AppPallete.textPrimary});

  /// Optional square size constraint applied to the progress indicator.
  final double? size;

  /// Optional color value. Default is ColorPallete.whiteColor
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color,
      constraints: size != null
          ? BoxConstraints(minWidth: size!, minHeight: size!)
          : null,
    );
  }
}
