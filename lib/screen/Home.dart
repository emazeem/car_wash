import 'package:carwash/apis/api_response.dart';
import 'package:carwash/constants.dart';
import 'package:carwash/model/Car.dart';
import 'package:carwash/model/Customer.dart';
import 'package:carwash/model/Task.dart';
import 'package:carwash/model/TaskWithDate.dart';
import 'package:carwash/model/User.dart';
import 'package:carwash/screen/CustomerDetails.dart';
import 'package:carwash/screen/Payment.dart';
import 'package:carwash/screen/ShowLocation.dart';
import 'package:carwash/screen/TaskDetails.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? authUser;

  String? authRole;

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


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {

      authRole=await ShPref.getAuthRole();
      await _pullAuthUser();
      if(authRole ==  Role.customer){
        _pullMyCars();
      }else{
        _pullTasks();
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
        height: Const.hi(context)-200,
        child: RefreshIndicator(
          onRefresh: ()async{
            if(authUser?.role == Role.customer){
              await _pullMyCars();
            }else{
              await _pullTasks();
            }
          },
          child: ListView(
            children: [
              if(authUser?.role==Role.customer)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Text('My Cars',style: TextStyle(fontSize: 25),),

                )
              else
                Container(
                  margin: EdgeInsets.only(top: 10,left: 10,right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.grey.shade200,
                        child: Text('Upcomming',style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.blue.shade50,
                        child: Text('Pending',style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.green.shade100,
                        child: Text('Completed',style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

              if(_indexViewModel.getStatus.status ==  Status.IDLE)
                if(authUser?.role==Role.customer)
                  if(cars.length==0)
                    Container(
                      width: double.infinity,
                      height: Const.hi(context)/1.3,
                      child: Center(
                        child: Text('No Cars'),
                      ),
                    )
                  else
                    for(int x=0;x<cars.length;x++)
                      Container(
                        margin: EdgeInsets.only(top: 10,left: 10,right: 10),
                        width: Const.wi(context),
                        child: Container(
                          color: Colors.grey.shade200,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${cars[x]?.make}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                  Text('${cars[x]?.model}',style: TextStyle(fontSize: 20),),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${cars[x]?.plate}',style: TextStyle(fontSize: 20),),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Container(height: 1,color: Colors.black12,),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Order # ${cars[x]?.order?.id.toString().padLeft(4, '0')}',style: TextStyle(fontSize: 20),),
                                  Text('${cars[x]?.order?.price} SAR',style: TextStyle(fontSize: 20),),

                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      if(cars[x]?.order?.subscription_id!=3)
                                        Icon(Icons.refresh),
                                      Text('${Const.subscription(cars[x]?.order?.subscription_id)} ',style: TextStyle(fontSize: 20),),
                                    ],
                                  ),

                                  Row(
                                    children: [

                                      ElevatedButton(
                                        onPressed: ()async {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerDetail(customer: cars[x]!.customer!,carId:  cars[x]!.id,))).then((value) => _pullMyCars());

                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.black, // Background color
                                        ),
                                        child: Text('Show Details', style: TextStyle(color: Colors.white)),
                                      ),
                                      SizedBox(width: 10,),

                                      if(cars[x]?.order?.payment == OrderPayment.pending)
                                        ElevatedButton(
                                          onPressed: ()async {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage(car: cars[x],))).then((value) => _pullMyCars());

                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.black, // Background color
                                          ),
                                          child: Text('Pay Now', style: TextStyle(color: Colors.white)),
                                        ),

                                    ],
                                  )
                                ],
                              ),

                            ],
                          ),
                        ),
                      )
                else
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
                    for(int x=0;x<tasks.length;x++)
                      Container(
                        margin: EdgeInsets.only(top: 10,left: 10,right: 10),
                        width: Const.wi(context),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${tasks[x]?.date}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                ],
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    for(int y=0; y < tasks[x]!.tasks!.length; y++ )
                                      InkWell(
                                        onTap:(){
                                          if(tasks[x]!.tasks![y].accessor==true){
                                            Task _tysk = tasks[x]!.tasks![y];
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => TaskScreen(task: _tysk,))).then((value) => _pullTasks());
                                          }else{
                                            Const.toastMessage('Its previous car washes are pending');
                                          }
                                        },
                                        child: Container(
                                          width: Const.wi(context)-10,
                                          padding: EdgeInsets.all(20),
                                          margin: EdgeInsets.all(5),
                                          color: (tasks[x]!.tasks![y].accessor == false)
                                              ? Colors.grey.shade200
                                              : (tasks[x]!.tasks![y].status==TaskStatus.complete)
                                              ? Colors.green.shade100
                                              : Colors.blue.shade50,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('${tasks[x]!.tasks![y].order?.user?.name} ',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),

                                                  if(tasks[x]!.tasks![y].order?.user?.long != null)
                                                    InkWell(
                                                      onTap: (){
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => ShowLocation(
                                                            User(
                                                              id: tasks[x]!.tasks![y].order?.user?.id,
                                                              name: tasks[x]!.tasks![y].order?.user?.name,
                                                              long: tasks[x]!.tasks![y].order?.user?.long,
                                                              lat: tasks[x]!.tasks![y].order?.user?.lat,
                                                              address: tasks[x]!.tasks![y].order?.user?.location,
                                                            )
                                                        )));
                                                      },
                                                      child: Icon(Icons.pin_drop_outlined),
                                                    )
                                                ],
                                              ),
                                              Text('Car ➤ ${tasks[x]!.tasks![y].order?.car?.make} | ${tasks[x]!.tasks![y].order?.car?.model} | ${tasks[x]!.tasks![y].order?.car?.plate}'),
                                              Text('Status ➤ ${tasks[x]!.tasks![y].status == TaskStatus.pending ? ' Pending' : 'Done'}')
                                            ],
                                          ),
                                        ),
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
                  height: Const.hi(context)/1.2,
                  child:   Const.LoadingIndictorWidtet(),
                ),
            ],
          ),
        ),
      ),
    );

  }
}






