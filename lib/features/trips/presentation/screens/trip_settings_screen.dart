// trip_settings_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/features/trips/presentation/controllers/trip_controller.dart';
import 'package:splittr/features/trips/presentation/providers/trip_providers.dart';

class TripSettingsScreen extends ConsumerStatefulWidget {
  const TripSettingsScreen({
    super.key,
    required this.trip,
    required this.free,
    required this.currentUserID,
    required this.deletable,
  });

  final TripModel trip;
  final bool free;
  final String currentUserID;
  final bool deletable;

  @override
  ConsumerState<TripSettingsScreen> createState() => _TripSettingsScreenState();
}

class _TripSettingsScreenState extends ConsumerState<TripSettingsScreen> {
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.trip.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // =====================================================
            // HEADER
            // =====================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                8,
                14,
                0,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Haptics.medium();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.82),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.08),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      'Group Settings',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // =====================================================
            // BODY
            // =====================================================

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  bottom: 40,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  // =====================================================
                  // GROUP CARD
                  // =====================================================

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 20,
                          sigmaY: 20,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.05),
                                blurRadius: 26,
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colorScheme.primary.withOpacity(0.20),
                                      colorScheme.primary.withOpacity(0.05),
                                    ],
                                  ),
                                  border: Border.all(
                                    color:
                                        colorScheme.primary.withOpacity(0.16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          colorScheme.primary.withOpacity(0.14),
                                      blurRadius: 18,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.groups_rounded,
                                    size: 42,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${widget.trip.users.length} members',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.textTheme.bodyMedium?.color
                                            ?.withOpacity(0.62),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _showEditDialog,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color:
                                        colorScheme.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    Icons.edit_rounded,
                                    color: colorScheme.primary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _optionTile(
                    context,
                    icon: Icons.group_add_rounded,
                    title: 'Add people to group',
                    onTap: () {
                      Haptics.medium();
                      Navigator.pushNamed(context, '/add-to-group',
                          arguments: widget.trip);
                    },
                  ),

                  _optionTile(
                    context,
                    icon: Icons.person_remove_rounded,
                    title: 'Remove people from group',
                    onTap: () {
                      Haptics.medium();
                      Navigator.pushNamed(context, '/remove-from-group',
                          arguments: widget.trip);
                    },
                  ),

                  _optionTile(
                    context,
                    icon: Icons.link_rounded,
                    title: 'Invite via link',
                    subtitle: 'Share invite code with friends',
                    onTap: () async {
                      Haptics.medium();
                      SharePlus.instance.share(ShareParams(
                        title: 'Invite to Group',
                        text:
                            'Use this code: ${widget.trip.code} to join my Splittr Group: ${widget.trip.name}',
                      ));
                    },
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Text(
                      'Group Members',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =====================================================
                  // MEMBERS LIST
                  // =====================================================

                  ...widget.trip.users.map(
                    (user) => _memberTile(
                      context,
                      user,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // =====================================================
                  // ADVANCED TITLE
                  // =====================================================

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Text(
                      'Advanced',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =====================================================
                  // LEAVE GROUP
                  // =====================================================

                  _dangerTile(
                    context,
                    icon: Icons.logout_rounded,
                    title: 'Leave Group',
                    subtitle: widget.free
                        ? 'Leave this group permanently'
                        : 'You cannot leave because you have outstanding balances',
                    enabled: widget.free,
                    onTap: () {},
                  ),

                  // =====================================================
                  // DELETE GROUP
                  // =====================================================

                  _dangerTile(
                    context,
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete Group',
                    subtitle: widget.deletable
                        ? 'Delete this group permanently'
                        : 'You cannot delete because balances still exist',
                    enabled: widget.deletable,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // OPTION TILE
  // =====================================================

  Widget _optionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 10,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.04),
              blurRadius: 22,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: colorScheme.primary.withOpacity(0.10),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.60),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.38),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // MEMBER TILE
  // =====================================================

  Widget _memberTile(
    BuildContext context,
    dynamic user,
  ) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 10,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 54,
              height: 54,
              child: Image.asset(
                'assets/profile/${user.dp}.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              user.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.trip.createdBy == user.id)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Admin',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =====================================================
  // DANGER TILE
  // =====================================================

  Widget _dangerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: enabled ? 1 : 0.42,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 10,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.red.withOpacity(0.06),
            border: Border.all(
              color: Colors.red.withOpacity(0.12),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.red.withOpacity(0.10),
                ),
                child: Icon(
                  icon,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.60),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // EDIT DIALOG
  // =====================================================

  Future<void> _showEditDialog() async {
    final controller = TextEditingController(
      text: _name,
    );

    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Edit Group Name',
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Group name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () async {
                final value = controller.text.trim();

                if (value.isEmpty) return;

                Haptics.medium();

                await ref
                    .read(
                      tripProvider(widget.trip).notifier,
                    )
                    .updateTripName(
                      value,
                    );

                if (!mounted) return;

                setState(() {
                  _name = value;
                });

                Navigator.pop(context);
              },
              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );
  }
}
