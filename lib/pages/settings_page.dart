import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_log/services_and_helpers/RunsDatabase.dart';
import 'package:running_log/theme/theme.dart';
import 'package:running_log/theme/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Settings", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              Divider(),
              Row(
                children: [
                  Expanded(child: Text("Theme")),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(Provider.of<ThemeProvider>(context).themeData == lightMode ? "Light" : "Dark", textAlign: TextAlign.right,),
                        IconButton(
                          icon: Icon(Provider.of<ThemeProvider>(context).themeData == lightMode ? Icons.light_mode : Icons.dark_mode),
                          onPressed: () {
                            if (Provider.of<ThemeProvider>(context, listen: false).themeData == lightMode) {
                              Provider.of<ThemeProvider>(context, listen: false).themeData = darkMode;
                            } else {
                              Provider.of<ThemeProvider>(context, listen: false).themeData = lightMode;
                            }
                          }
                        ),
                      ],
                    )
                  ),
                ],
              ),
              Divider(),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Expanded(child: Text("Your data", style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
                    Expanded(child: Text("→", textAlign: TextAlign.right, style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
                  ],
                ),
              ),
              Divider(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(textStyle: TextStyle(fontSize: 15),),
                onPressed: () {
                  RunsDatabase.instance.clearDatabase();
                  setState(() {});
                },
                child: Text("Clear Data", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}