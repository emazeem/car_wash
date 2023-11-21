import 'dart:io';

import 'package:carwash/apis/api_response.dart';
import 'package:carwash/app_url.dart';
import 'package:carwash/constants.dart';
import 'package:carwash/model/Task.dart';
import 'package:carwash/model/User.dart';
import 'package:carwash/screen/Image.dart';
import 'package:carwash/screen/ShowLocation.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';


class TaskScreen extends StatefulWidget {
  final Task? task;
  TaskScreen({required this.task});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {

  
  Task? task;
  Future<void> _pullTask() async {
    Provider.of<IndexViewModel>(this.context, listen: false).setTask(Task());
    Provider.of<IndexViewModel>(this.context, listen: false).fetchTask({'id': widget.task?.id.toString()});
  }
  XFile? imagePath;
  bool isSelectedFile=false;

  String selectedTab='Customer';
  String? selectedImageType;

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
  List<String> tabs=['Customer','Payment','Wash Status'];

  String? authRole;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authRole= await ShPref.getAuthRole();
      await _pullTask();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    IndexViewModel _indexViewModel=Provider.of<IndexViewModel>(context);
    task=_indexViewModel.getTask;

    return Scaffold(
      appBar: Const.appbar('Task Details'),
      body: RefreshIndicator(
        onRefresh: ()async{
          await _pullTask();
        },
        child: Container(
          width: Const.wi(context),
          height: Const.hi(context),
          child: ListView(
            children: [
              Container(
                width: double.infinity,
                child: Container(
                  child:
                  (_indexViewModel.getStatus.status == Status.IDLE)
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Image.network('${AppUrl.url}storage/car/${task?.order?.car?.image}',width: double.infinity,height: 200,fit: BoxFit.cover,),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 13),
                                decoration: BoxDecoration(
                                    color: task?.status == TaskStatus.pending ? Colors.blue.shade50 : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child:Text('${task?.status == TaskStatus.pending ? 'Pending' : 'Complete'}',
                                  style: TextStyle(color: Colors.black),)
                            ),
                          ),


                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${task?.order?.car?.make}',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20,color: Colors.white),),
                            Text('${task?.order?.car?.model} -  ${task?.order?.car?.plate}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white)),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  for(var b=0;b<tabs.length;b++)
                                    InkWell(
                                      onTap:(){
                                        setState(() {
                                          selectedTab=tabs[b];
                                        });
                                      },
                                      child: Container(
                                        width:Const.wi(context)/3,
                                        decoration:BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                  color: selectedTab==tabs[b]?Colors.black:Colors.grey,
                                                )
                                            )
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text('${tabs[b]}',style: TextStyle(fontWeight: selectedTab==tabs[b]? FontWeight.bold :FontWeight.normal,fontSize: 20,color: Colors.black),textAlign: TextAlign.center,),
                                          ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if(selectedTab=='Customer')
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Container(
                                      padding:EdgeInsets.symmetric(vertical:10),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 0.5
                                          )
                                        )
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Name',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),),
                                          Text('${task?.order?.user?.name}',style: TextStyle(fontSize: 20),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:EdgeInsets.symmetric(vertical:10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 0.5
                                              )
                                          )
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Phone',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),),

                                          InkWell(
                                              onTap: () async{
                                                String phone='${task?.order?.user?.phone}';
                                                try{
                                                  final call = Uri.parse('tel:${phone}');
                                                  if (await canLaunchUrl(call)) {
                                                    launchUrl(call);
                                                  } else {
                                                    Const.toastMessage('Phone format not correct');
                                                  }
                                                }catch(e){
                                                  Const.toastMessage('Phone format not correct');
                                                }
                                              },
                                              child: Text('${task?.order?.user?.phone}',style: TextStyle(fontSize: 20),)
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      padding:EdgeInsets.symmetric(vertical:10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 0.5
                                              )
                                          )
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Address',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),),
                                          InkWell(
                                              onTap: ()async{
                                                String url = '${task?.order?.user?.location}';
                                                if (await canLaunch(url)) {
                                                  await launch(url);
                                                } else {
                                                  Const.toastMessage('Something went wrong');
                                                }
                                              },
                                              child: Container(
                                                width: Const.wi(context)/1.5,
                                                child:Text('${task?.order?.user?.location}',overflow: TextOverflow.fade,style: TextStyle(fontSize: 20),textAlign: TextAlign.right,)
                                              )
                                          )
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            if(selectedTab=='Payment')
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Container(
                                      padding:EdgeInsets.symmetric(vertical:10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 0.5
                                              )
                                          )
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Order #',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),),
                                          Text('${task?.order?.id.toString().padLeft(4, '0')}',style: TextStyle(fontSize: 20),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:EdgeInsets.symmetric(vertical:10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 0.5
                                              )
                                          )
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Status',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),),
                                          Text(task?.order?.payment == OrderPayment.pending ? 'Pending' : 'Done',style: TextStyle(fontSize: 20),),
                                        ],
                                      ),
                                    ),
                                    if(task?.order?.payment == OrderPayment.complete)
                                    Container(
                                      padding:EdgeInsets.symmetric(vertical:10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 0.5
                                              )
                                          )
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Payment Date',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),),
                                          Text('${task?.order?.payment_date}',style: TextStyle(fontSize: 20),),
                                        ],
                                      ),
                                    ),


