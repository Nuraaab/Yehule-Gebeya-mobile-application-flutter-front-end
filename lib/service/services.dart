import 'package:flutter/material.dart';
import '../widget/my_text.dart';
class Services {
  static  Future<bool> onBackPressed(BuildContext context) async {
    bool exitApp = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Do you want to exit?',
          style: MyText.body1(context)!.copyWith(
              color: Colors.black,
              letterSpacing: 1,
              fontWeight: FontWeight.w400
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('No'
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Yes'
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return exitApp ?? false;
  }
}
