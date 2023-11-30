import 'package:carwash/app_url.dart';
import 'package:carwash/screen/Login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Role{
  static String manager='manager';
  static String customer='customer';
  static String technician='technician';
}
class TaskStatus{
  static int pending=0;
  static int complete=1;
}
class OrderPayment{
  static String pending='0';
  static String complete='1';
}
class SubscriptionType{
  static String oneTime='0';
  static String recurring='1';
}

class TaskApprovalActions{
  static String pending='0';
  static String approved='1';
  static String rescheduleRequested='2';
  static String rescheduled='3';
}




class ShPref{
  static saveAuthToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Const.authToken,key);
  }
  static saveAuthId(int key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(Const.authId,key);
  }
  static saveAuthRole(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Const.authRole,key);
  }
  static storeDeviceId(String? id)async{
    final pprefs = await SharedPreferences.getInstance();
    pprefs.remove('user-device-id');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user-device-id', id ?? '');
  }
  static getDeviceId()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user-device-id');
  }




  static getAuthToken()async{
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString(Const.authToken) ?? '';
    return token;
  }

  static getAuthId()async{
    final prefs = await SharedPreferences.getInstance();
    final int id = prefs.getInt(Const.authId) ?? 0;
    return id;
  }
  static getAuthRole()async{
    final prefs = await SharedPreferences.getInstance();
    final String role = prefs.getString(Const.authRole) ?? '';
    return role;
  }





  static logout(context)async{
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(Const.authToken);
    prefs.remove(Const.authId);
    prefs.remove(Const.authRole);
    Const.toastMessage('Logout successful');
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        LoginPage()), (Route<dynamic> route) => false);
  }
}
class Const{

  static String authToken='auth-token';
  static String authId='auth-id';
  static String authRole='auth-role';
  static String CHECKOUT_PUBLIC_KEY='pk_sbox_ha5eozx3ipt7z6l73xqmncc3uus';
  static List<String> ExpenseTypes=['Repair','Oil Change','Gas','Accessories','Water','Others'];
  static String ONE_SIGNAL_APP_ID='f92a3eeb-ed75-4b6b-ba23-1ae05f7540e6';

  static var logo = 'assets/logo.png';
  static Color primaryColor = const Color(0XFF000000);

  static LoadingIndictorWidtet({size = 20.0}) {
    return Center(
      child: Container(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          semanticsLabel: 'Circular progress indicator',
          color: Colors.black,
        ),
      ),
    );
  }
  static wi(context){
    return MediaQuery.of(context).size.width;
  }


  static hi(context){
    return MediaQuery.of(context).size.height;
  }
  static getReceiptPath(image){
    return AppUrl.url+'storage/receipt/'+image;
  }

  static appbar(String title){
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Const.primaryColor,
      title: Text(title,style: TextStyle(color: Colors.white),),
    );
  }
  static toastMessage(String message) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

}