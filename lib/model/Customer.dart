class Customer {
  final int? id;
  final String? name;
  final String? email;
  final String? location;
  final String? phone;
  final String? profile;
  final String? long;
  final String? lat;
  final String? address;
  final int? group_id;
  Customer({ this.id,  this.name,  this.location, this.phone, this.profile, this.long, this.lat,this.group_id,this.email,this.address});


  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id :json['id'] as int?,
      name: json['name'] as String?,
      location : json['address'] as String?,
      phone : json['phone'] as String?,
      profile : json['profile'] as String?,
      long : json['long'] as String?,
      lat : json['lat'] as String?,
      email : json['email'] as String?,
      address : json['address'] as String?,
      group_id : json['group_id'] as int?,
    );
  }
}