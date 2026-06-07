import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/features/trips/presentation/controllers/trip_controller.dart';
import 'package:splittr/features/trips/presentation/states/trip_state.dart';

final tripProvider =
    AsyncNotifierProviderFamily<TripNotifier, TripScreenData, TripModel>(
        TripNotifier.new);
