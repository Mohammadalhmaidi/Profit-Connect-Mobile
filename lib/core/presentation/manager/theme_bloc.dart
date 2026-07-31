import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  const ThemeState({required this.themeMode});

  @override
  List<Object> get props => [themeMode];
}

class ThemeBloc extends Bloc<ThemeMode, ThemeState> {
  final SharedPreferences sharedPreferences;

  ThemeBloc({required this.sharedPreferences})
      : super(ThemeState(
          themeMode: _loadTheme(sharedPreferences),
        )) {
    on<ThemeMode>((event, emit) {
      _saveTheme(event);
      emit(ThemeState(themeMode: event));
    });
  }

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final index = prefs.getInt('theme_mode') ?? 0;
    if (index >= 0 && index < ThemeMode.values.length) {
      return ThemeMode.values[index];
    }
    return ThemeMode.system;
  }

  void _saveTheme(ThemeMode mode) {
    sharedPreferences.setInt('theme_mode', mode.index);
  }

  void toggleTheme() {
    final next = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    add(next);
  }
}
