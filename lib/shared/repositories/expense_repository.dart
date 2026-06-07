import 'package:flutter/material.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';

class ExpenseRepository {
  const ExpenseRepository();

  Future<Map<String, dynamic>?> createExpense(
    BuildContext context, {
    required String tripId,
    required String name,
    required double amount,
    required String category,
    required String splitType,
    required List<Map<String, dynamic>> paidBy,
    required List<Map<String, dynamic>> paidFor,
    required String created,
  }) =>
      AppHttpClient.post(context, '/expense/new', {
        'id': '',
        'trip': tripId,
        'name': name,
        'amount': amount,
        'category': category,
        'split_type': splitType,
        'paid_by': paidBy,
        'paid_for': paidFor,
        'created': created,
      });

  Future<Map<String, dynamic>?> updateExpense(
    BuildContext context, {
    required String expenseId,
    required String tripId,
    required String name,
    required double amount,
    required String category,
    required String splitType,
    required List<Map<String, dynamic>> paidBy,
    required List<Map<String, dynamic>> paidFor,
    required String created,
  }) =>
      AppHttpClient.post(context, '/expense/update', {
        'id': expenseId,
        'trip': tripId,
        'name': name,
        'amount': amount,
        'category': category,
        'split_type': splitType,
        'paid_by': paidBy,
        'paid_for': paidFor,
        'created': created,
      });

  Future<Map<String, dynamic>?> deleteExpense(
          BuildContext context, String expenseId) =>
      AppHttpClient.delete(context, '/expense/$expenseId');

  Future<void> cacheExpense(ExpenseModel expense) =>
      HiveBoxes.expenses.put(expense.id, expense);
}
