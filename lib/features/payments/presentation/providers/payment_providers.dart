import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/features/payments/presentation/controllers/payment_controller.dart';
import 'package:splittr/features/payments/presentation/states/payment_state.dart';

final paymentNotifierProvider =
    AsyncNotifierProvider<PaymentNotifier, PaymentSavedData?>(
        PaymentNotifier.new);
