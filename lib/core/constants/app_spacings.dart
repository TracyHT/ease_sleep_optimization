import 'package:flutter/material.dart';

class AppSpacing {
  static const double xSmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xLarge = 32.0;

  static const double buttonPadding = 12.0;
  static const double cardPadding = 16.0;
  static const double screenPadding = 16.0;

  static const double listItemSpacing = 8.0;

  static const EdgeInsets smallPadding = EdgeInsets.all(small);
  static const EdgeInsets mediumPadding = EdgeInsets.all(medium);
  static const EdgeInsets largePadding = EdgeInsets.all(large);

  static const EdgeInsets screenEdgePadding = EdgeInsets.symmetric(
    horizontal: screenPadding,
    vertical: small,
  );

  static const EdgeInsets verticalSmall = EdgeInsets.symmetric(vertical: small);
  static const EdgeInsets verticalMedium = EdgeInsets.symmetric(
    vertical: medium,
  );
  static const EdgeInsets horizontalSmall = EdgeInsets.symmetric(
    horizontal: small,
  );
  static const EdgeInsets horizontalMedium = EdgeInsets.symmetric(
    horizontal: medium,
  );
}
