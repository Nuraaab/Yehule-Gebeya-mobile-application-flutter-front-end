import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:testing1213/constant/constant.dart';
import '../models/apiResponse.dart';

Future<ApiResponse> login(String email, String password) async {
  ApiResponse apiResponse =  ApiResponse();

  try{
final response = await http.post(
  Uri.parse(loginUrl),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({"email": email, "password": password}),
);

switch(response.statusCode){
  case 200:
    apiResponse.data = json.decode(response.body);
    apiResponse.token =json.decode(response.body)['token'];
    apiResponse.user_id =json.decode(response.body)['user'][0];
    apiResponse.success = loginSuccess;
    break;
  case 401:
    apiResponse.error = passError;
    break;
  case 400:
    apiResponse.error = emailError;
    break;
  default:
    apiResponse.error = json.decode(response.body)['message'];
    break;
}
  }catch(e){
 apiResponse.error = serverError;
  }

  return apiResponse;
}

Future<ApiResponse> getCustomerName(String? token, int? user_id) async{
  ApiResponse nameResponse = ApiResponse();
  try{
    final response  = await http.get(Uri.parse('${customerUrl}/$user_id'),
        headers: {'Authorization': 'Bearer $token'}
    );
    switch(response.statusCode){
      case 200:
        nameResponse.data = json.decode(response.body);
        break;
      default:
        nameResponse.error = json.decode(response.body)['message'];
        break;
    }
  }catch(e){
    nameResponse.error =serverError;
  }
  return nameResponse;
}

Future<ApiResponse> getItems(String? token) async{
  ApiResponse itemResponse = ApiResponse();
  try{
    final response = await http.get(Uri.parse(itemsUrl),
        headers: {'Authorization': 'Bearer $token'},
    );
    switch(response.statusCode){
      case 200:
        itemResponse.data = json.decode(response.body);
        break;
      default:
        itemResponse.error = json.decode(response.body)['message'];
        break;
    }
  }catch(e){
    itemResponse.error =serverError;
  }
  return itemResponse;
}

Future<ApiResponse> addSale(var body, String? token) async{
  ApiResponse addSaleResponse = ApiResponse();
  try{
    final response = await http.post(Uri.parse(addSalesUrl),
    body: body,
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}
    );
    switch(response.statusCode){
      case 201:
        addSaleResponse.data = json.decode(response.body);
        addSaleResponse.success = "Sales Added $success";
        break;
      default:
        addSaleResponse.error = json.decode(response.body)['message'];
        break;
    }
  }catch(e){
    addSaleResponse.error = serverError;
  }
  return addSaleResponse;
}

Future<ApiResponse> updateSale(var body, String? token, String? sales_id) async {
  ApiResponse updateResponse = ApiResponse();
  try{
    final response = await http.put(Uri.parse('$addSalesUrl/$sales_id'),
    body: body,
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    switch(response.statusCode){
      case 201:
        updateResponse.data = json.decode(response.body);
        updateResponse.success = json.decode(response.body)['message'];
        break;
      default:
        updateResponse.error = json.decode(response.body)['message'];
        break;
    }
  }catch(e){
    updateResponse.error = serverError;
  }
  return updateResponse;
}


Future<ApiResponse> viewSale(int? user_id, String? token) async {
ApiResponse viewResponse = ApiResponse();
try{
  final response = await http.get(Uri.parse('$salesUrl/$user_id'),
      headers: {'Authorization': 'Bearer $token'}
  );
  switch(response.statusCode){
    case 200:
      viewResponse.data = json.decode(response.body);
      break;
    default:
      viewResponse.error = json.decode(response.body)['message'];
      break;
  }
}catch(e){
  viewResponse.error =serverError;
}
return viewResponse;
}

Future<ApiResponse> viewCustomer(int? user_id, String? token) async {
  ApiResponse viewCustomerResponse = ApiResponse();
  try{
    final response = await http.get(Uri.parse('$customerUrl/$user_id'),
        headers: {'Authorization': 'Bearer $token'}
    );
    switch(response.statusCode){
      case 200:
        viewCustomerResponse.data = json.decode(response.body);
        break;
      default:
        viewCustomerResponse.error = json.decode(response.body)['message'];
        break;
    }
  }catch(e){
    viewCustomerResponse.error = serverError;
  }
  return viewCustomerResponse;
}
Future<ApiResponse> logout(String? token) async {
  ApiResponse logoutResponse = ApiResponse();
  try{
    final response = await http.post(Uri.parse(logoutUrl),
        headers: {'Content-Type':'application/json','Authorization': 'Bearer $token'}
    );
    switch(response.statusCode){
      case 200:
        logoutResponse.success = 'You are Logged out $success';
        break;
      default:
        logoutResponse.error = 'Error on LogOut';
        break;
    }
  }catch(e){
    print('error :$e');
    logoutResponse.error =serverError;
  }
  return logoutResponse;
}

Future<ApiResponse> addCustomers(var body, String? token, int? user_id) async {
  ApiResponse addCustomerResponse = ApiResponse();
  try{
    final response  = await http.post(Uri.parse(customerUrl),
    body: body,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    switch(response.statusCode){
      case 200:
        addCustomerResponse.data = json.decode(response.body);
        addCustomerResponse.success = json.decode(response.body)['message'];
        break;
      default:
        addCustomerResponse.error = json.decode(response.body)['message'];
        break;
    }
  }catch(e){
    addCustomerResponse.error = e as String?;
  }
  return addCustomerResponse;
}


Future<ApiResponse>  updateCustomers(var body, String? token, String? customer_id) async {
  ApiResponse updateCustomerResponse = ApiResponse();
try{
  final response = await http.put(Uri.parse('$updateCustomerUrl/$customer_id'),
    body: body,
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
  );
  switch(response.statusCode){
    case 200:
      updateCustomerResponse.data =json.decode(response.body);
      updateCustomerResponse.success = json.decode(response.body)['message'];
      break;
    default:
      updateCustomerResponse.error = json.decode(response.body)['message'];
      break;
  }
}catch(e){
  updateCustomerResponse.error= e as String?;
}
return updateCustomerResponse;
}