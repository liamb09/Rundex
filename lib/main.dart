import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_log/services_and_helpers/GPXHelper.dart';
import 'package:running_log/services_and_helpers/Run.dart';
import 'package:running_log/services_and_helpers/RunsDatabase.dart';
import 'package:running_log/pages/add_run_page.dart';
import 'package:running_log/pages/profile_page.dart';
import 'package:running_log/pages/stats_page.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';
import 'package:running_log/theme/theme.dart';
import 'package:running_log/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:running_log/firebase_options.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  //RunsDatabase.instance.clearDatabase();
  //UserDatabase.instance.clearDatabase();
  //print(GPXHelper.coordsToPolyline(GPXHelper.gpxToLatLong(await GPXHelper.readFromFile("assets/example_run.gpx"))));
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Running Log',
        theme: Provider.of<ThemeProvider>(context).themeData,
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {

}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

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

  ListTile getRunDisplay (Run run) {
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
              List<Widget> reps = [];
              List<Widget> descriptions = [];
              if (run.reps!.isNotEmpty) {
                result.add(Divider(color: txtColorByBkgd(run.color)));
                for (int i = 0; i < run.reps!.length; i++) {
                  reps.add(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${run.reps![i]}X",
                        style: TextStyle(fontWeight: FontWeight.bold, color: txtColorByBkgd(run.color)),
                        textAlign: TextAlign.right,
                      ),
                    )
                  );
                  descriptions.add(
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        run.descriptions![i],
                        textAlign: TextAlign.left,
                        style: TextStyle(color: txtColorByBkgd(run.color)),
                      ),
                    )
                  );
                }
                result.add(Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: reps,
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: descriptions,
                    ),
                  ],
                ));
              }
              return Column(children: result,);
            },
          ),
        ],
      ),
    );
  }

    @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.timeline),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return StatsPage();
                  },
                ));
              },
            ),
            scrolledUnderElevation: 0,
            title: Text("Running Log", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            iconTheme: IconThemeData(color: Colors.white,),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return ProfilePage();
                    },
                  ));
                },
              )
            ],
          ),
          body: Center(
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
                                        getRunDisplay(run),
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
                                                Icons.delete_forever_outlined, color: txtColorByBkgd(run.color),
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
                            child: getRunDisplay(run),
                          ),
                        ),
                      ),
                    );
                  }).toList()
                );
              }
            ),
          ),
          //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: CircleBorder(),
            child: Icon(Icons.add, color: Colors.white),
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
        );
      }
    );
  }

}