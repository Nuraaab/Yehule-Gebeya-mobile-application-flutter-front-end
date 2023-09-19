import 'dart:convert';
import 'package:testing1213/models/apiResponse.dart';
import 'package:testing1213/pages/ViewSales.dart';
import 'package:testing1213/pages/addCustomer.dart';
import 'package:testing1213/pages/connectionError.dart';
import 'package:testing1213/service/user_service.dart';
import 'package:testing1213/widget/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing1213/widget/navigation_drawer.dart';
import 'package:http/http.dart' as http;
import '../data/my_colors.dart';
import '../widget/my_text.dart';
import 'home.dart';

class ViewCustomers extends StatefulWidget {
  const ViewCustomers({Key? key}) : super(key: key);

  @override
  State<ViewCustomers> createState() => _ViewCustomersState();
}

class _ViewCustomersState extends State<ViewCustomers> {
  List<dynamic> _customers = [];
  bool isLoading = true;
  bool isEmptyData = false;

  @override
  void initState() {
    super.initState();
    _getCustomers().then((_) {
      setState(() {
        isLoading = false;
        isEmptyData = _customers.isEmpty;
      });
    });
  }
  Future<void> _getCustomers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('user_email') ?? '';
    String? userPassword = prefs.getString('user_password') ?? '';
    ApiResponse loginResponse = await login(userEmail, userPassword);
    if(loginResponse.error == null){
      String? token = loginResponse.token;
      int? user_id = loginResponse.user_id;
      ApiResponse viewCustomerResponse = await viewCustomer(user_id, token);
      if(viewCustomerResponse.error == null){
        dynamic data = viewCustomerResponse.data;
        setState(() {
          _customers =data['agent']['customer'];
        });
      }else{
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: ViewCustomers(),)));
      }
    }else{
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: ViewCustomers(),)));
    }
  }
  @override
  Widget build(BuildContext context) => isLoading ? Scaffold(
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
  ) :
  isEmptyData
      ? Scaffold(
    body: Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text( 'Looks like there no Customers yet. You can check it later.', textAlign: TextAlign.center, style: MyText.subhead(context)!.copyWith(
              color: Colors.black,  fontWeight: FontWeight.w400),),
          SizedBox(height: 20,),
          GestureDetector(
            onTap: (){
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
            },
            child: Container(
              width: 250,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: MyColors.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_ios, color: Colors.white, size: 25,),
                  SizedBox(width: 10,),
                  Text( 'Back', style: MyText.subhead(context)!.copyWith(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),),
  ):
      Scaffold(
        drawer: NavigationDrawerWidget(),
        appBar: AppBar(
          elevation: 0,
          title:  Text('Customers',
            style: MyText.body1(context)!.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500
            ),
          ),
          centerTitle: true,
          backgroundColor: MyColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTableTheme(
              data: DataTableThemeData(
                dataRowHeight: 56.0,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[400]!,
                      width: 2.0,
                    ),
                  ),
                ),
                headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
                dataRowColor: MaterialStateProperty.all(Colors.white),
                dividerThickness: 3,
              ), child: DataTable(
              columns: [
                DataColumn(label: Text('Name', style: MyText.subhead(context)!.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500
                ),)),
                DataColumn(label: Text('Phone Number', style: MyText.subhead(context)!.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500
                ),)),
                DataColumn(label: Text('Tin Number', style: MyText.subhead(context)!.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500
                ),)),
                DataColumn(label: Text('Action', style: MyText.subhead(context)!.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500
                ),)),
              ],
              rows: _customers.map((cust) {
                return DataRow(
                    cells: [
                      DataCell(Text(cust['name'].toString() ,
                        style: MyText.body1(context)!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      ),
                      DataCell(Text(cust['phone_number'].toString() ,
                        style: MyText.body1(context)!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      ),
                      DataCell(Text(cust['tin_number'].toString() ,
                        style: MyText.body1(context)!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      ),
                      DataCell(IconButton(onPressed: () async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool('editcust', true);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AddCustomer(customer: cust,)));
                        print('customer data: $cust');
                      }, icon: Icon(Icons.edit, color: Colors.black,),)),
                    ]);
              }).toList(),

            ),
            ),
          ),
        ),
      );
}
