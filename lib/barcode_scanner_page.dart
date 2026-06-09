import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with SingleTickerProviderStateMixin {
  // Controller untuk mengatur kamera (flash, switch camera, dll)
  final MobileScannerController cameraController = MobileScannerController();

  // Animasi untuk garis hijau yang naik turun
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0), // Biru sesuai desain
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Tombol Flash di AppBar (Kanan Atas)
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  default:
                  // Default ditambahkan untuk mengatasi error jika state = auto/unavailable
                    return const Icon(Icons.flash_off, color: Colors.grey);
                }
              },
            ),
            iconSize: 28.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. View Kamera Nyata
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                // Hentikan kamera sementara setelah berhasil scan
                cameraController.stop();

                // Tampilkan hasil scan
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Berhasil Scan: ${barcode.rawValue}')),
                );

                // Kembali ke halaman sebelumnya dengan membawa data (opsional)
                Navigator.pop(context, barcode.rawValue);
              }
            },
          ),

          // 2. Overlay Transparan Gelap di luar area scan
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.black, // Akan dilubangi oleh BlendMode
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Bingkai Sudut Kamera (Corner Brackets)
          SizedBox(
            width: 250,
            height: 250,
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
            ),
          ),

          // 4. Garis Laser Hijau Animasi
          SizedBox(
            width: 250,
            height: 250,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  top: _animation.value * 250,
                  child: Container(
                    width: 250,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // 5. Bottom Navigation Bar Khusus Scanner
      bottomNavigationBar: Container(
        height: 100,
        color: const Color(0xFF1A1A1A), // Hitam gelap
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Icon Petir (Kiri)
            IconButton(
              icon: const Icon(Icons.bolt, color: Colors.white, size: 32),
              onPressed: () => cameraController.toggleTorch(),
            ),

            // Tombol Scan Besar Biru (Tengah)
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0), // Biru
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3), // Border putih luar
              ),
              child: const Center(
                child: Icon(Icons.barcode_reader, color: Colors.white, size: 36),
              ),
            ),

            // Icon Kamera / Switch (Kanan)
            IconButton(
              icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 30),
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CLASS TAMBAHAN: Untuk menggambar sudut bingkai (Corner Brackets) ---
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    const double lineLength = 40.0;

    // Sudut Kiri Atas
    canvas.drawLine(const Offset(0, 0), const Offset(lineLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, lineLength), paint);

    // Sudut Kanan Atas
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - lineLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, lineLength), paint);

    // Sudut Kiri Bawah
    canvas.drawLine(Offset(0, size.height), Offset(lineLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - lineLength), paint);

    // Sudut Kanan Bawah
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - lineLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - lineLength), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}