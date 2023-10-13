
import 'package:carwash/model/Order.dart';

class Task {
  int? id;
  int? order_id;
  String? date;
  String? time;
  int? inside_wash;
  int? outside_wash;
  int? status;
  bool? accessor;
  Order? order;
  List<String>? images;

  Task(
      {this.id,
        this.order_id,
        this.accessor,
        this.order,
        this.inside_wash,
        this.outside_wash,
        this.date,
        this.time,
        this.images,
        this.status});

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    order_id = json['order_id'];
    date = json['date'];
    status = json['status'];
    time = json['time'];
    inside_wash = json['inside_wash'];
    outside_wash = json['outside_wash'];
    accessor = json['accessor'];
    order = json['order'] as Order?;
    images = json['images'] as List<String>?;
  }

}
