import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saab_wis/theme/theme.dart';
import 'package:wis_base/wis_base.dart';
import 'package:wis_navigation/wis_navigation.dart';

part 'app_state.dart';
part 'app_event.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState()) {
    on<AppModelSelected>(_onModelSelected);
    on<AppThemeChanged>(_onThemeChanged);

    add(AppThemeChanged(Brightness.light));
  }

  FutureOr<void> _onThemeChanged(AppThemeChanged event, Emitter<AppState> emit) {
    final theme = AppTheme.buildTheme(brightness: event.brightness);

    emit(state.copyWith(theme: theme));
  }

  FutureOr<void> _onModelSelected(AppModelSelected event, Emitter<AppState> emit) async {
    final parser = WisXmlParser();
    final path = 'wis_output/${event.model.toString()}/${event.language.name}/${event.modelYear}.xml';

    emit(
      state.copyWith(status: AppStatus.loading),
    );

    await Future.delayed(const Duration(seconds: 1));

    final modelData = await parser.parse(path);

    emit(
      state.copyWith(model: modelData, status: AppStatus.loaded),
    );
  }

  Future<List<String>> getModelYears({
    required Model model,
  }) async {
    final path = 'wis_output/${model.toString()}/English/';
    final directory = Directory(path);
    final files = await directory.list().toList();

    // Look for files in the format $PATH$/YYYY.xml
    final years = <String>{};
    files
        .where((file) => file is File && file.path.endsWith('.xml'))
        .map((file) => file.path.split('/').last.split('.').first.substring(0, 4))
        .forEach(years.add);

    // Sort the years in descending order
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));

    return sortedYears;
  }
}
