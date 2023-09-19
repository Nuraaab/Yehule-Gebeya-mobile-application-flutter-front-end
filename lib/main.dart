import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing1213/data/my_colors.dart';
import 'package:testing1213/pages/splashPage.dart';
import 'package:testing1213/route_generator.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: MyColors.primary, // set status bar color here
        statusBarBrightness: Brightness.light
    ));
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      home: const SplashScreen(),
    );
  }
}

