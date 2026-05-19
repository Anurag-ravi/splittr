// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'dart:math';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:splittr/core/constants/expense_categories.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

abstract final class ExcelExportService {
  static Future<SnackBar> export(
    TripModel trip,
    Map<String, TripMemberModel> tripUserMap,
    BuildContext context,
  ) async {
    try {
      final rows = _buildRows(trip, tripUserMap);
      final snackBar = await _saveAndReturn(trip.name, rows, context);
      return snackBar;
    } catch (e) {
      return SnackBar(
        content: Text(e.toString()),
        duration: const Duration(seconds: 10),
      );
    }
  }

  // ---------------------------------------------------------------------------

  static List<List<CellValue>> _buildRows(
    TripModel trip,
    Map<String, TripMemberModel> tripUserMap,
  ) {
    final rows = <List<CellValue>>[];

    // Header rows
    final row1 = <CellValue>[
      TextCellValue('Date'),
      TextCellValue('Name'),
      TextCellValue('Category'),
      TextCellValue('Amount'),
    ];
    final row2 = <CellValue>[
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ];

    final userPaid = List.filled(trip.users.length, 0.0);
    final userOwed = List.filled(trip.users.length, 0.0);
    final userTotal = List.filled(trip.users.length, 0.0);

    for (final tu in trip.users) {
      row1.add(TextCellValue(tu.name));
      row1.add(TextCellValue(''));
      row2.add(TextCellValue('paid'));
      row2.add(TextCellValue('owed'));
    }

    rows.add(row1);
    rows.add(row2);

    // Transaction rows
    final transactions = [
      ...trip.expenses.map((e) => _Txn(true, e.created, e, null)),
      ...trip.payments.map((p) => _Txn(false, p.created, null, p)),
    ]..sort((a, b) => a.date.compareTo(b.date));

    for (final txn in transactions) {
      final row = <CellValue>[TextCellValue(_formatDate(txn.date))];

      if (txn.isExpense && txn.expense != null) {
        row.add(TextCellValue(txn.expense!.name));
        row.add(
            TextCellValue(ExpenseCategories.labelOf(txn.expense!.category)));
        row.add(TextCellValue(txn.expense!.amount.toStringAsFixed(2)));
      } else if (txn.payment != null) {
        final byName = tripUserMap[txn.payment!.by]?.name ?? '?';
        final toName = tripUserMap[txn.payment!.to]?.name ?? '?';
        row.add(TextCellValue('$byName paid $toName'));
        row.add(TextCellValue('Payment'));
        row.add(TextCellValue(txn.payment!.amount.toStringAsFixed(2)));
      }

      for (int i = 0; i < trip.users.length; i++) {
        final tu = trip.users[i];
        double paid = 0, owed = 0;
        if (txn.isExpense && txn.expense != null) {
          for (final by in txn.expense!.paidBy) {
            if (by.user == tu.id) paid += by.amount;
          }
          for (final fo in txn.expense!.paidFor) {
            if (fo.user == tu.id) owed += fo.amount;
          }
          userPaid[i] += paid;
          userOwed[i] += owed;
        } else if (txn.payment != null) {
          if (txn.payment!.by == tu.id) paid += txn.payment!.amount;
          if (txn.payment!.to == tu.id) owed += txn.payment!.amount;
        }
        userTotal[i] += paid - owed;
        row.add(TextCellValue(paid.toStringAsFixed(2)));
        row.add(TextCellValue(owed.toStringAsFixed(2)));
      }

      rows.add(row);
    }

    // Summary rows
    rows.add([TextCellValue('')]);
    final now = DateTime.now();
    final summaryRow1 = <CellValue>[
      TextCellValue('${now.day}/${now.month}/${now.year}'),
      TextCellValue('Total Paid and Total Share'),
      TextCellValue(''),
      TextCellValue(''),
    ];
    final summaryRow2 = <CellValue>[
      TextCellValue(''),
      TextCellValue('Remaining Balance'),
      TextCellValue(''),
      TextCellValue(''),
    ];
    for (int i = 0; i < userPaid.length; i++) {
      summaryRow1.add(TextCellValue(userPaid[i].toStringAsFixed(2)));
      summaryRow1.add(TextCellValue(userOwed[i].toStringAsFixed(2)));
      summaryRow2.add(TextCellValue(userTotal[i].toStringAsFixed(2)));
      summaryRow2.add(TextCellValue(''));
    }
    rows.add(summaryRow1);
    rows.add(summaryRow2);

    return rows;
  }

  static Future<SnackBar> _saveAndReturn(
    String tripName,
    List<List<CellValue>> rows,
    BuildContext context,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    final colWidths = List.filled(rows[0].length, 0);

    for (final row in rows) {
      sheet.appendRow(row);
      for (int j = 0; j < row.length && j < colWidths.length; j++) {
        colWidths[j] = max(colWidths[j], row[j].toString().length);
      }
    }

    for (int i = 0; i < colWidths.length; i++) {
      sheet.setColumnWidth(i, colWidths[i] + 0.5);
    }

    // Merge user-name header cells
    for (int i = 4; i < rows[0].length; i += 2) {
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: i + 1, rowIndex: 0),
        customValue: TextCellValue(rows[0][i].toString()),
      );
    }

    // Styling
    final rowLen = rows.length;
    final colLen = rows[0].length;
    for (int i = 0; i < rowLen; i++) {
      for (int j = 0; j < colLen; j++) {
        final cell =
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i));
        cell.cellStyle = CellStyle(
          bold: i < 2 || i == rowLen - 2 || i == rowLen - 1,
          horizontalAlign: i < 2
              ? HorizontalAlign.Center
              : j < 2
                  ? HorizontalAlign.Left
                  : j == 2
                      ? HorizontalAlign.Center
                      : HorizontalAlign.Right,
          verticalAlign: VerticalAlign.Center,
          fontSize: i < 2 ? 11 : 10,
        );
      }
    }

    final fileBytes = excel.save();

    if (kIsWeb) {
      return SnackBar(content: Text('Downloaded splittr_$tripName.xlsx'));
    }

    Directory? dir = Directory('/storage/emulated/0/Download');
    if (!await dir.exists()) dir = await getExternalStorageDirectory();
    if (dir == null) {
      return const SnackBar(content: Text('Could not get downloads directory'));
    }

    final file = await File('${dir.path}/splittr_$tripName.xlsx')
        .writeAsBytes(fileBytes!);

    return SnackBar(
      content: Text('Downloaded splittr_$tripName.xlsx'),
      action: SnackBarAction(
        label: 'Open',
        textColor: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          await SharePlus.instance.share(
            ShareParams(
                title: 'splittr_$tripName.xlsx', files: [XFile(file.path)]),
          );
        },
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final h = d.hour > 12 ? d.hour - 12 : d.hour;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final hr = h.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year} $hr:$min $ampm';
  }
}

class _Txn {
  final bool isExpense;
  final DateTime date;
  final dynamic expense;
  final dynamic payment;

  const _Txn(this.isExpense, this.date, this.expense, this.payment);
}
