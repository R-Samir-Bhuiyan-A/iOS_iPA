import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final numberController = TextEditingController();
  final amountController = TextEditingController();
  final trxIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<WalletProvider>(context, listen: false).fetchBalance();
    Provider.of<WalletProvider>(context, listen: false).fetchDeposits();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = Provider.of<WalletProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Balance: ৳${wallet.balance}', style: TextStyle(fontSize: 20)),
            TextField(controller: numberController, decoration: InputDecoration(labelText: 'Number')),
            TextField(controller: amountController, decoration: InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            TextField(controller: trxIdController, decoration: InputDecoration(labelText: 'Transaction ID')),
            ElevatedButton(
              onPressed: () async {
                final amount = int.tryParse(amountController.text) ?? 0;
                await wallet.requestDeposit(amount, numberController.text, trxIdController.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deposit request sent.')));
              },
              child: Text('Request Deposit'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: wallet.deposits.length,
                itemBuilder: (context, index) {
                  final d = wallet.deposits[index];
                  return ListTile(
                    title: Text('৳${d.amount} - ${d.status}'),
                    subtitle: Text('TRX: ${d.trxId} | ${d.number}'),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
