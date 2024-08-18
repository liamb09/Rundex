import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_log/services_and_helpers/Run.dart';
import 'package:running_log/services_and_helpers/RunsDatabase.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';
import 'package:running_log/services_and_helpers/input_boxes.dart';
import 'package:intl/intl.dart';
import 'package:running_log/theme/theme.dart';
import 'package:running_log/theme/theme_provider.dart';

class AddRunPage extends StatefulWidget {
  @override
  State<AddRunPage> createState() => _AddRunPageState();
}

class _AddRunPageState extends State<AddRunPage> {
  final formKey = GlobalKey<FormState>();
  String _title = "";
  double _distance = 0;
  List<Widget> zeroTo100 = [];
  String? _unit;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  List<Widget> zeroTo60 = [];
  String _type = "Road run";
  String _notes = "";
  bool perceivedEffort = false;
  double? perceivedEffortRating;
  bool workoutStructure = false;
  int _numSets = 2;
  List<int?>? _reps;
  List<String>? _descriptions;
  List<MapEntry<String, Map<Uint8List?, double?>>?>? _routes;
  List<Uint8List?>? _images;
  List<dynamic>? _paces;
  List<Widget> oneTo20 = [];
  bool cardColor = false;
  Color? otherCardColor;
  int? editID;
  bool setupForEdit = false;
  int? timestamp;
  bool isDateTime = false;
  bool isTime = false;
  final now = DateTime.now();
  Uint8List? image;
  bool route = false;

  Future<User> getUserFromDB () async {
    var user = await UserDatabase.instance.getUser();
    //UserDatabase.instance.clearDatabase();
    if (user.isEmpty) {
      UserDatabase.instance.addDefaultUser();
      user = await UserDatabase.instance.getUser();
    }
    return user[0];
  }

