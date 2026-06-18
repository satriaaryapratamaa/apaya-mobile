import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'form_add_stock.dart';
import 'api_config.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  // Controller untuk mengatur kamera (flash, switch camera, dll)
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  // Animasi untuk garis laser hijau yang naik turun
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Flag agar scan hanya diproses sekali saat mendeteksi barcode
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// ── LOGIKA UTAMA SCAN DETECT ──────────────────────────────────────────────
  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return; // Cegah trigger ganda jika proses masih berjalan
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);

    // Hentikan kamera sementara proses validasi data berlangsung
    cameraController.stop();

    // Tampilkan loading indicator kecil agar user tahu ada proses pengecekan
    _showLoadingDialog();

    // Validasi kode SKU ke database / API Laravel
    final Map<String, dynamic>? productData = await _checkSkuInDatabase(rawValue.trim());

    // Tutup loading dialog sebelum berpindah halaman atau menampilkan alert
    if (mounted) Navigator.pop(context);

    if (!mounted) return;

    if (productData != null) {
      final apakahBerhasilUpdate = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormAddStock(
            sku: productData['barcode'],
            namaProduk: productData['nama_produk'],
            stokSekarang: productData['stok_sekarang'],
            hargaBeli: double.parse(productData['harga_beli'].toString()),
            hargaJual: double.parse(productData['harga_jual'].toString()),
          ),
        ),
      );
      if (apakahBerhasilUpdate == true && mounted) {
        Navigator.pop(context, true);
      } else {
        // Jika user menekan back biasa di form tanpa simpan, reset scanner agar bisa scan kode lain
        _resetScanner();
      }
    } else {
      _showProductNotFoundError(rawValue.trim());
    }
  }

  /// ── REQUESET KE API LARAVEL (Mengecek SKU) ──────────────────────────────────
  Future<Map<String, dynamic>?> _checkSkuInDatabase(String skuCode) async {
    try {
      // Sesuaikan URL ini dengan environment server Laravel Anda
      final url = Uri.parse('${ApiConfig.baseUrl}/produk/cek-barcode');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'barcode': skuCode,
        }),
      ).timeout(const Duration(seconds: 10));

      debugPrint("=== DEBUG API SCAN ===");
      debugPrint("SKU yang dikirim: $skuCode");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['data']; // Mengembalikan Map data produk
        }
      }

      return null;
    } catch (e) {
      debugPrint("Error Koneksi API: $e");
      return null;
    }
  }

  /// ── UTILITY DIALOGS & KONTROL SCANNER ─────────────────────────────────────

  // Dialog loading saat mengecek data ke Laravel
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
        ),
      ),
    );
  }

  // Dialog jika kode barang tidak terdaftar
  void _showProductNotFoundError(String skuCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Kode Tidak Ada', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('Kode barang (SKU) "$skuCode" tidak terdaftar di dalam sistem.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog error
                _resetScanner(); // Hidupkan kembali kamera untuk scan ulang
              },
              child: const Text(
                'Scan Ulang',
                style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mereset flag dan menghidupkan kembali kamera
  void _resetScanner() {
    setState(() => _isProcessing = false);
    cameraController.start();
  }

  /// ── UI BUILDER ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          'Scan SKU Produk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: cameraController,
            builder: (context, state, child) {
              final bool isOn = state.torchState == TorchState.on;
              return IconButton(
                icon: Icon(
                  isOn ? Icons.flash_on : Icons.flash_off,
                  color: isOn ? Colors.yellow : Colors.white70,
                ),
                iconSize: 28.0,
                tooltip: isOn ? 'Matikan Flash' : 'Nyalakan Flash',
                onPressed: () => cameraController.toggleTorch(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
            ),
          ),
          SizedBox(
            width: 260,
            height: 260,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      top: _animation.value * 257,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Positioned(
            bottom: 130,
            child: Text(
              'Arahkan kamera ke barcode SKU produk',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 100,
        color: const Color(0xFF1A1A1A),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomAction(
              icon: Icons.bolt,
              label: 'Flash',
              onTap: () => cameraController.toggleTorch(),
            ),
            GestureDetector(
              onTap: () {
                if (_isProcessing) {
                  _resetScanner();
                }
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.barcode_reader, color: Colors.white, size: 36),
                ),
              ),
            ),
            _buildBottomAction(
              icon: Icons.cameraswitch,
              label: 'Ganti',
              onTap: () => cameraController.switchCamera(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  const ScannerOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double lineLength = 40.0;

    canvas.drawLine(Offset.zero, const Offset(lineLength, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, lineLength), paint);

    canvas.drawLine(Offset(size.width, 0), Offset(size.width - lineLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, lineLength), paint);

    canvas.drawLine(Offset(0, size.height), Offset(lineLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - lineLength), paint);

    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - lineLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - lineLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}