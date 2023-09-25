import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing1213/data/img.dart';
import 'package:testing1213/models/apiResponse.dart';
import 'package:testing1213/pages/addSales.dart';
import 'package:testing1213/constant/constant.dart';
import 'package:testing1213/service/services.dart';
import 'package:testing1213/service/user_service.dart';
import '../data/my_colors.dart';
import '../widget/my_text.dart';
import 'dart:core';
import '../pages/connectionError.dart';
import 'package:testing1213/widget/snackbar.dart';
import '../widget/navigation_drawer.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
class ViewSalesPage extends StatefulWidget {
   ViewSalesPage({super.key});
  @override
  State<ViewSalesPage> createState() => _ViewSalesPageState();
}
class _ViewSalesPageState extends State<ViewSalesPage> {
  @override
  void initState() {
    super.initState();
    _getSales();
  }
  Map<String, dynamic> _salesData = {};
  String customer_name = '';
  Future<void> _getSales() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('user_email') ?? '';
    String? userPassword = prefs.getString('user_password') ?? '';
    ApiResponse loginResponse = await login(userEmail, userPassword);
    if(loginResponse.error == null){
      int? user_id = loginResponse.user_id;
      String? token = loginResponse.token;
      ApiResponse viewSalesResponse = await viewSale(user_id, token);
      if(viewSalesResponse.error == null){
        dynamic data = viewSalesResponse.data;
        setState(() {
          _salesData = data;
        });
      }else{
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: ViewSalesPage(),)));
      }
    }else{
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: ViewSalesPage(),)));
    }
  }

  DateTime currentDateWithTime = DateTime.now();
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  late String formattedDate = dateFormat.format(currentDateWithTime);
  late DateTime parsedDate = dateFormat.parse(formattedDate);
  late Duration difference = currentDateWithTime.difference(parsedDate);
  @override
  Widget build(BuildContext context) {
    print(' current date only ${formattedDate} difference ${difference.inDays}');
    List<dynamic> salesData = _salesData['data'] ?? [];
    Set<String> uniqueCustomers = Set<String>.from(salesData.map((sale) => sale['customer_name']));
    if (_salesData.isEmpty) {
      print('sales data list :${_salesData}');
      return Scaffold(
        body: Center(
          child: Container(
            height: 80,
            width: MediaQuery.of(context).size.width - 30,
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
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  'Loading...',
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
          drawer: const NavigationDrawerWidget(),
          appBar: AppBar(
            elevation: 0,
            title: Text('Sales',
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
          body: salesData.isEmpty ?  Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text( 'Looks like there is no sales yet. Add a new one by clicking here.', textAlign: TextAlign.center, style: MyText.subhead(context)!.copyWith(
                    color: Colors.black,  fontWeight: FontWeight.w400),),
                SizedBox(height: 20,),
                GestureDetector(
                  onTap: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool('edit', false);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AddSales()));
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
                        Icon(Icons.add,color: Colors.white, size: 25,),
                        SizedBox(width: 10,),
                        Text( 'Add New Sales', style: MyText.subhead(context)!.copyWith(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),) :
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[500],
                border: Border(
                  bottom: BorderSide(color: Colors.white, width: 3),
                ), // Set the border color and width
              ),
              child: ExpansionPanelList.radio(
                expandedHeaderPadding: EdgeInsets.all(0.0),
                elevation: 0,
                children: uniqueCustomers.map<ExpansionPanelRadio>((customerName) {
                  List<dynamic> sales = salesData.where((e) => e['customer_name'] == customerName).toList();
                  return ExpansionPanelRadio(
                    backgroundColor: Colors.white,
                    canTapOnHeader: true,
                    value: customerName, // Use customerName as the unique identifier
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(customerName,
                          style: MyText.body1(context)!.copyWith(
                              color: Colors.black.withOpacity(0.7),
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      );
                    },
                    body: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTableTheme(
                              data:  DataTableThemeData(
                                dataRowHeight: 56.0,
                                headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
                                dataRowColor: MaterialStateProperty.all(Colors.white),
                                dividerThickness: 3,
                              ),
                              child: DataTable(
                                columns: [
                                  DataColumn(label: Text('Date', style: MyText.subhead(context)!.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500
                                  ))),
                                  DataColumn(label: Text('Item', style: MyText.subhead(context)!.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500
                                  ))),
                                  DataColumn(label: Text('Quantity', style: MyText.subhead(context)!.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500
                                  ))),
                                  DataColumn(label: Text('Action', style: MyText.subhead(context)!.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500
                                  ))),
                                ],
                                rows: sales.map<DataRow>((sale) {
                                  late DateTime parsedFetchedDate = dateFormat.parse(sale['date']);
                                  Duration difference = parsedDate.difference(parsedFetchedDate);
                                  int differenceInDays = difference.inDays;
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(sale['date'].toString() ,
                                        style: MyText.body1(context)!.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ), ),
                                      DataCell(Text('${sale['item_code'].toString()}/ ${sale['item_name'].toString()}',
                                        style: MyText.body1(context)!.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500
                                        ),
                                      )),
                                      DataCell(Text(sale['quantity'].toString(),
                                        style: MyText.body1(context)!.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500
                                        ),
                                      )),
                                      (differenceInDays <= 30) ? DataCell(IconButton(onPressed: () async {
                                        int  customerId = int.parse(sale['customer_id'].toString());
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        prefs.setBool('edit', true);
                                        var latitude =  sale['location']['latitude'];
                                        var longitude = sale['location']['longitude'];
                                        var location = '${latitude},${longitude}';
                                        print('sales id ${sale['sales_id']} , date ${sale['date'].toString()} quantity ;${sale['quantity'].toString()} customerName: ${sale['customer_name'].toString()} itemName: ${sale['item_code'].toString()} itemCode: ${sale['item_name'].toString()} location:  ${location.toString()},');
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AddSales(date: sale['date'].toString(), quantity: sale['quantity'].toString(), customerName: sale['customer_name'].toString(), itemName: sale['item_code'].toString(), itemCode: sale['item_name'].toString(), location:  location.toString(), sales_id: sale['sales_id'].toString(), ))); }, icon: Icon(Icons.edit),color: Colors.black,)) :DataCell(Text('')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          )
      );
    }
  }
}
