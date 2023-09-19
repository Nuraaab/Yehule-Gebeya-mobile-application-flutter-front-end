import 'dart:convert';
import 'package:testing1213/pages/addCustomer.dart';
import 'package:testing1213/widget/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing1213/pages/ViewSales.dart';
import 'package:testing1213/pages/addSales.dart';
import 'package:testing1213/pages/viewCustomers.dart';
import '../data/my_colors.dart';
import '../models/apiResponse.dart';
import '../pages/connectionError.dart';
import '../pages/home.dart';
import '../pages/loginAndSignup.dart';
import '../service/user_service.dart';
import '/widget/my_text.dart';
import '/data/img.dart';
import 'package:http/http.dart' as http;
class NavigationDrawerWidget extends StatefulWidget {
  const NavigationDrawerWidget({super.key});
  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}
class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = const EdgeInsets.symmetric(horizontal: 20);
  @override
  void initState(){
    super.initState();
    _checkLoginStatus();
  }
  bool _isLoggedIn = false;
  bool _isLoggedOut = false;
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('login');
    setState(() {
      _isLoggedIn = isLoggedIn!;
    });
  }
  void _logout() async {
    setState(() {
      _isLoggedOut = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('user_email') ?? '';
    String? userPassword = prefs.getString('user_password') ?? '';

    ApiResponse loginResponse = await login(userEmail, userPassword);
    if(loginResponse.error == null){
      String? token = loginResponse.token;
      ApiResponse logoutResponse =  await logout(token);
      if(logoutResponse.error == null){
        await prefs.clear();
        prefs.setBool('login', false);
        setState(() {
          _isLoggedOut = false;
          _isLoggedIn = false;
          snackBar.show(
              context,"${logoutResponse.success}", Colors.green);
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginAndSignUpCard()));
        });
      }else{
        setState(() {
          _isLoggedOut = false;
        });
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: HomePage(),)));
      }
    }else{
      setState(() {
        _isLoggedOut = false;
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: HomePage(),)));
    }
  }
   @override
  Widget build(BuildContext context)=>Drawer(
    child: SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height:250,
              child: Stack(
                children: <Widget>[
                  Image.asset(
                    Img.get('image_slider3.jpg'),
                    height: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("Home" ,
                  style: MyText.subhead(context)!.copyWith(
                      color: Colors.black,   fontWeight: FontWeight.w500)),
              leading: const Icon(Icons.home, size: 25.0, color: Colors.black,),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> const HomePage()));
              },
            ),
            ListTile(
              title: Text("View Sales" ,
                  style: MyText.subhead(context)!.copyWith(
                      color: Colors.black,   fontWeight: FontWeight.w500)),
              leading: const Icon(Icons.bar_chart, size: 25.0, color: Colors.black,),
              onTap: () {
                _isLoggedIn ? Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> ViewSalesPage())) : Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> LoginAndSignUpCard()));
              },
            ),
            ListTile(
              title: Text("Add Sales" ,
                  style: MyText.subhead(context)!.copyWith(
                      color: Colors.black,   fontWeight: FontWeight.w500)),
              leading: const Icon(Icons.add_outlined, size: 25.0, color: Colors.black,),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('edit', false);
                _isLoggedIn ? Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> AddSales())) : Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> LoginAndSignUpCard()));
              },
            ),
            ListTile(
              title: Text("Add Customers" ,
                  style: MyText.subhead(context)!.copyWith(
                      color: Colors.black,   fontWeight: FontWeight.w500)),
              leading: const Icon(Icons.add_outlined, size: 25.0, color: Colors.black,),
              onTap: () async {
                _isLoggedIn ? Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> AddCustomer())) : Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> LoginAndSignUpCard()));
              },
            ),
            ListTile(
              title: Text("View Customers" ,
                  style: MyText.subhead(context)!.copyWith(
                      color: Colors.black,   fontWeight: FontWeight.w500)),
              leading: const Icon(Icons.people_outline_outlined, size: 25.0, color: Colors.black,),
              onTap: () {
                _isLoggedIn ? Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> const ViewCustomers())) : Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> LoginAndSignUpCard()));
              },
            ),
            const Padding(
              padding: EdgeInsets.only(right: 50),
              child: Divider(color: Colors.black, thickness: 1,),
            ),
            ListTile(
              title: Text(_isLoggedIn ? "Logout" : 'Login' ,
                  style: MyText.subhead(context)!.copyWith(
                      color: Colors.black,   fontWeight: FontWeight.w500)),
              leading: const Icon(Icons.logout_outlined, size: 25.0, color: Colors.black,),
              onTap: () {
                _isLoggedIn ? _logout() :
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> const LoginAndSignUpCard()));
              },
            ),
            SizedBox(height: 5,),
            if (_isLoggedOut)
              Container(
                width: double.infinity,
                height: 36,
                child: const Center(
                  child: CircularProgressIndicator(color: MyColors.primary,),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
