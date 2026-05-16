import 'package:intl/intl.dart';

final _formatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String formatRupiah(num amount) => _formatter.format(amount);
