import 'package:carwash/constants.dart';
import 'package:carwash/screen/Layout.dart';
import 'package:carwash/screen/Register.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = true;
  bool _loading=false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {


      final String? token = await ShPref.getAuthToken();
      if (token!='') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CWLayout()));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    IndexViewModel _indexViewModel=Provider.of<IndexViewModel>(context);


    return Scaffold(
      body: Container(
        height: Const.hi(context),
        child: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 40),
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Image.asset(
                  Const.logo,
                  width: Const.wi(context) / 2,
                  height: Const.wi(context) / 2,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email / Phone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          child: new Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),

                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size((MediaQuery.of(context).size.width / 3), 60),
                      primary: Const.primaryColor,
                      onPrimary: Colors.white,
                      textStyle: TextStyle(color: Colors.black, fontSize: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(_loading ? 'Loading..' : 'Login'),
                    onPressed: () async{
                      if (_emailController.text.isEmpty) {
                        Const.toastMessage('Email is required.');
                      } else if (_passwordController.text.isEmpty) {
                        Const.toastMessage('Password is required.');
                      } else {
                        if(!_loading){
                          setState(() { _loading = true; });
                          Map<String,dynamic> data = {
                            'email': _emailController.text,
                            'password': _passwordController.text,
                          };
                          try{
                            Map response=await _indexViewModel.loginApi(data);
                            print(response['data']['user']);
                            print(response['data']['token']);
                            ShPref.saveAuthToken(response['data']['token']);
                            ShPref.saveAuthId(response['data']['user']['id']);
                            ShPref.saveAuthRole(response['data']['user']['role']);

                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CWLayout()));
                          }catch(e){
                            print('e');
                          }
                          setState(() { _loading = false; });
                        }
                      }

                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            TextButton(
              onPressed: () {
                // Navigate to registration page
                // For example:
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: Text("Don't have an account? Register here",style: TextStyle(color: Const.primaryColor),),
            ),

          ],
        ),
      ),
    );
  }
}
