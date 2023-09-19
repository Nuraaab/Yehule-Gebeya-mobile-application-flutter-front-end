import 'package:flutter/material.dart';
import '../widget/my_text.dart';
class snackBar {
  final String msg;
  final Color? clr;
  const snackBar({
    required this.msg,
    this.clr,
  });

  static show(BuildContext context, String msg, Color clr) async{
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0.0,
      backgroundColor: clr,
      behavior: SnackBarBehavior.fixed,
      content: Text(msg,
          style: MyText.subhead(context)!
              .copyWith(fontWeight: FontWeight.w400, color: Colors.white),
      ),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: "Ok",
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        textColor: Colors.white,
      ),
    ));
  }
}
