import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'barcode_scanner_page.dart'; // Import halaman scan kamu

class TambahStokPage extends StatefulWidget {
  const TambahStokPage({super.key});

  @override
  State<TambahStokPage> createState() => _TambahStokPageState();
}

class _TambahStokPageState extends State<TambahStokPage> {
  // Controller untuk Form Input
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _jumlahStokController = TextEditingController();

  String _namaProduk = "Belum mendeteksi produk";
  int _stokSaatIni = 0;
  bool _isLoading = false;
  String? _produkId; // Untuk menyimpan ID produk dari Laravel

  /// Fungsi untuk membuka halaman Scanner dan menerima hasilnya
  Future<void> _bukaScanner() async {
    // Pindah ke ScanPage dan tunggu hasilnya (rawValue)
    final hasilScan = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScanPage()),
    );

    // Jika hasil scan ada (tidak null/kembali lewat tombol back biasa)
    if (hasilScan != null && hasilScan.isNotEmpty) {
      setState(() {
        _skuController.text = hasilScan; // Masukkan kode barcode ke TextField SKU
      });

      // Langsung cek ke API Laravel untuk validasi data produk tersebut
      _cekProdukKeLaravel(hasilScan);
    }
  }

  /// Fungsi untuk cek data produk berdasarkan SKU/Barcode ke Laravel
  Future<void> _cekProdukKeLaravel(String sku) async {
    setState(() => _isLoading = true);
    try {
      // Kita asumsikan kamu punya endpoint pencarian berdasarkan SKU, atau bisa pakai route show dengan modifikasi di backend
      final response = await http.get(Uri.parse('http://192.168.18.130:8000/api/produk/$sku'));

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        final data = res['data'];

        setState(() {
          _produkId = data['id'].toString();
          _namaProduk = data['nama_produk'];
          _stokSaatIni = data['stok_saat_ini'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk tidak ditemukan di database Master Data')),
        );
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Fungsi untuk mengirim update penambahan stok ke Laravel
  Future<void> _simpanPenambahanStok() async {
    if (_produkId == null) return;

    int jumlahTambah = int.tryParse(_jumlahStokController.text) ?? 0;
    if (jumlahTambah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah stok yang ditambahkan harus lebih dari 0')),
      );
      return;
    }

    // Hitung total stok baru untuk di-update via API
    int totalStokBaru = _stokSaatIni + jumlahTambah;

    try {
      // Kirim request PUT ke endpoint api.produk.update milik Laravel
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/api/produk/$_produkId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama_produk": _namaProduk, // Mengikuti aturan required validator Laravel kamu
          "sku": _skuController.text,
          "harga_beli": 0, // Sesuaikan dengan kebutuhan atau ambil dari model sebelumnya
          "harga_jual": 0,
          "stok_saat_ini": totalStokBaru, // Mengirimkan nilai total stok terbaru
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok berhasil ditambahkan!')),
        );
        Navigator.pop(context); // Kembali ke halaman daftar barang
      } else {
        print(response.body);
      }
    } catch (e) {
      print("Error update: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Stok Barang')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input SKU & Tombol Scan
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skuController,
                    decoration: const InputDecoration(
                      labelText: 'Kode Barcode / SKU',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true, // Biar wajib pakai scanner
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _bukaScanner,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Info singkat barang yang terdeteksi
            Card(
              color: Colors.blue.shade50,
              child: ListTile(
                title: Text(_namaProduk, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Stok saat ini di sistem: $_stokSaatIni'),
              ),
            ),
            const SizedBox(height: 20),

            // Input Jumlah Tambahan Stok
            TextField(
              controller: _jumlahStokController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Stok yang Ditambahkan',
                border: OutlineInputBorder(),
                hintText: 'Contoh: 50',
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _produkId == null ? null : _simpanPenambahanStok,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Simpan Stok Baru', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}