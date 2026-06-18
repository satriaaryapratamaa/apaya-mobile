import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

Future<List<dynamic>> fetchBarang() async {
  // Sesuaikan URL dengan env kamu (10.0.2.2 atau IP Lokal laptop)
  final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/produk'));

  if (response.statusCode == 200) {
    // Decode response body menjadi Map terlebih dahulu
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse['data'] ?? [];
  } else {
    throw Exception('Gagal memuat data produk');
  }
}

class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {

  late Future<List<dynamic>> _futureBarang;

  @override
  void initState() {
    super.initState();

    _refreshDataBarang();
  }

  void _refreshDataBarang() {
    setState(() {
      _futureBarang = fetchBarang();
    });
  }

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
            future: _futureBarang, // Memanggil fungsi API
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

                    return InkWell(
                      onTap: () async {
                        final otomatisRefresh = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormAddStock(
                              namaProduk: barang['nama_produk'].toString(),
                              sku: barang['sku'].toString(),
                              stokSekarang: int.parse(barang['stok_saat_ini'].toString()),
                              hargaJual: double.parse(barang['harga_jual'].toString()),
                              hargaBeli: double.parse(barang['harga_beli'].toString()),
                            ),
                          ),
                        );
                        if(otomatisRefresh == true) {
                          _refreshDataBarang();
                        }
                      },
                      child: _buildItemCard(
                          barang['nama_produk'].toString(),
                          barang['stok_saat_ini'].toString(),
                          'Rp ${barang['harga_jual'] ?? 0},'
                      ),
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