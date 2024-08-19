import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:running_log/services_and_helpers/Run.dart';
import 'package:running_log/services_and_helpers/RunsDatabase.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';
import 'package:running_log/theme/theme.dart';
import 'package:running_log/theme/theme_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;

class StatsPage extends StatefulWidget {
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {

  String distanceChartStep = "daily";

  Future<User> getUserFromDB () async {
    var user = await UserDatabase.instance.getUser();
    //UserDatabase.instance.clearDatabase();
    if (user.isEmpty) {
      UserDatabase.instance.addDefaultUser();
      user = await UserDatabase.instance.getUser();
    }
    return user[0];
  }  

  Future<List<Run>> getRuns () async {
    return await RunsDatabase.instance.getRuns();
  }

  double toUserUnits (double dist, String distUnit, String userUnit) {
    double newDist = dist;
    if (distUnit != userUnit) {
      if (distUnit == "km") {
        newDist = dist / 1.609;
      } else {
        newDist = dist * 1.609;
      }
    }
    newDist = (newDist*100).round()/100;
    return newDist;
  }

  List<double> getWeekMileage (List<Run> runs, User user) {
    // Get last sunday in unix timestamp
    var currentTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    // Unix timestamp started on thursday get start of last week and subtract 345600 to get to sunday
    var weekStartTimeStamp = currentTimestamp - (currentTimestamp % 604800) - 345600;
    List<double> weeklyMileage = [0];
    for (Run run in runs) {
      while (run.timestamp < weekStartTimeStamp) {
        weekStartTimeStamp -= 604800;
        weeklyMileage.add(0);
      }
      weeklyMileage[weeklyMileage.length-1] += toUserUnits(run.distance, run.unit, user.distUnit);
    }
    return weeklyMileage;
  }

  double getThisWeekMileage (List<Run> runs) {
    int currentTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    int weekStartTimestamp = (currentTimestamp - (currentTimestamp % 604800)) + 259200; // get to last sunday
    double ret = 0;
    for (int i = 0; i < runs.length; i++) {
      if (runs[i].timestamp >= weekStartTimestamp) {
        ret += runs[i].distance;
      } else {
        break;
      }
    }
    return ret;
  }

  List<MapEntry<String, double>> getLastWeekMileage (List<Run> runs, User user) {
    var currentTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    var dayIndex = ((((currentTimestamp % 604800)/86400).floor()-3)+7)%7;
    List<String> days = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
    List<MapEntry<String, double>> ret = [];
    for (int i = 6; i >= 0; i--) {
      ret.insert(0, MapEntry(days[((i-6)+dayIndex+7)%7], 0));
    }
    for (int i = runs.length-1; i >= 0; i--) {
      int index = 6-((currentTimestamp - (runs[i].timestamp - runs[i].timestamp%86400))/86400).floor();
      if (index >= 0) {
        ret[index] = MapEntry(ret[index].key, ret[index].value + toUserUnits(runs[i].distance, runs[i].unit, user.distUnit));
      }
    }
    return ret;
  }

  List<MapEntry<String, double>> getLastFewWeeksMileage (List<Run> runs, User user) {
    var currentTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    List<MapEntry<String, double>> ret = [];
    for (int i = 0; i < 7; i++) {
      ret.add(MapEntry(DateFormat.Md().format(DateTime.fromMillisecondsSinceEpoch(((currentTimestamp - currentTimestamp%604800) - (6-i)*604800 + 86400*4)*1000)), 0));
    }
    for (int i = runs.length-1; i >= 0; i--) {
      int weeksSinceThisRun = ((currentTimestamp - (runs[i].timestamp - runs[i].timestamp%86400))/604800).floor();
      int retIndex = ret.length-1-weeksSinceThisRun;
      if (retIndex >= 0) {
        ret[retIndex] = MapEntry(ret[retIndex].key, ((ret[retIndex].value + toUserUnits(runs[i].distance, runs[i].unit, user.distUnit))*100).round()/100);
      }
    }
    return ret;
  }

  List<MapEntry<String, double>> getLastFewWeeksGoal (User user) {
    var currentTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    List<MapEntry<String, double>> ret = [];
    for (int i = 0; i < 7; i++) {
      ret.add(MapEntry(DateFormat.Md().format(DateTime.fromMillisecondsSinceEpoch(((currentTimestamp - currentTimestamp%604800) - (6-i)*604800 + 86400*4)*1000)), (user.goal).toDouble() ));
    }
    return ret;
  }

  List<DayData> getDailyChartData (List<MapEntry<String, double>> distances) {
    List<DayData> ret = [];
    for (int i = 0; i < distances.length; i++) {
      ret.add(DayData(distances[i].key, distances[i].value));
    }
    return ret;
  }

  List<WeekData> getWeeklyGraphData (List<MapEntry<String, double>> distances) {
    List<WeekData> ret = [];
    for (int i = 0; i < distances.length; i++) {
      ret.add(WeekData(distances[i].key, distances[i].value));
    }
    return ret;
  }

  @override
  Widget build (BuildContext context) {

    Future<User> user = getUserFromDB();
    Future<List<Run>> futureRuns = getRuns();

    return FutureBuilder<List<Run>>(
      future: futureRuns,
      builder: (BuildContext context, AsyncSnapshot<List<Run>> runSnapshot) {
        var runs = runSnapshot.data;
        return FutureBuilder<User>(
          future: user,
          builder: (BuildContext context, AsyncSnapshot<User> userSnapshot) {
            var userData = userSnapshot.data;
            double thisWeekMileage = 0;
            List<DayData> lastWeek = [];
            List<WeekData> lastFewWeeks = [];
            List<WeekData> userGoalWeeks = [];
            if (userData == null) {
              return CircularProgressIndicator();
            } else {
              if (runs != null) {
                thisWeekMileage = getThisWeekMileage(runs);
                lastWeek = getDailyChartData(getLastWeekMileage(runs, userData));
                lastFewWeeks = getWeeklyGraphData(getLastFewWeeksMileage(runs, userData));
              }
              userGoalWeeks = getWeeklyGraphData(getLastFewWeeksGoal(userData));
            }
            return Scaffold(
              appBar: AppBar(
                surfaceTintColor: Theme.of(context).colorScheme.tertiary == Colors.white ? null : Colors.transparent,
                title: Text(
                  "Mileage stats",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        gauges.SfRadialGauge(
                          axes: <gauges.RadialAxis>[
                            gauges.RadialAxis(
                              showLabels: false,
                              showTicks: false,
                              radiusFactor: 0.8,
                              axisLineStyle: gauges.AxisLineStyle(
                                thickness: 0.2,
                                cornerStyle: gauges.CornerStyle.bothCurve,
                                color: Provider.of<ThemeProvider>(context).themeData == darkMode ? Color(0xff171717) : Color(0xffE8E8E8),
                                thicknessUnit: gauges.GaugeSizeUnit.factor,
                              ),
                              pointers: <gauges.GaugePointer>[
                                gauges.RangePointer(
                                  value: (thisWeekMileage/userData.goal)*100,
                                  width: 0.2,
                                  cornerStyle: gauges.CornerStyle.bothCurve,
                                  color: Theme.of(context).colorScheme.primary,
                                  sizeUnit: gauges.GaugeSizeUnit.factor,
                                  enableAnimation: true,
                                  animationDuration: 200,
                                  animationType: gauges.AnimationType.linear
                                )
                              ],
                              annotations: <gauges.GaugeAnnotation>[
                                gauges.GaugeAnnotation(
                                  positionFactor: 0.1,
                                  angle: 90,
                                  widget: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${thisWeekMileage.toStringAsFixed(2)} / ${userData.goal}",
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                      Text(
                                        "${userData.distUnit == "mi" ? "Miles" : "Kilometers"} this week",
                                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        CupertinoSlidingSegmentedControl<String>(
                          groupValue: distanceChartStep,
                          children: <String, Widget>{
                            "daily": Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Daily Mileage"),
                            ),
                            "weekly": Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Weekly Mileage"),
                            ),
                          },
                          onValueChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                distanceChartStep = value;
                              });
                            }
                          },
                        ),
                        Builder(
                          builder: (context) {
                            if (distanceChartStep == "daily") {
                              return SizedBox(
                                height: 250,
                                child: charts.SfCartesianChart(
                                  series: [
                                    charts.ColumnSeries<DayData, String>(
                                      dataSource: lastWeek,
                                      xValueMapper: (DayData day, _) => day.day,
                                      yValueMapper: (DayData day, _) => day.distance,
                                      color: Theme.of(context).colorScheme.primary,
                                      animationDuration: 200,
                                      dataLabelSettings: charts.DataLabelSettings(isVisible: true, showZeroValue: false),
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                                    ),
                                  ],
                                  primaryXAxis: charts.CategoryAxis(
                                    majorGridLines: charts.MajorGridLines(width: 0),
                                    majorTickLines: charts.MajorTickLines(width: 0),
                                    labelStyle: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  primaryYAxis: charts.NumericAxis(
                                    isVisible: false,
                                  ),
                                  borderColor: Colors.transparent,
                                  plotAreaBorderWidth: 0,
                                ),
                              );
                            } else if (distanceChartStep == "weekly") {
                              return SizedBox(
                                height: 250,
                                child: charts.SfCartesianChart(
                                  series: [
                                    charts.LineSeries<WeekData, String>(
                                      dataSource: lastFewWeeks,
                                      xValueMapper: (WeekData week, _) => week.name,
                                      yValueMapper: (WeekData week, _) => week.distance,
                                      color: Theme.of(context).colorScheme.primary,
                                      animationDuration: 200,
                                      enableTooltip: true,
                                      width: 4,
                                    ),
                                    charts.LineSeries<WeekData, String>(
                                      dataSource: userGoalWeeks,
                                      xValueMapper: (WeekData week, _) => week.name,
                                      yValueMapper: (WeekData week, _) => week.distance,
                                      color: Theme.of(context).colorScheme.secondary,
                                      animationDuration: 200,
                                      dashArray: <double>[4, 4],
                                      enableTooltip: false,
                                      width: 2,
                                    ),
                                  ],
                                  tooltipBehavior: charts.TooltipBehavior(
                                    enable: true,
                                    header: "",
                                    color: Colors.transparent,
                                    textStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary == Colors.black ? Colors.white : Colors.black),
                                    format: "point.y${userData.distUnit}"
                                  ),
                                  primaryXAxis: charts.CategoryAxis(
                                    majorGridLines: charts.MajorGridLines(width: 0),
                                    majorTickLines: charts.MajorTickLines(width: 0),
                                    labelStyle: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  primaryYAxis: charts.NumericAxis(
                                    isVisible: false,
                                  ),
                                  borderColor: Colors.transparent,
                                  plotAreaBorderWidth: 0,
                                ),
                              );
                            }
                            return Container();
                          }
                        ),
                    
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }
}

class DayData {
  final String day;
  final double distance;

  DayData(this.day, this.distance);
}

class WeekData {
  final String name;
  final double distance;

  WeekData(this.name, this.distance);
}