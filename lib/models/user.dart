import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject{
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String email;
  
  @HiveField(3)
  String country_code;
  
  @HiveField(4)
  String phone;
  
  @HiveField(5)
  String upi_id;
  
  @HiveField(6)
  String dp;

  UserModel(this.id,this.name,this.email,this.country_code,this.phone,this.upi_id,this.dp);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(json['_id'],json['name'],json['email'],json['country_code'],json['phone'],json['upi_id'],json['dp']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['country_code'] = country_code;
    data['phone'] = phone;
    data['upi_id'] = upi_id;
    data['dp'] = dp;
    return data;
  }

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email, country_code: $country_code, phone: $phone, upi_id: $upi_id, dp: $dp}';
  }


}