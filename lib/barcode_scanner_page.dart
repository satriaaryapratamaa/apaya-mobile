import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  // Flag agar scan hanya diproses sekali
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

  /// Dipanggil saat barcode berhasil terdeteksi
  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return; // Cegah trigger ganda
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);

    // Hentikan kamera setelah berhasil scan
    cameraController.stop();

    // Kembali ke halaman sebelumnya sambil membawa data hasil scan
    Navigator.pop(context, rawValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          'Scan Barcode',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Tombol Flash di AppBar (kanan atas)
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
          // ── 1. Feed kamera nyata ──────────────────────────────────────
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // ── 2. Overlay gelap transparan di luar area scan ─────────────
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Lapisan gelap penuh (background overlay)
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                // Lubang transparan (area scan)
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

          // ── 3. Bingkai sudut kamera (Corner Brackets) ─────────────────
          const SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
            ),
          ),

          // ── 4. Garis laser hijau animasi ──────────────────────────────
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
                      top: _animation.value * 257, // 260 - 3 (tebal garis)
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

          // ── 5. Teks petunjuk di bawah area scan ───────────────────────
          const Positioned(
            bottom: 130,
            child: Text(
              'Arahkan kamera ke barcode produk',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),

      // ── 6. Bottom bar khusus scanner ───────────────────────────────────
      bottomNavigationBar: Container(
        height: 100,
        color: const Color(0xFF1A1A1A),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Tombol Flash (kiri)
            _buildBottomAction(
              icon: Icons.bolt,
              label: 'Flash',
              onTap: () => cameraController.toggleTorch(),
            ),

            // Tombol Scan (tengah) — tekan untuk restart kamera jika berhenti
            GestureDetector(
              onTap: () {
                if (_isProcessing) {
                  setState(() => _isProcessing = false);
                  cameraController.start();
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

            // Tombol Switch Camera (kanan)
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

  /// Widget helper: tombol ikon di bottom bar
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

// ── CustomPainter: Sudut bingkai (Corner Brackets) ──────────────────────────
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

    // Sudut Kiri Atas
    canvas.drawLine(Offset.zero, const Offset(lineLength, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, lineLength), paint);

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}