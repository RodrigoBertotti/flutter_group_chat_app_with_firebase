import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class SeparatorDateForMessagesWidget extends StatelessWidget {
  final DateTime dateTime;

  const SeparatorDateForMessagesWidget({required this.dateTime, Key? key}) : super(key: key);

  String get text {
    DateTime now = DateTime.now();
    final int differenceInDays = DateTime(dateTime.year, dateTime.month, dateTime.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    if(differenceInDays == 0){
      return 'Today';
    }
    if(differenceInDays == -1){
      return 'Yesterday';
    }
    if(differenceInDays > -7){
      return [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][dateTime.weekday-1];
    }
    if(differenceInDays > -365){
      return '${[
        'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
      ][dateTime.month-1]} ${dateTime.day}';
    }
    return DateFormat('yyyy/MM/dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.only(top: 17, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          decoration: BoxDecoration(
            color: Color(0xffebf5fc),
            borderRadius: const BorderRadius.all(Radius.circular(50)),
          ),
          child: Text(text, style: const TextStyle(color: Colors.indigo, fontSize: 14)),
        )
    );
  }
}
