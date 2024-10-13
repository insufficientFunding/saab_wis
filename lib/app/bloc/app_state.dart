part of 'app_bloc.dart';

enum AppStatus {
  loading,
  loaded,
}

class AppState extends Equatable {
  final WisModelData? model;
  final ThemeData theme;
  final AppStatus status;

  AppState({
    this.model,
    ThemeData? theme,
    this.status = AppStatus.loaded,
  }) : theme = theme ?? ThemeData.from(colorScheme: const ColorScheme.light());

  @override
  List<Object?> get props => [status, model, theme];

  AppState copyWith({
    WisModelData? model,
    ThemeData? theme,
    AppStatus? status,
  }) {
    return AppState(
      model: model ?? this.model,
      theme: theme ?? this.theme,
      status: status ?? this.status,
    );
  }
}
