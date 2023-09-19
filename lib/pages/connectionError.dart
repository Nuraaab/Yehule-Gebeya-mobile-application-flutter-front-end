import 'package:flutter/material.dart';
import 'package:testing1213/pages/home.dart';
import '../data/img.dart';
import 'package:lottie/lottie.dart';
class ConnectionError extends StatelessWidget {
  Widget routeWidget;
  ConnectionError({super.key, required this.routeWidget});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(Img.get('noconnection.json')),
            Container(
              width: MediaQuery.of(context).size.width/2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: (){Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> HomePage()));}, child: Row(children: [Icon(Icons.arrow_back, ), Text('back')],)),
                  TextButton(onPressed: (){Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => routeWidget),
                  );}, child: Row(children: [Icon(Icons.refresh), Text('Try Again')],)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
