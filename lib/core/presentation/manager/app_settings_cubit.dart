import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class AppSettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;

  const AppSettingsState({
    required this.themeMode,
    required this.locale,
  });

  @override
  List<Object> get props => [themeMode, locale];

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState(
    themeMode: ThemeMode.light,
    locale: Locale('en'),
  ));

  void toggleTheme() {
    emit(state.copyWith(
      themeMode: state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    ));
  }

  void setLocale(String languageCode) {
    emit(state.copyWith(
      locale: Locale(languageCode),
    ));
  }
}
