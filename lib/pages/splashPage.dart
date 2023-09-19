import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing1213/data/my_colors.dart';
import 'package:testing1213/pages/home.dart';
import 'package:testing1213/pages/loginAndSignup.dart';
import 'package:page_transition/page_transition.dart';
import '../data/img.dart';
import 'package:lottie/lottie.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await _checkLoggedIn();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnimatedSplashScreen(
          splash: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width - 10,
                child: Image.asset(
                  Img.get('image_slider3.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              Lottie.asset(Img.get('mainsplash.json')),
            ],
          ),
          splashIconSize: 530,
          backgroundColor: Colors.white,
          duration: 5000,
          pageTransitionType: PageTransitionType.topToBottom,
          animationDuration: Duration(seconds: 0),
          nextScreen:_isLoggedIn ? HomePage() : LoginAndSignUpCard(),
        ),
      ),
    );
  }

  bool _isLoggedIn =false;

  Future<void> _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('login') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }
  @override
  Widget build(BuildContext context)  {
    print('the login status is ${_isLoggedIn}');
    return  Scaffold(
              body: Center(
                        child: Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width-30,
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: MyColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4), // Set the shadow color
                          blurRadius: 10, // Set the blur radius of the shadow
                          offset: Offset(0, 3), // Set the offset of the shadow
                        ),
                      ],
                    ),
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                      CircularProgressIndicator(color: Colors.white,),
                                      SizedBox(width: 15,),
                                      Text('Loading...', style: TextStyle(fontSize: 17, color: Colors.white),),
                                      ],
                                ),
                    ),
          ),
    );
  }
}
