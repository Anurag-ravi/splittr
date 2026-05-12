import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:splittr/models/tripuser.dart';

/// Builds a list of human-readable change lines from a comment's raw diff JSON.
///
/// Pass [entityType] as "expense" or "payment" to select the right field set.
/// [tripUserMap] is used to resolve TripUser IDs to display names.
Widget buildDiffWidget(
  String diffJson,
  String entityType,
  Map<String, TripUser> tripUserMap,
) {
  Map<String, dynamic> diff;
  try {
    diff = jsonDecode(diffJson) as Map<String, dynamic>;
  } catch (_) {
    return const SizedBox.shrink();
  }

  final before = diff['before'] as Map<String, dynamic>?;
  final after = diff['after'] as Map<String, dynamic>?;
  if (after == null) return const SizedBox.shrink();

  final bool isCreated = before == null;
  final lines = <String>[];

  if (entityType == 'expense') {
    lines.addAll(_expenseDiff(before, after, isCreated, tripUserMap));
  } else if (entityType == 'payment') {
    lines.addAll(_paymentDiff(before, after, isCreated, tripUserMap));
  }

  if (lines.isEmpty) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map((line) => Text(
                line,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ))
          .toList(),
    ),
  );
}

List<String> _expenseDiff(
  Map<String, dynamic>? before,
  Map<String, dynamic> after,
  bool isCreated,
  Map<String, TripUser> tripUserMap,
) {
  final lines = <String>[];

  void compareField(String key, String label, {String Function(dynamic)? fmt}) {
    final f = fmt ?? (v) => '$v';
    if (isCreated) {
      if (after[key] != null) lines.add('$label set to ${f(after[key])}');
    } else {
      final bv = before![key];
      final av = after[key];
      if (bv != null && av != null && bv.toString() != av.toString()) {
        lines.add('$label changed from ${f(bv)} to ${f(av)}');
      }
    }
  }

  compareField('name', 'Name');
  compareField('amount', 'Amount', fmt: (v) => '₹${(v + 0.0).toStringAsFixed(2)}');
  compareField('category', 'Category');
  compareField('split_type', 'Split type');
  compareField('description', 'Description');

  // paid_by
  final bPaidBy = isCreated ? null : _paidByStr(before!['paid_by'], tripUserMap);
  final aPaidBy = _paidByStr(after['paid_by'], tripUserMap);
  if (aPaidBy != null) {
    if (isCreated) {
      lines.add('Paid by: $aPaidBy');
    } else if (bPaidBy != aPaidBy) {
      lines.add('Paid by changed from $bPaidBy to $aPaidBy');
    }
  }

  // paid_for
  final bFor = isCreated ? null : _paidForStr(before!['paid_for'], tripUserMap);
  final aFor = _paidForStr(after['paid_for'], tripUserMap);
  if (aFor != null) {
    if (isCreated) {
      lines.add('Split for: $aFor');
    } else if (bFor != aFor) {
      lines.add('Split changed from $bFor to $aFor');
    }
  }

  return lines;
}

List<String> _paymentDiff(
  Map<String, dynamic>? before,
  Map<String, dynamic> after,
  bool isCreated,
  Map<String, TripUser> tripUserMap,
) {
  final lines = <String>[];

  String userName(dynamic id) =>
      tripUserMap[id?.toString()]?.name ?? id?.toString() ?? '?';

  void compare(String key, String label, {String Function(dynamic)? fmt}) {
    final f = fmt ?? (v) => '$v';
    if (isCreated) {
      if (after[key] != null) lines.add('$label: ${f(after[key])}');
    } else {
      final bv = before![key];
      final av = after[key];
      if (bv != null && av != null && bv.toString() != av.toString()) {
        lines.add('$label changed from ${f(bv)} to ${f(av)}');
      }
    }
  }

  compare('amount', 'Amount', fmt: (v) => '₹${(v + 0.0).toStringAsFixed(2)}');
  compare('by', 'Paid by', fmt: userName);
  compare('to', 'Paid to', fmt: userName);

  return lines;
}

String? _paidByStr(dynamic list, Map<String, TripUser> map) {
  if (list == null) return null;
  final items = (list as List).map((e) {
    final name = map[e['user']]?.name ?? e['user'];
    final amt = (e['amount'] + 0.0).toStringAsFixed(2);
    return '$name ₹$amt';
  }).toList();
  return items.isEmpty ? null : items.join(', ');
}

String? _paidForStr(dynamic list, Map<String, TripUser> map) {
  if (list == null) return null;
  final items = (list as List).map((e) {
    final name = map[e['user']]?.name ?? e['user'];
    final amt = (e['amount'] + 0.0).toStringAsFixed(2);
    return '$name ₹$amt';
  }).toList();
  return items.isEmpty ? null : items.join(', ');
}
