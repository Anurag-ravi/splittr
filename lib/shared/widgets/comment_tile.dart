import 'package:flutter/material.dart';
import 'package:splittr/features/expenses/data/models/comment_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/shared/services/comment_diff_service.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.tripUserMap,
    required this.myUserId,
    required this.onDelete,
  });

  final CommentModel comment;
  final Map<String, TripMemberModel> tripUserMap;
  final String? myUserId;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isSystem = comment.type == 'system';
    final canDelete = !isSystem && comment.createdByUser == myUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/profile/${comment.createdByDp}.png',
              height: 32,
              width: 32,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSystem)
                  Text(
                    comment.createdByName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  comment.body,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                if (isSystem && comment.diff != null)
                  CommentDiffService.buildDiffWidget(
                    comment.diff!,
                    comment.entityType,
                    tripUserMap,
                  ),
                const SizedBox(height: 3),
                Text(
                  _formatTime(comment.createdAt),
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          if (canDelete)
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.close, color: Colors.white38, size: 16),
            ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    int hour = dt.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final hr = hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $hr:$min $ampm';
  }
}
