import 'dart:io';

import 'package:flutter/material.dart';
import 'package:welfare_attendance_project/profilepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_state.dart';
import 'googlesheet.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // void sheet() async {
  late final sheet;
  late List<bool> _selectedIcon;
  final List<Widget> icons = <Widget>[
    const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.circle_outlined,
          size: 16.0,
        ),
        Text('출석'),
      ],
    ),
    const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.clear,
          size: 16.0,
        ),
        Text('결석'),
      ],
    ),
  ];
  int _grid_or_list = 1; //false = grid

  void initialize() {}

  @override
  void initState() {
    super.initState();
    sheet = sheetclass();
    // sheet.find_sheetid();
    // sheet.downloadcsv();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    final ThemeData theme = Theme.of(context);
    // appState.getdata(sheet.data);
    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '강의목록',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.person,
              semanticLabel: 'profile',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ),
        body: Column(
          children: [
            Text(FirebaseAuth.instance.currentUser!.uid),
            ElevatedButton(
                onPressed: () async {
                  // sheet.find_sheetid();
                  // sheet.downloadcsv();

                  // await sheet.initalWorkSheet();
                  // sheet.insertRow();

                  appState.getdata(sheet.data);
                  _selectedIcon = <bool>[false, true];
                },
                child: Text('sheet')),
            Expanded(
              child: appState.exceldata == null
                  ? CircularProgressIndicator()
                  : ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: cardtolist(theme)),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> cardtolist(ThemeData theme) {
    late Card card;
    List<Widget> list = [];
    List<bool> _selectedIcon = [];
    for (var data in sheet.data) {
      if (data[0] != '이름') {
        if (data[2] == 'o')
          _selectedIcon = [true, false];
        else
          _selectedIcon = [false, true];
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
                  ToggleButtons(
                    direction: Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        // The button that is tapped is set to true, and the others to false.
                        for (int i = 0; i < _selectedIcon.length; i++) {
                          // if(data[2] == 'o')
                          //  index = index!;
                          _selectedIcon[i] = i == index;
                        }
                        _grid_or_list = index;
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor: theme.colorScheme.primary,
                    selectedColor: theme.colorScheme.primary,
                    fillColor: Colors.blue[200],
                    color: Colors.grey,
                    isSelected: _selectedIcon,
                    children: icons,
                  ),
                  // Text('${data[2]}')
                ],
              )),
        ));
      }
    }
    return list;
  }
}
