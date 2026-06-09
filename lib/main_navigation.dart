import 'package:flutter/material.dart';
import 'barang_page.dart';
import 'history_page.dart';
// import 'pages/profil_page.dart';
import 'notifikasi_page.dart';
import 'barcode_scanner_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Index: 0 = Barang, 1 = Histori, 2 = Profil, 3 = Notifikasi
  int _currentIndex = 0;

  // Daftar body untuk masing-masing halaman
  final List<Widget> _pages = [
    const BarangPage(),
    const HistoriPage(),
    // const ProfilPage(),
    const NotifikasiPage(),
  ];

  // Fungsi untuk mengubah halaman
  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Mengatur AppBar Dinamis berdasarkan halaman
  PreferredSizeWidget _buildAppBar() {
    switch (_currentIndex) {
      case 0:
        return AppBar(
          leading: const Icon(Icons.menu),
          title: const Text('Daftar Barang', style: TextStyle(fontWeight: FontWeight.bold)),
        );
      case 1:
        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _changePage(0), // Kembali ke Barang
          ),
          title: const Text('Histori Stok', style: TextStyle(fontWeight: FontWeight.bold)),
        );
      case 2:
        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _changePage(0), // Kembali ke Barang
          ),
          // Tidak ada judul di halaman profil pada gambar
        );
      case 3:
        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _changePage(0), // Kembali ke Barang
          ),
          title: const Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: const [
            Icon(Icons.notifications),
            SizedBox(width: 16),
          ],
        );
      default:
        return AppBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: _pages[_currentIndex],

      // Tombol Scan Bulat di tengah (Hanya muncul jika bukan di halaman Barang)
      floatingActionButton: _currentIndex != 0
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF1565C0),
        shape: const CircleBorder(),
        onPressed: () {
          // Pindah ke halaman Scan Full Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanPage()),
          );
        },
        child: const Text('Scan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
          : null,

      // Posisi FAB menyatu dengan navbar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Navbar dinamis
      bottomNavigationBar: _currentIndex == 0 ? _buildStandardNavBar() : _buildCustomBottomAppBar(),
    );
  }

  // Tampilan Navbar Halaman Pertama (Barang) - Tanpa tombol scan
  Widget _buildStandardNavBar() {
    return BottomNavigationBar(
      currentIndex: 0, // Karena ini hanya muncul di index 0
      onTap: (index) {
        if (index == 0) _changePage(0);
        if (index == 1) _changePage(1); // Ke Histori
        if (index == 2) _changePage(3); // Ke Notifikasi
      },
      selectedItemColor: const Color(0xFF1565C0),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Barang'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histori'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Notifikasi'),
      ],
    );
  }

  // Tampilan Navbar Halaman Lain (Dengan cekungan untuk FAB Scan)
  Widget _buildCustomBottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tombol Kiri selalu "Barang"
            _buildNavItem(icon: Icons.inventory_2, label: 'Barang', isActive: false, onTap: () => _changePage(0)),

            const SizedBox(width: 48), // Ruang kosong untuk tombol Scan di tengah

            // Tombol Kanan dinamis (Jika di notifikasi, tombol kanan berubah jadi profil)
            if (_currentIndex == 1 || _currentIndex == 2)
              _buildNavItem(icon: Icons.people, label: 'Notifikasi', isActive: _currentIndex == 3, onTap: () => _changePage(3))
            else if (_currentIndex == 3)
              _buildNavItem(icon: Icons.person, label: 'Profil', isActive: false, onTap: () => _changePage(2)),
          ],
        ),
      ),
    );
  }

  // Widget bantuan untuk membuat item navigasi kustom
  Widget _buildNavItem({required IconData icon, required String label, required bool isActive, required VoidCallback onTap}) {
    Color color = isActive ? const Color(0xFF1565C0) : Colors.grey;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}