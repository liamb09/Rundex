import 'package:flutter/material.dart';
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

  List<double> getWeekMileage (List<Run> runs) {
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
      weeklyMileage[weeklyMileage.length-1] += run.distance;
    }
    return weeklyMileage;
  }

  List<MapEntry<String, double>> getLastWeekRuns (List<Run> runs) {
    var currentTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    var dayIndex = ((currentTimestamp - (currentTimestamp % 604800))%86400).floor();
    List<String> days = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
    List<MapEntry<String, double>> ret = [];
    for (int i = 0; i < 7; i++) {
      ret.insert(0, MapEntry(days[(i+dayIndex)%7], 0));
    }
    for (int i = runs.length-1; i >= 0; i--) {
      int index = 6-((currentTimestamp - runs[i].timestamp)/86400).floor();
      if (index >= 0) {
        ret[index] = MapEntry(ret[index].key, ret[index].value + runs[i].distance);
      }
    }
    return ret;
  }

  List<DayData> getChartData (List<MapEntry<String, double>> distances) {
    List<DayData> ret = [];
    for (int i = 0; i < distances.length; i++) {
      ret.add(DayData(distances[i].key, distances[i].value));
    }
    return ret;
  }

  /*List<ChartSampleData> getMileageSeries (List<Run> runs) {
    List<ChartSampleData> result = [];
    for (Run run in runs) {
      result.add(ChartSampleData(run.))
    }
  }*/

  @override
  Widget build (BuildContext context) {

    Future<User> user = getUserFromDB();
    Future<List<Run>> futureRuns = getRuns();

    return FutureBuilder<List<Run>>(
      future: futureRuns,
      builder: (BuildContext context, AsyncSnapshot<List<Run>> runSnapshot) {
        var runs = runSnapshot.data;
        var weeklyMileage = [];
        List<DayData> lastWeek = [];
        if (runs != null) {
          weeklyMileage = getWeekMileage(runs);
          getLastWeekRuns(runs);
          lastWeek = getChartData(getLastWeekRuns(runs));
        }
        return FutureBuilder<User>(
          future: user,
          builder: (BuildContext context, AsyncSnapshot<User> userSnapshot) {
            var userData = userSnapshot.data;
            if (userData == null) {
              return CircularProgressIndicator();
            }
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("This week", textAlign: TextAlign.left, style: TextStyle(
                            fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                          ),),
                        ],
                      ),
                      SizedBox(
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
                      ),
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
                                value: (weeklyMileage[0]/userData.goal!)*100,
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
                                widget: Text(
                                  "${weeklyMileage[0].toStringAsFixed(2)} / ${userData.goal}",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
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