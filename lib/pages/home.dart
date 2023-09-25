import 'dart:convert';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing1213/models/apiResponse.dart';
import 'package:testing1213/pages/ViewSales.dart';
import 'package:testing1213/pages/addCustomer.dart';
import 'package:testing1213/pages/addSales.dart';
import 'package:testing1213/pages/connectionError.dart';
import 'package:testing1213/pages/viewCustomers.dart';
import 'package:testing1213/service/services.dart';
import 'package:testing1213/service/user_service.dart';
import '../data/img.dart';
import '../data/my_colors.dart';
import 'package:testing1213/widget/snackbar.dart';
import '../widget/my_text.dart';
import '../widget/navigation_drawer.dart';
import 'loginAndSignup.dart';
import 'package:http/http.dart' as http;
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  @override
  void initState(){
    super.initState();
    _checkLoginStatus();
  }
  bool _isLoggedIn = false;
  bool isLoggedOut = false;
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('login');
    setState(() {
      _isLoggedIn = isLoggedIn!;
    });
  }
  void _logout() async {
    setState(() {
      isLoggedOut = true;
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
          isLoggedOut = false;
          _isLoggedIn = false;
          snackBar.show(
              context,"${logoutResponse.success}", Colors.green);
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginAndSignUpCard()));
        });
      }else{
        setState(() {
          isLoggedOut = false;
        });
        snackBar.show(
            context,"Something went wrong. Please try again", Colors.red);
      }
    }else{
      setState(() {
        isLoggedOut = false;
      });
      snackBar.show(
          context,"Something went wrong. Please try again", Colors.red);
    }
  }
  List<String> slider = [
    'image_slider1.jpg',
    'image_slider2.jpg',
    'image_slider3.jpg',
    'image_slider4.jpg',
    'image_slider5.jpg',
    'image_slider6.jpg',
    'image_slider7.jpg',
    'image_slider8.jpg',
    'image_slider9.jpg',
    'image_slider10.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Services.onBackPressed(context),
      child: Scaffold(
        drawer: NavigationDrawerWidget(),
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          title:  Text('Yehule Gebeya',
            style: MyText.body1(context)!.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500
            ),
          ),
          backgroundColor: MyColors.primary,
          foregroundColor: Colors.white,
        ),
        // floatingActionButton: ExpandableWidget(),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 15),
          child: Column(
            children: <Widget>[
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 200,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              aspectRatio: 5/1,
                              autoPlayCurve: Curves.easeInOut,
                              enableInfiniteScroll: true,
                              autoPlayAnimationDuration: Duration(milliseconds: 800),
                              viewportFraction: 1.5,
                            ),
                            items: slider.map((imageTxt) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:200,
                                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child:  Image.asset(Img.get(imageTxt), fit: BoxFit.cover,)
                                  );
                                },
                              );
                            }).toList(),
                          ),

                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('የሁሌ ገበያ',
                                style: MyText.subhead(context)!.copyWith(
                                    color: MyColors.primary, fontSize: 40, letterSpacing: 1, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        width: MediaQuery.of(context).size.width,
                        child: Row(

                          children: [
                            Text('Yehule Gebeya ',
                                style: MyText.body2(context)!.copyWith(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500
                                )
                            ),
                          ],
                        ),
                      ),
                     // Center(child: Text('body'),),
                      Container(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                             _isLoggedIn ? Navigator.of(context).push(MaterialPageRoute(builder: (_)=> ViewSalesPage())) : Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginAndSignUpCard()));
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.white,
                              elevation: 6,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: SizedBox(
                                height: 160,
                                width: 170,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20), // set border radius of container
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.white60, // set shadow color
                                        spreadRadius: 1, // set the spread radius of the shadow
                                        blurRadius: 1, // set the blur radius of the shadow
                                        offset: Offset(0, 1), // set offset of the shadow
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(Icons.bar_chart,
                                            size: 40, color: MyColors.primary),
                                      ),
                                      Text('View Sales',
                                          textAlign: TextAlign.center,
                                          style: MyText.subhead(context)!
                                              .copyWith(color: Colors.black,  letterSpacing: 1, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setBool('edit', false);
                              _isLoggedIn ? Navigator.of(context).push(MaterialPageRoute(builder: (_)=> AddSales())) : Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginAndSignUpCard()));
                              },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.white,
                              elevation: 6,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                height: 160,
                                width: 170,
                                alignment: Alignment.center,
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20), // set border radius of container
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.white60, // set shadow color
                                      spreadRadius: 1, // set the spread radius of the shadow
                                      blurRadius: 1, // set the blur radius of the shadow
                                      offset: Offset(0, 1), // set offset of the shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(Icons.add_outlined,
                                          size: 40, color: MyColors.primary),
                                    ),
                                    Text('Add Sales',
                                        textAlign: TextAlign.center,
                                        style: MyText.subhead(context)!
                                            .copyWith(color: Colors.black, fontWeight: FontWeight.w500, letterSpacing: 1)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async  {
                              _isLoggedIn ? Navigator.of(context).push(MaterialPageRoute(builder: (_)=> ViewCustomers())) : Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) =>LoginAndSignUpCard()));
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),

                              color: Colors.white,
                              elevation: 6,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                height: 160,
                                width: 170,
                                alignment: Alignment.center,
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20), // set border radius of container
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.white60, // set shadow color
                                      spreadRadius: 1, // set the spread radius of the shadow
                                      blurRadius: 1, // set the blur radius of the shadow
                                      offset: Offset(0, 1), // set offset of the shadow
                                    ),
                                  ],
                                ),

                                child: Center(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(Icons.people_outline_outlined,
                                            size: 40, color: MyColors.primary),
                                      ),
                                      Text('View Customers',
                                          textAlign: TextAlign.center,
                                          style: MyText.subhead(context)!
                                              .copyWith(color: Colors.black, fontWeight: FontWeight.w500, letterSpacing: 1)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // _isLoggedIn ? _logout():
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddCustomer()));
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.white,
                              elevation: 6,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                height: 160,
                                width: 170,
                                alignment: Alignment.center,
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20), // set border radius of container
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.white60, // set shadow color
                                      spreadRadius: 1, // set the spread radius of the shadow
                                      blurRadius: 1, // set the blur radius of the shadow
                                      offset: Offset(0, 1), // set offset of the shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      child: Icon( Icons.add ,
                                          size: 40, color: MyColors.primary),
                                    ),
                                    Text('Add Customers',
                                        textAlign: TextAlign.center,
                                        style: MyText.subhead(context)!
                                            .copyWith(color: Colors.black, fontWeight: FontWeight.w500, letterSpacing: 1)),
                                    SizedBox(height: 5,),
                                    // if (isLoggedOut)
                                    //   Container(
                                    //     width: double.infinity,
                                    //     height: 36,
                                    //     child: Center(
                                    //       child: CircularProgressIndicator(color: MyColors.primary,),
                                    //     ),
                                    //   ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30,),
                      // GridViewDashboard(),

                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
