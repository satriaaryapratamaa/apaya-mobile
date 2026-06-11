import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Taruh fungsi fetch di sini atau di file terpisah
Future<List<dynamic>> fetchBarang() async {
  // Sesuaikan URL dengan env kamu (10.0.2.2 atau IP Lokal laptop)
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/produk'));

  if (response.statusCode == 200) {
    // Decode response body menjadi Map terlebih dahulu
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse['data'] ?? [];
  } else {
    throw Exception('Gagal memuat data produk');
  }
}

class BarangPage extends StatelessWidget {
  const BarangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar tetap sama
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

        // Daftar Item dari API Laravel
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: fetchBarang(), // Memanggil fungsi API
            builder: (context, snapshot) {
              // Kondisi saat data sedang loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Kondisi saat terjadi error (misal: server mati / IP salah)
              if (snapshot.hasError) {
                return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
              }

              // Kondisi saat data berhasil didapatkan
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                List<dynamic> daftarBarang = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: daftarBarang.length,
                  itemBuilder: (context, index) {
                    var barang = daftarBarang[index];

                    return _buildItemCard(
                      barang['nama_produk'].toString(),
                      barang['stok_saat_ini'].toString(),
                      'Rp ${barang['harga_jual'] ?? 0}',
                    );
                  },
                );
              }

              // Kondisi jika data dari API kosong
              return const Center(child: Text('Tidak ada data produk.'));
            },
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
        subtitle: Text('Stok: $stok\nHarga: $harga'),
        trailing: const Icon(Icons.inventory, size: 40, color: Colors.orange),
        isThreeLine: true,
      ),
    );
  }
}