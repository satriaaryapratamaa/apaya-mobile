import 'package:flutter/material.dart';
import 'barang_page.dart';
import 'history_page.dart';
import 'notifikasi_page.dart';
import 'profil_page.dart';
import 'barcode_scanner_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    BarangPage(),
    HistoriPage(),
    NotifikasiPage(),
    ProfilPage(),
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

  Future<void> _openScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanPage()),
    );

    if (!mounted || result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Barcode terbaca: $result')),
    );
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
        onPressed: _openScanner,
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