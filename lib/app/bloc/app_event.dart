part of 'app_bloc.dart';

/// Base class for all events regarding basic app state changes.
sealed class AppEvent {
  const AppEvent();

  ///{@macro AppModelSelected}
  factory AppEvent.modelSelected(Model model, Language language, String modelYear) =>
      AppModelSelected(model: model, language: language, modelYear: modelYear);

  ///{@macro AppThemeChanged}
  factory AppEvent.themeChanged(Brightness brightness) => AppThemeChanged(brightness);

  factory AppEvent.waitingForModel() => AppWaitingForModel();
}

///{@template AppModelSelected}
/// Event to notify that a model has been selected
///{@endtemplate}
class AppModelSelected extends AppEvent {
  final Model model;
  final Language language;
  final String modelYear;

  AppModelSelected({
    required this.model,
    required this.language,
    required this.modelYear,
  });
}

class AppWaitingForModel extends AppEvent {}

///{@template AppThemeChanged}
/// Event to notify that the theme has been changed
///{@endtemplate}
class AppThemeChanged extends AppEvent {
  final Brightness brightness;

  AppThemeChanged(this.brightness);
}
