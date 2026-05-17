import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.countryCode,
    required this.phone,
    required this.upiId,
    required this.dp,
  });

  final String id;
  final String name;
  final String email;
  final String countryCode;
  final String phone;
  final String upiId;
  final String dp;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? countryCode,
    String? phone,
    String? upiId,
    String? dp,
  }) =>
      UserEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        countryCode: countryCode ?? this.countryCode,
        phone: phone ?? this.phone,
        upiId: upiId ?? this.upiId,
        dp: dp ?? this.dp,
      );

  @override
  List<Object?> get props => [id, name, email, countryCode, phone, upiId, dp];
}
