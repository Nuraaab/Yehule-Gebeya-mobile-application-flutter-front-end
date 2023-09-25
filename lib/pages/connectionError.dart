import 'package:flutter/material.dart';
import 'package:testing1213/pages/home.dart';
import 'package:testing1213/service/services.dart';
import '../data/img.dart';
import '../widget/my_text.dart';
import 'package:lottie/lottie.dart';
class ConnectionError extends StatelessWidget {
  Widget routeWidget;
  ConnectionError({super.key, required this.routeWidget});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () =>Services.onBackPressed(context),
      child: Center(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 8, right: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(Img.get('somethingwentwrong.json')),
              SizedBox(height: 10,),
              Text('Please check your connection and try again.',
                style: MyText.body1(context)!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width/2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(onPressed: (){Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => routeWidget),
                    );}, child: Row(children: [Icon(Icons.refresh, size: 18,), SizedBox(width: 5,),Text('Reload')],)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
