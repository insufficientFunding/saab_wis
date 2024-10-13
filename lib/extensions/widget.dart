import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  Widget tooltip(String message, {Duration? waitDuration}) {
    return Tooltip(
      message: message,
      waitDuration: waitDuration ?? const Duration(milliseconds: 400),
      verticalOffset: 15,
      child: this,
    );
  }
}
