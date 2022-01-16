import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

class DateTimeInput extends StatefulWidget {
  final String? initialValue;
  final DateTime? initialDateTime;
  final DateTime firstDateTime;
  final DateTime lastDateTime;
  final DateFormat _formatter;
  final ValueChanged<DateTime> onChanged;

  DateTimeInput({
    Key? key,
    this.initialValue,
    this.initialDateTime,
    required this.firstDateTime,
    required this.lastDateTime,
    required this.onChanged,
    DateFormat? formatter,
  })  : assert(initialValue != null || initialDateTime != null),
        _formatter = formatter ?? _dateFormat,
        super(key: key);

  @override
  createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  late String _text;
  late DateTime _dateTime;

  DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);
  TimeOfDay _time(DateTime d) => TimeOfDay(hour: d.hour, minute: d.minute);

  @override
  initState() {
    super.initState();

    _dateTime = widget.initialDateTime ?? DateTime.now();
    _text = widget.initialValue ?? widget._formatter.format(_dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final dateTime = await _inputDateTime(
          context,
          _dateTime,
          widget.firstDateTime,
          widget.lastDateTime,
        );
        if (dateTime == null || dateTime.isAtSameMomentAs(_dateTime)) {
          return;
        }

        setState(() {
          _dateTime = dateTime;
          _text = widget._formatter.format(_dateTime);
          widget.onChanged(_dateTime);
        });
      },
      child: Text(_text),
    );
  }

  Future<DateTime?> _inputDateTime(
    BuildContext context,
    DateTime initialDateTime,
    DateTime firstDateTime,
    DateTime lastDateTime,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date(initialDateTime),
      firstDate: firstDateTime,
      lastDate: lastDateTime,
    );
    if (date == null) {
      return null;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: _time(initialDateTime),
    );
    if (time == null) {
      return null;
    }

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
