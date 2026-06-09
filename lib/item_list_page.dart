import 'package:flutter/material.dart';
import 'barcode_scanner_page.dart';
import 'barang.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({Key? key}) : super(key: key);

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  // 1. DATA MANUAL (MOCK DATA) YANG SUDAH DIINPUT LANGSUNG
  final List<Barang> _semuaBarangManual = [
    Barang(
      kodeBarcode: '8999999195438',
      nama: 'Kopi Sachet',
      stok: 150,
      harga: 2000,
    ),
    Barang(
      kodeBarcode: '8992761123456',
      nama: 'Minyak Goreng',
      stok: 85,
      harga: 14000,
    ),
    Barang(
      kodeBarcode: '8993005123789',
      nama: 'Sabun Mandi',
      stok: 120,
      harga: 5000,
    ),
    Barang(
      kodeBarcode: '8998899123123',
      nama: 'Air Mineral',
      stok: 200,
      harga: 3000,
    ),
  ];

  // List yang akan mengontrol perubahan data di layar
  List<Barang> _barangDitampilkan = [];
  bool _isLoading = false;
  String? _barcodeTerakhir;

  @override
  void initState() {
    super.initState();
    _ambilDataBarang(); // Tampilkan semua data saat pertama kali dibuka
  }

  // 2. FUNGSI UNTUK MENGAMBIL SEMUA BARANG MANUAL
  void _ambilDataBarang() {
    setState(() {
      _isLoading = true;
    });

    // Mensimulasikan loading singkat agar transisinya halus
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _barangDitampilkan = List.from(_semuaBarangManual); // Salin semua data manual
        _barcodeTerakhir = null;
        _isLoading = false;
      });
    });
  }

  // 3. FUNGSI UNTUK FILTER BARANG BERDASARKAN BARCODE SECARA LOKAL
  void _cariBarangBerdasarkanBarcode(String barcode) {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _barcodeTerakhir = barcode;

        // Mencari kecocokan kode barcode di dalam data manual kita
        _barangDitampilkan = _semuaBarangManual
            .where((barang) => barang.kodeBarcode == barcode)
            .toList();

        _isLoading = false;
      });
    });
  }

  // Fungsi Navigasi ke Scanner Page
  Future<void> _bukaScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
    );

    if (result != null) {
      _cariBarangBerdasarkanBarcode(result); // Filter data lokal setelah scan berhasil
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text('Daftar Barang', style: TextStyle(color: Colors.white)),
        actions: [
          if (_barcodeTerakhir != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _ambilDataBarang, // Reset, kembali tampilkan semua data manual
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_barcodeTerakhir != null)
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.blue.shade50,
              width: double.infinity,
              child: Text(
                'Hasil Scan Barcode: $_barcodeTerakhir',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          Expanded(
            child: _barangDitampilkan.isEmpty
                ? _buildTampilanTidakAdaData()
                : _buildDaftarBarang(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1976D2),
        onPressed: _bukaScanner,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }

  Widget _buildTampilanTidakAdaData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Tidak ada data',
            style: TextStyle(fontSize: 28, color: Color(0xFF009688)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _ambilDataBarang,
            child: const Text('Muat Ulang Semua Data'),
          )
        ],
      ),
    );
  }

  Widget _buildDaftarBarang() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _barangDitampilkan.length,
      itemBuilder: (context, index) {
        final barang = _barangDitampilkan[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(barang.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Stok: ${barang.stok}\nHarga: Rp ${barang.harga}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}