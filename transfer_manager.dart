import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transfers.dart';

class TransferManager extends ChangeNotifier {
  late Box<Transfer> _transferBox;

  List<Transfer> get transfers => _transferBox.values.toList();
  double get totalTransfersAmount => transfers.fold(
        0.0,
        (sum, transfer) => sum + (transfer.amount ?? 0.0),
      );

  Future<void> init() async {
    _transferBox = Hive.box<Transfer>('transfers');
    notifyListeners();
  }

  List<Transfer> getTransfers() {
    return transfers;
  }

  Future<void> addTransfer(String name, double amount, String date) async {
    final transfer = Transfer(name: name, amount: amount, date: date);
    await _transferBox.add(transfer);
    notifyListeners(); 
  }

  Future<void> deleteTransfer(int index) async {
    await _transferBox.deleteAt(index);
    notifyListeners(); 
  }

  Future<void> clearAllTransfers() async {
    await _transferBox.clear();
    notifyListeners();
  }

  Future<void> updateTransfer(
      int index, String name, double amount, String date) async {
    final transfer = _transferBox.getAt(index);
    if (transfer != null) {
      transfer.name = name;
      transfer.amount = amount;
      transfer.date = date;
      await transfer.save();
      notifyListeners();
    }
  }
}
