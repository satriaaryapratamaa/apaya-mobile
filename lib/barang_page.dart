import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'form_add_stock.dart';
import 'api_config.dart';

Future<List<dynamic>> fetchBarang() async {
  final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/produk'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse['data'] ?? [];
  } else {
    throw Exception('Gagal memuat data produk');
  }
}

class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => BarangPageState(); // Garis bawah (_) dihapus
}

// Class ini dibuat Public agar bisa diakses dari Navbar
class BarangPageState extends State<BarangPage> {
  late Future<List<dynamic>> _futureBarang;

  @override
  void initState() {
    super.initState();
    refreshDataBarang();
  }

  // ── FUNGSI INI DIBUAT PUBLIC AGAR BISA DIPANGGIL DARI NAVBAR ──
  void refreshDataBarang() {
    setState(() {
      _futureBarang = fetchBarang();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── BAGIAN ATAS: HANYA SEARCH BAR (SCANNER DIHAPUS) ──
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari Produk...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // ── DAFTAR ITEM DARI API LARAVEL ──
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _futureBarang,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
              }

              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                List<dynamic> daftarBarang = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: daftarBarang.length,
                  itemBuilder: (context, index) {
                    var barang = daftarBarang[index];

                    return InkWell(
                      onTap: () async {
                        // Buka Form Manual jika list di-klik
                        final otomatisRefresh = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormAddStock(
                              sku: barang['sku'].toString(),
                              namaProduk: barang['nama_produk'].toString(),
                              stokSekarang: int.parse(barang['stok_saat_ini'].toString()),
                              hargaJual: double.parse(barang['harga_jual'].toString()),
                              hargaBeli: double.parse(barang['harga_beli'].toString()),
                            ),
                          ),
                        );

                        // Refresh jika berhasil update manual
                        if (!context.mounted) return;
                        if (otomatisRefresh == true) {
                          refreshDataBarang();
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