import 'package:carwash/apis/api_response.dart';
import 'package:carwash/app_url.dart';
import 'package:carwash/constants.dart';
import 'package:carwash/model/Car.dart';
import 'package:carwash/model/Customer.dart';
import 'package:carwash/model/Task.dart';
import 'package:carwash/screen/CreateCar.dart';
import 'package:carwash/screen/SingleTask.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class CustomerDetail extends StatefulWidget {
  final Customer customer;
  final int? carId;
  CustomerDetail({required this.customer,this.carId=null});

  @override
  State<CustomerDetail> createState() => _CustomerDetailState();
}

class _CustomerDetailState extends State<CustomerDetail> {

  Future<void> _pullCars() async {
    Provider.of<IndexViewModel>(context, listen: false).fetchCars({'id': widget.customer.id.toString(),'car_id':widget.carId.toString()});
  }

  List<Car?> cars=[];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Provider.of<IndexViewModel>(context, listen: false).setCars([]);
      _pullCars();
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    IndexViewModel _indexViewModel=Provider.of<IndexViewModel>(context);
    cars=_indexViewModel.getCars;

    return Scaffold(
      appBar: Const.appbar('Details of Car Wash'),
      body: RefreshIndicator(
        onRefresh: ()async{
          await _pullCars();
        },
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20,left: 20,bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${widget.customer.name}',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5.0),
                      Container(
                        width: Const.wi(context)/2,
                        child: Text(
                          'Location: ${widget.customer.location}',
                          overflow: TextOverflow.fade,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'Phone: ${widget.customer.phone}',
                        style: TextStyle(fontSize: 16.0),
                      ),

                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateCar(customer: widget.customer,))).then((value) => _pullCars());
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black, // Background color
                    ),
                    child: Text('Add Car', style: TextStyle(color: Colors.white)),
                  ),
                ),

              ],
            ),
            Column(
              children: [
                if(_indexViewModel.getStatus.status ==  Status.IDLE)
                  if(cars.length==0)
                    Center(
                      child: Container(
                        width: double.infinity,
                        child: Text('No Cars',textAlign: TextAlign.center,),
                      ),
                    )
                  else
                    for(int i=0;i<cars.length;i++)
                      Card(
                        elevation: 3.0,
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          width: Const.wi(context),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Column(
                                    children: [
                                      Text('Make',style: TextStyle(fontWeight: FontWeight.bold),),
                                      Text('${cars[i]?.make}'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text('Model',style: TextStyle(fontWeight: FontWeight.bold),),
                                      Text('${cars[i]?.model}'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text('Plate No.',style: TextStyle(fontWeight: FontWeight.bold),),
                                      Text('${cars[i]?.plate}'),
                                    ],
                                  ),

                                ],
                              ),

                              (cars[i]?.image == null)? Container():
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Image.network('${AppUrl.url}storage/car/${cars[i]?.image}',width: 100,),
                                )
                              ),

                              Divider(),
                              (cars[i]?.order?.tasks?.length == 0)
                                  ? Container()
                                  : Container(
                                    height: Const.hi(context)/2,
                                    child: Timeline(
                                      lineColor:Colors.black,
                                      children:[
                                        for (int x = 0; x < (cars[i]?.order?.tasks?.length ?? 0); x++)
                                          TimelineModel(
                                            Container(
                                              margin: EdgeInsets.only(top: 20),
                                            height: 100,
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(bottom: 10),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('Date : ${cars[i]?.order?.tasks?[x].date}'),
                                                          Text('Time : ${cars[i]?.order?.tasks?[x].time}'),
                                                          Row(
                                                              children: [
                                                                Text('Inside'),
                                                                Icon(cars[i]?.order?.tasks?[x].inside_wash==1?Icons.check:Icons.close,size: 15,),
                                                                Text('Outside'),
                                                                Icon(cars[i]?.order?.tasks?[x].outside_wash==1?Icons.check:Icons.close,size: 15,)
                                                              ]
                                                          ),

                                                          if(cars[i]?.order?.tasks?[x].approval ==TaskApprovalActions.rescheduleRequested)
                                                          Container(
                                                            width: Const.wi(context)/2,
                                                            child: Text('${cars[i]?.order?.tasks?[x].comments}',style: TextStyle(color: Colors.red),overflow: TextOverflow.fade,),
                                                          )

                                                        ],
                                                      )
                                                    ),
                                                    (cars[i]?.order?.tasks?[x].images?.length == 0) ? Container() :
                                                    SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: Row(
                                                        children: [
                                                          for (int ii = 0; ii < (cars[i]?.order?.tasks?[x].images?.length ?? 0); ii++)
                                                            Container(
                                                              width: Const.wi(context)/8,
                                                              height: Const.wi(context)/8,
                                                              child: Image.network('${cars[i]?.order?.tasks?[x].images?[ii]}'),
                                                              //child: Text('${task!.images![f]}'),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                InkWell(
                                                  onTap: (){
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SingleTaskScreen(id: cars[i]?.order?.tasks?[x].id.toString()))).then((value) => _pullCars());

                                                  },
                                                  child:  Icon(Icons.edit,),
                                                ),
                                                Icon(Icons.check_circle_outline,color: cars[i]?.order?.tasks?[x].status == TaskStatus.pending ? Colors.black: Colors.green,),
                                              ],
                                            ),
                                          ),
                                          icon: Icon(Icons.receipt,color: Colors.white,),
                                          iconBackground: cars[i]?.order?.tasks?[x].status == TaskStatus.pending ? Colors.black: Colors.green,
                                        ),
                                      ],

                                      position: TimelinePosition.Left,
                                      iconSize: 25,
                                    ),
                                  ),
                              Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text('Subscription : ${cars[i]?.order?.subscription?.title}'),
                                      (cars[i]?.order?.subscription?.is_recurring == SubscriptionType.oneTime)
                                          ? Container()
                                          : Icon(Icons.refresh)
                                    ],
                                  ),
                                  ((cars[i]?.order?.subscription?.is_recurring == SubscriptionType.recurring) && cars[i]?.order?.renew_on!=null)
                                  ? Text('Auto Renew : ${cars[i]?.order?.renew_on}')
                                  : Container(),
                                ],
                              ),
                              Text('Price : ${cars[i]?.order?.subscription?.price} SAR'),

                              (cars[i]?.order?.receipt == null)
                                  ? Container()
                                  : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Divider(),
                                      Text('Receipt Image',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                      Image.network(
                                        Const.getReceiptPath(cars[i]?.order?.receipt),width: Const.wi(context)/2,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            child: Text('Not Found'),
                                          );
                                        },
                                      )
                                    ],
                                  ),

                              Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: cars[i]?.order?.payment == OrderPayment.pending? Colors.red : Colors.green, // Background color
                                    ),
                                    child:
                                    cars[i]?.order?.payment == OrderPayment.pending
                                      ? Text('Payment Pending')
                                      : Text('Payment Done'),
                                  ),
                                  cars[i]?.order?.subscription?.is_recurring == SubscriptionType.recurring
                                  ?
                                  ElevatedButton(
                                    onPressed: () async{
                                      dynamic response=await _indexViewModel.cancelSubscription({'id':'${ cars[i]?.order?.id}'});
                                      print(response);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red, // Background color
                                    ),
                                    child: Text('Cancel Subscription'),
                                  ):Container(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                else if (_indexViewModel.getStatus.status == Status.BUSY)
                  Container(
                    width: Const.wi(context),
                    child:   Const.LoadingIndictorWidtet(),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}