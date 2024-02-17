// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/utilities/constants.dart';
import 'package:splittr/utilities/request.dart';

Future<String> excelExport(TripModel trip,Map<String,TripUser> tripUserMap) async {
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
      row.add(DateCellValue(year: transaction.date.year, month: transaction.date.month, day: transaction.date.day));
      if (transaction.isExpense && transaction.expense != null) {
        row.add(TextCellValue(transaction.expense!.name));
        row.add(TextCellValue(catMap[transaction.expense!.category]!));
        row.add(DoubleCellValue(double.parse(transaction.expense!.amount.toStringAsFixed(2))));
      } else {
        row.add(TextCellValue("${tripUserMap[transaction.payment!.by]!.name} paid ${tripUserMap[transaction.payment!.to]!.name}"));
        row.add(TextCellValue("Payment"));
        row.add(DoubleCellValue(double.parse(transaction.payment!.amount.toStringAsFixed(2))));
      }
      for (var tu in trip.users) {
        double amount = 0;
        if (transaction.isExpense) {
          for( var by in transaction.expense!.paid_by) {
            if (by.user == tu.id) {
              amount += by.amount;
            }
          }
          for( var to in transaction.expense!.paid_for) {
            if (to.user == tu.id) {
              amount -= to.amount;
            }
          }
        } else {
          if(transaction.payment!.by == tu.id) {
            amount += transaction.payment!.amount;
          }
          if(transaction.payment!.to == tu.id) {
            amount -= transaction.payment!.amount;
          }
        }
        row.add(DoubleCellValue(double.parse(amount.toStringAsFixed(2)))); 
        userTotal[trip.users.indexOf(tu)] += amount;
      }
      rows.add(row);
    }
    // add empty row
    rows.add([]);
    // add total row
    List<CellValue> last = [];
    last.add(DateCellValue(year: DateTime.now().year, month: DateTime.now().month, day: DateTime.now().day));
    last.add(TextCellValue('Total'));
    last.add(TextCellValue(''));
    last.add(TextCellValue(''));
    for (var total in userTotal) {
      last.add(DoubleCellValue(double.parse(total.toStringAsFixed(2))));
    }
    rows.add(last);
    addLog(rows.toString());

    var excel = Excel.createExcel();
    try {
      Sheet sheetObject = excel['Sheet1'];
      for (var row in rows) {
        sheetObject.appendRow(row);
      }
      var fileBytes = excel.save();
      var directory = await getApplicationDocumentsDirectory();
      var filePath = "${directory.path}/splittr_${trip.name}_${trip.created.day}-${trip.created.month}-${trip.created.year}.xlsx";
      addLog(filePath);
      File(filePath).writeAsBytes(fileBytes!);
      return filePath;
    } catch (e) {
      addLog(e.toString());
      return "";
    }
}