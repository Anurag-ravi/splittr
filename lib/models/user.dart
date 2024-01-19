
class UserModel {
  String id,name,email,country_code,phone,upi_id,dp;

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