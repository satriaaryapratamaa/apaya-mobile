import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        const CircleAvatar(
          radius: 48,
          backgroundColor: Color(0xFF1565C0),
          child: Icon(Icons.person, color: Colors.white, size: 56),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Song Hye Kyo',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child: Text(
            'Intern',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 32),
        _profileMenu(Icons.edit, 'Edit Profil'),
        _profileMenu(Icons.lock, 'Ubah Kata Sandi'),
        _profileMenu(Icons.help, 'Bantuan'),
        _profileMenu(Icons.logout, 'Keluar', iconColor: Colors.red),
      ],
    );
  }

  Widget _profileMenu(
      IconData icon,
      String title, {
        Color iconColor = const Color(0xFF1565C0),
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}