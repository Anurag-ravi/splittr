// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'dart:math';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/utilities/constants.dart';

Future<SnackBar> excelExport(
    TripModel trip, Map<String, TripUser> tripUserMap) async {
  List<List<CellValue>> rows = [];
  List<CellValue> row = [], row2 = [];
  row.add(TextCellValue('Date'));
  row2.add(TextCellValue(''));
  row.add(TextCellValue('Name'));
  row2.add(TextCellValue(''));
  row.add(TextCellValue('Category'));
  row2.add(TextCellValue(''));
  row.add(TextCellValue('Amount'));
  row2.add(TextCellValue(''));
  List<double> userPaid = [], userOwed = [], userTotal = [];
  for (var tu in trip.users) {
    row.add(TextCellValue(tu.name));
    row.add(TextCellValue(''));
    row2.add(TextCellValue('paid'));
    row2.add(TextCellValue('owed'));
    userPaid.add(0);
    userOwed.add(0);
    userTotal.add(0);
  }
  List<int> columnWidths = [];
  for (var x in row) {
    columnWidths.add(x.toString().length);
  }
  for(var x in row2) {
    columnWidths[row2.indexOf(x)] =
          max(columnWidths[row2.indexOf(x)], x.toString().length);
  }
  rows.add(row);
  rows.add(row2);
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
    int hours = transaction.date.hour;
    int minutes = transaction.date.minute;
    if(hours > 12) {
      hours -= 12;
    }
    String am_pm = transaction.date.hour > 12 ? "PM" : "AM";
    String hr = hours > 9 ? hours.toString() : "0" + hours.toString();
    String min = minutes > 9 ? minutes.toString() : "0" + minutes.toString();
    row.add(TextCellValue(transaction.date.day.toString() +
        "/" +
        transaction.date.month.toString() +
        "/" +
        transaction.date.year.toString() +
        " " +
        hr +
        ":" +
        min +
        " " +
        am_pm
        ));
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
      double paid = 0,owed = 0;
      if (transaction.isExpense) {
        for (var by in transaction.expense!.paid_by) {
          if (by.user == tu.id) {
            paid += by.amount;
          }
        }
        for (var to in transaction.expense!.paid_for) {
          if (to.user == tu.id) {
            owed += to.amount;
          }
        }
        userPaid[trip.users.indexOf(tu)] += paid;
        userOwed[trip.users.indexOf(tu)] += owed;
      } else {
        if (transaction.payment!.by == tu.id) {
          paid += transaction.payment!.amount;
        }
        if (transaction.payment!.to == tu.id) {
          owed += transaction.payment!.amount;
        }
      }
      row.add(TextCellValue(paid.toStringAsFixed(2)));
      row.add(TextCellValue(owed.toStringAsFixed(2)));
      userTotal[trip.users.indexOf(tu)] += paid - owed;
    }
    for (var x in row) {
      columnWidths[row.indexOf(x)] =
          max(columnWidths[row.indexOf(x)], x.toString().length);
    }
    rows.add(row);
  }
  // add empty row
  rows.add([TextCellValue("")]);
  // add total row
  List<CellValue> last = [], last2 = [];
  DateTime now = DateTime.now();
  last.add(TextCellValue('${now.day}/${now.month}/${now.year}'));
  last.add(TextCellValue('Total Paid and Total Share'));
  last.add(TextCellValue(''));
  last.add(TextCellValue(''));
  last2.add(TextCellValue(''));
  last2.add(TextCellValue('Remaining Balance'));
  last2.add(TextCellValue(''));
  last2.add(TextCellValue(''));
  for (int i = 0; i < userPaid.length; i++) {
    last.add(TextCellValue(userPaid[i].toStringAsFixed(2)));
    last.add(TextCellValue(userOwed[i].toStringAsFixed(2)));
    last2.add(TextCellValue(userTotal[i].toStringAsFixed(2)));
    last2.add(TextCellValue(''));
  }
  for (var x in last) {
    columnWidths[last.indexOf(x)] =
        max(columnWidths[last.indexOf(x)], x.toString().length);
  }
  for (var x in last2) {
    columnWidths[last2.indexOf(x)] =
        max(columnWidths[last2.indexOf(x)], x.toString().length);
  }
  rows.add(last);
  rows.add(last2);

  var excel = Excel.createExcel();
  try {
    Sheet sheetObject = excel['Sheet1'];
    for (var row in rows) {
      sheetObject.appendRow(row);
    }
    // auto resize columns
    for (var x in columnWidths) {
      sheetObject.setColumnWidth(columnWidths.indexOf(x), x + 0.5);
    }
    // join cells for headers
    int col_len = rows[0].length,row_len = rows.length;
    for (int i = 4; i < col_len; i += 2) {
      sheetObject.merge(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
          CellIndex.indexByColumnRow(columnIndex: i + 1, rowIndex: 0),
          customValue: TextCellValue(rows[0][i].toString())
          );
    }
    // formatting
    for (int i = 0; i < row_len; i++) {
      for (int j = 0; j < col_len; j++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i));
        cell.cellStyle = CellStyle(
            bold: i < 2 || i == row_len - 2 || i == row_len - 1,
            horizontalAlign: i < 2 
                    ? HorizontalAlign.Center 
                    : j < 2
                      ? HorizontalAlign.Left
                      : j == 2
                        ? HorizontalAlign.Center
                        : HorizontalAlign.Right
                    ,
            verticalAlign: VerticalAlign.Center,
            fontSize: i < 2 ? 11 : 10,
          );
      }
    }

    // save file
    var fileBytes = excel.save();
    if(kIsWeb) {
      return SnackBar(content: Text("Downloaded splittr_${trip.name}.xlsx")); 
    }
    // request storage permissions
    Directory? directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists())
      directory = await getExternalStorageDirectory();
    if (directory == null) {
      return SnackBar(content: Text("Could not get downloads directory"));
    }
    var filePath = "${directory.path}/splittr_${trip.name}.xlsx";
    var file = await File(filePath).writeAsBytes(fileBytes!);
    print(file.path);
    return SnackBar(
      content: Text('Downloaded splittr_${trip.name}.xlsx'),
      action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            FlutterShare.shareFile(
              title: 'splittr_${trip.name}.xlsx',
              filePath: file.path,
            );
          },
        ),
    );
  } catch (e) {
    return SnackBar(content: Text(e.toString()));
  }
}
