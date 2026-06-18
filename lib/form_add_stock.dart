import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormAddStock extends StatefulWidget {
  final String sku;
  final String namaProduk;
  final int stokSekarang;
  final double hargaBeli;
  final double hargaJual;

  const FormAddStock({
    super.key,
    required this.sku,
    required this.namaProduk,
    required this.stokSekarang,
    required this.hargaBeli,
    required this.hargaJual,
  });

  @override
  State<FormAddStock> createState() => _FormAddStockState();
}

class _FormAddStockState extends State<FormAddStock> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stokTambahanController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _stokTambahanController.dispose();
    super.dispose();
  }

  /// ── FUNGSI AKSES KE API UPDATE STOK ────────────────────────────────────────
  void _simpanStokBaru() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Ambil jumlah stok tambahan dari input text
    int jumlahTambahan = int.parse(_stokTambahanController.text);
    int totalStokBaru = widget.stokSekarang + jumlahTambahan;

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      final url = Uri.parse('http://192.168.0.105:8000/api/produk/${widget.sku}');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nama_produk': widget.namaProduk,
          'sku': widget.sku,
          'stok_saat_ini': totalStokBaru,
          'harga_jual': widget.hargaJual,
          'harga_beli' : widget.hargaBeli,
        }),
      );

      // Tampilkan notifikasi berhasil
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stok ${widget.namaProduk} berhasil diperbarui menjadi $totalStokBaru Pcs!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        // Jika Laravel menolak (misal karena 404 atau 422)
        if (!mounted) return;
        setState(() => _isLoading = false);

        // Membaca pesan error dari Laravel
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal Update: ${errorData['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui stok. Terjadi kesalahan server.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Stok Barang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Produk Terdeteksi:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // ── KARTU INFORMASI DATA BARANG DARI SCANNER ──────────────
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDetailRow('Kode SKU', widget.sku),
                        const Divider(height: 24),
                        _buildDetailRow('Nama Produk', widget.namaProduk),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Stok Saat Ini',
                          '${widget.stokSekarang} Pcs',
                          valueColor: widget.stokSekarang <= 10 ? Colors.orange : Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  'Input Perubahan Stok:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // ── INPUT TEXT JUMLAH STOK BARU ───────────────────────────
                TextFormField(
                  controller: _stokTambahanController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah Stok Tambahan',
                    hintText: 'Masukkan angka (contoh: 10, 50, 100)',
                    prefixIcon: const Icon(Icons.add_box, color: Color(0xFF1565C0)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
                    ),
                  ),
                  // Validasi Input data
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Jumlah tambahan stok tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Harus berupa angka bulat yang valid';
                    }
                    if (int.parse(value) <= 0) {
                      return 'Jumlah stok harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // ── TOMBOL SUBMIT SIMPAN DATA ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _simpanStokBaru,
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      'Simpan Perubahan Stok',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper Widget untuk membuat baris detail data yang rapi
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: valueColor ?? Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}