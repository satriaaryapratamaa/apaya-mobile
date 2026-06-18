import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

Future<List<dynamic>> fetchHistori() async {
  try {
    final response = await http.get(Uri.parse('http://192.168.0.105:8000/api/produk/history'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['data'] ?? [];
    } else {
      throw Exception('Server mengembalikan status ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Gagal terhubung ke server: $e');
  }
}

class HistoriPage extends StatelessWidget {
  const HistoriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchHistori(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          List<dynamic> historiData = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: historiData.length,
            itemBuilder: (context, index) {
              var item = historiData[index];
              String title = 'Stok Terupdate: ${item['nama_produk']}';
              String amount = ' [Total: ${item['stok_saat_ini']}]';

              String rawDate = item['updated_at'] ?? '';
              String formattedDate = rawDate.length > 10 ? rawDate.substring(0, 10) : rawDate;

              return _buildHistoryCard(
                title,
                amount,
                formattedDate,
                Colors.red,
              );
            },
          );
        }

        return const Center(child: Text('Belum ada histori aktivitas.'));
      },
    );
  }

  Widget _buildHistoryCard(String title, String amount, String date, Color amountColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: RichText(
          text: TextSpan(
            text: '$title ',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(date),
        ),
      ),
    );
  }
}