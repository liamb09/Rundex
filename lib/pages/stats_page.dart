import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_log/services_and_helpers/Run.dart';
import 'package:running_log/services_and_helpers/RunsDatabase.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';
import 'package:running_log/theme/theme.dart';
import 'package:running_log/theme/theme_provider.dart';
//import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:tinycolor2/tinycolor2.dart';

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
        if (runs != null) {
          weeklyMileage = getWeekMileage(runs);
        }
        return FutureBuilder<User>(
          future: user,
          builder: (BuildContext context, AsyncSnapshot<User> userSnapshot) {
            var userData = userSnapshot.data;
            if (userData == null) {
              return CircularProgressIndicator();
            }
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                title: Text("Your stats", style: TextStyle(color: Colors.white),),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              body: Center(
                child: Column(
                  children: [
                    SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          showLabels: false,
                          showTicks: false,
                          radiusFactor: 0.8,
                          axisLineStyle: AxisLineStyle(
                            thickness: 0.2,
                            cornerStyle: CornerStyle.bothCurve,
                            color: Provider.of<ThemeProvider>(context).themeData == darkMode ? Color(0xff171717) : Color(0xffE8E8E8),
                            thicknessUnit: GaugeSizeUnit.factor,
                          ),
                          pointers: <GaugePointer>[
                            RangePointer(
                              value: (weeklyMileage[0]/userData.goal!)*100,
                              width: 0.2,
                              cornerStyle: CornerStyle.bothCurve,
                              color: Theme.of(context).colorScheme.primary,
                              sizeUnit: GaugeSizeUnit.factor,
                              enableAnimation: true,
                              animationDuration: 30,
                              animationType: AnimationType.linear
                            )
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
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
                    Text("Your Mileage This Week", style: TextStyle(fontSize: 20),)
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }
}