import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:testing1213/data/my_colors.dart';
import 'package:testing1213/models/apiResponse.dart';
import 'package:testing1213/service/services.dart';
import 'package:testing1213/service/user_service.dart';
import 'package:testing1213/widget/navigation_drawer.dart';
import 'package:geolocator/geolocator.dart';
import '../widget/my_text.dart';
import 'package:testing1213/widget/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../pages/connectionError.dart';
import 'ViewSales.dart';
import 'connectionError.dart';
import 'home.dart';
class AddSales extends StatefulWidget {
  int? customer_id;
  String? sales_id;
  String? date;
  String? quantity;
  String? customerName;
  String? itemName;
  String? itemCode;
  String? location;
   AddSales({super.key, this.customer_id, this.date, this.quantity, this.customerName, this.itemCode, this.location, this.sales_id, this.itemName});

  @override
  State<AddSales> createState() => _AddSalesState();
}

class _AddSalesState extends State<AddSales> {

  bool isAddingOrUpdating = false;
  List<dynamic> _custName = [];
  List<dynamic> _fcustName = [];
  List<dynamic> _efcustName = [];
  List<dynamic> _itemsName = [];
  List<dynamic> _fitemsName = [];
  List<dynamic> _ufitemsName = [];
  int _agent_id =0;
  int _cust_id =0;
  int _ecust_id =0;
  String _item_code = '';
  String _uitem_code = '';
  @override
  void initState() {
    super.initState();
    isLoading = true;
    _getEdditingStatus().then((_) {
      if(_isEdditingMode){
        _setEdditingData();
        print('hiiiiiiiiiiiii');
      }
      _getCustomereName().then((_) {
        _getItemsName().then((_){
          setState(() {
            isEmptyData = _custName.isEmpty || _itemsName.isEmpty; // Check if data is empty
            isLoading = false; // Set isLoading to false after fetching data
            print(' cust ${_custName.isEmpty }  item ${_itemsName.isEmpty} over all ${isEmptyData}');
            _customernamecontroller =_isEdditingMode ?(widget.customerName!.isNotEmpty ? widget.customerName : null) : (_custName.isNotEmpty ? _custName[0].toString() : null);
            _itemnamecontroller = _isEdditingMode ? (widget.itemCode!.isNotEmpty ? widget.itemCode : null) : (_itemsName.isNotEmpty ? _itemsName[0].toString(): null);
          });
        });
      });
    });
    _getLocation().then((_) {
      setState(() {
        _isLocationLoaded =false;
      });
    });
  }
  bool _isLocationLoaded = false;
  bool _isEdditingMode = false;
  bool _isLocate = false;
  bool _isCustChanged = false;
  bool _isItemeChanged = false;
  bool _isPast = false;
 Future<void> _getLocation() async {
   setState(() {
     _isLocationLoaded =true;
   });
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    setState(() {
      _latitude = position.latitude.toString();
      _longtude = position.longitude.toString();
      _locationcontroller = '${_latitude},${_longtude}';
    });
    print(position);
  }
  _getEdditingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isEdditingMode = prefs.getBool('edit') ?? false;
    setState(() {
      _isEdditingMode =isEdditingMode;
    });
  }
  void _setEdditingData(){
      setState(() {
        forintializaton = widget.date;
        _customernamecontroller = widget.customerName;
        _itemnamecontroller = widget.itemCode;
        _quantitycontroller.text = widget.quantity!;
        _locationcontroller = widget.location!;
        _cust_id =widget.customer_id ?? 0;
        _uitem_code = widget.itemName!;
        print('date :${forintializaton} customerName: ${_customernamecontroller} itemName : ${_itemnamecontroller} quantity : ${_quantitycontroller.text} location: ${_locationcontroller}');
      });
  }
  Future<void> _getCustomereName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user_id = prefs.getString('user_id');
    String? userEmail = prefs.getString('user_email') ?? '';
    String? userPassword = prefs.getString('user_password') ?? '';

    ApiResponse loginResponse = await login(userEmail, userPassword);
    if(loginResponse.error == null){
      int? user_id =loginResponse.user_id;
      String? token = loginResponse.token;
     ApiResponse customerResponse = await getCustomerName(token, user_id);
     if(customerResponse.error == null){
       dynamic data = customerResponse.data;
       if (data != null && data['agent'] != null && data['agent']['customer'] != null) {
         _custName = (data['agent']['customer'] as List<dynamic>)
             .map<String>((customer) => customer['name'] as String)
             .toList();
         print('customer name:$_custName');
       }else{
         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: AddSales(),)));
       }
     }else{
       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: AddSales(),)));
     }

    }else{
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: AddSales(),)));
    }
  }
  Future<void> _addSales() async {
    if(forintializaton == ''){
      snackBar.show(
          context,"Date must be filled.", Colors.red);
    }else if(_isPast){
      snackBar.show(
          context,"The selected date is already past.", Colors.red);
    }else if(_customernamecontroller == null){
      snackBar.show(
          context,"Customer Name must be selected.", Colors.red);
    }else if(_itemnamecontroller == null){
      snackBar.show(
          context,"Item Name must be selected.", Colors.red);
    }else if(_quantitycontroller.text == ''){
      snackBar.show(
          context,"Quantity must be filled.", Colors.red);
    }else if(_locationcontroller!.isEmpty){
      snackBar.show(
          context,"Your current location must be filled.", Colors.red);
    }else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('user_email') ?? '';
      String? userPassword = prefs.getString('user_password') ?? '';
      ApiResponse loginResponse = await login(userEmail, userPassword);
      if (loginResponse.error == null) {
        String? token = loginResponse.token;
        int? user_id = loginResponse.user_id;
        ApiResponse customerResponse = await getCustomerName(token, user_id);
        if (customerResponse.error == null) {
          dynamic data = customerResponse.data;
          int selectedIndex = _custName.indexWhere((
              customerName) => customerName == _customernamecontroller);
          if (selectedIndex != -1) {
            // Retrieve the customer data based on the index
            Map<String,
                dynamic> customerData = data['agent']['customer'][selectedIndex];
            _cust_id = customerData['id'];
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: AddSales(),)));
            isAddingOrUpdating = false;
          }
          ApiResponse itemResponse = await getItems(token);
          if (itemResponse.error == null) {
            dynamic data = itemResponse.data;
            int selectedItemIndex = _itemsName.indexWhere((
                ItemName) => ItemName == _itemnamecontroller);
            print('index:$selectedItemIndex');
            if (selectedItemIndex != -1) {
              Map<String, dynamic> ItemData = data['items'][selectedItemIndex];
              _item_code = ItemData['item_code'].toString();
              print('item code :${_item_code}');
            } else {
              snackBar.show(
                  context,"Something went wrong. Please try again", Colors.red);
              isAddingOrUpdating = false;
            }
            var body = jsonEncode({
              'agent_id': user_id,
              'customer_id': _cust_id.toString(),
              'date': forintializaton,
              'quantity': _quantitycontroller.text,
              'location': _locationcontroller,
              'item_code': _item_code,
            });
            ApiResponse addSalesResponse = await addSale(body, token);
            if (addSalesResponse.error == null) {
              snackBar.show(
                  context, "${addSalesResponse.success}", Colors.green);
              isAddingOrUpdating = false;
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => ViewSalesPage()));
            } else {
              snackBar.show(
                  context,"Something went wrong. Please try again", Colors.red);
              isAddingOrUpdating = false;
            }
          } else {
            snackBar.show(
                context,"Something went wrong. Please try again", Colors.red);
            isAddingOrUpdating = false;
          }
        } else {
          snackBar.show(
              context,"Something went wrong. Please try again", Colors.red);
          isAddingOrUpdating = false;
        }
      } else {
        snackBar.show(
            context,"Something went wrong. Please try again", Colors.red);
        isAddingOrUpdating = false;
      }
    }
 }
  Future<void> _updateSales() async {
    if(forintializaton == ''){
      snackBar.show(
          context,"Date must be filled.", Colors.red);
    }else if(_isPast){
      snackBar.show(
          context,"The selected date is already past.", Colors.red);
    }else if(_customernamecontroller == null){
      snackBar.show(
          context,"Customer Name must be selected.", Colors.red);
    }else if(_itemnamecontroller == null){
      snackBar.show(
          context,"Item Name must be selected.", Colors.red);
    }else if(_quantitycontroller.text == ''){
      snackBar.show(
          context,"Quantity must be filled.", Colors.red);
    }else if(_locationcontroller!.isEmpty){
      snackBar.show(
          context,"Your current location must be filled.", Colors.red);
    }else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('user_email') ?? '';
      String? userPassword = prefs.getString('user_password') ?? '';

      ApiResponse loginResponse = await login(userEmail, userPassword);
      if(loginResponse.error == null){
        String? token = loginResponse.token;
        int? user_id = loginResponse.user_id;
        ApiResponse customerResponse = await getCustomerName(token, user_id);
        if(customerResponse.error == null){
          dynamic data = customerResponse.data;
          int selectedIndex = _custName.indexWhere((customerName) => customerName == _customernamecontroller);
          if (selectedIndex != -1) {
            Map<String, dynamic> customerData = data['agent']['customer'][selectedIndex];
            _cust_id = customerData['id'];
          }else{
            isAddingOrUpdating = false;
            snackBar.show(
                context,"Something went wrong. Please try again", Colors.red);
          }
          ApiResponse itemResponse = await getItems(token);
          if(itemResponse.error == null){
            dynamic data = itemResponse.data;
            int selectedItemIndex = _itemsName.indexWhere((ItemName) => ItemName == _itemnamecontroller);
            print('item index list ${selectedItemIndex}');
            if (selectedItemIndex != -1) {
              Map<String, dynamic> ItemData = data['items'][selectedItemIndex];
              _uitem_code = ItemData['item_code'].toString();
            }else{
              isAddingOrUpdating = false;
              snackBar.show(
                  context,"Something went wrong. Please try again", Colors.red);
            }
            var body = jsonEncode({
              "sales_id": widget.sales_id,
              "agent_id": user_id,
              'date': forintializaton,
              'customer_id': _cust_id.toString(),
              'item_code': _uitem_code,
              'quantity': _quantitycontroller.text,
              'location': _locationcontroller,
            });
            ApiResponse updateResponse = await updateSale(body, token, widget.sales_id);
            if(updateResponse.error == null){
              snackBar.show(
                  context, "${updateResponse.success}", Colors.green);
              isAddingOrUpdating = false;
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => ViewSalesPage()));
            }else{
              print(updateResponse.error);
              isAddingOrUpdating = false;
              snackBar.show(
                  context,"Something went wrong. Please try again", Colors.red);
            }
          }else{
            isAddingOrUpdating = false;
            snackBar.show(
                context,"Something went wrong. Please try again", Colors.red);
          }
        }else{
          isAddingOrUpdating = false;
          snackBar.show(
              context,"Something went wrong. Please try again", Colors.red);
        }
      }else{
        isAddingOrUpdating = false;
        snackBar.show(
            context,"Something went wrong. Please try again", Colors.red);
      }
    }
  }
  Future<void> _getItemsName() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
   String? userEmail = prefs.getString('user_email') ?? '';
   String? userPassword = prefs.getString('user_password') ?? '';
   ApiResponse loginResponse = await login(userEmail, userPassword);
   if(loginResponse.error ==null){
     String? token = loginResponse.token;
     ApiResponse itemResponse = await getItems(token);
     if(itemResponse.error == null){
       dynamic data = itemResponse.data;
       if(data!= null && data['items']!= null){
         _itemsName = (data['items'] as List<dynamic>).map((
             item) => item['name']).toList() ?? [];
       }else{
         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: AddSales(),)));
       }
     }else{
       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: AddSales(),)));
     }
   }else{
     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ConnectionError(routeWidget: AddSales(),)));
   }
 }

  DateTime currentDate = DateTime.now();
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  late String formattedDate = dateFormat.format(currentDate);

  late String? forintializaton = formattedDate;
  TextEditingController _quantitycontroller = TextEditingController();
  String? _locationcontroller;
  String? _customernamecontroller = '';
  String? _itemnamecontroller = '';
  String _latitude = '';
  String _longtude = '';
  bool isLoading = true; // Set this flag to true when data loading starts and false when it finishes
  late bool isEmptyData = _custName.isEmpty || _itemsName.isEmpty;
  // ||
  @override
  Widget build(BuildContext context)  => isLoading ?
  Scaffold(
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
  (isEmptyData)
      ?
  Scaffold(
    body: Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text( 'Looks like there is no Items and Customers yet. You can check it later.', textAlign: TextAlign.center, style: MyText.subhead(context)!.copyWith(
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
    drawer: const NavigationDrawerWidget(),
    appBar: AppBar(
      elevation: 0,
      title:  Text(_isEdditingMode ? 'Update Sales' : 'Add Sales',
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
    body:  SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      scrollDirection: Axis.vertical,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(height: 35),
              Padding(
                padding:  EdgeInsets.only(bottom: 10.0),
                child: TextField(
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.date_range_outlined , color: MyColors.iconColor,),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.textColor1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.textColor1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.all(15),
                    hintText: _isEdditingMode ? ('${forintializaton.toString()}'): ('${forintializaton == null ? formattedDate : forintializaton.toString()}'),
                    hintStyle:  MyText.body1(context)!.copyWith(
                        color: MyColors.textColor1,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  onTap: () async {
                    late DateTime parsedFetchedDate = dateFormat.parse(forintializaton!);
                    DateTime? newdate = await showDatePicker(
                        context: context,
                        initialDate: _isEdditingMode ? parsedFetchedDate :DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100));

                    if (newdate == null) {
                      DateTime currentDate = DateTime.now();
                      late String formattedDate = dateFormat.format(currentDate);
                      setState(() {
                        forintializaton = formattedDate;
                      });
                    }else{
                      setState(() {
                        DateTime currentDate = DateTime.now();
                        DateTime currentDateWithTime = newdate;
                        DateFormat dateFormat = DateFormat('yyyy-MM-dd');
                        late String formattedDate = dateFormat.format(currentDateWithTime);
                        if(newdate.isBefore(currentDate)){
                          _isPast = true;
                        }else {
                          _isPast = false;
                        }
                        forintializaton = formattedDate;
                        print('date: ${forintializaton.toString()} ${formattedDate}');
                      });
                    }

                  },
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(bottom: 10.0),
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  height: 47,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: MyColors.textColor1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      items: _custName.map<DropdownMenuItem<String>>((dynamic items) {
                        return DropdownMenuItem<String>(
                          alignment: AlignmentDirectional.centerStart,
                          value: items.toString(),
                          child: Container(
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
                              ),
                            ),
                            child: Text(
                              items.toString(),
                              style: MyText.body1(context)!.copyWith(
                                  color: MyColors.textColor1,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      value: _isCustChanged ? _customernamecontroller : null, // Set value to null if _customernamecontroller is empty
                      onChanged: (_customernamecontroller) {
                        setState(() {
                          this._customernamecontroller = _customernamecontroller;
                          print('selected cust${_itemnamecontroller}');
                          _isCustChanged = true;
                        });
                      },
                      hint: Text(_isEdditingMode ? '${widget.customerName}' : 'Customer Name',
                        style: MyText.body1(context)!.copyWith(
                            color: MyColors.textColor1,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      isExpanded: true,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(bottom: 10.0),
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  height: 47,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: MyColors.textColor1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      items:_itemsName.map<DropdownMenuItem<String>>((dynamic items) {
                        return DropdownMenuItem<String>(
                          value: items.toString(),
                          child: Container(
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
                              ),
                            ),
                            child: Text(
                              items.toString(),
                              style: MyText.body1(context)!.copyWith(
                                  color: MyColors.textColor1,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                      value: _isItemeChanged ? _itemnamecontroller : null,
                      onChanged: ( _itemnamecontroller) {
                        setState(() {
                          this._itemnamecontroller = _itemnamecontroller;
                          _isItemeChanged = true;
                          print('item name ${this._itemnamecontroller}');
                        });
                      },
                      hint: Text(_isEdditingMode ? '${_itemnamecontroller}' : 'Item Name',
                        style: MyText.body1(context)!.copyWith(
                            color: MyColors.textColor1,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      isExpanded: true,
                    ),

                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(bottom: 10.0),
                child: TextField(
                  controller: _quantitycontroller,
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.format_list_numbered , color: MyColors.iconColor,),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.textColor1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.textColor1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.all(15),
                    hintText: _isEdditingMode ? _quantitycontroller.text : 'Quantity' ,
                    hintStyle: MyText.body1(context)!.copyWith(
                        color: MyColors.textColor1,
                        fontWeight: FontWeight.w500
                    ),
                  ),

                  style: MyText.body1(context)!.copyWith(
                    color: MyColors.textColor1,
                    fontWeight: FontWeight.w500,
                  ),

                ),
              ),
              Padding(
                padding:  EdgeInsets.only(bottom: 10.0),
                child: TextField(
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons. location_on, color: MyColors.iconColor,),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.textColor1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.textColor1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.all(15),
                    hintText: _isEdditingMode ? _locationcontroller : ((_latitude.isEmpty) ?  'Location' : '${_latitude},${_longtude}') ,
                    hintStyle: MyText.body1(context)!.copyWith(
                        color: MyColors.textColor1,
                        fontWeight: FontWeight.w500
                    ),
                  ),

                ),
              ),

              _isEdditingMode ? GestureDetector(
                onTap: ()  {
                  _getLocation().then((value){
                    setState(() {
                      _locationcontroller = '${_latitude},${_longtude}';
                      _isLocationLoaded =false;
                    });
                  });
                },
                child: _isLocationLoaded ? Container(
                  width: 500,
                  height: 36,
                  child: Center(
                    child: CircularProgressIndicator(color: MyColors.primary,),
                  ),
                ) :Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(left: 30),
                      decoration: BoxDecoration(
                        color: MyColors.textColor2,
                        border: Border.all(width: 1, color:  MyColors.textColor1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.location_on_outlined, color: Colors.white ),
                    ),
                    SizedBox(width: 5,),
                    Text('Update Location', style: MyText.body1(context)!.copyWith(
                        color: MyColors.textColor1,
                        fontWeight: FontWeight.w500
                    ),
                    ),
                  ],
                ),
              ) : _isLocationLoaded ? Container(
                width: double.infinity,
                height: 36,
                child: Center(
                  child: CircularProgressIndicator(color: MyColors.primary,),
                ),
              ) :Text(''),
              Container(height: 35),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 57,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primary,
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_isEdditingMode ? Icons.update : Icons.add),
                          SizedBox(width: 10),
                          Text(
                            _isEdditingMode ? 'Update Sales' : "Add Sale",
                            style: MyText.subhead(context)!.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        setState(() {
                          isAddingOrUpdating = true;
                        });

                        _isEdditingMode ? await _updateSales() : await _addSales();

                        setState(() {
                          isAddingOrUpdating = false;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10,),
                  if (isAddingOrUpdating)
                    Container(
                      width: double.infinity,
                      height: 36,
                      child: Center(
                        child: CircularProgressIndicator(color: MyColors.primary,),
                      ),
                    ),
                ],
              ),

            ],
          ),
        ),
      ),
    ),
  );
}
