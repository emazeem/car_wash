
import 'package:carwash/model/Order.dart';

class Task {
  int? id;
  int? order_id;
  String? comments;
  String? date;
  String? approval;
  String? time;
  String? date_time;
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
        this.comments,
        this.inside_wash,
        this.approval,
        this.outside_wash,
        this.date_time,
        this.date,
        this.time,
        this.images,
        this.status});

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    order_id = json['order_id'];
    date = json['date'];
    status = json['status'];
    comments = json['comments'];
    time = json['time'];
    inside_wash = json['inside_wash'];
    outside_wash = json['outside_wash'];
    approval = json['approval'];
    accessor = json['accessor'];
    order = json['order'] as Order?;
    images = json['images'] as List<String>?;
  }

}
