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
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? authUser;
  final FlutterLocalization _localization = FlutterLocalization.instance;

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
        height: Const.hi(context)-150,
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
                ),
              if(authUser?.role==Role.technician || authUser?.role==Role.manager)
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
                   SingleChildScrollView(
                     scrollDirection: Axis.vertical,
                     child: Container(
                       width: Const.wi(context),
                       height: Const.hi(context)-200,
                       child:  GridView(
                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                           crossAxisCount: 2,
                           crossAxisSpacing: 5,
                           mainAxisSpacing: 5,
                           childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height-130),
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
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             ElevatedButton(
                                               onPressed: ()async {
                                                 Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerDetail(customer: cars[x]!.customer!,carId:  cars[x]!.id,))).then((value) => _pullMyCars());
                                               },
                                               style: ElevatedButton.styleFrom(
                                                 primary: Colors.black, // Background color
                                               ),
                                               child: Text('Details', style: TextStyle(color: Colors.white)),
                                             ),
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
                                                    onTap: ()async{
                                                      /*Navigator.push(context, MaterialPageRoute(builder: (context) => ShowLocation(
                                                          User(
                                                            id: tasks[x]!.tasks![y].order?.user?.id,
                                                            name: tasks[x]!.tasks![y].order?.user?.name,
                                                            long: tasks[x]!.tasks![y].order?.user?.long,
                                                            lat: tasks[x]!.tasks![y].order?.user?.lat,
                                                            address: tasks[x]!.tasks![y].order?.user?.location,
                                                          )
                                                      )));*/
                                                      String url = '${tasks[x]!.tasks![y].order?.user?.location}';
                                                      if (await canLaunch(url)) {
                                                      await launch(url);
                                                      } else {
                                                      Const.toastMessage('Something went wrong');
                                                      }
                                                    },
                                                    child: Icon(Icons.pin_drop_outlined),
                                                  )
                                              ],
                                            ),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Car ➤ ${tasks[x]!.tasks![y].order?.car?.make} | ${tasks[x]!.tasks![y].order?.car?.model} | ${tasks[x]!.tasks![y].order?.car?.plate}'),
                                                    Text('Subscription ➤ ${tasks[x]!.tasks![y].order?.subscription?.title}'),
                                                    Text('Status ➤ ${tasks[x]!.tasks![y].status == TaskStatus.pending ? ' Pending' : 'Done'}')
                                                  ],
                                                ),
                                                (tasks[x]!.tasks![y].order?.car?.image == null)? Container():
                                                Container(
                                                    padding: EdgeInsets.all(10),
                                                    child: Center(
                                                      child: InkWell(
                                                        onTap: (){
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage('${AppUrl.url}storage/car/${tasks[x]!.tasks![y].order?.car?.image}')));

                                                        },
                                                          child: Image.network('${AppUrl.url}storage/car/${tasks[x]!.tasks![y].order?.car?.image}',width: 40,height: 70,)),
                                                    )
                                                ),
                                              ],
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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

              Visibility(
                visible: false,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              child: const Text('English'),
                              onPressed: () {
                                _localization.translate('en');
                              },
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: ElevatedButton(
                              child: const Text('Arabic'),
                              onPressed: () {
                                _localization.translate('ar');
                              },
                            ),
                          ),


                        ],
                      ),
                      const SizedBox(height: 16.0),
                      ItemWidget(
                        title: 'Current Language',
                        content: _localization.getLanguageName(),
                      ),
                      ItemWidget(
                        title: 'Font Family',
                        content: _localization.fontFamily,
                      ),
                      ItemWidget(
                        title: 'Locale Identifier',
                        content: _localization.currentLocale.localeIdentifier,
                      ),
                      ItemWidget(
                        title: 'String Format',
                        content: Strings.format(
                          'Hello %a, this is me %a.',
                          ['Dara', 'Sopheak'],
                        ),
                      ),
                      ItemWidget(
                        title: 'Context Format String',
                        content: context.formatString(
                          AppLocale.thisIs,
                          [AppLocale.title, 'LATEST'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}




class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.title,
    required this.content,
  });

  final String? title;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(title ?? '')),
          const Text(' : '),
          Expanded(child: Text(content ?? '')),
        ],
      ),
    );
  }
}