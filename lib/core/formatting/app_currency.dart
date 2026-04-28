import 'package:intl/intl.dart';

/// ISO 4217 formatting backed by [Intl]; pair codes with a sensible locale for symbols.
class AppCurrencyFormat {
  AppCurrencyFormat(this.currencyCode);

  /// Uppercase ISO code (e.g. INR, USD).
  final String currencyCode;

  static String localeForCurrency(String code) {
    switch (code.toUpperCase()) {
      case 'INR':
        return 'en_IN';
      case 'USD':
        return 'en_US';
      case 'EUR':
        return 'de_DE';
      case 'GBP':
        return 'en_GB';
      case 'AED':
        return 'ar_AE';
      case 'SGD':
        return 'en_SG';
      case 'JPY':
        return 'ja_JP';
      case 'AUD':
        return 'en_AU';
      case 'CAD':
        return 'en_CA';
      case 'CHF':
        return 'de_CH';
      case 'SAR':
        return 'ar_SA';
      case 'MYR':
        return 'ms_MY';
      default:
        return 'en_US';
    }
  }

  /// Typical decimal places for ISO codes (JPY/KRW often 0).
  static int decimalDigitsFor(String code) {
    switch (code.toUpperCase()) {
      case 'JPY':
      case 'KRW':
      case 'VND':
        return 0;
      default:
        return 2;
    }
  }

  NumberFormat formatter({int? decimalDigits}) {
    final code = currencyCode.toUpperCase();
    final digits = decimalDigits ?? decimalDigitsFor(code);
    return NumberFormat.currency(
      locale: localeForCurrency(code),
      name: code,
      decimalDigits: digits,
    );
  }

  String format(double amount, {int? decimalDigits}) =>
      formatter(decimalDigits: decimalDigits).format(amount);

  /// Prefix for amount fields, e.g. `"₹ "` or `"$ "`.
  String get prefix => '${formatter().currencySymbol} ';
}
