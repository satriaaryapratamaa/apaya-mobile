import 'package:flutter/material.dart';

class HistoriPage extends StatelessWidget {
  const HistoriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHistoryCard('Barang Masuk: Kopi Sachet', '+50', '12 Apr 2024', Colors.green),
        _buildHistoryCard('Barang Keluar: Sabun Mandi', '-30', '10 Apr 2024', Colors.red),
        _buildHistoryCard('Penyesuaian Stok: Minyak Goreng', '+10', '08 Apr 2024', Colors.green),
      ],
    );
  }

  Widget _buildHistoryCard(String title, String amount, String date, Color amountColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: RichText(
          text: TextSpan(
            text: '$title ',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: amount, style: TextStyle(color: amountColor)),
            ],
          ),
        ),
        subtitle: Text(date),
      ),
    );
  }
}