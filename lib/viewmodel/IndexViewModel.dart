import 'dart:convert';

import 'package:carwash/apis/api_response.dart';
import 'package:carwash/app_url.dart';
import 'package:carwash/constants.dart';
import 'package:carwash/model/Activity.dart';
import 'package:carwash/model/Expense.dart';
import 'package:carwash/model/TaskCount.dart';
import 'package:carwash/model/Trx.dart';
import 'package:carwash/model/Car.dart';
import 'package:carwash/model/Customer.dart';
import 'package:carwash/model/Order.dart';
import 'package:carwash/model/Subscription.dart';
import 'package:carwash/model/Task.dart';
import 'package:carwash/model/TaskWithDate.dart';
import 'package:carwash/model/User.dart';
import 'package:carwash/services/BaseApiServices.dart';
import 'package:carwash/services/NetworkApiServices.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class IndexViewModel extends ChangeNotifier {
  BaseApiServices _apiServices = NetworkApiServices();

  ApiResponse _getStatus=ApiResponse();
  ApiResponse get getStatus => _getStatus;

  ///////////////////////////////////////////////////////
  List<Customer?> _getCustomerList=[];
  List<Customer?> get getCustomerList => _getCustomerList;
  void setCustomers(List<Customer> data) {
    _getCustomerList = data;
    notifyListeners();
  }
  Future fetchCustomers(dynamic data) async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching customers');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchCustomers, data, authToken);
      List<Customer?> customers=[];
      response['data'].forEach((item) {
        //item['created_at']=NpDateTime.fromJson(item['created_at']);
        print('item ${item}');
        customers.add(Customer.fromJson(item));
      });
      _getStatus = ApiResponse.completed(customers);
      _getCustomerList=customers;
      print('done ${customers.length}');
      notifyListeners();

    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }
  ///////////////////////////////////////////////////////
  List<Customer?> _getTechniciansList=[];
  List<Customer?> get getTechniciansList => _getTechniciansList;
  void setTechniciansList(List<Customer> data) {
    _getTechniciansList = data;
    notifyListeners();
  }
  Future fetchTechniciansList(dynamic data) async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching technicians');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchTechnicians, data, authToken);
      List<Customer?> customers=[];
      response['data'].forEach((item) {
        customers.add(Customer.fromJson(item));
      });
      _getStatus = ApiResponse.completed(customers);
      _getTechniciansList=customers;
      notifyListeners();

    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }

  ///////////////////////////////////////////////////////
  List<Activity?> _getActivities=[];
  List<Activity?> get getActivities => _getActivities;
  void setActivity(List<Activity> data) {
    _getActivities = data;
    notifyListeners();
  }
  Future fetchActivity(dynamic data) async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching activities');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchActivities, data, authToken);
      List<Activity?> activities=[];
      response['data'].forEach((item) {
        activities.add(Activity.fromJson(item));
      });
      _getStatus = ApiResponse.completed(activities);
      _getActivities=activities;
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }
  ///////////////////////////////////////////////////////
  List<Expense?> _getExpenses=[];
  List<Expense?> get getExpenses => _getExpenses;
  void setExpense(List<Expense> data) {
    _getExpenses = data;
    notifyListeners();
  }
  Future fetchExpenses(dynamic data) async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching Expenses');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchExpenses, data, authToken);
      List<Expense?> expense=[];
      response['data'].forEach((item) {
        item['user']=User.fromJson(item['user']);
        expense.add(Expense.fromJson(item));
      });
      _getStatus = ApiResponse.completed(expense);
      _getExpenses=expense;
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }


  ///////////////////////////////////////////////////////
  List<Trx?> _getTrx=[];
  List<Trx?> get getTrx => _getTrx;
  void setTrx(List<Trx> data) {
    _getTrx = data;
    notifyListeners();
  }
  Future fetchTrx(dynamic data) async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching transactions');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchMyTransactions, data, authToken);
      List<Trx?> trx=[];
      response['data'].forEach((item) {
        trx.add(Trx.fromJson(item));
      });
      _getStatus = ApiResponse.completed(trx);
      _getTrx=trx;
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }



  ///////////////////////////////////////////////////////
  List<Subscription?> _getSubscriptionList=[];
  List<Subscription?> get getSubscriptionList => _getSubscriptionList;
  void setSubscriptions(List<Subscription> data) {
    _getSubscriptionList = data;
    notifyListeners();
  }
  Future fetchSubscriptions(dynamic data) async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching subscriptions');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchSubscriptions, data, authToken);
      List<Subscription?> sub=[];
      response['data'].forEach((item) {
        sub.add(Subscription.fromJson(item));
      });
      _getStatus = ApiResponse.completed(sub);
      _getSubscriptionList=sub;
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }
  ///////////////////////////////////////////////////////
  List<TaskWithDate?> _getTasksList=[];
  List<TaskWithDate?> get getTasksList => _getTasksList;
  void setTasksList(List<TaskWithDate> data) {
    _getTasksList = data;
    notifyListeners();
  }
  Future fetchTaskList(dynamic data) async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching tasks list');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchTasks, data, authToken);
      List<TaskWithDate> _taskWithDate=[];
      response['data'].forEach((index,item) {
        List<Task> _tasks=[];
        item.forEach((task){
          task['order']['user']=Customer.fromJson(task['order']['car']['user']);
          task['order']['car']['user']=Customer();
          task['order']['car']=Car.fromJson(task['order']['car']);
          task['order']['subscription']=Subscription.fromJson(task['order']['subscription']);
          task['order']=Order.fromJson(task['order']);
          Task _t=Task.fromJson(task);
          //Task _t=Task();
          _tasks.add(_t);
        });
        _taskWithDate.add(TaskWithDate(date: index,tasks:_tasks ));
      });
      _getStatus = ApiResponse.completed(_taskWithDate);
      _getTasksList=_taskWithDate;
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }

  ///////////////////////////////////////////////////////
  List<Car?> _getMyCars=[];
  List<Car?> get getMyCars => _getMyCars;
  void setMyCars(List<Car> data) {
    _getMyCars = data;
    notifyListeners();
  }
  Future fetchMyCars(dynamic data) async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching my cars list');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchMyCars, data, authToken);
      List<Car?> _cars=[];
      response['data'].forEach((item) {
        dynamic jsonSubscription=item['order']['subscription'];
        item['order']['subscription']=Subscription(
            id: jsonSubscription['id'],title: jsonSubscription['title'],price: jsonSubscription['price'],
            is_recurring: jsonSubscription['is_recurring']);
        item['order']=Order.fromJson(item['order']);
        item['user']=Customer.fromJson(item['user']);
        _cars.add(Car.fromJson(item));
      });




      _getStatus = ApiResponse.completed(_cars);
      _getMyCars=_cars;
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }



  ///////////////////////////////////////////////////////

  Task? _getTask;
  Task? get getTask => _getTask;
  void setTask(Task? data) {
    _getTask = data;
    notifyListeners();
  }
  Future fetchTask(dynamic data) async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching task');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchTask, data, authToken);
      response=response['data'];
      Task? _tsk=new Task();


      List<String> _images=[];
      if(response['images']!='[]'){
        response['images'].forEach((image){
          _images.add(AppUrl.url+'storage/tasks/'+image);
        });
      }
      response['images']=_images;
      response['order']['user']=Customer.fromJson(response['order']['car']['user']);
      response['order']['car']['user']=Customer();
      response['order']['car']=Car.fromJson(response['order']['car']);
      response['order']=Order.fromJson(response['order']);
      _tsk=Task.fromJson(response);

      String timeString = '${_tsk.time}';
      if (timeString.contains('AM')) {
        timeString = timeString.replaceAll(' AM', '');
      } else if (timeString.contains('PM')) {
        timeString = timeString.replaceAll(' PM', '');
        List<String> timeComponents = timeString.split(':');
        int hours = int.parse(timeComponents[0]);
        if (hours < 12) {
          hours += 12;
          timeString = '$hours:${timeComponents[1]}';
        }
      }
      _tsk.date_time='${_tsk.date}T$timeString';

      _getStatus = ApiResponse.completed(_tsk);
      _getTask=_tsk;
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }

  ///////////////////////////////////////////////////////


  List<Order?> _getInvoiceList=[];
  List<Order?> get getInvoiceList => _getInvoiceList;
  void setInvoiceList(List<Order> data) {
    _getInvoiceList = data;
    notifyListeners();
  }
  Future fetchInvoices(String type) async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching orders');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchInvoices, {}, authToken);
      List<Order?> orders=[];
      response['data'].forEach((item) {
        item['user']=Customer.fromJson(item['car']['user']);
        item['car']=Car.fromJson(item['car']);
        orders.add(Order.fromJson(item));
      });
      _getStatus = ApiResponse.completed(orders);
      if(type=='all'){
        _getInvoiceList=orders;
      }else if(type=='pending'){
        List<Order?> filteringOrders=[];
        orders.forEach((element) { 
          if(element?.payment == OrderPayment.pending){
            filteringOrders.add(element);
          }
        });
        _getInvoiceList=filteringOrders;
      }else if(type=='complete'){
        List<Order?> filteringOrders=[];
        orders.forEach((element) { 
          if(element?.payment == OrderPayment.complete){
            filteringOrders.add(element);
          }
        });
        _getInvoiceList=filteringOrders;
      }else{
        _getInvoiceList=orders;
      }
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }
  ///////////////////////////////////////////////////////

  List<Car?> _getCars=[];
  List<Car?> get getCars => _getCars;
  void setCars(List<Car> data) {
    _getCars = data;
    notifyListeners();
  }
  Future fetchCars(dynamic data) async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching cars');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchCars, data, authToken);
      List<Car?> sub=[];
      response['data'].forEach((item) {
        List<Task> _tasks=[];

        item['order']['tasks'].forEach((it) {
          List<String> _images=[];
          if(it['images']!='[]'){
            it['images'].forEach((image){
              _images.add(AppUrl.url+'storage/tasks/'+image);
            });
          }
          it['images']=_images;

          Task task=Task.fromJson(it);
          _tasks.add(task);
        });
        item['order']['tasks']=_tasks;
        item['order']['subscription']=Subscription.fromJson(item['order']['subscription']);
        item['order']=Order.fromJson(item['order']);
        Car car=Car.fromJson(item);
        sub.add(car);
      });
      print('object');
      print(data['car_id']);
      print(data['car_id'] == 'null');
      if(data['car_id'] != 'null'){
        sub = sub.where((car) => car?.id.toString() == data['car_id']).toList();
      }


      _getStatus = ApiResponse.completed(sub);
      _getCars=sub;
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }
  ///////////////////////////////////////////////////////
  User? _getUser=User();
  User? get getUser => _getUser;
  void setUser(User? data) {
    _getUser = data;
    notifyListeners();
  }
  Future fetchUser() async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching auth user');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchUser, {}, authToken);
      User? _user= User.fromJson(response['data']);
      _getStatus = ApiResponse.completed(_user);
      _getUser=_user;
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }
  ///////////////////////////////////////////////////////
  List<String>? _get4Sundays=[];
  List<String>? get get4Sundays => _get4Sundays;
  void set4Sundays(List<String> _sundays) {
    _get4Sundays = _sundays;
    notifyListeners();
  }
  Future fetch4Sundays() async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching coming sundays');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetch4sundays, {}, authToken);
      List<String>? get4Sundays=[];
      response['data'].forEach((item){
        get4Sundays.add(item);
      });
      _getStatus = ApiResponse.completed(get4Sundays);
      _get4Sundays=get4Sundays;
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }



  ///////////////////////////////////////////////////////
  List<Task>? _getTaskByDate=[];
  List<Task>? get getTaskByDate => _getTaskByDate;
  void setTaskByDate(List<Task> _t) {
    _getTaskByDate = _t;
    notifyListeners();
  }
  Future fetchTaskByDate(data) async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching task by date');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchTasksFromDate,data, authToken);
      List<Task>? tasks=[];
      response['data'].forEach((item){
        //item['order']['customer']=Customer.fromJson(item['order']['car']['user']);
        //item['order']['car']=Car.fromJson(item['order']['car']);

        dynamic jsonOrder=item['order'];
        dynamic jsonCar=item['order']['car'];
        dynamic jsonUser=item['order']['car']['user'];
        item['order']=Order(price: jsonOrder['price'],
            car: Car(make: jsonCar['make'],model: jsonCar['model'],plate: jsonCar['plate']),
            user: Customer(id: jsonUser['id'],name: jsonUser['name']));
        Task _task=Task.fromJson(item);
        tasks.add(_task);
      });
      _getStatus = ApiResponse.completed(tasks);
      _getTaskByDate=tasks;
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }



  ///////////////////////////////////////////////////////
  List<TaskCount>? _getTaskCount=[];
  List<TaskCount>? get getTaskCount => _getTaskCount;
  void setTaskCount(List<TaskCount> _t) {
    _getTaskCount = _t;
    notifyListeners();
  }
  Future fetchTaskCount() async {
    var authToken = await ShPref.getAuthToken();
    try{
      _getStatus = ApiResponse.loading('Fetching task counter');
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchTasksFromDates,{}, authToken);
      List<TaskCount>? tasks=[];
      response['data'].forEach((item){
        print(item);
        tasks.add(TaskCount(date: item['task_date'],count: item['task_count']));
      });
      _getStatus = ApiResponse.completed(tasks);
      _getTaskCount=tasks;
      notifyListeners();
    }catch(e){
      _getStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }













  Future registerApi(dynamic data) async {
    try{
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.register, data);
      Const.toastMessage(response['message']);
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }
  Future loginApi(dynamic data) async {
    try{
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.login, data);
      //Const.toastMessage(response['message']);
      print('object ${response}');
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }
  Future updateUser(dynamic data) async {
    try{
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.updateUser, data);
      print('object ${response}');
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }
  Future updateLocation(dynamic data) async {
    String authToken= await ShPref.getAuthToken();
    try{
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.updateLocation, data,authToken);
      Const.toastMessage(response['message']);
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }
  Future deleteAccount(dynamic data) async {
    String authToken= await ShPref.getAuthToken();
    try{
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.deleteAccount,data,authToken);
     return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }

  Future updatePackage(dynamic data) async {
    String authToken= await ShPref.getAuthToken();
    try{
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.updateSubscription, data,authToken);
      Const.toastMessage(response['message']);
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }

  Future taskApproval(dynamic data) async {
    String authToken= await ShPref.getAuthToken();
    try{
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.taskAction, data,authToken);
      Const.toastMessage(response['message']);
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }
  Future updateTask(dynamic data) async {
    String authToken= await ShPref.getAuthToken();
    try{
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.updateTask, data,authToken);
      Const.toastMessage(response['message']);
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }


  Future addCar(dynamic data) async {
    String authToken= await ShPref.getAuthToken();
    try{
      print(data);
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.createCarSubscription, data,authToken);
      Const.toastMessage(response['message']);
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }
  Future cancelSubscription(dynamic data) async {
    String authToken= await ShPref.getAuthToken();
    try{
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.cancelSubscription, data,authToken);
      Const.toastMessage(response['message']);
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }
  Future editUser(dynamic data) async {
    String authToken= await ShPref.getAuthToken();
    try{
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.editUser, data,authToken);
      Const.toastMessage(response['message']);
      fetchUser();
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }
  Future createExpense(Map<String, dynamic> data) async {
    String authToken= await ShPref.getAuthToken();
    try{
      print(data);
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.createExpense, data,authToken);
      Const.toastMessage(response['message']);
      fetchUser();
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }

  Future markPaymentAsDone(dynamic data) async {
    String authToken= await ShPref.getAuthToken();
    try{
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.paymentMarkAsDone, data,authToken);
      Const.toastMessage(response['message']);
      fetchUser();
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }
  Future taskMarkAsDone(dynamic data) async {
    String authToken= await ShPref.getAuthToken();
    try{
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.taskMarkAsDone, data,authToken);
      Const.toastMessage(response['message']);
      fetchUser();
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }
  Future changePassword(dynamic data) async {
    String authToken= await ShPref.getAuthToken();
    try{
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.changePassword, data,authToken);
      Const.toastMessage(response['message']);
      fetchUser();
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }


  Future checkout(dynamic data) async {
    String authToken= await ShPref.getAuthToken();
    print(data);
    try{
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.checkout, data,authToken);
      Const.toastMessage(response['message']);
      return response;
    }catch(e){
      Const.toastMessage(e.toString());
    }
  }
  Future storeDeviceId(deviceId) async {
    String authToken= await ShPref.getAuthToken();
    print('deviceId ${deviceId}');
    if(deviceId != null){
      try{
        dynamic data={'device_id':deviceId};
        dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.storeNotificationDevice, data,authToken);
        print('notification device stored');
        return response;
      }catch(e){
        print('object ${e.toString()}');
      }
    }
  }

}