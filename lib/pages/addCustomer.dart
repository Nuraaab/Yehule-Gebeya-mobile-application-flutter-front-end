import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing1213/pages/connectionError.dart';
import 'package:testing1213/pages/viewCustomers.dart';
import 'package:testing1213/service/services.dart';
import 'package:testing1213/service/user_service.dart';
import 'package:testing1213/widget/snackbar.dart';
import '../data/my_colors.dart';
import '../models/apiResponse.dart';
import '../widget/my_text.dart';
import '../widget/navigation_drawer.dart';

class AddCustomer extends StatefulWidget {
  Map<String, dynamic>? customer;
  AddCustomer({super.key,this.customer});

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {

  @override
  void  initState(){
    super.initState();
    _getEdditingStatus().then((_){
      setEdditingData();
    });
  }
  String gender = 'male';
  bool _isLodding = false;
  bool _isEdditingMode = false;
  String? _customer_id;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _stateController  = TextEditingController();
  final TextEditingController _subCityController = TextEditingController();
  final TextEditingController _woredaController = TextEditingController();
  final TextEditingController _kebelController = TextEditingController();
  final TextEditingController _tinNumberController = TextEditingController();
   _getEdditingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isEdditingMode = prefs.getBool('editcust') ?? false;
    setState(() {
      _isEdditingMode =isEdditingMode;
    });
  }
  void setEdditingData() {
    if(_isEdditingMode){
      _customer_id = widget.customer?['customer_id'];
      _fullNameController.text = widget.customer?['name'];
      _emailController.text = widget.customer?['email'];
      _phoneController.text = widget.customer?['phone_number'];
      _stateController.text = widget.customer?['state'];
      _subCityController.text = widget.customer?['sub_city'];
      _woredaController.text = widget.customer?['woreda'];
      _kebelController.text = widget.customer?['kebele'];
      _tinNumberController.text = widget.customer?['tin_number'];
      gender = widget.customer!['gender'].toString();
    }
  }
  Future<void> addCustomer() async{
    if(_fullNameController.text == ''){
      snackBar.show(
          context,"Full Name Required.", Colors.red);
    }else if(_emailController.text == ''){
      snackBar.show(
          context,"Email Required.", Colors.red);
    }else if(_phoneController.text == ''){
      snackBar.show(
          context,"Phone Number Required.", Colors.red);
    }else if(_stateController.text == ''){
      snackBar.show(
          context,"State Required.", Colors.red);
    }else if(_subCityController.text == ''){
      snackBar.show(
          context,"Sub-City Required.", Colors.red);
    }else if(_woredaController.text == ''){
      snackBar.show(
          context,"Woreda Required.", Colors.red);
    }else if(_kebelController.text == ''){
      snackBar.show(
          context,"Kebele Required.", Colors.red);
    }else if(_tinNumberController.text == ''){
      snackBar.show(
          context,"Tin Number Required.", Colors.red);
    }else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('user_email') ?? '';
      String? userPassword = prefs.getString('user_password') ?? '';
      ApiResponse loginResponse  = await login(userEmail, userPassword);
      if(loginResponse.error == null){
        String? token = loginResponse.token;
        int? user_id = loginResponse.user_id;
        var body = jsonEncode({
          'name':_fullNameController.text,
          'email': _emailController.text,
          'phone_number': _phoneController.text,
          'state': _stateController.text,
          'sub_city': _subCityController.text,
          'woreda': _woredaController.text,
          'kebele': _kebelController.text,
          'gender': gender.toString(),
          'agent_id':user_id,
          'tin_number':_tinNumberController.text,
        });
        ApiResponse addCustomerResponse = await addCustomers(body, token, user_id);
         if(addCustomerResponse.error == null){
           setState(() {
             _isLodding =false;
           });
           snackBar.show(
               context,"${addCustomerResponse.success}", Colors.green);
           Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ViewCustomers()));
         }else{
             setState(() {
               _isLodding =false;
           });
             snackBar.show(
                 context,"Something went wrong. Please try again", Colors.red);
         }
      }else{
        setState(() {
          _isLodding =false;
        });
        snackBar.show(
            context,"Something went wrong. Please try again", Colors.red);
      }
    }
  }
  Future<void> updateCustomer() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('user_email') ?? '';
    String? userPassword = prefs.getString('user_password') ?? '';
    ApiResponse loginResponse  = await login(userEmail, userPassword);

    if(loginResponse.error == null){
      String? token = loginResponse.token;
      int? user_id = loginResponse.user_id;
      var body = jsonEncode({
        'name':_fullNameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
        'state': _stateController.text,
        'sub_city': _subCityController.text,
        'woreda': _woredaController.text,
        'kebele': _kebelController.text,
        'gender': gender.toString(),
        'agent_id':user_id,
        'tin_number':_tinNumberController.text,
      });
      ApiResponse updateCustomersResponse = await updateCustomers(body, token, _customer_id);
      if(updateCustomersResponse.error == null){
        setState(() {
          _isLodding =false;
        });
        snackBar.show(
            context,"${updateCustomersResponse.success}", Colors.green);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ViewCustomers()));
      }else{
        setState(() {
          _isLodding =false;
        });
        prefs.setBool('editcust', true);
        snackBar.show(
            context,"Something went wrong. Please try again", Colors.red);
      }
    }else{
      setState(() {
        _isLodding =false;
      });
      prefs.setBool('editcust', true);
      snackBar.show(
          context,"Something went wrong. Please try again", Colors.red);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawerWidget(),
      appBar: AppBar(
        elevation: 0,
        title:  Text(_isEdditingMode ? 'Update Customers':'Add Customers',
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        scrollDirection: Axis.vertical,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 30,),
                Padding(
                  padding:  EdgeInsets.only(bottom: 10.0),
                  child: TextField(
                    obscureText: false,
                    controller: _fullNameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline_outlined , color: MyColors.iconColor,),
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
                      hintText: 'Full Name',
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
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined , color: MyColors.iconColor,),
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
                      hintText: 'Email',
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
                    controller: _phoneController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone_outlined , color: MyColors.iconColor,),
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
                      hintText: 'Phone Number',
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
                    controller: _stateController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.place_outlined , color: MyColors.iconColor,),
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
                      hintText: 'State',
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
                    controller: _subCityController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_city , color: MyColors.iconColor,),
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
                      hintText: 'Sub-City',
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
                    controller: _woredaController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_on , color: MyColors.iconColor,),
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
                      hintText: 'Woreda',
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
                    controller: _kebelController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_city , color: MyColors.iconColor,),
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
                      hintText: 'Kebele',
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
                    controller: _tinNumberController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.credit_card , color: MyColors.iconColor,),
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
                      hintText: 'Tin Number',
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
                        items:const [
                          DropdownMenuItem(value: 'male',child: Text('Male'),),
                          DropdownMenuItem(value: 'female',child: Text('Female'),),
                        ],

                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                        hint: Text('Gender',
                          style: MyText.body1(context)!.copyWith(
                              color: MyColors.textColor1,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        isExpanded: true,
                        value:gender,
                        onChanged: (String? value) {
                          setState(() {
                            gender = value!;
                            print('gender: $gender');
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
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
                            Icon( _isEdditingMode ? Icons.update : Icons.add),
                            SizedBox(width: 10),
                            Text(_isEdditingMode ? "Update Customer" :"Add Customers",
                              style: MyText.subhead(context)!.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          setState(() {
                            _isLodding =true;
                          });
                          _isEdditingMode ? updateCustomer() : addCustomer();
                          setState(() {
                            _isLodding =false;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 10,),
                    if(_isLodding)
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
}
