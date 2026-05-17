import 'package:equatable/equatable.dart';

class FriendEntity extends Equatable {
  const FriendEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.countryCode,
    required this.phone,
    required this.dp,
  });

  final String id;
  final String name;
  final String email;
  final String countryCode;
  final String phone;
  final String dp;

  @override
  List<Object?> get props => [id, name, email, phone];
}
