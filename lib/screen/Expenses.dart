import 'package:carwash/apis/api_response.dart';
import 'package:carwash/app_url.dart';
import 'package:carwash/constants.dart';
import 'package:carwash/model/Activity.dart';
import 'package:carwash/model/Expense.dart';
import 'package:carwash/model/User.dart';
import 'package:carwash/screen/CreateExpense.dart';
import 'package:carwash/screen/ShowImage.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpensePage extends StatefulWidget {
  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  List<Expense?> expenses = [];
  User? authUser;

  Future<void> _pullExpenses() async {
    Provider.of<IndexViewModel>(context, listen: false).setExpense([]);
    Provider.of<IndexViewModel>(context, listen: false).fetchExpenses({});
  }
  Future<void> _pullAuthUser() async {
    Provider.of<IndexViewModel>(context, listen: false).setUser(User());
    Provider.of<IndexViewModel>(context, listen: false).fetchUser();
  }
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _pullExpenses();
      await _pullAuthUser();

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    IndexViewModel _indexViewModel=Provider.of<IndexViewModel>(context);
    expenses = _indexViewModel.getExpenses;
    authUser = _indexViewModel.getUser;

    return Scaffold(
      appBar: Const.appbar(authUser?.role == Role.technician ? 'My Expense' : 'All Expenses'),
      body: RefreshIndicator(
        onRefresh: ()async{
          await _pullExpenses();
        },
        child: (_indexViewModel.getStatus.status == Status.IDLE)
            ? (expenses.length==0)
              ? Container(
                  padding: EdgeInsets.all(30),
                  child: Center(child: Text('No Expense')),
                )
              : Container(
                width: Const.wi(context),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('By')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Narration')),
                      DataColumn(label: Text('Amount'),numeric: true),
                    ],
                    columnSpacing: 10,
                    rows: List<DataRow>.generate(expenses.length, (index) => DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              Text('${expenses[index]?.user?.name}'),
                             InkWell(
                               onTap: (){
                                   Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                       ShowImage('${AppUrl.url}storage/expense/${expenses[index]?.image}')));},
                               child:  Icon(Icons.broken_image_outlined,size: 20,),
                             )
                            ],
                          )
                        ),
                        DataCell(Text('${expenses[index]?.date}')),
                        DataCell(Text('${expenses[index]?.narration}')),
                        DataCell(Text('${expenses[index]?.amount}')),
                      ],
                    ),
                    ),
                  ),
                ),
              )
            : Container(
                width: Const.wi(context),
                height: Const.hi(context)/1.3,
                child: Const.LoadingIndictorWidtet(),
            ),
      ),
      floatingActionButton: (authUser?.role == Role.technician)? FloatingActionButton(
        backgroundColor: Const.primaryColor,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateExpensePage())).then((value) => _pullExpenses());
        },
        child: Icon(Icons.add,color: Colors.white,),
      ): Container(),
    );
  }
}