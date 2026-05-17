import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/payments/presentation/providers/payment_providers.dart';
import 'package:splittr/features/payments/presentation/states/payment_state.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({
    super.key,
    required this.from,
    required this.to,
    required this.amount,
    required this.tripUserMap,
    this.updating = false,
    this.paymentId = '',
    this.created,
  });

  final String from;
  final String to;
  final double amount;
  final Map<String, TripMemberModel> tripUserMap;
  final bool updating;
  final String paymentId;
  final DateTime? created;

  @override
  ConsumerState<RecordPaymentScreen> createState() =>
      _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
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

  final _amountController = TextEditingController();
  String _amount = '0.00';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.amount.toStringAsFixed(2) != '0.00') {
      _amount = widget.amount.toStringAsFixed(2);
      _amountController.text = _amount;
    }
    if (widget.updating && widget.created != null) {
      _selectedDate = widget.created!;
    }

    ref.listenManual<AsyncValue<PaymentSavedData?>>(paymentNotifierProvider,
        (_, next) {
      final controller = ref.read(paymentNotifierProvider.notifier);
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
          controller.reset();
        },
        data: (result) {
          if (result == null) return;
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(widget.updating ? 'Payment updated' : 'Payment added'),
              duration: const Duration(seconds: 4),
            ));
            Navigator.pop(context, true);
          });
          controller.reset();
        },
      );
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _timeStr(DateTime d) {
    int h = d.hour;
    final ampm = h >= 12 ? 'PM' : 'AM';
    if (h > 12) h -= 12;
    if (h == 0) h = 12;
    return '${h.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final paymentAsync = ref.watch(paymentNotifierProvider);
    final controller = ref.read(paymentNotifierProvider.notifier);
    final saving = paymentAsync.isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.updating ? 'Update Payment' : 'Record Payment',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          IconButton(
            icon: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.done, color: Colors.white),
            onPressed: saving
                ? null
                : () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Haptics.medium();
                    if (_amountController.text.isEmpty) return;
                    controller.record(
                      fromTripUserId: widget.from,
                      toTripUserId: widget.to,
                      amount: double.parse(_amount),
                      tripUserMap: widget.tripUserMap,
                      created: _selectedDate,
                      paymentId: widget.updating ? widget.paymentId : null,
                    );
                  },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset(
                        'assets/profile/${widget.tripUserMap[widget.from]!.dp}.png'),
                  ),
                ),
                const SizedBox(width: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.arrow_right_alt_outlined,
                        color: Colors.white, size: 30),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset(
                        'assets/profile/${widget.tripUserMap[widget.to]!.dp}.png'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '${widget.tripUserMap[widget.from]!.name.trim()} pays ${widget.tripUserMap[widget.to]!.name.trim()}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.currency_rupee_outlined,
                        color: Colors.white),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    cursorColor: AppColors.primary,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) =>
                        setState(() => _amount = v.isEmpty ? '0.00' : v),
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary)),
                      labelText: '0.00',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.grey[900],
                      filled: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month_outlined, color: Colors.white),
                GestureDetector(
                  onTap: () async {
                    Haptics.medium();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            _selectedDate.hour,
                            _selectedDate.minute,
                          ).toLocal());
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        border: const Border(
                            bottom: BorderSide(
                                color: Color(0xffa0a0a0), width: 0.5)),
                      ),
                      child: Center(
                        child: Text(
                          '${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.access_time_outlined, color: Colors.white),
                GestureDetector(
                  onTap: () async {
                    Haptics.medium();
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDate),
                    );
                    if (time != null) {
                      setState(() => _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            time.hour,
                            time.minute,
                          ).toLocal());
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        border: const Border(
                            bottom: BorderSide(
                                color: Color(0xffa0a0a0), width: 0.5)),
                      ),
                      child: Center(
                        child: Text(
                          _timeStr(_selectedDate),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
