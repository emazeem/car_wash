import 'package:carwash/constants.dart';
import 'package:carwash/model/Product.dart';
import 'package:carwash/model/Subscription.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carwash/apis/api_response.dart';



class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {


  List<Subscription?> subscriptions=[];
  List<bool?> updateSubscriptionBool=[false,false,false];

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _idController = TextEditingController();


  Future<void> _pullSubscriptions() async {
    Provider.of<IndexViewModel>(context, listen: false).fetchSubscriptions({});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Provider.of<IndexViewModel>(context, listen: false).setSubscriptions([]);
      _pullSubscriptions();
    });
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IndexViewModel _indexViewModel=Provider.of<IndexViewModel>(context);
    subscriptions = _indexViewModel.getSubscriptionList;
    return Scaffold(
      appBar: Const.appbar('Packages'),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if(_indexViewModel.getStatus.status ==  Status.IDLE)
                    if(subscriptions.length==0)
                      Center(
                        child: Container(
                          width: double.infinity,
                          child: Text('No Subscription',textAlign: TextAlign.center,),
                        ),
                      )
                    else
                      for(int i=0;i<subscriptions.length;i++)
                        Container(
                          width: Const.wi(context)/1.1,
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /*Container(
                                  width: double.infinity,
                                  height: Const.hi(context)/5,
                                  color: Colors.black,
                                  child: Image.asset('assets/gradient.jpeg'),
                                ),*/
                                Visibility(
                                  visible: updateSubscriptionBool[i]==false,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${subscriptions[i]?.title}',style: TextStyle(fontWeight: FontWeight.bold),),
                                        (subscriptions[i]?.is_recurring== SubscriptionType.recurring)
                                        ? Icon(Icons.repeat,)
                                        : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: updateSubscriptionBool[i]==false,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${subscriptions[i]?.price} SAR'),
                                        InkWell(
                                          onTap: (){
                                            setState(() {
                                              _titleController.text='${subscriptions[i]?.title}';
                                              _priceController.text='${subscriptions[i]?.price}';
                                              _idController.text='${subscriptions[i]?.id}';
                                              updateSubscriptionBool=[false,false,false];
                                              updateSubscriptionBool[i]=true;
                                            });
                                          },
                                          child: Text('Update',style: TextStyle(fontWeight: FontWeight.bold),),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: updateSubscriptionBool[i]==true,
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [

                                        TextField(
                                          controller: _titleController,
                                          decoration: InputDecoration(
                                            labelText: 'Title',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        TextField(
                                          controller: _priceController,
                                          decoration: InputDecoration(
                                            labelText: 'Price',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                setState(() { updateSubscriptionBool[i]=false; });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.only(left: 5),
                                                  child: Text('Cancel',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
                                              ),
                                            ),

                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(100, 40),
                                                primary: Const.primaryColor,
                                                onPrimary: Colors.white,
                                                textStyle: TextStyle(color: Colors.black, fontSize: 18),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                              ),
                                              child: Text('Update'),
                                              onPressed: () async{
                                                if (_titleController.text.isEmpty) {
                                                  Const.toastMessage('Title is required.');
                                                } else if (_priceController.text.isEmpty) {
                                                  Const.toastMessage('Price is required.');
                                                } else {
                                                  Map<String,dynamic> data = {
                                                    'id': _idController.text,
                                                    'title': _titleController.text,
                                                    'price': _priceController.text,
                                                  };
                                                  try{
                                                    Map response=await _indexViewModel.updatePackage(data);
                                                    await _pullSubscriptions();
                                                    setState(() {
                                                      updateSubscriptionBool=[false,false,false];
                                                    });
                                                  }catch(e){
                                                    print('e');
                                                  }
                                                }

                                              },
                                            ),

                                          ],
                                        )
                                      ],
                                    ),
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
                ]
              ),
            ),

          ],
        ),
      ),
    );
  }
}
