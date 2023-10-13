import 'dart:io';

import 'package:carwash/app_url.dart';
import 'package:carwash/constants.dart';
import 'package:carwash/model/Customer.dart';
import 'package:carwash/model/Product.dart';
import 'package:carwash/model/Subscription.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:carwash/apis/api_response.dart';

class CreateCar extends StatefulWidget {

  final Customer customer;
  CreateCar({required this.customer});

  @override
  _CreateCarState createState() => _CreateCarState();
}

class _CreateCarState extends State<CreateCar> {
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();
  int? selectedSubscription = 0;
  List<Subscription?> subscriptions=[];
  List<String>? sundays=[];

  bool showTimeWidget=false;

  Future<void> _pullSubscriptions() async {
    Provider.of<IndexViewModel>(this.context, listen: false).fetchSubscriptions({});
  }
  Future<void> _pullSundays() async {
    Provider.of<IndexViewModel>(this.context, listen: false).set4Sundays([]);
    Provider.of<IndexViewModel>(this.context, listen: false).fetch4Sundays();
  }

  bool _isLoading=false;
  Map<int, dynamic> selectedDateTimeMap = {};
  List<DateTime?> selectedDates=[];
  List<bool> _insideWash=[false,false,false,false,];
  List<bool> _outsideWash=[false,false,false,false,];


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
      Provider.of<IndexViewModel>(this.context, listen: false).setSubscriptions([]);
      _pullSubscriptions();
      _pullSundays();
    });
    super.initState();
  }
  @override
  void dispose() {
    makeController.dispose();
    modelController.dispose();
    plateNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IndexViewModel _indexViewModel=Provider.of<IndexViewModel>(context);
    subscriptions = _indexViewModel.getSubscriptionList;
    sundays = _indexViewModel.get4Sundays;

    return Scaffold(
      appBar: Const.appbar('Add New Car'),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Car Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            TextField(
              controller: makeController,
              decoration: InputDecoration(labelText: 'Make of Car'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: modelController,
              decoration: InputDecoration(labelText: 'Model of Car'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: plateNumberController,
              decoration: InputDecoration(labelText: 'Plate Number'),
            ),
            SizedBox(height: 40),

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
                      primary: Colors.grey, // Background color
                    ),
                    child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                ) ,

              ],
            ),

            Divider(),
            SizedBox(height: 16),
            Text(
              'Select Subscription:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),

            if(_indexViewModel.getStatus.status ==  Status.IDLE)...[
            if(subscriptions.length==0)
              Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Text('No Subscription',textAlign: TextAlign.center,),
                ),
              )
            else
              for(int i=0;i<subscriptions.length;i++)
                CheckboxListTile(
                  title: Text('${subscriptions[i]!.title} (${subscriptions[i]!.price} SAR)'),
                  value: subscriptions[i]!.id == selectedSubscription,
                  onChanged: (value) {
                    setState(() {
                      showTimeWidget=true;
                      selectedSubscription = subscriptions[i]!.id;
                    });
                  },
                ),
            SizedBox(height: 20),

            Visibility(
              visible: showTimeWidget,
              child: Text(
                'Select Date and Time:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),


            Visibility(
              visible: showTimeWidget,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: selectedSubscription == 3 ? 1:sundays!.length,
                itemBuilder: (context, index) {
                  DateTime selectedDateTime = DateTime.parse(sundays![index]);
                  if(selectedDates.length<4){
                    selectedDates.add(selectedDateTime);
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDateTime,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                selectedDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                selectedDates[index] = selectedDateTime;


                                for(int x=0;x<selectedDates.length;x++){
                                  selectedDates[x]=DateTime(
                                    selectedDates[x]!.year,
                                    selectedDates[x]!.month,
                                    selectedDates[x]!.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                }

                              });
                            }
                          }
                        },
                        child: Text(
                            DateFormat('yyyy-MM-dd').add_jm().format(selectedDates[index]!)
                        ),
                      ),
                      InkWell(
                        onTap:(){
                          setState(() {
                            _insideWash[index]=!_insideWash[index];
                          });
                        },
                        child: Container(
                          color:_insideWash[index] ? Colors.greenAccent : Colors.grey.shade300,
                          padding:EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Text('Inside'),
                              Icon(
                                _insideWash[index] ? Icons.check_box :
                                Icons.check_box_outline_blank,size: 14,),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap:(){
                          setState(() {
                            _outsideWash[index]=!_outsideWash[index];
                          });
                        },
                        child: Container(
                          color:_outsideWash[index] ? Colors.greenAccent : Colors.grey.shade300,
                          padding:EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Text('Outside'),
                              Icon(
                                _outsideWash[index] ? Icons.check_box :
                                Icons.check_box_outline_blank,size: 14,),
                            ],
                          ),
                        ),
                      ),


                    ],
                  );
                },
              ),

            ),





          ]
          else if (_indexViewModel.getStatus.status == Status.BUSY)...[
            Container(
              width: Const.wi(context),
              padding: EdgeInsets.all(20),
              child:   Const.LoadingIndictorWidtet(),
            ),
          ],


            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async{
                    String formattedDateTime = '';
                    int take = (selectedSubscription==3) ? 1 : 4;
                    selectedDates.take(take).forEach((dateTime) {
                      String date = DateFormat('yyyy-MM-dd').format(dateTime!);
                      String time = DateFormat('HH:mm').format(dateTime);
                      formattedDateTime += '$date#$time@';
                    });

                    if (makeController.text.isEmpty) {
                      Const.toastMessage('Make of card is required.');
                    } else if (modelController.text.isEmpty) {
                      Const.toastMessage('Model of car is required.');
                    } else if (plateNumberController.text.isEmpty) {
                      Const.toastMessage('Plate no. is required.');
                    } else if (selectedSubscription==0) {
                      Const.toastMessage('Subscription is required to be selected.');
                    } else {
                      if(!_isLoading){
                        setState(() { _isLoading=true; });
                        String path = imagePath!.path;
                        dynamic formData=FormData.fromMap({
                          'make': makeController.text,
                          'model': modelController.text,
                          'plate': plateNumberController.text,
                          'date_time': formattedDateTime,
                          'inside': _insideWash.map((value) => '${value}@').join(),
                          'outside': _outsideWash.map((value) => '${value}@').join(),
                          'user_id': widget.customer.id.toString(),
                          'subscription_id': selectedSubscription.toString(),
                          'image': await MultipartFile.fromFile(path, filename: basename(path)),
                        });
                        await createCar(context, formData);
                        setState(() { _isLoading=false; });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black, // Set background color to black
                  ),
                  child: Text(
                    _isLoading?'Processing..':'Submit',
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



  Dio dio = new Dio();
  createCar(context,formData) async {
    String authToken=await ShPref.getAuthToken();
    String uploadUrl = AppUrl.createCarSubscription;
    try{
      Response response = await dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            'Authorization': "Bearer " + authToken
          },
          receiveTimeout: 200000,
          sendTimeout: 200000,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      setState(() { _isLoading=false; });
      if (response.statusCode == 200){
        setState(() {
          imagePath=null;
        });
        Navigator.pop(context);
        Const.toastMessage('Car booked successfully!!');
      } else{
        Const.toastMessage('Something went wrong! Please try again!');
      }
    }catch(e){
      setState(() { _isLoading=false; });
      Const.toastMessage('Something went wrong! Please try again!');
      print(e);
    }

  }
}
