import 'package:carwash/apis/api_response.dart';
import 'package:carwash/app_url.dart';
import 'package:carwash/constants.dart';
import 'package:carwash/model/Car.dart';
import 'package:carwash/model/Customer.dart';
import 'package:carwash/model/Task.dart';
import 'package:carwash/screen/CreateCar.dart';
import 'package:carwash/screen/Image.dart';
import 'package:carwash/screen/SingleTask.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetail extends StatefulWidget {
  final Customer customer;
  final int? carId;
  CustomerDetail({required this.customer,this.carId=null});

  @override
  State<CustomerDetail> createState() => _CustomerDetailState();
}

class _CustomerDetailState extends State<CustomerDetail> {

  int lengthOfCars=0;
  Future<void> _pullCars() async {
    await Provider.of<IndexViewModel>(context, listen: false).fetchCars({'id': widget.customer.id.toString(),'car_id':widget.carId.toString()});
    lengthOfCars=Provider.of<IndexViewModel>(context,listen: false).getCars.length;
    for (int i = 0; i < lengthOfCars; i++){
      showCarsBool.add(false);
      print(showCarsBool[i]);
    }
    print('length of cars ${lengthOfCars}');
  }
  int? selectedTech;

  List<Car?> cars=[];
  List<bool> showCarsBool=[];
  String? authRole;
  List<String> orderTypeList=['Transfer','Mada','Cash','Online Payment'];

  String selectedOrderType='';
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Provider.of<IndexViewModel>(context, listen: false).setCars([]);
      await _pullCars();
      await _pullTechList();
      authRole=await ShPref.getAuthRole();

