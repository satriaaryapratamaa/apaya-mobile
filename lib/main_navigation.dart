import 'package:flutter/material.dart';
import 'barang_page.dart';
import 'history_page.dart';
import 'notifikasi_page.dart';
import 'profil_page.dart';
import 'barcode_scanner_page.dart';
import 'form_add_stock.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final GlobalKey<BarangPageState> barangPageKey = GlobalKey<BarangPageState>();

  late final List<Widget> _pages = [
    BarangPage(key: barangPageKey), // Pasang key di sini!
    const HistoriPage(),
    const NotifikasiPage(),
    const ProfilPage(),
  ];

  final List<String> _titles = const [
    'Daftar Barang',
    'Histori Stok',
    'Notifikasi',
    'Profil Pengguna',
  ];

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // UPDATE ALUR FUNGSI SCANNER
  Future<void> _openScanner() async {
    // Buka halaman scanner
    final dynamic productData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanPage()),
    );

    if (!mounted || productData == null) return;

    // Jika sukses scan dan dapat data barang, buka Form Add Stock
    final otomatisRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormAddStock(
          sku: productData['barcode'].toString(),
          namaProduk: productData['nama_produk'].toString(),
          stokSekarang: int.parse(productData['stok_sekarang'].toString()),
          hargaBeli: double.parse(productData['harga_beli'].toString()),
          hargaJual: double.parse(productData['harga_jual'].toString()),
        ),
      ),
    );

    if (!mounted) return;

    // Jika form sukses disimpan (return true)
    if (otomatisRefresh == true) {
      // Pindahkan otomatis ke tab "Barang" (index 0) jika sebelumnya user scan dari tab lain
      if (_currentIndex != 0) {
        _changePage(0);
      }

      // Tekan tombol "Refresh" di BarangPage menggunakan remote control (Key)
      barangPageKey.currentState?.refreshDataBarang();

      // Munculkan snackbar sukses tambahan (Opsional)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sistem sedang memperbarui daftar stok...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: _currentIndex == 0
            ? const Icon(Icons.menu)
            : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _changePage(0),
        ),
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _pages[_currentIndex],

      floatingActionButton: FloatingActionButton.large(
        backgroundColor: const Color(0xFF1565C0),
        shape: const CircleBorder(
          side: BorderSide(color: Colors.white, width: 4),
        ),
        onPressed: _openScanner, // Memanggil fungsi scanner yang baru
        child: const Text(
          'Scan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.inventory_2, 'Barang', 0),
              _navItem(Icons.history, 'Histori', 1),
              const SizedBox(width: 72),
              _navItem(Icons.notifications, 'Notifikasi', 2),
              _navItem(Icons.person, 'Profil', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool active = _currentIndex == index;
    final Color color = active ? const Color(0xFF1565C0) : Colors.grey;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _changePage(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}