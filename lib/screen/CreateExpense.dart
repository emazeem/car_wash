import 'dart:io';

import 'package:carwash/app_url.dart';
import 'package:carwash/constants.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';


class CreateExpensePage extends StatefulWidget {
  @override
  _CreateExpensePageState createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final TextEditingController typeController = TextEditingController();
  final TextEditingController narrationController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool _loading=false;
  XFile? imagePath;
  bool isSelectedFile=false;

  void getImage(String type) async {
    final ImagePicker _picker = ImagePicker();
    imagePath = await _picker.pickImage(
      source: (type == 'gallery') ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 100,
      maxHeight: 1000,
    );
    if (imagePath != null) {
      File file = File(imagePath!.path);
      double temp = file.lengthSync() / (1024 * 1024);
      setState(() {
        isSelectedFile = true;
      });
    } else {
      setState(() {
        isSelectedFile = false;
      });
      Const.toastMessage('Image not selected!');
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    IndexViewModel _indexViewModel=Provider.of<IndexViewModel>(context);

    return Scaffold(
      appBar: Const.appbar('Create Expense'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: 16),
                  Text('Type the Details of Expense'),
                  SizedBox(height: 16),
                  TextField(
                    controller:narrationController,
                    maxLines: 5,
                    decoration: InputDecoration(
                        hintText: 'Narration',
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller:amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                  ),
                  SizedBox(height: 16),

                  for(int i=0;i<Const.ExpenseTypes.length;i++)
                    CheckboxListTile(
                      title: Text('${Const.ExpenseTypes[i]}'),
                      value: Const.ExpenseTypes[i]==typeController.text,
                      onChanged: (value) {
                        setState(() {
                          typeController.text = Const.ExpenseTypes[i];
                        });
                      },
                    ),
                  SizedBox(height: 20),


                  Row(
                    mainAxisAlignment: imagePath==null ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      (imagePath==null)
                          ? Container()
                          : Container(
                        width: Const.wi(context) / 5,
                        height: Const.wi(context) / 5,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey, // Color of the dashed border
                            width: 1, // Width of the dashed border
                          ),
                          borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
                          shape: BoxShape.rectangle,
                        ),
                        child: Image.file(File(imagePath!.path)),
                      ),

                      (imagePath==null) ? InkWell(
                        onTap: (){
                          getImage('gallery');
                        },
                        child: Container(
                          width: Const.wi(context) / 10,
                          height: Const.wi(context) / 10,
                          margin: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // Color of the dashed border
                              width: 1, // Width of the dashed border
                            ),
                            borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
                            shape: BoxShape.rectangle,
                          ),
                          child: Icon(
                            Icons.image,
                            size: 25,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ) : Container(),
                      (imagePath==null)  ? InkWell(
                        onTap: (){
                          getImage('camera');
                        },
                        child: Container(
                          width: Const.wi(context) / 10,
                          height: Const.wi(context) / 10,
                          margin: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // Color of the dashed border
                              width: 1, // Width of the dashed border
                            ),
                            borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
                            shape: BoxShape.rectangle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 25,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ) : Container(),


                      (imagePath==null) ? Container() : Container(
                        padding:EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          onPressed: ()async {
                            setState(() {
                              imagePath=null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey, // Background color
                          ),
                          child: Text('Cancel', style: TextStyle(color: Colors.white)),
                        ),
                      ) ,

                    ],
                  ),


                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Const.primaryColor, // Set the background color to black
                        ),
                        onPressed: ()async {
                          if (typeController.text.isEmpty) {
                            Const.toastMessage('Type is required.');
                          } else if (narrationController.text.isEmpty) {
                            Const.toastMessage('Narration is required.');
                          } else if (amountController.text.isEmpty) {
                            Const.toastMessage('Amount is required.');
                          } else if (imagePath?.path == null) {
                            Const.toastMessage('Image is required.');
                          } else {
                            setState(() { _loading=true; });
                            String path = imagePath!.path;
                            dynamic formData=FormData.fromMap(
                                {
                                  'narration': narrationController.text,
                                  'amount': amountController.text,
                                  'type':typeController.text,
                                  'image': await MultipartFile.fromFile(path, filename: basename(path)),
                                }
                            );
                            uploadFile(context, formData);

                          }
                        },
                        child: Text(_loading ? 'Processing..' : 'Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Dio dio = new Dio();
  uploadFile(context,formData) async {
    String authToken=await ShPref.getAuthToken();
    String uploadUrl = AppUrl.createExpense;
    Response response = await dio.post(
      uploadUrl,
      data: formData,
      options: Options(
        headers: {
          "Accept": "application/json",
          'Authorization': "Bearer " + authToken
        },
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
    setState(() { _loading=false; });
    if (response.statusCode == 200){
      setState(() {
        imagePath=null;
      });
      Navigator.pop(context);
      Const.toastMessage('Expense booked successfully!!');
    } else{
      Const.toastMessage('Something went wrong! Please try again!');
    }
  }
}
