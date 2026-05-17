import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';

abstract final class CommentDiffService {
  /// Builds a widget showing human-readable before/after change lines
  /// from a comment's raw diff JSON. Returns [SizedBox.shrink] when empty.
  static Widget buildDiffWidget(
    String diffJson,
    String entityType,
    Map<String, TripMemberModel> tripUserMap,
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

    final isCreated = before == null;
    final List<String> lines;

    if (entityType == 'expense') {
      lines = _expenseDiff(before, after, isCreated, tripUserMap);
    } else if (entityType == 'payment') {
      lines = _paymentDiff(before, after, isCreated, tripUserMap);
    } else {
      return const SizedBox.shrink();
    }

    if (lines.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines
            .map(
              (line) => Text(
                line,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            )
            .toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------

  static List<String> _expenseDiff(
    Map<String, dynamic>? before,
    Map<String, dynamic> after,
    bool isCreated,
    Map<String, TripMemberModel> tripUserMap,
  ) {
    final lines = <String>[];

    void compare(String key, String label, {String Function(dynamic)? fmt}) {
      final f = fmt ?? (v) => '$v';
      if (isCreated) {
        if (after[key] != null) lines.add('$label set to ${f(after[key])}');
      } else {
        final bv = before![key];
        final av = after[key];
        if (bv != null && av != null && '$bv' != '$av') {
          lines.add('$label changed from ${f(bv)} to ${f(av)}');
        }
      }
    }

    compare('name', 'Name');
    compare('amount', 'Amount',
        fmt: (v) => '₹${((v as num) + 0.0).toStringAsFixed(2)}');
    compare('category', 'Category');
    compare('split_type', 'Split type');
    compare('description', 'Description');

    final bPaidBy =
        isCreated ? null : _paidByStr(before!['paid_by'], tripUserMap);
    final aPaidBy = _paidByStr(after['paid_by'], tripUserMap);
    if (aPaidBy != null) {
      if (isCreated) {
        lines.add('Paid by: $aPaidBy');
      } else if (bPaidBy != aPaidBy) {
        lines.add('Paid by changed from $bPaidBy to $aPaidBy');
      }
    }

    final bFor =
        isCreated ? null : _paidForStr(before!['paid_for'], tripUserMap);
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

  static List<String> _paymentDiff(
    Map<String, dynamic>? before,
    Map<String, dynamic> after,
    bool isCreated,
    Map<String, TripMemberModel> tripUserMap,
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
        if (bv != null && av != null && '$bv' != '$av') {
          lines.add('$label changed from ${f(bv)} to ${f(av)}');
        }
      }
    }

    compare('amount', 'Amount',
        fmt: (v) => '₹${((v as num) + 0.0).toStringAsFixed(2)}');
    compare('by', 'Paid by', fmt: userName);
    compare('to', 'Paid to', fmt: userName);

    return lines;
  }

  static String? _paidByStr(dynamic list, Map<String, TripMemberModel> map) {
    if (list == null) return null;
    final items = (list as List).map((e) {
      final name = map[e['user'] as String]?.name ?? e['user'];
      final amt = ((e['amount'] as num) + 0.0).toStringAsFixed(2);
      return '$name ₹$amt';
    }).toList();
    return items.isEmpty ? null : items.join(', ');
  }

  static String? _paidForStr(dynamic list, Map<String, TripMemberModel> map) {
    if (list == null) return null;
    final items = (list as List).map((e) {
      final name = map[e['user'] as String]?.name ?? e['user'];
      final amt = ((e['amount'] as num) + 0.0).toStringAsFixed(2);
      return '$name ₹$amt';
    }).toList();
    return items.isEmpty ? null : items.join(', ');
  }
}
