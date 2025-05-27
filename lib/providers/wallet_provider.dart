import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/deposit.dart';

class WalletProvider with ChangeNotifier {
  int balance = 0;
  List<Deposit> deposits = [];

  Future<void> fetchBalance() async {
    final res = await ApiService.post('/wallet/balance.php', {});  // <-- add empty map here
    if (res['status'] == 'success') {
      balance = res['data']['balance'];
      notifyListeners();
    }
  }

  Future<void> requestDeposit(int amount, String number, String trxId) async {
    final res = await ApiService.post('/wallet/deposit.php', {
      'amount': amount,
      'number': number,
      'trx_id': trxId,
    });
    if (res['status'] == 'success') {
      await fetchDeposits();
      notifyListeners();
    }
  }

  Future<void> fetchDeposits() async {
    final res = await ApiService.get('/wallet/list_deposits.php');
    if (res['status'] == 'success') {
      deposits = (res['data'] as List).map((d) => Deposit.fromJson(d)).toList();
      notifyListeners();
    }
  }

  // New: Withdraw request method
  Future<bool> requestWithdraw(String number, int amount) async {
    if (amount < 100) return false;

    final res = await ApiService.post('/wallet/withdraw.php', {
      'number': number,
      'amount': amount,
    });
    return res['status'] == 'success';
  }
}
