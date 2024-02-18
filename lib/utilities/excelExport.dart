// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

Future<SnackBar> excelExport(
    TripModel trip, Map<String, TripUser> tripUserMap) async {
  List<List<CellValue>> rows = [];
  List<CellValue> row = [];
  row.add(TextCellValue('Date'));
  row.add(TextCellValue('Name'));
  row.add(TextCellValue('Category'));
  row.add(TextCellValue('Amount'));
  List<double> userTotal = [];
  for (var tu in trip.users) {
    row.add(TextCellValue(tu.name));
    userTotal.add(0);
  }
  rows.add(row);
  List<Transaction> transactions = [];
  for (var expense in trip.expenses) {
    transactions.add(Transaction(true, expense.created, expense, null));
  }
  for (var payment in trip.payments) {
    transactions.add(Transaction(false, payment.created, null, payment));
  }
  transactions.sort((a, b) => a.date.compareTo(b.date));
  for (var transaction in transactions) {
    List<CellValue> row = [];
    row.add(TextCellValue(transaction.date.day.toString() +
        "/" +
        transaction.date.month.toString() +
        "/" +
        transaction.date.year.toString()));
    if (transaction.isExpense && transaction.expense != null) {
      row.add(TextCellValue(transaction.expense!.name));
      row.add(TextCellValue(catMap[transaction.expense!.category]!));
      row.add(TextCellValue(transaction.expense!.amount.toStringAsFixed(2)));
    } else if (!transaction.isExpense && transaction.payment != null) {
      row.add(TextCellValue(
          "${tripUserMap[transaction.payment!.by]!.name} paid ${tripUserMap[transaction.payment!.to]!.name}"));
      row.add(TextCellValue("Payment"));
      row.add(TextCellValue(transaction.payment!.amount.toStringAsFixed(2)));
    }
    for (var tu in trip.users) {
      double amount = 0;
      if (transaction.isExpense) {
        for (var by in transaction.expense!.paid_by) {
          if (by.user == tu.id) {
            amount += by.amount;
          }
        }
        for (var to in transaction.expense!.paid_for) {
          if (to.user == tu.id) {
            amount -= to.amount;
          }
        }
      } else {
        if (transaction.payment!.by == tu.id) {
          amount += transaction.payment!.amount;
        }
        if (transaction.payment!.to == tu.id) {
          amount -= transaction.payment!.amount;
        }
      }
      row.add(TextCellValue(amount.toStringAsFixed(2)));
      userTotal[trip.users.indexOf(tu)] += amount;
    }
    rows.add(row);
  }
  // add empty row
  rows.add([TextCellValue("")]);
  // add total row
  List<CellValue> last = [];
  DateTime now = DateTime.now();
  last.add(TextCellValue('${now.day}/${now.month}/${now.year}'));
  last.add(TextCellValue('Total'));
  last.add(TextCellValue(''));
  last.add(TextCellValue(''));
  for (var total in userTotal) {
    last.add(TextCellValue(total.toStringAsFixed(2)));
  }
  rows.add(last);

  var excel = Excel.createExcel();
  try {
    Sheet sheetObject = excel['Sheet1'];
    for (var row in rows) {
      sheetObject.appendRow(row);
    }
    var fileBytes = excel.save();
    // request storage permissions
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
      if(await Permission.storage.isPermanentlyDenied){
        openAppSettings();
      }
      if (!await Permission.storage.isGranted) {
        return SnackBar(content: Text('Grant Storage Permission to export'));
      }
    }
    Directory? directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists()) directory = await getExternalStorageDirectory();
    if (directory == null) {
      return SnackBar(content: Text("Could not get downloads directory"));
    }
    var filePath = "${directory.path}/splittr_${trip.name}.xlsx";
    var file = await File(filePath).writeAsBytes(fileBytes!);
    addLog(file.path);
    return SnackBar(
      content: Text('Exported splittr_${trip.name}.xlsx'),
      action: SnackBarAction(
        label: 'Open',
        onPressed: () async {
          haptics();
          OpenFile.open(file.path,
              type:
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        },
      ),
    );
  } catch (e) {
    return SnackBar(content: Text(e.toString()));
  }
}
