import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_log/pages/add_run_page.dart';
import 'package:running_log/services_and_helpers/Run.dart';
import 'package:running_log/services_and_helpers/RunsDatabase.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';
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

  ListTile getRunDisplay (User user, Run run, bool inDialog) {
    int secondsSinceRun = (DateTime.now().millisecondsSinceEpoch/1000).round() - run.timestamp;
    String dateMessage = "";
    if (secondsSinceRun < 86400) {
      dateMessage = "Today";
    } else if (secondsSinceRun < 86400*2) {
      dateMessage = "Yesterday";
    } else if (secondsSinceRun < 604800) {
      dateMessage = "${(secondsSinceRun/86400).floor()}d";
    } else if (secondsSinceRun < 86400*365) {
      dateMessage = "${(secondsSinceRun/(86400*7)).floor()}w";
    } else {
      dateMessage = "${(secondsSinceRun/(86400*365)).floor()}y";
    }
    return ListTile(
      // Title, type, and date
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  run.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  run.type,
                ),
              ],
            ),
          ),
          Text(
            dateMessage,
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                if (run.distance == 0 && run.time == 0) {
                  return Container();
                }
                return Column(
                  children: [
                    Builder(
                      builder: (context) {
                        if (run.distance == 0 && run.timestamp == 0) {
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
                                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                  ],
                );
              }
            ),
            Builder(
              builder: (context) {
                if (run.sets!.isEmpty) {
                  return Container();
                }
                return Column(
                  children: [
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: run.sets!.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("${run.sets![index]![2]}"),
                                SizedBox(width: 3,),
                                Icon(Icons.close, size: 15,),
                                SizedBox(width: 3,),
                                Expanded(child: Text("${run.sets![index]![0]}", softWrap: true, style: TextStyle(height: 1.2))),
                              ],
                            ),
                            Builder(
                              builder: (context) {
                                if (!inDialog) {
                                  return SizedBox(height: 2);
                                }
                                return SizedBox(height: 6);
                              }
                            ),
                          ],
                        );
                      },
                    ),
                  ],
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
                    SizedBox(height: 6),
                    Text(run.notes, textAlign: TextAlign.left,),
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
                    Expanded(
                      child: ListView(
                        children: snapshot.data!.map((run) {
                          return Column(
                            children: [
                              Builder(
                                builder: (context) {
                                  if (snapshot.data![0] == run) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            SizedBox(width: 20,),
                                            Text("Your runs", textAlign: TextAlign.left, style: TextStyle(
                                              fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                                              fontWeight: FontWeight.w900,
                                            ),),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    );
                                  }
                                  return Container();
                                },
                              ),
                              Center(
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
                                              content: SizedBox(
                                                width: double.maxFinite,
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    getRunDisplay(user, run, true),
                                                  ],
                                                )
                                              ),
                                              actionsAlignment: MainAxisAlignment.center,
                                              actions: [
                                                MaterialButton(
                                                  color: run.color == null ? Theme.of(context).cardColor.darken(20) : (txtColorByBkgd(run.color) == Colors.black ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).lighten(10) : Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).darken(10)),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        // backgroundColor: Theme.of(context).colorScheme.surface,
                                                        content: Text("Delete \"${run.title}?\""),
                                                        actionsAlignment: MainAxisAlignment.center,
                                                        actions: [
                                                          Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              MaterialButton(
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(6),
                                                                  child: Text("Delete"),
                                                                ),
                                                                onPressed: () {
                                                                  RunsDatabase.instance.removeRun(run.id!).then((_) => Navigator.pop(context));
                                                                },
                                                              ),
                                                              SizedBox(width: 10,),
                                                              MaterialButton(
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                color: Theme.of(context).colorScheme.primary,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(6),
                                                                  child: Text("Cancel"),
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
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                                      child: getRunDisplay(user, run, false),
                                    ),
                                  ),
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  if (snapshot.data![snapshot.data!.length-1] == run) {
                                    return SizedBox(height: 60);
                                  }
                                  return Container();
                                },
                              ),
                            ],
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