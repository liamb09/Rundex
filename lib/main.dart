import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_log/pages/home_page.dart';
import 'package:running_log/pages/pr_page.dart';
import 'package:running_log/pages/profile_page.dart';
import 'package:running_log/pages/stats_page.dart';
import 'package:running_log/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getBool("light_mode") == null) {
    sharedPreferences.setBool("light_mode", true);
  }
  final bool isLight = sharedPreferences.getBool("light_mode")!;
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(sharedPreferences.getBool("light_mode")!),
      builder: (context, child) {
        return MyApp(isLight: isLight,);
      },
    )
  );
}

class MyApp extends StatelessWidget {
  final bool isLight;
  const MyApp({super.key, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      builder: (context, child) {
        return MaterialApp(
          title: 'Running Log',
          theme: Provider.of<ThemeProvider>(context, listen: true).themeData,
          home: MyHomePage(),
        );
      },
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

  var _currentPage = 0;

  final _pages = [
    HomePage(),
    StatsPage(),
    PRPage(),
    ProfilePage(),
  ];

    @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: _pages[_currentPage],
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            indicatorColor: Theme.of(context).colorScheme.primary,
            selectedIndex: _currentPage,
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.timeline_rounded),
                icon: Icon(Icons.timeline_rounded),
                label: 'Stats',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.emoji_events),
                icon: Icon(Icons.emoji_events_outlined),
                label: 'PRs',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.person),
                icon: Icon(Icons.person_outlined),
                label: 'Profile',
              ),
            ],
          ),
        );
      }
    );
  }

}