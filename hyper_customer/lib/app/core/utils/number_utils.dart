import 'package:intl/intl.dart';

abstract class NumberUtils {
  static NumberFormat numberFormat = NumberFormat();

  static String vnd(double? value) {
    if (value == null || value < 0.0) return '-';
    return "${numberFormat.format(value)} VNĐ";
  }
}
