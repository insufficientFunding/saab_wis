import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saab_wis/app/bloc/app_bloc.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => read<AppBloc>().state.theme;
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  ThemeData get watchTheme => watch<AppBloc>().state.theme;
  ColorScheme get watchColorScheme => watch<AppBloc>().state.theme.colorScheme;

  Color colorForBrightness({
    required Color light,
    required Color dark,
  }) {
    return colorScheme.brightness == Brightness.light ? light : dark;
  }

  String getImagePath(String imageId) {
    final model = read<AppBloc>().state.model;
    if (model == null) {
      return '';
    }

    final withoutPrefix = imageId.replaceFirst('wisimg://i', '').toUpperCase();
    final startsWithImg = withoutPrefix.startsWith('IMG');
    final subdirectory = (startsWithImg ? 'img' : withoutPrefix.substring(0, 2)).toUpperCase();
    return 'wis_output/${model.model.toString()}/img/$subdirectory/$withoutPrefix.svg.vec';
  }
}