                                    if(task?.order?.payment == OrderPayment.pending)
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: imagePath==null ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            if(imagePath!=null && selectedImageType=='order')
                                              Container(
                                                width: Const.wi(context) / 5,
                                                height: Const.wi(context) / 5,
                                                padding: EdgeInsets.all(10),
                                                margin: EdgeInsets.only(left: 10),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey, width: 1),
                                                  borderRadius: BorderRadius.circular(8),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Image.file(File(imagePath!.path)),
                                              ),
                                            if(imagePath==null)
                                              InkWell(
                                                onTap: (){
                                                  getImage('gallery');
                                                  setState(() {
                                                    selectedImageType='order';
                                                  });
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
                                              ),
                                            if(imagePath==null)
                                              InkWell(
                                                onTap: (){
                                                  getImage('camera');
                                                  setState(() {
                                                    selectedImageType='order';
                                                  });
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
                                              ),
                                            Row(
                                              children: [
                                                if(imagePath!=null && selectedImageType=='order')
                                                  Container(
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
                                                  ),
                                                if(imagePath!=null && selectedImageType=='order')
                                                  Container(
                                                    padding:EdgeInsets.only(top: 10),
                                                    margin: EdgeInsets.only(left: 10),
                                                    child: ElevatedButton(
                                                      onPressed: ()async {
                                                        uploadFile(context,'receipt',task?.order?.id);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        primary: Colors.black, // Background color
                                                      ),
                                                      child: Text('Upload', style: TextStyle(color: Colors.white)),
                                                    ),
                                                  ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),

                                    if(task?.order?.receipt != null)
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Image.network(
                                          Const.getReceiptPath(task?.order?.receipt),width: Const.wi(context)/3,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container();
                                          },
                                        )
                                      ),

                                    if(task?.order?.receipt!=null )...[
                                      if(task?.order?.payment == OrderPayment.pending)
                                        Container(
                                          margin: EdgeInsets.only(right: 16.0),
                                          child: ElevatedButton(
                                            onPressed: ()async {
                                              await _indexViewModel.markPaymentAsDone({'id':'${task?.order?.id}'});
                                              _pullTask();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.black, // Background color
                                            ),
                                            child: Text('Mark Order # ${task?.order?.id.toString().padLeft(4, '0')} as Paid', style: TextStyle(color: Colors.white)),
                                          ),
                                      )
                                    ]
                                  ],
                                ),
                              ),

                            if(selectedTab=='Wash Status')
                              Container(
                                padding:EdgeInsets.all(10),
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if(task?.inside_wash==1 && task?.outside_wash==1) Text('Inside and Outside Wash',style: TextStyle(color: Colors.green,fontSize: 17),textAlign: TextAlign.left,),
                                    if(task?.outside_wash==1 && task?.inside_wash==0) Text('Only Outside Wash',style: TextStyle(color: Colors.green,fontSize: 17),textAlign: TextAlign.left,),
                                    if(task?.outside_wash==0 && task?.inside_wash==1) Text('Only Inside Wash',style: TextStyle(color: Colors.green,fontSize: 17),textAlign: TextAlign.left,),
                                    if(task?.status == TaskStatus.pending && authRole ==  Role.technician)
                                        Row(
                                            mainAxisAlignment: imagePath==null ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              if(imagePath!=null && selectedImageType=='task')
                                                  Container(
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
                                              if(imagePath==null)
                                                InkWell(
                                                  onTap: (){
                                                    getImage('gallery');
                                                    setState(() {
                                                      selectedImageType='task';
                                                    });
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
                                                ),
                                              if(imagePath==null)
                                                InkWell(
                                                onTap: (){
                                                  getImage('camera');
                                                  setState(() {
                                                    selectedImageType='task';
                                                  });
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
                                              ),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    if(imagePath!=null && selectedImageType=='task')
                                                      Container(
                                                      padding:EdgeInsets.only(top: 10),
                                                      child: ElevatedButton(
                                                        onPressed: ()async {
                                                          setState(() { imagePath=null; });
                                                        },
                                                        style: ElevatedButton.styleFrom( primary: Colors.grey),
                                                        child: Text('Cancel', style: TextStyle(color: Colors.white)),
                                                      ),
                                                    ),
                                                      SizedBox(width: 10,),
                                                    if(imagePath!=null && selectedImageType=='task')
                                                      Container(
                                                        padding:EdgeInsets.only(top: 10),
                                                        child: ElevatedButton(
                                                            onPressed: ()async {
                                                              uploadFile(context,'task',task?.id);
                                                            },
                                                            style: ElevatedButton.styleFrom(primary: Colors.black,),
                                                            child: Text('Upload', style: TextStyle(color: Colors.white)),
                                                          ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                    SizedBox(height: 10,),
                                    if(task!.images!.length == 0)
                                      Container(
                                        width: Const.wi(context),
                                        margin: EdgeInsets.only(top: 20),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image,size: 100,color: Colors.grey,),
                                            Text('No wash image uploaded',textAlign: TextAlign.center,style: TextStyle(color: Colors.grey,fontSize: 20),),
                                          ],
                                        ),
                                      )
                                    else
                                      SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children:[
                                          for(int f=0;f< task!.images!.length; f++)
                                            Container(
                                              width: Const.wi(context)/3,
                                              height: Const.wi(context)/3,
                                              padding: EdgeInsets.all(5),
                                              child: InkWell(
                                                  onTap: (){
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage('${task!.images![f]}')));
                                                  },
                                                  child: Image.network('${task!.images![f]}',fit: BoxFit.cover,)
                                              ),
                                              //child: Text('${task!.images![f]}'),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if(task?.status == TaskStatus.pending && task!.images!.length > 0)...[
                                      if(authRole == Role.technician)
                                        Container(
                                          margin: EdgeInsets.all(10),
                                          child: ElevatedButton(
                                            onPressed: ()async {
                                              await _indexViewModel.taskMarkAsDone({'id':'${task?.id}'});
                                              _pullTask();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.black, // Background color
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text('Mark as washed', style: TextStyle(color: Colors.white)),
                                                SizedBox(width: 10,),
                                                Icon(Icons.check_circle,size: 14,),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ]
                                  ],
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  )
                  : Container(
                    height: Const.hi(context)-100,
                    child: Center(
                      child: Const.LoadingIndictorWidtet(),
                    ),
                  ),
                ),
              )
            ]
          ),
        ),
      ),
    );

  }




  Dio dio = new Dio();
  uploadFile(context,type,id) async {
    String authToken=await ShPref.getAuthToken();
    String uploadUrl = type=='receipt'? AppUrl.uploadReceipt : AppUrl.uploadTaskImage;
    var formData;
    if (imagePath != null) {
      String path;
      path = imagePath!.path;
      formData = FormData.fromMap(
        {
          'id':'${id}',
          'image': await MultipartFile.fromFile(path, filename: basename(path)),
        },
      );
    } else {
      Const.toastMessage('Please select image to upload');
    }

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

    if (response.statusCode == 200){
      setState(() {
        imagePath=null;
      });
      await _pullTask();
      Const.toastMessage('Image is uploaded!');
    } else{
      Const.toastMessage('Something went wrong! Please try again!');
    }
  }



}