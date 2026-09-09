import 'package:equatable/equatable.dart';

enum AppThemeMode { light, dark, system }

/// Préférences UI globales persistées — table `preferences` (au plus 1 ligne, id = 1).
class Preference extends Equatable {
  final AppThemeMode themeMode;
  final String language;
  final String currency;
  final String dateFormat;

  const Preference({
    this.themeMode = AppThemeMode.system,
    this.language = 'fr',
    this.currency = 'FCFA',
    this.dateFormat = 'dd/MM/yyyy',
  });

  Preference copyWith({
    AppThemeMode? themeMode,
    String? language,
    String? currency,
    String? dateFormat,
  }) {
    return Preference(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme_mode': themeMode.name,
      'language': language,
      'currency': currency,
      'date_format': dateFormat,
    };
  }

  factory Preference.fromMap(Map<String, dynamic> map) {
    return Preference(
      themeMode: AppThemeMode.values.firstWhere(
        (m) => m.name == map['theme_mode'],
        orElse: () => AppThemeMode.system,
      ),
      language: (map['language'] ?? 'fr') as String,
      currency: (map['currency'] ?? 'FCFA') as String,
      dateFormat: (map['date_format'] ?? 'dd/MM/yyyy') as String,
    );
  }

  @override
  List<Object> get props => [themeMode, language, currency, dateFormat];
}
