import 'package:carwash/apis/api_response.dart';
import 'package:carwash/constants.dart';
import 'package:carwash/model/Car.dart';
import 'package:carwash/model/Customer.dart';
import 'package:carwash/screen/CreateCustomer.dart';
import 'package:carwash/screen/CustomerDetails.dart';

import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerPage extends StatefulWidget {
  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  Future<void> _pullRefresh() async {
    Provider.of<IndexViewModel>(context, listen: false).fetchCustomers({});
  }
  String? authToken;
  int? authId;

  List<Customer?> customers=[];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await ShPref.getAuthToken();
      authId = await ShPref.getAuthId();
      Provider.of<IndexViewModel>(context, listen: false).setCustomers([]);
      _pullRefresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    IndexViewModel _indexViewModel=Provider.of<IndexViewModel>(context);
    customers = _indexViewModel.getCustomerList;

    return Scaffold(
      appBar: Const.appbar('Customers'),
      body: RefreshIndicator(
        onRefresh: ()async{
          await _pullRefresh();
        },
        child: Container(
          width: Const.wi(context),
          child: ListView(
            children: [
              if(_indexViewModel.getStatus.status ==  Status.IDLE)
                if(customers.length==0)
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: Const.hi(context)/1.3,
                      child: Center(
                        child: Text('No Customer'),
                      ),
                    ),
                  )
                else
                  for(int x=0;x<customers.length;x++)
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerDetail(customer: customers[x]!,)));
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 10,left: 10,right: 10),
                        width: Const.wi(context),
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${customers[x]?.name}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                    Text('${customers[x]?.phone}'),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.pin_drop_outlined,size: 20,),
                                        Container(
                                          width: Const.wi(context)/2,
                                          child: Text('${customers[x]?.location}'),
                                        ),

                                      ],
                                    ),

                                    Text('Customer ID:${customers[x]?.id}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        //Navigator.push(context, MaterialPageRoute(builder: (context) => DeleteAccountPage(id: customers[x]?.id))).then((value) => _pullRefresh());
                                      },
                                      child: Icon(Icons.delete_outline,color: Colors.red,),
                                    ),

                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
              else if (_indexViewModel.getStatus.status == Status.BUSY)
                Container(
                  width: Const.wi(context),
                  height: Const.hi(context)/1.2,
                  child:   Const.LoadingIndictorWidtet(),
                )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Const.primaryColor,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddCustomerPage())).then((value) => _pullRefresh());
        },
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}
