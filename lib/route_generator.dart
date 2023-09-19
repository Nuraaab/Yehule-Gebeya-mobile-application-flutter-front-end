import 'package:flutter/material.dart';
import 'package:testing1213/pages/addSales.dart';
import 'package:testing1213/pages/home.dart';
import 'package:testing1213/pages/loginAndSignup.dart';
import 'data/img.dart';
import 'main.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());


      case '/add':
        return MaterialPageRoute(builder: (_) => AddSales());

      case '/login':
        return MaterialPageRoute(builder: (_) => LoginAndSignUpCard());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(100.0),
                child: Image.asset(
                  Img.get('error.png'),
                ),
              ),
              const Text(
                'something went wrong while routing',
                style: TextStyle(color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      );
    });
  }
}
