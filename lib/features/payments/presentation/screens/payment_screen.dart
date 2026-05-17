import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/expenses/presentation/controllers/comments_controller.dart';
import 'package:splittr/features/expenses/presentation/providers/expense_providers.dart';
import 'package:splittr/features/payments/presentation/controllers/payment_controller.dart';
import 'package:splittr/features/payments/presentation/providers/payment_providers.dart';
import 'package:splittr/features/payments/presentation/states/payment_state.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/shared/widgets/comment_tile.dart';

typedef PaymentPageBuilder = Widget Function(BuildContext context);

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.payment,
    required this.tripUserMap,
    required this.paymentPageBuilder,
  });

  final PaymentModel payment;
  final Map<String, TripMemberModel> tripUserMap;
  final PaymentPageBuilder paymentPageBuilder;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final _commentController = TextEditingController();
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _myUserId = HiveBoxes.me.get('me')?.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(commentsProvider(widget.payment.id).notifier)
          .refreshForPayment(widget.payment.id);
    });
    ref.listenManual<AsyncValue<PaymentSavedData?>>(paymentNotifierProvider,
        (_, next) {
      final paymentCtrl = ref.read(paymentNotifierProvider.notifier);
      next.whenOrNull(
        error: (e, _) {
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(e.toString()),
              duration: const Duration(seconds: 4),
            ));
          });
          paymentCtrl.reset();
        },
        data: (result) {
          if (result != null) return;
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context)) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Payment deleted'),
                duration: Duration(seconds: 4),
              ));
              Navigator.pop(context, true);
            }
          });
          paymentCtrl.reset();
        },
      );
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _dateStr() {
    final d = widget.payment.created;
    int h = d.hour;
    final ampm = h >= 12 ? 'PM' : 'AM';
    if (h > 12) h -= 12;
    if (h == 0) h = 12;
    return 'Added on ${_months[d.month - 1]} ${d.day}, ${d.year} at '
        '${h.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.payment.id));
    final commentsCtrl = ref.read(commentsProvider(widget.payment.id).notifier);
    final paymentAsync = ref.watch(paymentNotifierProvider);
    final paymentCtrl = ref.read(paymentNotifierProvider.notifier);

    final comments = commentsAsync.value ?? [];
    final sending = commentsAsync.isLoading;
    final deleting = paymentAsync.isLoading;

    final p = widget.payment;
    final byName = widget.tripUserMap[p.by]?.name ?? '';
    final toName = widget.tripUserMap[p.to]?.name ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          deleting
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () {
                    Haptics.medium();
                    _confirmDelete(context, paymentCtrl);
                  }),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () async {
              Haptics.medium();
              final res = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (ctx) => widget.paymentPageBuilder(ctx)),
              );
              if (!mounted) return;
              if (res == true) Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => commentsCtrl.refreshForPayment(p.id),
              child: ListView(
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset('assets/categories/payment.png',
                          height: 60, width: 60),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text('$byName paid $toName',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 17)),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text('₹${p.amount.toStringAsFixed(2)}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(_dateStr(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                    child: Row(children: [
                      const Text('Activity',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(child: Divider(color: Colors.white24)),
                    ]),
                  ),
                  ...comments.map((c) => CommentTile(
                        comment: c,
                        tripUserMap: widget.tripUserMap,
                        myUserId: _myUserId,
                        onDelete: () =>
                            commentsCtrl.deleteFromPayment(c.id, p.id),
                      )),
                ],
              ),
            ),
          ),
          _commentInput(commentsCtrl, sending),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, PaymentNotifier ctrl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This will permanently delete this payment.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ctrl.delete(widget.payment.id, widget.payment.trip);
    }
  }

  Widget _commentInput(
    CommentsNotifier ctrl,
    bool sending,
  ) {
    final p = widget.payment;
    final byName = widget.tripUserMap[p.by]?.name ?? '';
    final toName = widget.tripUserMap[p.to]?.name ?? '';

    return Container(
      color: Colors.grey[850],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.grey[800],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _post(ctrl, byName, toName),
            ),
          ),
          const SizedBox(width: 8),
          sending
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: () => _post(ctrl, byName, toName)),
        ],
      ),
    );
  }

  void _post(CommentsNotifier ctrl, String byName, String toName) {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    _commentController.clear();
    final p = widget.payment;
    ctrl.postOnPayment(
      text: text,
      paymentId: p.id,
      tripId: p.trip,
      title:
          'Comment added on payment of ₹${p.amount.toStringAsFixed(2)} from $byName to $toName',
    );
  }
}
