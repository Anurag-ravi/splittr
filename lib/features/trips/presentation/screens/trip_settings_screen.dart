import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/groups/presentation/screens/home_screen.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class TripSettingsScreen extends StatefulWidget {
  const TripSettingsScreen({
    super.key,
    required this.trip,
    required this.free,
    required this.currentUserID,
    required this.deletable,
  });

  final TripModel trip;
  final bool free;
  final bool deletable;
  final String currentUserID;

  @override
  State<TripSettingsScreen> createState() => _TripSettingsScreenState();
}

class _TripSettingsScreenState extends State<TripSettingsScreen> {
  late String _name;
  late TextEditingController _controller;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.trip.name;
    _controller = TextEditingController(text: _name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 4),
      ));

  void _setLoading(bool v) {
    if (!mounted) return;
    setState(() => _loading = v);
  }

  Future<void> _showEditDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit trip name'),
        content: TextField(controller: _controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _name = _controller.text);
              await _editName();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm')),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _editName() async {
    _setLoading(true);
    if (!mounted) return;
    final data = await AppHttpClient.post(
        context, '/trip/${widget.trip.id}/edit', {'name': _name});
    _setLoading(false);
    if (data == null) return;
    _showSnack(data['message']?.toString() ?? '');
    if (data['status'] == 200) {
      await HiveBoxes.trips
          .put(widget.trip.id, widget.trip.copyWith(name: _name));
      if (mounted) setState(() {});
    }
  }

  Future<void> _handleLeave() async {
    if (!widget.free) return;
    final confirmed = await _confirmDialog(
        'Are you sure?', 'This will remove you from this group.');
    if (!confirmed || !mounted) return;
    _setLoading(true);
    final data =
        await AppHttpClient.get(context, '/trip/${widget.trip.id}/leave');
    _setLoading(false);
    if (!mounted) return;
    if (data == null) return;
    _showSnack(data['message']?.toString() ?? '');
    if (data['status'] == 200) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 0)),
      );
    }
  }

  Future<void> _handleDelete() async {
    if (widget.trip.createdBy != widget.currentUserID || !widget.deletable) {
      return;
    }
    final confirmed = await _confirmDialog('Are you sure?',
        'This will permanently delete this group and all its data.');
    if (!confirmed || !mounted) return;
    _setLoading(true);
    final data = await AppHttpClient.delete(context, '/trip/${widget.trip.id}');
    _setLoading(false);
    if (!mounted) return;
    if (data == null) return;
    _showSnack(data['message']?.toString() ?? '');
    if (data['status'] == 200) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 0)),
      );
    }
  }

  Widget _memberTile(TripMemberModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 10),
          ClipOval(
            child: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset('assets/profile/${user.dp}.png'),
            ),
          ),
          const SizedBox(width: 20),
          Text(user.name,
              style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color iconColor = Colors.white,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Opacity(
          opacity: enabled ? 1 : 0.2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 25),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Opacity(
          opacity: _loading ? 0.5 : 1,
          child: Scaffold(
            backgroundColor: Colors.grey[900],
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: const Text('Group Settings',
                  style: TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: ListView(
              children: [
                Container(
                  height: 100,
                  width: w,
                  decoration: const BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Group Details',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              width: 75,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: const DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/images/trip.png'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(_name,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 17)),
                            ),
                            IconButton(
                              onPressed: _showEditDialog,
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Group Members',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                _optionTile(
                  icon: Icons.group_add_outlined,
                  title: 'Add people to group',
                  onTap: () {
                    Haptics.medium();
                    // Navigates to old AddToGroup page (kept as-is)
                    Navigator.pushNamed(context, '/add-to-group',
                        arguments: widget.trip);
                  },
                ),
                _optionTile(
                  icon: Icons.group_remove_outlined,
                  title: 'Remove people from group',
                  onTap: () {
                    Haptics.medium();
                    Navigator.pushNamed(context, '/remove-from-group',
                        arguments: widget.trip);
                  },
                ),
                _optionTile(
                  icon: Icons.link,
                  title: 'Invite via link',
                  onTap: () {
                    Haptics.medium();
                    SharePlus.instance.share(ShareParams(
                      title: 'Invite to Group',
                      text:
                          'Use this code: ${widget.trip.code} to join my Splittr Group: ${widget.trip.name}',
                    ));
                  },
                ),
                ...widget.trip.users.where((u) => u.involved).map(_memberTile),
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text('Advanced settings',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                _optionTile(
                  icon: Icons.exit_to_app_outlined,
                  title: 'Leave Group',
                  enabled: widget.free,
                  subtitle: widget.free
                      ? null
                      : "You can't leave this group because you have outstanding debts.",
                  onTap: _handleLeave,
                ),
                _optionTile(
                  icon: Icons.delete_outline,
                  iconColor: Colors.red,
                  title: 'Delete Group',
                  enabled: widget.trip.createdBy == widget.currentUserID &&
                      widget.deletable,
                  subtitle: widget.trip.createdBy == widget.currentUserID
                      ? "You can't delete this group because there are outstanding debts."
                      : 'You are not the creator of this group.',
                  onTap: _handleDelete,
                ),
              ],
            ),
          ),
        ),
        if (_loading)
          const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
      ],
    );
  }
}
