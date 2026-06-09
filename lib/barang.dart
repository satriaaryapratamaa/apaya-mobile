class Barang {
  final String kodeBarcode;
  final String nama;
  final int stok;
  final int harga;
  // final String image;

  Barang({
    required this.kodeBarcode,
    required this.nama,
    required this.stok,
    required this.harga,
    // required this.image,
  });

  // Fungsi untuk konversi dari JSON API ke Objek Dart
  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      kodeBarcode: json['sku'] ?? '',
      nama: json['nama'] ?? '',
      stok: json['stok'] ?? 0,
      harga: json['harga'] ?? 0,
      // image: json['image'] ?? 'https://via.placeholder.com/150',
    );
  }
}