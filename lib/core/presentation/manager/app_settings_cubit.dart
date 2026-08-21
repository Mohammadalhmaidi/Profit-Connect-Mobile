import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsState extends Equatable {
  final Locale locale;

  const AppSettingsState({required this.locale});

  @override
  List<Object> get props => [locale];

  AppSettingsState copyWith({Locale? locale}) =>
      AppSettingsState(locale: locale ?? this.locale);
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final SharedPreferences sharedPreferences;

  AppSettingsCubit({required this.sharedPreferences})
    : super(AppSettingsState(locale: _loadLocale(sharedPreferences)));

  static Locale _loadLocale(SharedPreferences prefs) {
    final code = prefs.getString('locale_code');
    if (code == 'ar' || code == 'en') {
      return Locale(code!);
    }
    return const Locale('en');
  }

  void setLocale(String languageCode) {
    if (languageCode != 'ar' && languageCode != 'en') return;
    sharedPreferences.setString('locale_code', languageCode);
    emit(state.copyWith(locale: Locale(languageCode)));
  }
}
