import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing1213/data/my_colors.dart';
import 'package:testing1213/models/apiResponse.dart';
import 'package:testing1213/pages/home.dart';
import 'package:testing1213/service/user_service.dart';
import 'package:testing1213/widget/snackbar.dart';
import '../data/img.dart';
import 'package:http/http.dart' as http;
import '../widget/my_text.dart';
class LoginAndSignUpCard extends StatefulWidget {
  const LoginAndSignUpCard({Key? key}) : super(key: key);
  @override
  State<LoginAndSignUpCard> createState() => _LoginAndSignUpCardState();
}
class _LoginAndSignUpCardState extends State<LoginAndSignUpCard> {
 @override
 void initState(){
   super.initState();
   _setUserData();
 }
  bool isLoggingOrSignup = false;
  final _lemailcontroller = TextEditingController();
  final _lpasswordcontroller = TextEditingController();
  late final String _gender;
  void _setUserData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('user_email') ?? '';
    String? userPassword = prefs.getString('user_password') ?? '';

    setState(() {
      _lemailcontroller.text = userEmail;
      _lpasswordcontroller.text = userPassword;
    });
  }
  Future Login(BuildContext cont) async {
    setState(() {
      isLoggingOrSignup = true;
    });
    if (_lemailcontroller.text == "" || _lpasswordcontroller.text == "") {
      snackBar.show(
          context,"Email and password must be filled", Colors.red);
    } else {

      ApiResponse apiResponse = await login(_lemailcontroller.text, _lpasswordcontroller.text);
      if(apiResponse.error == null){
       int? user_id =apiResponse.user_id;
       String? token = apiResponse.token;
         SharedPreferences prefs = await SharedPreferences.getInstance();
         prefs.setBool('login', true);
         prefs.setString('user_email', '${_lemailcontroller.text}');
         prefs.setString('user_password', '${_lpasswordcontroller.text}');
         print('user id ${user_id}');
         print('token ${token}');
         setState(() {
         isLoggingOrSignup = false;
        });
       snackBar.show(
           context,"${apiResponse.success}", Colors.green);
       Navigator.of(cont).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }else{
        snackBar.show(
            context,"${apiResponse.error}", Colors.red);
        setState(() {
          isLoggingOrSignup = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(color: Colors.blue)),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Container( height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Img.get('image_slider3.jpg',),), fit: BoxFit.fill,
                  ),
                ),
                child: Container(
                  color: MyColors.primary.withOpacity(0.6),
                ),
              ),
              Column(
                children: <Widget>[
                  SizedBox(height: 160,),
                  AnimatedContainer(
                    duration: Duration(microseconds: 2000),
                    curve: Curves.bounceInOut,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        margin: const EdgeInsets.all(25),
                        elevation: 10,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          child:  Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        // _isSignupScreen = false;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Text('LOGIN',
                                          style:  MyText.subhead(context)!.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 3,),
                                        Container(
                                          height: 2,
                                          width: 45,
                                          color:  MyColors.primary,
                                        )
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                              Container(height: 30),
                                Padding(
                                  padding:  EdgeInsets.only(bottom: 10.0),
                                  child: TextField(
                                    controller: _lemailcontroller,
                                    obscureText: false,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.email_outlined , color: MyColors.iconColor,),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: MyColors.textColor1,
                                        ),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: MyColors.textColor1,
                                        ),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: 'Email',
                                      hintStyle: TextStyle(fontSize: 14, color: MyColors.textColor1),
                                    ),
                                  ),
                                ),
                                Padding(
                                padding:  EdgeInsets.only(bottom: 10.0),
                                child: TextField(
                                  controller: _lpasswordcontroller,
                                  obscureText: true,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock_outlined , color: MyColors.iconColor,),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: MyColors.textColor1,
                                      ),
                                      borderRadius: BorderRadius.circular(35),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: MyColors.textColor1,
                                      ),
                                      borderRadius: BorderRadius.circular(35),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: 'Password',
                                    hintStyle: TextStyle(fontSize: 14, color: MyColors.textColor1),
                                  ),
                                ),
                              ),
                                Container(height: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: MyColors.primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5)),
                                      ),
                                      child:  Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.login, color: Colors.white,),
                                          SizedBox(width: 20,),
                                          Text(
                                            "SIGN IN" ,
                                            style: TextStyle(color: Colors.white),
                                          ),

                                        ],
                                      ),
                                         onPressed: () {
                                        FocusScopeNode currentFocus =
                                        FocusScope.of(context);

                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }

                                         Login(context);

                                      },
                                    ),
                              ),
                                    SizedBox(height: 5,),
                                    if (isLoggingOrSignup)
                                      Container(
                                        width: double.maxFinite,
                                        height: 36,
                                        child: Center(
                                          child: CircularProgressIndicator(color: MyColors.primary,),
                                        ),
                                      ),
                                  ],
                                ),
                                Container(height: 20),
                            ],
                          )
                        )),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
