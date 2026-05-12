import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/activity.dart';
import 'package:splittr/utilities/activity_navigator.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<ActivityModel> activities = [];
  bool loading = true;
  bool loadingMore = false;
  bool hasMore = true;
  String? _loadingActivityId;
  int offset = 0;
  static const int _limit = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetch(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !loadingMore &&
        hasMore) {
      _fetch();
    }
  }

  Future<void> _fetch({bool reset = false}) async {
    if (reset) {
      setState(() {
        loading = true;
        activities = [];
        offset = 0;
        hasMore = true;
      });
    } else {
      setState(() => loadingMore = true);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    if (url == null || token == null) return;

    final data = await getRequest(
      '$url/activity/?offset=$offset&limit=$_limit',
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      prefs,
      context,
    );

    if (!mounted) return;

    if (data != null && data['status'] == 200) {
      final List<ActivityModel> fetched = (data['data'] as List)
          .map((e) => ActivityModel.fromJson(e))
          .toList();
      final int total = int.tryParse(data['pagination']['total'].toString()) ?? 0;

      setState(() {
        activities.addAll(fetched);
        offset += fetched.length;
        hasMore = activities.length < total;
      });
    }

    setState(() {
      loading = false;
      loadingMore = false;
    });
  }

  Future<void> _markRead(ActivityModel activity) async {
    if (activity.read) return;

    setState(() => activity.read = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('url');
    String? token = prefs.getString('token');
    if (url == null || token == null) return;

    await postRequest(
      '$url/activity/${activity.id}/read',
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      '{}',
      prefs,
      context,
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  Widget _buildIcon(ActivityModel activity) {
    if (activity.entityType == 'trip') {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.group, color: Colors.white70, size: 28),
      );
    }

    final String assetName = activity.entityType == 'payment'
        ? 'payment'
        : (activity.category ?? 'general');

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        'assets/categories/$assetName.png',
        width: 48,
        height: 48,
        errorBuilder: (_, __, ___) => Container(
          width: 48,
          height: 48,
          color: Colors.grey[700],
          child: const Icon(Icons.receipt, color: Colors.white54),
        ),
      ),
    );
  }

  Color _subtitleColor(String? net) {
    switch (net) {
      case '+':
        return mainGreen;
      case '-':
        return mainOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: loading
          ? const Center(child: CircularProgressIndicator(color: mainGreen))
          : RefreshIndicator(
              color: mainGreen,
              onRefresh: () => _fetch(reset: true),
              child: activities.isEmpty
                  ? const Center(
                      child: Text('No activity yet',
                          style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: activities.length + (loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == activities.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: mainGreen)),
                          );
                        }
                        final activity = activities[index];
                        final isLoading = _loadingActivityId == activity.id;
                        return _ActivityTile(
                          activity: activity,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: mainGreen),
                                  ),
                                )
                              : _buildIcon(activity),
                          subtitleColor: _subtitleColor(activity.net),
                          dateText: _formatDate(activity.createdAt),
                          onTap: _loadingActivityId != null
                              ? null
                              : () async {
                                  final ctx = context;
                                  setState(() => _loadingActivityId = activity.id);
                                  await _markRead(activity);
                                  if (!ctx.mounted) return;
                                  await ActivityNavigator.navigate(
                                      ctx, activity.entityId, activity.entityType);
                                  if (!ctx.mounted) return;
                                  setState(() => _loadingActivityId = null);
                                },
                        );
                      },
                    ),
            ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.icon,
    required this.subtitleColor,
    required this.dateText,
    required this.onTap,
  });

  final ActivityModel activity;
  final Widget icon;
  final Color subtitleColor;
  final String dateText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool unread = !activity.read;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: unread ? Colors.grey[800] : Colors.transparent,
          border: unread
              ? const Border(
                  left: BorderSide(color: mainGreen, width: 3),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  if (activity.subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      activity.subtitle!,
                      style: TextStyle(color: subtitleColor, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              dateText,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
