import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/features/activity/presentation/controllers/activity_controller.dart';
import 'package:splittr/features/activity/presentation/states/activity_state.dart';

final activityNotifierProvider =
    AsyncNotifierProvider<ActivityNotifier, ActivityFeedData>(
        ActivityNotifier.new);