  Future<DateTime?> getDateTime () async {
    DateTime? selectedDate = await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime.now(), initialDate: timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp!*1000) : now);
    return selectedDate;
  }

  void setMilageAndImage (MapEntry<String, Map<Uint8List?, double?>> chosenRoute) {
    if (route) {
      if (_distance == 0 && chosenRoute.value.values.first != null) {
        _distance = chosenRoute.value.values.first!;
      }
      if (image == null && chosenRoute.value.keys.first != null) {
        image = chosenRoute.value.keys.first!;
      }
      setState(() {});
    }
  }

  String secondsToTime (int s) {
    if (s == 0) return "-:--";
    int hours = s ~/ 3600;
    int minutes = (s - hours * 3600) ~/ 60;
    int seconds = s - (hours * 3600 + minutes * 60);
    String secondsStr = "$seconds";
    if (seconds < 10) {
      secondsStr = "0$seconds";
    }
    if (hours > 0) {
      String minutesStr = "$minutes";
      if (minutes < 10) {
        minutesStr = "0$minutes";
      }
      return "$hours:$minutesStr:$secondsStr";
    } else {
      return "$minutes:$secondsStr";
    }
  }

  @override
  Widget build(BuildContext context) {

    if (zeroTo100.isEmpty) {
      for (int i = 0; i < 100; i++) {
        zeroTo100.add(Center(child: Text("${i < 10 ? "0$i" : i}")));
      }
    }
    if (zeroTo60.isEmpty) {
      for (int i = 0; i < 60; i++) {
        zeroTo60.add(Center(child: Text("${i < 10 ? "0$i" : i}")));
      }
    }
    if (oneTo20.isEmpty) {
      for (int i = 1; i <= 20; i++) {
        oneTo20.add(Center(child: Text("$i")));
      }
    }

    var user = getUserFromDB();

    final editRun = ModalRoute.of(context)!.settings.arguments == null ? null : ModalRoute.of(context)!.settings.arguments as Run;
    if (editRun != null && !setupForEdit) {
      editID = editRun.id;
      _title = editRun.title;
      _distance = editRun.distance;
      _unit = editRun.unit;
      _hours = (editRun.time / 3600).floor();
      _minutes = ((editRun.time % 3600) / 60).floor();
      _seconds = editRun.time % 60;
      _type = editRun.type;
      _notes = editRun.notes;
      perceivedEffort = editRun.perceivedEffort == null ? false : true;
      perceivedEffortRating = editRun.perceivedEffort;
      workoutStructure = editRun.sets == null ? false : (editRun.sets!.isEmpty ? false : true);
      if (workoutStructure) {
        _numSets = editRun.sets!.length;
        _reps = [];
        _descriptions = [];
        _routes = [];
        _images = [];
        _paces = [];
        for (var entry in editRun.sets!.entries) {
          _descriptions!.add(entry.value[0]);
          _reps!.add(entry.value[2]);
          _images!.add(entry.value[1]);
          _paces!.add(entry.value[3]);
          _routes!.add(null);
        }
      }
      cardColor = editRun.color == "ffebedf3" ? false : true;
      otherCardColor = editRun.color == null ? null : Color(int.parse(editRun.color!.substring(2, 8), radix: 16) + 0xFF000000);
      setupForEdit = true;
      isDateTime = true;
      timestamp = editRun.timestamp;
      image = editRun.image;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              }
            ),
            title: Text(
              "New run",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          body: SafeArea(
            child: SingleChildScrollView(
              child: FutureBuilder<User>(
                future: user,
                builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                  var userData = snapshot.data;
                  if (userData == null) {
                    return CircularProgressIndicator();
                  }
                  if (!setupForEdit && _unit == null) {
                    _unit = userData.distUnit;
                  }
                  List<DropdownMenuItem> types = [];
                  for (String type in userData.runColors.keys) {
                    types.add(DropdownMenuItem(value: type, child: Text(type)));
                  }
                  return Column(
                    children: [
                      Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Title
                              InputBox(
                                labelText: "Title",
                                value: _title,
                                setter: (String? value) {
                                  _title = value as String;
                                },
                                validator: (String? value) {
                                  return value == null || value == "" ? "Required" : null;
                                },
                              ),
                              SizedBox(height: 12),
                              // Distance + units
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Distance",
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        InkWell(
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          splashFactory: NoSplash.splashFactory,
                                          onTap: () {
                                            if (_unit == "mi") {
                                              setState(() {
                                                _unit = "km";
                                              });
                                            } else {
                                              setState(() {
                                                _unit = "mi";
                                              });
                                            }
                                          },
                                          child: Text(
                                            _unit == "mi" ? "Miles" : "Kilometers",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                                              color: Theme.of(context).colorScheme.secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    splashFactory: NoSplash.splashFactory,
                                    onTap: () async {
                                      showCupertinoModalPopup(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            color: Provider.of<ThemeProvider>(context, listen: false).themeData == lightMode ? Colors.white : Color(0xff0a0a0a),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("Distance", style: Theme.of(context).textTheme.titleLarge),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        height: 200,
                                                        width: 100,
                                                        child: CupertinoPicker(
                                                          backgroundColor: Provider.of<ThemeProvider>(context, listen: false).themeData == lightMode ? Colors.white : Color(0xff0a0a0a),
                                                          itemExtent: 40,
                                                          onSelectedItemChanged: (index) {
                                                            setState(() {
                                                              _distance = index + (_distance - _distance.floor());
                                                            });
                                                          },
                                                          scrollController: FixedExtentScrollController(
                                                            initialItem: _distance.floor(),
                                                          ),
                                                          children: zeroTo100,
                                                        ),
                                                      ),
                                                      Text(".", style: Theme.of(context).textTheme.headlineLarge),
                                                      SizedBox(
                                                        height: 200,
                                                        width: 100,
                                                        child: CupertinoPicker(
                                                          itemExtent: 40,
                                                          onSelectedItemChanged: (index) {
                                                            setState(() {
                                                              _distance = _distance.floor() + index/100;
                                                            });
                                                          },
                                                          scrollController: FixedExtentScrollController(
                                                            initialItem: (((_distance - _distance.floor())*100).round()).toInt(),
                                                          ),
                                                          children: zeroTo100,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  MaterialButton(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(6.0),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            child: Text(
                                                              "OK",
                                                              style: TextStyle(color: Colors.black),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      );
                                    },
                                    child: Text(
                                      _distance == 0 ? "—" : "${(_distance*100).round()/100}",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ]
                              ),
                              SizedBox(height: 12),
                              // Time
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Time",
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        Text(
                                          "h:m:s",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    splashFactory: NoSplash.splashFactory,
                                    onTap: () async {
                                      showCupertinoModalPopup(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            color: Provider.of<ThemeProvider>(context, listen: false).themeData == lightMode ? Colors.white : Color(0xff0a0a0a),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("Time", style: Theme.of(context).textTheme.titleLarge),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        height: 200,
                                                        width: 100,
                                                        child: CupertinoPicker(
                                                          backgroundColor: Provider.of<ThemeProvider>(context, listen: false).themeData == lightMode ? Colors.white : Color(0xff0a0a0a),
                                                          itemExtent: 40,
                                                          onSelectedItemChanged: (index) {
                                                            setState(() {
                                                              _hours = index;
                                                            });
                                                          },
                                                          scrollController: FixedExtentScrollController(
                                                            initialItem: _hours,
                                                          ),
                                                          children: zeroTo60,
                                                        ),
                                                      ),
                                                      Text(":", style: Theme.of(context).textTheme.headlineLarge),
                                                      SizedBox(
                                                        height: 200,
                                                        width: 100,
                                                        child: CupertinoPicker(
                                                          itemExtent: 40,
                                                          onSelectedItemChanged: (index) {
                                                            setState(() {
                                                              _minutes = index;
                                                            });
                                                          },
                                                          scrollController: FixedExtentScrollController(
                                                            initialItem: _minutes,
                                                          ),
                                                          children: zeroTo60,
                                                        ),
                                                      ),
                                                      Text(":", style: Theme.of(context).textTheme.headlineLarge),
                                                      SizedBox(
                                                        height: 200,
                                                        width: 100,
                                                        child: CupertinoPicker(
                                                          itemExtent: 40,
                                                          onSelectedItemChanged: (index) {
                                                            setState(() {
                                                              _seconds = index;
                                                            });
                                                          },
                                                          scrollController: FixedExtentScrollController(
                                                            initialItem: _seconds,
                                                          ),
                                                          children: zeroTo60,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  MaterialButton(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(6.0),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            child: Text(
                                                              "OK",
                                                              style: TextStyle(color: Colors.black),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      );
                                    },
                                    child: Text(
                                      _hours*60*60 + _minutes*60 + _seconds == 0 ? "—" : secondsToTime(_hours*60*60 + _minutes*60 + _seconds),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ]
                              ),
                              SizedBox(height: 12),
                              // Type
                              Column(
                                children: [
                                  Container(
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Theme.of(context).colorScheme.surface,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(8))
                                      ),
                                    ),
                                    child: RadioListTile(
                                      value: "Road run",
                                      groupValue: _type,
                                      onChanged: (value) {
                                        setState(() {
                                          _type = value!;
                                        });
                                      },
                                      title: Text("Road"),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Container(
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Theme.of(context).colorScheme.surface,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(8))
                                      ),
                                    ),
                                    child: RadioListTile(
                                      
                                      value: "Trail run",
                                      groupValue: _type,
                                      onChanged: (value) {
                                        setState(() {
                                          _type = value!;
                                        });
                                      },
                                      title: Text("Trail"),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Container(
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Theme.of(context).colorScheme.surface,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(8))
                                      ),
                                    ),
                                    child: RadioListTile(
                                      value: "Track run",
                                      groupValue: _type,
                                      onChanged: (value) {
                                        setState(() {
                                          _type = value!;
                                        });
                                      },
                                      title: Text("Track"),
                                    ),
                                  ),
                                  // Possible other option (look into later)
                                  // TextFormField(
                                  //   decoration: InputDecoration(
                                  //     hintText: "Other",
                                  //     fillColor: Colors.white,
                                  //     enabledBorder: OutlineInputBorder(
                                  //       borderSide: BorderSide(
                                  //         color: Theme.of(context).colorScheme.surface,
                                  //         width: 2,
                                  //       ),
                                  //       borderRadius: BorderRadius.all(Radius.circular(8)),
                                  //     ),
                                  //     focusedBorder: OutlineInputBorder(
                                  //       borderSide: BorderSide(
                                  //         color: Theme.of(context).colorScheme.surface,
                                  //         width: 2,
                                  //       ),
                                  //       borderRadius: BorderRadius.all(Radius.circular(8)),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              SizedBox(height: 12),
                              // Notes
                              InputBox(
                                labelText: "Notes",
                                value: _notes,
                                setter: (value) => _notes = value,
                                validator: (value) => null,
                                maxLines: 5,
                              ),
                              SizedBox(height: 12),
                              // Date
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Date",
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    splashFactory: NoSplash.splashFactory,
                                    onTap: () async {
                                      showCupertinoModalPopup(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            color: Provider.of<ThemeProvider>(context, listen: false).themeData == lightMode ? Colors.white : Color(0xff0a0a0a),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("Date", style: Theme.of(context).textTheme.titleLarge),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          height: 200,
                                                          child: CupertinoDatePicker(
                                                            backgroundColor: Provider.of<ThemeProvider>(context, listen: false).themeData == lightMode ? null : Color(0xff0a0a0a),
                                                            initialDateTime: timestamp == null ? now : DateTime.fromMillisecondsSinceEpoch(timestamp!*1000),
                                                            maximumDate: now,
                                                            mode: CupertinoDatePickerMode.date,
                                                            showDayOfWeek: true,
                                                            onDateTimeChanged: (dateTime) {
                                                              setState(() {
                                                                timestamp = (dateTime.millisecondsSinceEpoch/1000).round();
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  MaterialButton(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(6.0),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            child: Text(
                                                              "OK",
                                                              style: TextStyle(color: Colors.black),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      );
                                    },
                                    child: Text(
                                      timestamp == null || timestamp == (DateTime.parse(now.toString()).millisecondsSinceEpoch/1000).round() ?
                                        "Today" :
                                        DateFormat.yMMMEd().format(DateTime.fromMillisecondsSinceEpoch(timestamp!*1000)),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ]
                              ),
                              SizedBox(height: 12,),
                              // Perceived Effort
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Perceived Effort",
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    splashFactory: NoSplash.splashFactory,
                                    onTap: () async {
                                      await showModalBottomSheet(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
                                        ),
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) => Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 64.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Perceived Effort",
                                                    style: Theme.of(context).textTheme.titleLarge
                                                  ),
                                                  Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Slider(
                                                        value: perceivedEffortRating ?? 5,
                                                        min: 0,
                                                        max: 10,
                                                        divisions: 100,
                                                        label: perceivedEffortRating == null ? "5" : "${(perceivedEffortRating!*10).round()/10}",
                                                        inactiveColor: Theme.of(context).colorScheme.secondary,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            perceivedEffortRating = value;
                                                            perceivedEffort = true;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  MaterialButton(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(6.0),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            child: Text(
                                                              "OK",
                                                              style: TextStyle(color: Colors.black),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      perceivedEffortRating ??= 5;
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      perceivedEffortRating == null ? "—" : "${(perceivedEffortRating!*10).round()/10}/10",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ]
                              ),
                              SizedBox(height: 12,),
                              // Card color
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Checkbox(
                              //       checkColor: Colors.white,
                              //       activeColor: Theme.of(context).colorScheme.primary,
                              //       value: cardColor,
                              //       onChanged: (bool? value) {
                              //         setState(() {
                              //           cardColor = value!;
                              //         });
                              //       }
                              //     ),
                              //     Text("Card Color", style: TextStyle(fontSize: 15)),
                              //   ],
                              // ),
                              // Builder(
                              //   builder: (context) {
                              //     if (cardColor) {
                              //       //cardColor = true;
                              //       return ColorPicker(
                              //         enableShadesSelection: false,
                              //         pickersEnabled: <ColorPickerType, bool>{
                              //           ColorPickerType.primary: false,
                              //           ColorPickerType.accent: false,
                              //           ColorPickerType.wheel: true,
                              //         },
                              //         height: 40,
                              //         showColorCode: true,
                              //         colorCodeHasColor: true,
                              //         copyPasteBehavior: ColorPickerCopyPasteBehavior(
                              //           copyFormat: ColorPickerCopyFormat.numHexRRGGBB,
                              //         ),
                              //         color: otherCardColor ?? Color(int.parse(userData.runColors[_type]!, radix: 16) + 0xff000000),
                              //         onColorChanged: (Color color) => setState(() => otherCardColor = color),
                              //       );
                              //     }
                              //     return Container();
                              //   },
                              // ),
                              
                              // Sets
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Sets",
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        splashFactory: NoSplash.splashFactory,
                                        onTap: () async {
                                          setState(() {
                                            workoutStructure = true;
                                            _numSets = 2;
                                            _reps = [1, 1];
                                            _descriptions = ["", ""];
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Builder(
                                              builder: (context) {
                                                return Text(
                                                  workoutStructure ? "$_numSets" : "—",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                                                    color: Theme.of(context).colorScheme.secondary,
                                                  ),
                                                );
                                              }
                                            ),
                                            Builder(
                                              builder: (context) {
                                                if (workoutStructure) {
                                                  return IconButton(
                                                    padding: EdgeInsets.fromLTRB(2, 0, 0, 0),
                                                    constraints: BoxConstraints(),
                                                    iconSize: 20,
                                                    icon: Icon(Icons.delete_outline),
                                                    onPressed: () {
                                                      setState(() {
                                                        _numSets = 2;
                                                        workoutStructure = false;
                                                      });
                                                    },
                                                  );
                                                }
                                                return Container();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                  ),
                                  Builder(
                                    builder: (context) {
                                      if (workoutStructure) {
                                        return Column(
                                          children: [
                                            ListView.builder(
                                              physics: NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: _numSets,
                                              itemBuilder: (context, builderIndex) {
                                                return Column(
                                                  children: [
                                                    SizedBox(height: 6,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        InkWell(
                                                          borderRadius: BorderRadius.circular(8),
                                                          onTap: () {
                                                            showCupertinoModalPopup(
                                                              context: context,
                                                              builder: (context) {
                                                                return Container(
                                                                  color: Provider.of<ThemeProvider>(context, listen: false).themeData == lightMode ? Colors.white : Color(0xff0a0a0a),
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(16.0),
                                                                    child: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        Text("Reps", style: Theme.of(context).textTheme.titleLarge),
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            SizedBox(
                                                                              height: 200,
                                                                              width: 100,
                                                                              child: CupertinoPicker(
                                                                                backgroundColor: Provider.of<ThemeProvider>(context, listen: false).themeData == lightMode ? null : Color(0xff0a0a0a),
                                                                                itemExtent: 40,
                                                                                onSelectedItemChanged: (index) {
                                                                                  setState(() {
                                                                                    _reps![builderIndex] = index+1;
                                                                                  });
                                                                                },
                                                                                scrollController: FixedExtentScrollController(
                                                                                  initialItem: _reps![builderIndex]!-1,
                                                                                ),
                                                                                children: oneTo20,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        MaterialButton(
                                                                          color: Theme.of(context).colorScheme.primary,
                                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.all(6.0),
                                                                            child: Row(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                SizedBox(
                                                                                  child: Text(
                                                                                    "OK",
                                                                                    style: TextStyle(color: Colors.black),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          onPressed: () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            );
                                                          },
                                                          child: SizedBox(
                                                            width: 48,
                                                            height: 48,
                                                            child: Container(
                                                              alignment: Alignment.center,
                                                              decoration: ShapeDecoration(
                                                                shape: RoundedRectangleBorder(
                                                                  side: BorderSide(
                                                                    color: Theme.of(context).colorScheme.surface,
                                                                    width: 2,
                                                                  ),
                                                                  borderRadius: BorderRadius.all(Radius.circular(8))
                                                                ),
                                                              ),
                                                              child: Text(
                                                                "${_reps![builderIndex]}",
                                                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 8,),
                                                        Expanded(
                                                          child: InputBox(
                                                            labelText: "Description",
                                                            value: _descriptions![builderIndex],
                                                            setter: (value) {
                                                              _descriptions![builderIndex] = value;
                                                            },
                                                            validator: (value) => null,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            SizedBox(height: 8,),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: SizedBox(
                                                    height: 40,
                                                    child: TextButton(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Theme.of(context).colorScheme.surface,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        if (_numSets > 1) {
                                                          setState(() {
                                                            _numSets--;
                                                            _reps!.removeLast();
                                                            _descriptions!.removeLast();
                                                          });
                                                        }
                                                      },
                                                      child: Text(
                                                        "-",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w900,
                                                          fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8,),
                                                Expanded(
                                                  child: SizedBox(
                                                    height: 40,
                                                    child: TextButton(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Theme.of(context).colorScheme.surface,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        if (_numSets < 10) {
                                                          setState(() {
                                                            _numSets++;
                                                            _reps!.add(1);
                                                            _descriptions!.add("");
                                                          });
                                                        }
                                                      },
                                                      child: Text(
                                                        "+",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w900,
                                                          fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                ],
                              ),
                              Builder(
                                builder: (context) {
                                  if (route) {
                                    List<DropdownMenuItem<Object>>? userRoutes = [];
                                    for (String route in userData.routes!.keys) {
                                      userRoutes.add(DropdownMenuItem(value: route, child: Text(route)));
                                    }
                                    return Column(
                                      children: [
                                        DropdownButtonFormField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Route",
                                          ),
                                          items: userRoutes,
                                          onChanged: (value) {
                                            MapEntry<String, Map<Uint8List?, double?>> chosenRoute = userData.routes!.entries.elementAt(userData.routes!.keys.toList().indexOf(value as String));
                                            setMilageAndImage(chosenRoute);
                                          },
                                          validator: (value) {
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 6),
                                      ],
                                    );
                                  }
                                  return Container();
                                },
                              ),
                              // Upload GPS
                              // ElevatedButton(
                              //   style: ElevatedButton.styleFrom(
                              //     textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              //   ),
                              //   onPressed: () async {
                              //     final result = await FilePicker.platform.pickFiles(withData: true);
                              //     if (result != null) {
                              //       var file = utf8.decode(result.files.single.bytes as List<int>);
                              //       var polyline = await GPXHelper.getPolyline(file);
                              //       final response = await http.get(Uri.parse("https://maps.googleapis.com/maps/api/staticmap?size=400x400&style=feature:poi|visibility:off&style=feature:transit|visibility:off&style=feature:administrative|visibility:off&path=color:0x012271ff%7Cenc:$polyline&key=${Env.msApiKey}"));
                              //       if (response.statusCode == 200) {
                              //         print("Successfully fetched map");
                              //         image = await FlutterImageCompress.compressWithList(
                              //           response.bodyBytes,
                              //           minHeight: 400,
                              //           minWidth: 400,
                              //           quality: 40
                              //         );
                              //         setState(() {});
                              //       } else {
                              //         print("Failed to fetch map");
                              //       }
                              //     }
                              //   },
                              //   child: Text("Upload GPS Data"),
                              // ),
                              // Builder(
                              //   builder: (context) {
                              //     if (image != null) {
                              //       return Column(
                              //         children: [
                              //           SizedBox(height: 12,),
                              //           Image.memory(image!),
                              //         ],
                              //       );
                              //     }
                              //     return Container();
                              //   }
                              // )
                              SizedBox(height: 60,),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: SizedBox(
            width: 150,
            height: 40,
            child: FloatingActionButton.extended(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              label: Text(
                "Save",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                ),
              ),
              onPressed: () async {
                // _reps = [];
                // _descriptions = [];
                // _routes = [];
                // _images = [];
                // _paces = [];
                // for (var i = _descriptions!.length; i < _numSets; i++) {
                //   _descriptions!.add("");
                //   _reps!.add(null);
                //   _images!.add(null);
                //   _routes!.add(null);
                //   _paces!.add(null);
                // }
                if (formKey.currentState?.validate() == true) {
                  formKey.currentState?.save();
                  // Add run to database
                  int timeInSeconds = (_hours*60 + _minutes)*60 + _seconds;
                  Map<int, List<dynamic>> sets = {};
                  if (_descriptions != null) {
                    for (int i = 0; i < _descriptions!.length; i++) {
                      List<dynamic> details = [_descriptions![i], null, _reps![i], null];
                      sets.addAll({i : details});
                    }
                  }
                  var run = Run(
                    id: editID,
                    title: _title,
                    distance: (_distance*100).round()/100,
                    unit: _unit!,
                    time: timeInSeconds,
                    perceivedEffort: perceivedEffortRating == null ? null : (perceivedEffortRating!*100).round()/100,
                    type: _type,
                    notes: _notes,
                    sets: workoutStructure ? sets : {},
                    color: cardColor ? (otherCardColor ?? Theme.of(context).colorScheme.secondary).value.toRadixString(16) : "ffebedf3",
                    timestamp: timestamp ?? (now.millisecondsSinceEpoch/1000).round(),
                    image: image,
                  );
                  if (editID == null) {
                    await RunsDatabase.instance.addRun(run);
                  } else {
                    await RunsDatabase.instance.updateRun(run);
                  }
                  // return to homepage
                  Navigator.pop(context);
                }
              },
            ),
          ),
        );
      }
    );
  }
}