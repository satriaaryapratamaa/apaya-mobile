import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

Future<List<dynamic>> fetchNotifikasi() async {
  try {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/produk/notification'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['data'] ?? [];
    } else {
      throw Exception('Gagal memuat data dari server');
    }
  } catch (e) {
    throw Exception('Gagal terhubung ke server');
  }
}

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchNotifikasi(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          List<dynamic> notifData = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifData.length,
            itemBuilder: (context, index) {
              var notif = notifData[index];

              // Menentukan warna berdasarkan data dari Laravel
              Color iconColor = Colors.blue;
              if (notif['color'] == 'orange') {
                iconColor = Colors.orange;
              } else if (notif['color'] == 'green') {
                iconColor = Colors.green;
              }

              // Memotong string tanggal agar lebih rapi jika diperlukan
              String rawDate = notif['date'] ?? '';
              String formattedDate = rawDate.length > 10 ? rawDate.substring(0, 10) : rawDate;

              return _buildNotifCard(
                Icons.notifications,
                notif['message'] ?? '',
                formattedDate,
                iconColor,
              );
            },
          );
        }

        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off, size: 60, color: Colors.grey),
              SizedBox(height: 8),
              Text('Tidak ada notifikasi baru.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotifCard(IconData icon, String title, String date, Color iconColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(date),
        ),
      ),
    );
  }
}