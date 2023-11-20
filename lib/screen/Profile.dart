import 'package:carwash/apis/api_response.dart';
import 'package:carwash/constants.dart';
import 'package:carwash/model/User.dart';
import 'package:carwash/screen/HomeLocation.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? role;
  User? authUser;
  int? authId;
  bool _loading=false;

  Future<void> _pullAuthUser() async {
    Provider.of<IndexViewModel>(context, listen: false).setUser(User());
    Provider.of<IndexViewModel>(context, listen: false).fetchUser();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authId=await ShPref.getAuthId();
      _pullAuthUser();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    IndexViewModel _indexViewModel=Provider.of<IndexViewModel>(context);
    authUser=_indexViewModel.getUser;
    nameController.text='${authUser?.name}';
    emailController.text='${authUser?.email}';
    phoneController.text='${authUser?.phone}';
    addressController.text='${authUser?.address}';
    role=authUser?.role;



    return SingleChildScrollView(
      child:
      (_indexViewModel.getStatus.status == Status.IDLE)?
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ((role) !=null)
                ?Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.amber,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Text('${role?.toUpperCase()}',style: TextStyle(fontWeight: FontWeight.bold),),
                )
                :Container(),
            ],
          ),
          SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/car_wash.jpeg'), // Replace with user's profile image
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              // Implement logic to change profile image
            },
            child: /*Text('Change Profile Picture',style: TextStyle(color: Const.primaryColor),)*/ Container(),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                TextField(
                  controller:nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 16),
                TextField(
                  enabled: false,
                  controller:emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller:phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller:addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /*ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.amber, // Set the background color to black
                      ),
                      onPressed: ()async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeLocationScreen()));
                      },
                      child: Text('My Google Location'),
                    ),*/
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Const.primaryColor, // Set the background color to black
                      ),
                      onPressed: ()async {
                        if (nameController.text.isEmpty) {
                          Const.toastMessage('Name is required.');
                        } else if (phoneController.text.isEmpty) {
                          Const.toastMessage('Phone is required.');
                        } else if (addressController.text.isEmpty) {
                          Const.toastMessage('Address is required.');
                        } else {
                          Map<String, dynamic> data = {
                            'user_id':_indexViewModel.getUser?.id.toString(),
                            'email':emailController.text,
                            'name': nameController.text,
                            'phone': phoneController.text,
                            'address': addressController.text,
                          };
                          if(!_loading){
                            try{
                              setState(() { _loading=true; });
                              Map response=await _indexViewModel.editUser(data);
                            }catch(e){ }
                            setState(() { _loading=false; });
                          }
                        }
                      },
                      child: Text(_loading ? 'Processing..' : 'Save Profile'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ): Container(
        width: double.infinity,
        height: Const.hi(context)-100,
        child: Center(
          child: Const.LoadingIndictorWidtet(),
        ),
      ),
    );
  }
}
