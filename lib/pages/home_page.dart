import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_log/pages/add_run_page.dart';
import 'package:running_log/services_and_helpers/GPXHelper.dart';
import 'package:running_log/services_and_helpers/Run.dart';
import 'package:running_log/services_and_helpers/RunsDatabase.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';
import 'package:running_log/services_and_helpers/input_boxes.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:running_log/services_and_helpers/env.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:running_log/theme/theme.dart';
import 'package:running_log/theme/theme_provider.dart';
import 'package:tinycolor2/tinycolor2.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
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

  Color txtColorByBkgd (String? color) {
    return (color != null ? Color(int.parse(color.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black);
  }

  ListTile getRunDisplay (User user, Run run) {
    return ListTile(
      title: Center(
        child: Text(
          run.title, 
          style: TextStyle(color: txtColorByBkgd(run.color)),
        ),
      ),
      subtitle: Column(
        children: [
          Builder(
            builder: (context) {
              if (run.type != "N/A") {
                return Column(
                  children: [
                    SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: txtColorByBkgd(run.color)),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Text(run.type, style: TextStyle(color: txtColorByBkgd(run.color)),),
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            },
          ),
          Column(
            children: [
              Divider(color: txtColorByBkgd(run.color)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${DateFormat('EEEE, MMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(run.timestamp*1000))}${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(run.timestamp*1000)) == "12:00 AM" ? "" : " at ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(run.timestamp*1000))}"}", 
                    style: TextStyle(color: txtColorByBkgd(run.color)))
                ],
              ),
            ],
          ),
          Builder(
            builder: (context) {
              if (run.perceivedEffort != null) {
                return Column(
                  children: [
                    Divider(color: txtColorByBkgd(run.color)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Perceived Effort: ", style: TextStyle(fontWeight: FontWeight.bold, color: txtColorByBkgd(run.color)),),
                        Text("${run.perceivedEffort} / 10", style: TextStyle(color: txtColorByBkgd(run.color)),),
                      ],
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
          Builder(
            builder: (context) {
              if (run.time > 0 && run.distance > 0) {
                return Column(
                  children: [
                    Divider(color: txtColorByBkgd(run.color)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text("${run.distance} ${run.unit}", style: TextStyle(color: txtColorByBkgd(run.color)),),
                              Text("Distance", style: TextStyle(color: txtColorByBkgd(run.color)),),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            children: [
                              Text(secondsToTime((run.time/run.distance).round()), style: TextStyle(color: txtColorByBkgd(run.color)),),
                              Text("Average Pace", style: TextStyle(color: txtColorByBkgd(run.color)),),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            children: [
                              Text(secondsToTime(run.time), style: TextStyle(color: txtColorByBkgd(run.color)),),
                              Text("Time", style: TextStyle(color: txtColorByBkgd(run.color)),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else if (run.time > 0 && run.distance == 0) {
                return Column(
                  children: [
                    Divider(color: txtColorByBkgd(run.color)),
                    Column(
                      children: [
                        Text(secondsToTime(run.time), style: TextStyle(color: txtColorByBkgd(run.color)),),
                        Text("Time", style: TextStyle(color: txtColorByBkgd(run.color)),),
                      ],
                    ),
                  ],
                );
              } else if (run.time == 0 && run.distance > 0) {
                return Column(
                  children: [
                    Divider(color: txtColorByBkgd(run.color)),
                    Column(
                      children: [
                        Text("${run.distance} ${run.unit}", style: TextStyle(color: txtColorByBkgd(run.color)),),
                        Text("Distance", style: TextStyle(color: txtColorByBkgd(run.color)),),
                      ],
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            }
          ),
          Builder(
            builder: (context) {
              if (run.notes != "") {
                return Column(
                  children: [
                    Divider(color: txtColorByBkgd(run.color)),
                    Text(
                      run.notes,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: txtColorByBkgd(run.color)),
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            }
          ),
          Builder(
            builder: (context) {
              List<Widget> result = [];
              if (run.sets == null) {
                return Container();
              }
              if (run.sets!.isNotEmpty) {
                List<String> descriptions = [];
                List<int> reps = [];
                List<dynamic> paces = [];
                for (var entry in run.sets!.values) {
                  descriptions.add(entry[0]);
                  reps.add(entry[2]);
                  paces.add(entry[3]);
                }
                result.add(Divider(color: txtColorByBkgd(run.color)));
                List<Widget> workoutParts = [];
                for (int i = 0; i < run.sets!.length; i++) {
                  if (run.sets!.values.toList()[i][2] == 1) {
                    workoutParts.add(Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            descriptions[i],
                            textAlign: TextAlign.left,
                            style: TextStyle(color: txtColorByBkgd(run.color)),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            if (paces[i] != null && paces[i] != 0) {
                              return Row(
                                children: [
                                  SizedBox(width: 10),
                                  Text(
                                    "@",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: txtColorByBkgd(run.color)),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    paces[i] is String ? "${paces[i]} pace" : "${secondsToTime(paces[i]!)}/${user.distUnit}",
                                    style: TextStyle(color: txtColorByBkgd(run.color)),
                                  ),
                                ],
                              );
                            }
                            return Container();
                          },
                        ),
                      ],
                    ));
                  } else {
                    workoutParts.add(Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${run.sets!.values.toList()[i][2]}X",
                            style: TextStyle(fontWeight: FontWeight.bold, color: txtColorByBkgd(run.color)),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        SizedBox(width: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            descriptions[i],
                            textAlign: TextAlign.left,
                            style: TextStyle(color: txtColorByBkgd(run.color)),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            if (paces[i] != null && paces[i] != 0) {
                              return Row(
                                children: [
                                  SizedBox(width: 10),
                                  Text(
                                    "@",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: txtColorByBkgd(run.color)),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    paces[i] is String ? "${paces[i]} pace" : "${secondsToTime(paces[i]!)}/${user.distUnit}",
                                    style: TextStyle(color: txtColorByBkgd(run.color)),
                                  ),
                                ],
                              );
                            }
                            return Container();
                          },
                        ),
                      ],
                    ));
                  }
                }
                result.add(Column(children: workoutParts,));
              }
              return Column(mainAxisAlignment: MainAxisAlignment.center, children: result,);
            },
          ),
          Builder(
            builder: (context) {
              if (run.image != null) {
                return Column(
                  children: [
                    Divider(color: txtColorByBkgd(run.color)),
                    Image.memory(run.image!),
                  ],
                );
              }
              return Container();
            },
          )
        ],
      ),
    );
  }

  Future<User> getUserFromDB () async {
    var user = await UserDatabase.instance.getUser();
    //UserDatabase.instance.clearDatabase();
    if (user.isEmpty) {
      UserDatabase.instance.addDefaultUser();
      user = await UserDatabase.instance.getUser();
    }
    return user[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<User>(
        future: getUserFromDB(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          var user = snapshot.data;
          if (user == null) {
            return CircularProgressIndicator();
          }
          return Center(
            child: FutureBuilder<List<Run>>(
              future: RunsDatabase.instance.getRuns(),
              builder: (BuildContext context, AsyncSnapshot<List<Run>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: Text("Loading..."));
                }
                return snapshot.data!.isEmpty
                ? Center(child: Text("You have no runs."))
                : ListView(
                  children: snapshot.data!.map((run) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: run.color == null ? null : Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              showDialog(
                                context: context, 
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: run.color == null ? null : Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        getRunDisplay(user, run),
                                      ],
                                    ),
                                    actionsAlignment: MainAxisAlignment.center,
                                    actions: [
                                      MaterialButton(
                                        color: run.color == null ? Theme.of(context).cardColor.darken(20) : (txtColorByBkgd(run.color) == Colors.black ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).lighten(10) : Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).darken(10)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.delete_outline, color: txtColorByBkgd(run.color),
                                              ),
                                              SizedBox(width: 5,),
                                              Text(
                                                "Delete",
                                                style: TextStyle(
                                                  color: txtColorByBkgd(run.color),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onPressed: () {
                                          showDialog(context: context, builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              content: Text("Delete \"${run.title}?\""),
                                              actionsAlignment: MainAxisAlignment.center,
                                              actions: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    MaterialButton(
                                                      color: Theme.of(context).cardColor.darken(20),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(6),
                                                        child: Text("Delete", style: TextStyle(
                                                          color: Provider.of<ThemeProvider>(context).themeData == lightMode ? Colors.red.darken(20) : Colors.red.lighten(20),
                                                        ),),
                                                      ),
                                                      onPressed: () {
                                                        RunsDatabase.instance.removeRun(run.id!).then((_) => Navigator.pop(context));
                                                      },
                                                    ),
                                                    SizedBox(width: 10,),
                                                    MaterialButton(
                                                      color: Theme.of(context).colorScheme.secondary,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(6),
                                                        child: Text("Cancel", style: TextStyle(color: Provider.of<ThemeProvider>(context).themeData == lightMode ? Colors.white : Colors.black),),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                )
                                              ],
                                            );
                                          }).then((_) => Navigator.pop(context)).then((_) => setState(() {}));
                                        },
                                      ),
                                      MaterialButton(
                                        color: run.color == null ? Theme.of(context).cardColor.darken(20) : (txtColorByBkgd(run.color) == Colors.black ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).lighten(10) : Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).darken(10)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.edit_outlined, color: txtColorByBkgd(run.color),
                                              ),
                                              SizedBox(width: 5,),
                                              Text(
                                                "Edit",
                                                style: TextStyle(
                                                  color: txtColorByBkgd(run.color),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute<void>(
                                            builder: (BuildContext context) => AddRunPage(),
                                            settings: RouteSettings(
                                              arguments: run,
                                            )
                                          )).then((_) => Navigator.pop(context)).then((_) => setState(() {}));
                                        },
                                      ),
                                      MaterialButton(
                                        color: run.color == null ? Theme.of(context).cardColor.darken(20) : (txtColorByBkgd(run.color) == Colors.black ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).lighten(10) : Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).darken(10)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.share_outlined, color: txtColorByBkgd(run.color),
                                              ),
                                              SizedBox(width: 5,),
                                              Text(
                                                "Share",
                                                style: TextStyle(
                                                  color: txtColorByBkgd(run.color),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onPressed: () {},
                                      )
                                    ],
                                  );
                                }
                              );
                            },
                            child: getRunDisplay(user, run),
                          ),
                        ),
                      ),
                    );
                  }).toList()
                );
              }
            ),
          );
        }
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
          icon: Icon(Icons.add, color: Colors.black),
          label: Text("New run", style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          )),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return AddRunPage();
              },
            )).then((_) => setState(() {}));
            // showModalBottomSheet(
            //   context: context,
            //   builder: (context) => SizedBox(height: constraints.maxHeight, child: AddRunPage()),
            // ).then((_) => setState(() {}));
          },
        ),
      ),
    );
  }
}