      selectedTech=widget.customer.group_id;
    });
    super.initState();
  }
  Future<void> _pullTechList() async {
    Provider.of<IndexViewModel>(context, listen: false).setTechniciansList([]);
    await Provider.of<IndexViewModel>(context, listen: false).fetchTechniciansList({});
  }

  @override
  Widget build(BuildContext context) {
    IndexViewModel _indexViewModel=Provider.of<IndexViewModel>(context);
    cars=_indexViewModel.getCars;

    return Scaffold(
      appBar: Const.appbar('Customer Details'),
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
                        child: InkWell(
                          onTap: ()async{
                            String url = '${widget.customer.location}';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              Const.toastMessage('Invalid link');
                            }
                          },
                          child: Text(
                            'Location: ${widget.customer.location}',
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'Phone: ${widget.customer.phone}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      if(authRole!=Role.customer)
                      InkWell(
                        onTap: () {
                          _showTechniciansBottomSheet(context,_indexViewModel.getTechniciansList,_indexViewModel);
                        },
                        child: Container(
                          width: Const.wi(context)/2,
                          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Text(selectedTech!=null ? '${_indexViewModel.getTechniciansList.where((element) => element?.id == selectedTech ).first?.name}' : 'Assign to Technician',style: TextStyle(color: Colors.black87),),
                        ),
                      ),

                    ],
                  ),
                ),
                if(authRole!=Role.customer && authRole!=null)
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
                              if(cars[i]?.image != null)
                                InkWell(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage('${AppUrl.url}storage/car/${cars[i]?.image}')));
                                  },
                                  child: Image.network('${AppUrl.url}storage/car/${cars[i]?.image}',width: double.infinity,fit: BoxFit.cover,height: Const.hi(context)/3,)
                              ),
                                Container(
                                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                color: Colors.black,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${cars[i]?.make}',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20,color: Colors.white),),
                                    Row(
                                      children: [
                                        Text('${cars[i]?.model} -  ${cars[i]?.plate}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white)),
                                        InkWell(
                                          onTap: (){
                                            setState(() {
                                              showCarsBool[i]=!showCarsBool[i];
                                            });
                                          },
                                          child: Icon( showCarsBool[i] ? Icons.arrow_drop_up : Icons.arrow_drop_down,color: Colors.white),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: showCarsBool[i],
                                child: Column(
                                  children: [
                                    if(cars[i]?.order?.tasks?.length != 0)
                                      Container(
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
                                                                        Icon(cars[i]?.order?.tasks?[x].inside_wash==1?Icons.check_box:Icons.check_box_outline_blank,size: 15,color: cars[i]?.order?.tasks?[x].inside_wash==1?Colors.green:Colors.red,),
                                                                        Text('Outside'),
                                                                        Icon(cars[i]?.order?.tasks?[x].outside_wash==1?Icons.check_box:Icons.check_box_outline_blank,size: 15,color: cars[i]?.order?.tasks?[x].outside_wash==1?Colors.green:Colors.red,)
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
                                                                    height: 30,
                                                                    child: InkWell(
                                                                        onTap: (){
                                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage('${cars[i]?.order?.tasks?[x].images?[ii]}')));
                                                                        },
                                                                        child: Image.network('${cars[i]?.order?.tasks?[x].images?[ii]}')),
                                                                    //child: Text('${task!.images![f]}'),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      cars[i]?.order?.tasks?[x].status == TaskStatus.pending?
                                                      InkWell(
                                                        onTap: (){
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => SingleTaskScreen(id: cars[i]?.order?.tasks?[x].id.toString()))).then((value) => _pullCars());

                                                        },
                                                        child:  Icon(Icons.edit,),
                                                      ):Container(),
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
                                    if(cars[i]?.order?.receipt != null)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Divider(),
                                          Text('Receipt Image',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                          SizedBox(height: 10,),
                                          Center(
                                            child: InkWell(
                                              onTap: (){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage(Const.getReceiptPath(cars[i]?.order?.receipt))));

                                              },
                                              child: Image.network(
                                                Const.getReceiptPath(cars[i]?.order?.receipt),width: Const.wi(context)/3,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    child: Text('Not Found'),
                                                  );
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if(cars[i]?.order?.payment == OrderPayment.pending)
                                        InkWell(
                                          onTap: () {
                                            _updateOrderTypeBottomSheet(context,orderTypeList,cars[i]?.order?.id,_indexViewModel);
                                          },
                                          child: Container(
                                            width: Const.wi(context)/2.5,
                                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                            decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: Text(cars[i]?.order?.type!=null ? '${cars[i]?.order?.type}' : 'Select Type of Payment',style: TextStyle(color: Colors.black87),),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: cars[i]?.order?.payment == OrderPayment.pending? Colors.red : Colors.green, // Background color
                                          ),
                                          child:
                                          cars[i]?.order?.payment == OrderPayment.pending
                                              ? Text('Payment Pending',style: TextStyle(color: Colors.white))
                                              : Text('Payment Done',style: TextStyle(color: Colors.white)),
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
                                          child: Text('Cancel Subscription',style: TextStyle(color: Colors.white),),
                                        ):Container(),
                                      ],
                                    ),
                                  ],
                                ),
                              )
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
  void _showTechniciansBottomSheet(BuildContext context,List<Customer?> tech_list,IndexViewModel _indexViewModel) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Assign Customer to Technician',style: TextStyle(fontSize: 20),),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),

                    for (int x = 0; x < tech_list.length; x++)
                      InkWell(
                        onTap: () async{
                          setState((){
                            selectedTech = tech_list[x]?.id;
                          });
                          Map<String, dynamic> data = {
                            'user_id':widget.customer.id.toString(),
                            'email':widget.customer.email,
                            'name': widget.customer.name,
                            'phone': widget.customer.phone,
                            'address': widget.customer.address,
                            'group_id': selectedTech.toString(),
                          };
                          try{
                            Map response=await _indexViewModel.editUser(data);
                            print(response);
                          }catch(e){
                          }
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
    ).then((value)async {
      setState(() {
        selectedTech=selectedTech;
      });

    });
  }
  void _updateOrderTypeBottomSheet(BuildContext context,List<String> orderTypeList,int? id,IndexViewModel _indexViewModel) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Assign Order Type',style: TextStyle(fontSize: 20),),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),

                    for (int x = 0; x < orderTypeList.length; x++)
                      InkWell(
                        onTap: () async{
                          setState((){
                            selectedOrderType = orderTypeList[x];
                          });
                          Map<String, dynamic> data = {
                            'id':id.toString(),
                            'type': selectedOrderType.toString(),
                          };
                          try{
                            Map response=await _indexViewModel.updateOrderType(data);
                            print(response);
                          }catch(e){
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          color: selectedOrderType == orderTypeList[x]
                              ? Colors.black
                              : Colors.grey.shade200,
                          margin: EdgeInsets.only(top: 2, bottom: 2),
                          child: Text(
                            '${orderTypeList[x]}',
                            style: TextStyle(
                              color:Colors.orange,
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
    ).then((value)async {
      await _indexViewModel.fetchCars({'id': widget.customer.id.toString(),'car_id':widget.carId.toString()});
      setState(() {
        selectedOrderType=selectedOrderType;
      });

    });
  }


}