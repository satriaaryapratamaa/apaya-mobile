import 'package:flutter/material.dart';
import 'barcode_scanner_page.dart'; // Pastikan file scanner Anda sudah benar dan bebas error

void main() {
  runApp(const MyApp());
}

// 1. MODEL DATA BARANG LOKAL
class Barang {
  final String kodeBarcode;
  final String nama;
  final int stok;
  final int harga;

  Barang({
    required this.kodeBarcode,
    required this.nama,
    required this.stok,
    required this.harga,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Kasir',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 2. INPUT DATA MANUAL DI SINI
  final List<Barang> _semuaBarangManual = [
    Barang(kodeBarcode: '8999999195438', nama: 'Kopi Sachet', stok: 150, harga: 2000),
    Barang(kodeBarcode: '8992761123456', nama: 'Minyak Goreng', stok: 85, harga: 14000),
    Barang(kodeBarcode: '8993005123789', nama: 'Sabun Mandi', stok: 120, harga: 5000),
    Barang(kodeBarcode: '8998899123123', nama: 'Air Mineral', stok: 1000, harga: 3000),
  ];

  // List yang akan dikontrol perubahannya di UI
  List<Barang> _barangDitampilkan = [];
  String? _barcodeTerakhir;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Saat pertama kali dibuka, langsung tampilkan semua barang manual
    _barangDitampilkan = List.from(_semuaBarangManual);
  }

  // 3. FUNGSI NAVIGASI & FILTER DATA BARANG
  Future<void> _bukaScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
    );

    if (result != null) {
      setState(() {
        _barcodeTerakhir = result;
        _isSearching = true;

        // COCOKKAN HASIL SCAN DENGAN DATA MANUAL
        _barangDitampilkan = _semuaBarangManual
            .where((barang) => barang.kodeBarcode == result)
            .toList();
      });

      if (_barangDitampilkan.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk dengan barcode $result tidak ditemukan!')),
        );
      }
    }
  }

  // Fungsi untuk reset pencarian dan kembali menampilkan seluruh barang
  void _resetPencarian() {
    setState(() {
      _barangDitampilkan = List.from(_semuaBarangManual);
      _barcodeTerakhir = null;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _resetPencarian, // Klik untuk kembalikan semua list barang
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),

          // Bagian Tombol Scan & Info Status Barcode (Seperti gambar Anda)
          Center(
            child: Column(
              children: [
                const Text(
                  'Kode Barcode:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  _barcodeTerakhir ?? "Belum ada produk yang di-scan",
                  style: TextStyle(
                      fontSize: 16,
                      color: _barcodeTerakhir != null ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _bukaScanner,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Buka Scanner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(thickness: 1),

          // 4. DAFTAR LIST BARANG UTAMA
          Expanded(
            child: _barangDitampilkan.isEmpty
                ? _buildTampilanTidakAdaData()
                : _buildDaftarBarang(),
          ),
        ],
      ),
    );
  }

  // Tampilan jika barang hasil scan tidak terdaftar di list manual
  Widget _buildTampilanTidakAdaData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Tidak ada data',
            style: TextStyle(
                fontSize: 26,
                color: Color(0xFF009688),
                fontWeight: FontWeight.w400
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _resetPencarian,
            child: const Text('Tampilkan Semua Barang'),
          )
        ],
      ),
    );
  }

  // Tampilan List Barang (Mirip mockup awal yang Anda inginkan)
  Widget _buildDaftarBarang() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _barangDitampilkan.length,
      itemBuilder: (context, index) {
        final barang = _barangDitampilkan[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            // Menggunakan Icon Box sebagai placeholder agar aman dari error gambar internal
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              // child: const Icon(Icons.box, color: Color(0xFF1976D2)),
            ),
            title: Text(
                barang.nama,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Stok: ${barang.stok}\nHarga: Rp ${barang.harga.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: const TextStyle(color: Colors.black87, height: 1.3),
              ),
            ),
            trailing: Text(
                '${barang.kodeBarcode.substring(0, 4)}...',
                style: const TextStyle(color: Colors.grey, fontSize: 12)
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}