import 'package:flutter/material.dart';

class StatsPage extends StatefulWidget {
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build (BuildContext context) {
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
      body: Placeholder(),
    );
  }
}