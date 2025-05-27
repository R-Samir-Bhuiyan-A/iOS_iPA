import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  String number = '';
  int amount = 0;
  bool loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => loading = true);
    final success = await Provider.of<WalletProvider>(context, listen: false)
        .requestWithdraw(number, amount);
    setState(() => loading = false);

    final msg = success ? 'Withdraw request sent!' : 'Failed or amount < 100';
    showDialog(context: context, builder: (_) => AlertDialog(title: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Withdraw')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Number'),
              onSaved: (val) => number = val ?? '',
              validator: (val) => val == null || val.length < 10 ? 'Enter valid number' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onSaved: (val) => amount = int.tryParse(val ?? '0') ?? 0,
              validator: (val) => (int.tryParse(val ?? '') ?? 0) < 100 ? 'Minimum is 100' : null,
            ),
            SizedBox(height: 20),
            loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: Text('Submit Withdraw')),
          ]),
        ),
      ),
    );
  }
}
