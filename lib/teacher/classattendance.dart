import 'package:flutter/material.dart';
import 'package:welfare_attendance_project/app_state.dart';
import 'package:provider/provider.dart';
import 'package:welfare_attendance_project/teacher/classattendanceedit.dart';
import 'package:welfare_attendance_project/teacher/googlesheet.dart';

class ClassAttendance extends StatefulWidget {
  ClassAttendance(
      {Key? key,
      required this.classname,
      required this.date,
      required this.sheetid})
      : super(key: key);
  final classname;
  final date;
  final sheetid;

  @override
  State<ClassAttendance> createState() => _ClassAttendanceState();
}

class _ClassAttendanceState extends State<ClassAttendance> {
  late var appState;

  @override
  Widget build(BuildContext context) {
    appState = context.watch<ApplicationState>();
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('출석체크'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.create,
              semanticLabel: 'edit',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassAttendacnceEdit(
                    classname: widget.classname,
                    date: widget.date,
                    spreadsheetId: widget.sheetid,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(widget.classname),
            SizedBox(
              width: 10,
            ),
            Text(widget.date)
          ]),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: _cardtolist(theme)),
          ),
        ],
      ),
    );
  }

  List<Widget> _cardtolist(ThemeData theme) {
    List<Widget> list = [];
    int outindex = 2;
    for (var data in appState.attendancedata) {
      if (data[0] == '이름') {
        int index = 0;
        for (var exceldate in data) {
          if (exceldate == widget.date) {
            outindex = index;
          }
          index++;
        }
      } else {
        list.add(Card(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data[0]}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text('${data[1]}'),
                    ],
                  ),
                  // SizedBox(width: 20,),
                  data[outindex] == 'o'
                      ? Icon(Icons.check_circle)
                      : Icon(Icons.close_rounded)

                  // Text('${data[2]}')
                ],
              )),
        ));
      }
    }
    return list;
  }
}
