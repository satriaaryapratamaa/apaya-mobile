import 'package:flutter/material.dart';

class BarangPage extends StatelessWidget {
  const BarangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari Produk...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // Daftar Item (Mockup)
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildItemCard('Kopi Sachet', '150', 'Rp 2.000'),
              _buildItemCard('Minyak Goreng', '85', 'Rp 14.000'),
              _buildItemCard('Sabun Mandi', '120', 'Rp 5.000'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(String nama, String stok, String harga) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Stok: $stok\nHarga $harga'),
        trailing: const Icon(Icons.inventory, size: 40, color: Colors.orange), // Dummy Icon
        isThreeLine: true,
      ),
    );
  }
}