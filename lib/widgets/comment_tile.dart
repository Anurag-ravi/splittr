import 'package:flutter/material.dart';
import 'package:splittr/models/comment.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/utilities/comment_diff.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.tripUserMap,
    required this.myUserId,
    required this.onDelete,
  });

  final CommentModel comment;
  final Map<String, TripUser> tripUserMap;
  final String? myUserId;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isSystem = comment.type == 'system';
    final canDelete = !isSystem && comment.created_by_user == myUserId;
    final timeStr = _formatTime(comment.created_at);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/profile/${comment.created_by_dp}.png',
              height: 32.0,
              width: 32.0,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSystem)
                  Text(
                    comment.created_by_name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 2),
                Text(
                  comment.body_text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isSystem && comment.diff != null)
                  buildDiffWidget(
                      comment.diff!, comment.entity_type, tripUserMap),
                const SizedBox(height: 3),
                Text(
                  timeStr,
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          if (canDelete)
            GestureDetector(
              onTap: onDelete,
              child:
                  const Icon(Icons.close, color: Colors.white38, size: 16),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    int hour = dt.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final hr = hour < 10 ? '0$hour' : '$hour';
    final min = dt.minute < 10 ? '0${dt.minute}' : '${dt.minute}';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $hr:$min $ampm';
  }
}
