import 'package:carwash/constants.dart';
import 'package:carwash/screen/Login.dart';
import 'package:carwash/screen/Register.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[

              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  Const.logo,
                                  width: Const.wi(context)/2,
                                  height: Const.wi(context)/2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size((MediaQuery.of(context).size.width / 2.3), 70),
                                  backgroundColor:Const.primaryColor,
                                  textStyle: TextStyle(color: Colors.black, fontSize: 22),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(50))),
                              child: Text('Sign Up'),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                              },
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size((Const.wi(context) / 2.3), 70),
                                  backgroundColor: Colors.white,
                                  textStyle: TextStyle(color: Colors.black, fontSize: 22),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                  ),
                              ),
                              child: Text('Sign In'),
                              onPressed: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
