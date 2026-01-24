import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Model Sederhana untuk Notifikasi
class AppNotification {
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final String type; // 'info', 'alert', 'success'

  AppNotification({
    required this.title, 
    required this.body, 
    required this.time, 
    this.isRead = false,
    this.type = 'info',
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Simulasi Data Notifikasi (Nanti bisa diambil dari Database)
  List<AppNotification> notifications = [
    AppNotification(
      title: "Jangan lupa catat! 📝",
      body: "Sudahkah kamu mencatat pengeluaran makan siang hari ini?",
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: 'alert',
    ),
    AppNotification(
      title: "Target Tercapai! 🎉",
      body: "Selamat! Kamu berhasil menabung Rp 500.000 minggu ini. Pertahankan!",
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: 'success',
    ),
    AppNotification(
      title: "Update Aplikasi v1.0",
      body: "CompoundMe kini hadir dengan tampilan baru yang lebih segar. Cek fitur Habits!",
      time: DateTime.now().subtract(const Duration(days: 3)),
      type: 'info',
    ),
    AppNotification(
      title: "Tips Keuangan 💡",
      body: "Tahukah kamu? Membawa bekal bisa menghemat pengeluaran hingga 30%.",
      time: DateTime.now().subtract(const Duration(days: 5)),
      type: 'info',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifikasi", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_check),
            tooltip: "Tandai semua dibaca",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Semua notifikasi ditandai sudah dibaca")),
              );
            },
          )
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Belum ada notifikasi", style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Dismissible(
                  key: Key(notif.title),
                  onDismissed: (direction) {
                    setState(() {
                      notifications.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notifikasi dihapus")),
                    );
                  },
                  background: Container(
                    color: Colors.red[100],
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: _buildIcon(notif.type),
                      title: Text(
                        notif.title,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notif.body, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
                          const SizedBox(height: 8),
                          Text(
                            _formatTime(notif.time),
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Helper untuk Ikon Berdasarkan Tipe
  Widget _buildIcon(String type) {
    Color color;
    IconData icon;

    switch (type) {
      case 'alert':
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case 'success':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  // Helper Format Waktu
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} menit yang lalu";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} jam yang lalu";
    } else {
      return DateFormat('dd MMM yyyy').format(time);
    }
  }
}