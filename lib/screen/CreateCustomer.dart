import 'package:carwash/constants.dart';
import 'package:carwash/model/Customer.dart';
import 'package:carwash/model/Product.dart';
import 'package:carwash/model/User.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AddCustomerPage extends StatefulWidget {
  @override
  _AddCustomerPageState createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int? selectedTech;
  bool _passwordVisible = true;


  @override
  void initState() {
    _pullTechList();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    phoneController.dispose();
    emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pullTechList() async {
    Provider.of<IndexViewModel>(context, listen: false).setTechniciansList([]);
    Provider.of<IndexViewModel>(context, listen: false).fetchTechniciansList({});
  }
  List<User> _technicians=[];

  @override
  Widget build(BuildContext context) {
    IndexViewModel _indexViewModel=Provider.of<IndexViewModel>(context);
    return Scaffold(
      appBar: Const.appbar('Add Customer'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),


            SizedBox(height: 20),
            Center(
              child:CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/car_wash.jpeg'), // Replace with user's profile image
              ),
            ),


            SizedBox(height: 16),

            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),

            SizedBox(height: 16),

            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: _passwordVisible,
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
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



            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 16),

            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 16),

            InkWell(
              onTap: () {
                _showTechniciansBottomSheet(context,_indexViewModel.getTechniciansList);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Text(selectedTech!=null ? '${_indexViewModel.getTechniciansList.where((element) => element?.id == selectedTech ).first?.name}' : 'Assign to Technician',style: TextStyle(color: Colors.black87),),
              ),
            ),

            SizedBox(height: 20), // Add spacing between sections
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: ()async {
                    if (nameController.text.isEmpty) {
                      Const.toastMessage('Name is required.');
                    } else if (emailController.text.isEmpty) {
                      Const.toastMessage('Email is required.');
                    }else if (_passwordController.text.isEmpty) {
                      Const.toastMessage('Password is required.');
                    }  else if (phoneController.text.isEmpty) {
                      Const.toastMessage('Phone is required.');
                    } else if (locationController.text.isEmpty) {
                      Const.toastMessage('Address is required.');
                    } else if (selectedTech == null) {
                      Const.toastMessage('Assign customer to technician.');
                    } else {
                      Map<String, dynamic> data = {
                        'name': nameController.text,
                        'password': _passwordController.text,
                        'email': emailController.text,
                        'phone': phoneController.text,
                        'address': locationController.text,
                        'role': Role.customer,
                        'group_id': selectedTech.toString(),
                      };
                      await _indexViewModel.registerApi(data);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black, // Set background color to black
                  ),
                  child: Text(
                    'Create Customer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _showTechniciansBottomSheet(BuildContext context,List<Customer?> tech_list) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                    for (int x = 0; x < tech_list.length; x++)
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedTech = tech_list[x]?.id;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          color: selectedTech == tech_list[x]?.id
                              ? Colors.black
                              : Colors.grey.shade200,
                          margin: EdgeInsets.only(top: 2, bottom: 2),
                          child: Text(
                            '${tech_list[x]?.name}',
                            style: TextStyle(
                              color: selectedTech == tech_list[x]?.id
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((value) {
      setState(() {
        selectedTech=selectedTech;
      });
    });
  }
}
