import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:welfare_attendance_project/app_state.dart';
import 'package:welfare_attendance_project/teacher/classattendance.dart';
import 'package:welfare_attendance_project/teacher/googlesheet.dart';

class ClassDate extends StatefulWidget {
  ClassDate({Key? key, required this.sheetid, required this.classname})
      : super(key: key);

  final sheetid;
  final classname;

  @override
  State<ClassDate> createState() => _ClassDateState();
}

class _ClassDateState extends State<ClassDate> {

  bool downcheck = false;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    if (downcheck == false) {
      appState.downloadcsv(widget.sheetid);
      downcheck = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('강의 날짜'),
      ),
      body: appState.attendancedata == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Text(widget.classname),
                const SizedBox(
                  height: 10,
                ),
                appState.datelist.length != 0
                    ? Expanded(
                        child: GridView.count(
                          crossAxisCount: 1,
                          padding: const EdgeInsets.all(16.0),
                          childAspectRatio: 5.0 / 2.0,
                          children: appState.datelist
                              .map((element) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ClassAttendance(classname: widget.classname,date: element,sheetid: widget.sheetid,)),
                                    );
                                  },
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        AspectRatio(
                                          aspectRatio: 1 / 1,
                                          child: Lottie.network(
                                            'https://assets2.lottiefiles.com/packages/lf20_h9rxcjpi.json',
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8.0, 12.0, 8.0, 0.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: <Widget>[
                                                    Text(
                                                      element,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge,
                                                      maxLines: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                              .toList()
                              .cast(),
                        ),
                      )
                    : Text('출석 명단이 없습니다 작성해주세요'),
              ],
            ),
    );
  }
}
