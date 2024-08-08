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
    return Colors.black;
    //return (color != null ? Color(int.parse(color.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black);
  }

  ListTile getRunDisplay (User user, Run run) {
    // TODO: maybe fix run card ui? dont really know what to do
    int secondsSinceRun = (DateTime.now().millisecondsSinceEpoch/1000).round() - run.timestamp;
    String timeMessage = "";
    if (secondsSinceRun < 86400) {
      timeMessage = "Today";
    } else if (secondsSinceRun < 86400*2) {
      timeMessage = "Yesterday";
    } else if (secondsSinceRun < 604800) {
      timeMessage = "${(secondsSinceRun/86400).floor()}d";
    } else if (secondsSinceRun < 86400*365) {
      timeMessage = "${(secondsSinceRun/(86400*7)).floor()}w";
    } else {
      timeMessage = "${(secondsSinceRun/(86400*365)).floor()}y";
    }
    return ListTile(
      // Title, type, and date
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  run.title,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  run.type,
                ),
              ],
            ),
          ),
          Text(
            timeMessage
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            Builder(
              builder: (context) {
                if (run.distance == 0 && run.time == 0) {
                  return Container();
                }
                return Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Builder(
                          builder: (context) {
                            if (run.distance != 0) {
                              return Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      "${run.distance}",
                                      style: TextStyle(fontWeight: FontWeight.w900)
                                    ),
                                    Text(
                                      run.unit == "mi" ? "Miles" : "Kilometers",
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                        Builder(
                          builder: (context) {
                            if (run.time != 0) {
                              return Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      secondsToTime(run.time),
                                      style: TextStyle(fontWeight: FontWeight.w900)
                                    ),
                                    Text(
                                      "Time",
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                        Builder(
                          builder: (context) {
                            if (run.time != 0) {
                              return Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      secondsToTime((run.time/run.distance).round()),
                                      style: TextStyle(fontWeight: FontWeight.w900)
                                    ),
                                    Text(
                                      "Min/${run.unit}",
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                  ],
                );
              }
            ),
            Builder(
              builder: (context) {
                if (run.sets == null) {
                  return Container();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: run.sets!.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${run.sets![index]![2]}"),
                        SizedBox(width: 3,),
                        Icon(Icons.close, size: 15,),
                        SizedBox(width: 3,),
                        Text("${run.sets![index]![0]}"),
                      ],
                    );
                  },
                );
              },
            ),
            Builder(
              builder: (context) {
                if (run.notes == "") {
                  return Container();
                }
                return Column(
                  children: [
                    SizedBox(height: 10,),
                    Text(run.notes),
                  ],
                );
              },
            ),
          ],
        ),
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
      backgroundColor: Colors.white,
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
                : Column(
                  children: [
                    SizedBox(height: 15),
                    Expanded(
                      child: ListView(
                        children: snapshot.data!.map((run) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                color: Theme.of(context).colorScheme.surface, //run.color == null ? null : Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    showDialog(
                                      context: context, 
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: run.color == null ? null : Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
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
                      ),
                    ),
                  ],
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