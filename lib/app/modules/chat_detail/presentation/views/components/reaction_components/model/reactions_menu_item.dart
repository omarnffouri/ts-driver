import 'package:flutter/widgets.dart';

class ReactionsMenuItem {
  final int id;
  final String label;
  final IconData icon;
  final bool isDestuctive;
  final Widget? customIcon;

  // contsructor
  const ReactionsMenuItem({
    required this.id,
    required this.label,
    required this.icon,
    this.isDestuctive = false,
    this.customIcon,
  });
}
