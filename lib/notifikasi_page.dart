import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildNotifCard(Icons.notifications, 'Stok Kopi Sachet di bawah minimum!', '11 Apr 2024', Colors.orange),
        _buildNotifCard(Icons.notifications, 'Pesanan Baru: Order #1234', '09 Apr 2024', Colors.yellow[700]!),
        _buildNotifCard(Icons.notifications, 'Stok Air Mineral sisa tinggal 10 lagi', '07 Apr 2024', Colors.orange),
        _buildNotifCard(Icons.notifications, 'Update Stok Berhasil!', '05 Apr 2024', Colors.green),
      ],
    );
  }

  Widget _buildNotifCard(IconData icon, String title, String date, Color iconColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(date),
      ),
    );
  }
}