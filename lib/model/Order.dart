import 'package:carwash/model/Car.dart';
import 'package:carwash/model/Customer.dart';
import 'package:carwash/model/Subscription.dart';
import 'package:carwash/model/Task.dart';
import 'package:carwash/model/User.dart';

class Order {
  final int? id;
  final int? car_id;
  final int? subscription_id;
  final String? price;
  final String? payment;
  final String? payment_date;
  final String? receipt;
  final String? type;
  final int? status;
  final String? renew_on;
  final List<Task>? tasks;
  final Subscription? subscription;
  final Car? car;
  final Customer? user;


  Order({
     this.id,
     this.car_id,
     this.subscription_id,
     this.price,
     this.payment,
     this.payment_date,
     this.receipt,
     this.tasks,
     this.renew_on,
     this.status,
     this.subscription,
     this.type,
     this.car,
     this.user,
  });


  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id :json['id'] as int?,
      car_id :json['car_id'] as int?,
      subscription_id :json['subscription_id'] as int?,
      price: json['price'] as String?,
      payment : json['payment'] as String?,
      payment_date : json['payment_date'] as String?,
      receipt : json['receipt'] as String?,
      renew_on : json['renew_on'] as String?,
      type : json['type'] as String?,
      status : json['status'] as int?,
      tasks : json['tasks'] as List<Task>?,
      subscription : json['subscription'] as Subscription?,
      car : json['car'] as Car?,
      user : json['user'] as Customer?,

    );
  }
}