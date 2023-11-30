import 'package:carwash/apis/api_response.dart';
import 'package:carwash/app_url.dart';
import 'package:carwash/constants.dart';
import 'package:carwash/main.dart';
import 'package:carwash/model/Car.dart';
import 'package:carwash/model/Customer.dart';
import 'package:carwash/model/Task.dart';
import 'package:carwash/model/TaskWithDate.dart';
import 'package:carwash/model/User.dart';
import 'package:carwash/screen/CustomerDetails.dart';
import 'package:carwash/screen/Image.dart';
import 'package:carwash/screen/Payment.dart';
import 'package:carwash/screen/ShowLocation.dart';
import 'package:carwash/screen/TaskDetails.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:checkout_sdk_flutter/checkout_sdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carwash/payment_configurations.dart';


class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? authUser;
  final FlutterLocalization _localization = FlutterLocalization.instance;

  String? authRole;
  int? selectedDate=0;
  var cko = new Checkout(publicKey: Const.CHECKOUT_PUBLIC_KEY);

  Future<void> _pullTasks() async {
    Provider.of<IndexViewModel>(context, listen: false).setTasksList([]);
    Provider.of<IndexViewModel>(context, listen: false).fetchTaskList({});
  }
  Future<void> _pullMyCars() async {
    Provider.of<IndexViewModel>(context, listen: false).setMyCars([]);
    Provider.of<IndexViewModel>(context, listen: false).fetchMyCars({});
  }
  
  Future<void> _pullAuthUser() async {
    Provider.of<IndexViewModel>(context, listen: false).setUser(User());
    Provider.of<IndexViewModel>(context, listen: false).fetchUser();
  }

  formatDate(originalDate){
    DateTime dateTime = DateTime.parse(originalDate);
    String desiredFormat = "MMMM dd, yyyy";
    return DateFormat(desiredFormat).format(dateTime);
  }
  formatDate2(originalDate){
    DateTime dateTime = DateTime.parse(originalDate);
    String desiredFormat = "dd MMM";
    return DateFormat(desiredFormat).format(dateTime);
  }
  void onApplePayResult(paymentResult) {
    var token=cko.tokenizeApplePay(paymentResult);
    print(token);
  }



  bool showSideBar=false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {

      authRole=await ShPref.getAuthRole();
      await _pullAuthUser();
      if(authRole ==  Role.customer){
        await _pullMyCars();
      }else{
        await _pullTasks();
      }

    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    IndexViewModel _indexViewModel=Provider.of<IndexViewModel>(context);
    List<TaskWithDate?> tasks = _indexViewModel.getTasksList;

    authUser = _indexViewModel.getUser;
    List<Car?> cars = _indexViewModel.getMyCars;

    return Scaffold(
      body: Container(
        width: Const.wi(context),
        height: Const.hi(context)-100,
        child: (authUser?.role==Role.customer)
            ? RefreshIndicator(
              onRefresh: ()async{
                await _pullMyCars();
              },
              child:  ListView(
                children: [
                  Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Text('My Cars',style: TextStyle(fontSize: 25),),
                    ),
                  if(_indexViewModel.getStatus.status ==  Status.IDLE)
                      if(cars.length==0)
                        Container(
                          width: double.infinity,
                          height: Const.hi(context)/1.3,
                          child: Center(
                            child: Text('No Cars'),
                          ),
                        )
                      else
                       SingleChildScrollView(
                         scrollDirection: Axis.vertical,
                         child: Container(
                           width: Const.wi(context),
                           height: Const.hi(context)-250,
                           padding: EdgeInsets.symmetric(horizontal: 5),
                           child:  GridView(
                             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                               crossAxisCount: 2,
                               crossAxisSpacing: 5,
                               mainAxisSpacing: 5,
                               childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height-155),
                             ),
                             children: [
                               for(int x=0;x<cars.length;x++)
                                 Container(
                                   width: Const.wi(context)/2,
                                   decoration: BoxDecoration(
                                       color: Colors.grey.shade200,
                                       border: Border.all(
                                         color: Colors.black26
                                       )
                                   ),
                                   child: Column(
                                     children: [
                                        Stack(
                                          children: [
                                            Image.network('${AppUrl.url}storage/car/${cars[x]?.image}',width: double.infinity,height: Const.hi(context)/4.5,fit: BoxFit.cover,),
                                            Container(
                                              margin: EdgeInsets.only(left: 5,top: 5),
                                              padding: EdgeInsets.symmetric(vertical: 4,horizontal: 10),
                                               decoration: BoxDecoration(
                                                 color: Colors.black,
                                                 borderRadius: BorderRadius.circular(20),
                                               ),
                                               child: Text('${cars[x]?.order?.price} SAR',style: TextStyle(color: Colors.white),textAlign: TextAlign.right,),
                                            )
                                          ],
                                        ),

                                        Container(
                                          padding: EdgeInsets.only(top: 7,bottom: 7),
                                          color: Colors.black,
                                          child:  Column(
                                            children: [
                                              SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text('${cars[x]?.make}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                                                    Text(' - ${cars[x]?.model}',style: TextStyle(color: Colors.white),),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text('${cars[x]?.plate}',style: TextStyle(color: Colors.white),),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                       SizedBox(height: 10,),
                                       Container(
                                         padding: EdgeInsets.all(5),
                                         child: Column(
                                           children: [
                                             Row(
                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                               children: [
                                                 Text('Order # ${cars[x]?.order?.id.toString().padLeft(4, '0')}',style: TextStyle(fontWeight: FontWeight.bold),),
                                               ],
                                             ),
                                             Row(
                                               children: [
                                                 Text('Subscription : ',style: TextStyle(fontWeight: FontWeight.bold),),
                                                 Text('${cars[x]?.order?.subscription?.title}'),
                                                 if(cars[x]?.order?.subscription_id!=3)
                                                   Icon(Icons.refresh,size: 14,),
                                               ],
                                             ),
                                             SizedBox(height: 10,),
                                             Row(
                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                               children: [
                                                 InkWell(
                                                   onTap: (){
                                                     Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerDetail(customer: cars[x]!.customer!,carId:  cars[x]!.id,))).then((value) => _pullMyCars());
                                                   },
                                                   child: Container(
                                                     decoration: BoxDecoration(
                                                         color: Colors.black,
                                                       borderRadius: BorderRadius.circular(5)
                                                     ),
                                                     padding: EdgeInsets.symmetric(vertical: 6,horizontal: 13),
                                                     child: Text('Details', style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w500)),
                                                   ),
                                                 ),
                                                 if(cars[x]?.order?.payment == OrderPayment.pending)
                                                   ApplePayButton(
                                                     paymentConfiguration: PaymentConfiguration.fromJsonString(defaultApplePay),
                                                     paymentItems: [
                                                       PaymentItem(
                                                         label: 'Total',
                                                         amount: '${cars[x]?.order?.price}',
                                                         status: PaymentItemStatus.final_price,
                                                       )
                                                     ],
                                                     style: ApplePayButtonStyle.black,
                                                     type: ApplePayButtonType.checkout,
                                                     onPaymentResult: onApplePayResult,
                                                     loadingIndicator: const Center(
                                                       child: CircularProgressIndicator(),
                                                     ),
                                                   ),
                                                   /*ElevatedButton(
                                                     onPressed: ()async {
                                                       Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage(car: cars[x],))).then((value) => _pullMyCars());

                                                     },
                                                     style: ElevatedButton.styleFrom(
                                                       primary: Colors.black, // Background color
                                                     ),
                                                     child: Text('Pay Now', style: TextStyle(color: Colors.white)),
                                                   ),*/

                                               ],
                                             ),
                                           ],
                                         ),
                                       )
                                     ],
                                   ),
                                 ),
                             ],
                           ),
                         ),
                       )

                    else if (_indexViewModel.getStatus.status == Status.BUSY)
                    Container(
                      width: Const.wi(context),
                      height: Const.hi(context)/1.2,
                      child:   Const.LoadingIndictorWidtet(),
                    ),
                ],
              ),
            ) : ListView(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.grey.shade200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                              onTap:(){
                                setState(() {
                                  showSideBar=!showSideBar;
                                });
                              },
                              child: Icon(Icons.filter_list,size: 25,)
                          ),
                          (selectedDate!=null && tasks.asMap().containsKey(selectedDate)) ? Text('${formatDate(tasks[selectedDate!]!.date)}',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),) : Container(),
                        ],
                      ),
                    ),
                    if(_indexViewModel.getStatus.status ==  Status.IDLE)
                      if(tasks.length==0)
                        Center(
                          child: Container(
                            width: double.infinity,
                            height: Const.hi(context)-100,
                            child: Center(
                              child: Text('No Task'),
                            ),
                          ),
                        )
                      else
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Visibility(
                                visible: showSideBar,
                                child: Container(
                                  margin:EdgeInsets.only(top: 10),
                                  width: Const.wi(context)/5,
                                  child: Column(
                                    children: [
                                      for(int x=0;x<tasks.length;x++)
                                        InkWell(
                                            onTap: (){
                                              setState(() {
                                                selectedDate=x;
                                              });
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: x==selectedDate ? Colors.black : Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4)
                                                ),
                                                padding: EdgeInsets.all(10),
                                                margin: EdgeInsets.only(top: 4,bottom: 4,left: 4),
                                                child: Text('${formatDate2(tasks[x]?.date)}',style: TextStyle(color: x==selectedDate ? Colors.white:Colors.black),)
                                            )
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              selectedDate != null
                                  ? Expanded(
                                child: Container(
                                  height: Const.hi(context)-210,
                                  padding: EdgeInsets.all(10),
                                  child: ListView(
                                    children: [
                                      for(int y=0; y < tasks[selectedDate!]!.tasks!.length; y++ )
                                        InkWell(
                                          onTap:(){
                                            if(tasks[selectedDate!]!.tasks![y].accessor==true){
                                              Task _tysk = tasks[selectedDate!]!.tasks![y];
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => TaskScreen(task: _tysk,))).then((value) => _pullTasks());
                                            }else{
                                              Const.toastMessage('Its previous car washes are pending');
                                            }
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 20),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.grey.shade500
                                                    )
                                                )
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text('${tasks[selectedDate!]!.tasks![y].order?.car?.make}',style: TextStyle(fontSize: 19,fontWeight: FontWeight.w500),),
                                                    Container(
                                                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 13),
                                                        decoration: BoxDecoration(
                                                            color:(tasks[selectedDate!]!.tasks![y].accessor == false) ? Colors.grey.shade200 : (tasks[selectedDate!]!.tasks![y].status==TaskStatus.complete)
                                                                ? Colors.green.shade100
                                                                : Colors.blue.shade50,
                                                            borderRadius: BorderRadius.circular(20)
                                                        ),
                                                        child:Text(
                                                          '${(tasks[selectedDate!]!.tasks![y].accessor == false) ? 'Upcoming' : (tasks[selectedDate!]!.tasks![y].status==TaskStatus.complete)
                                                              ? 'Completed'
                                                              : 'Pending'}',
                                                          style: TextStyle(color: Colors.black),)
                                                    ),

                                                  ],
                                                ),
                                                Text(' ${tasks[selectedDate!]!.tasks![y].order?.car?.model} | ${tasks[selectedDate!]!.tasks![y].order?.car?.plate}',style: TextStyle(),),
                                                SizedBox(height: 10,),
                                                (tasks[selectedDate!]!.tasks![y].order?.car?.image == null)? Container():
                                                Stack(
                                                  children: [
                                                    InkWell(
                                                        onTap: (){
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage('${AppUrl.url}storage/car/${tasks[selectedDate!]!.tasks![y].order?.car?.image}')));
                                                        },
                                                        child: Image.network('${AppUrl.url}storage/car/${tasks[selectedDate!]!.tasks![y].order?.car?.image}',width: double.infinity,height: 200,fit: BoxFit.cover,)
                                                    ),
                                                    Positioned(
                                                      right: 10,
                                                      top: 10,
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(vertical: 7,horizontal: 15),
                                                        decoration: BoxDecoration(
                                                            color:Colors.black,
                                                            borderRadius: BorderRadius.circular(20)
                                                        ),
                                                        child:Text('${tasks[selectedDate!]!.tasks![y].order?.subscription?.title}',style: TextStyle(color: Colors.white),),
                                                      ),
                                                    )

                                                  ],
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(top: 10),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      if(tasks[selectedDate!]!.tasks![y].order?.user?.long != null)
                                                        InkWell(
                                                          onTap: ()async{
                                                            String url = '${tasks[selectedDate!]!.tasks![y].order?.user?.location}';
                                                            if (await canLaunch(url)) {
                                                              await launch(url);
                                                            } else {
                                                              Const.toastMessage('Invalid link');
                                                            }
                                                          },
                                                          child: Icon(Icons.pin_drop_outlined),
                                                        ),
                                                      SizedBox(width: 10,),
                                                      Text('${tasks[selectedDate!]!.tasks![y].order?.user?.name} ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),

                                                    ],
                                                  ),
                                                ),


                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ) : Container(
                                child: Text('No Car'),
                              ),
                            ],
                          ),
                        )
                    else if (_indexViewModel.getStatus.status == Status.BUSY)
                      Container(
                        width: Const.wi(context),
                        height: Const.hi(context)/1.2,
                        child:   Const.LoadingIndictorWidtet(),
                      ),
                  ],
             ),
      ),
    );
  }



}
