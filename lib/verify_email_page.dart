import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard_page.dart'; // Wajib di-import agar bisa langsung pindah halaman

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // 1. Cek apakah user sudah terverifikasi saat halaman dibuka
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      // 2. Cek status verifikasi secara otomatis setiap 3 detik
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Hentikan timer saat keluar halaman
    super.dispose();
  }

  // Fungsi untuk mengecek status verifikasi di server Firebase
  Future checkEmailVerified() async {
    try {
      // PAKSA Firebase untuk mengambil data terbaru dari server
      await FirebaseAuth.instance.currentUser?.reload();

      setState(() {
        // Ambil status terbaru setelah reload
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });

      if (isEmailVerified) {
        timer?.cancel();
        // Karena main.dart kadang lambat merespon, kita langsung atur
        // pergerakan UI di bagian build() di bawah.
      }
    } catch (e) {
      // Cegah aplikasi crash (layar merah) jika koneksi internet terputus
      debugPrint("Menunggu jaringan / Gagal reload: $e");
    }
  }

  // Fungsi untuk mengirim ulang email verifikasi
  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(
        const Duration(seconds: 30),
      ); // Tunggu 30 detik sebelum bisa klik lagi
      setState(() => canResendEmail = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // JIKA SUDAH TERVERIFIKASI, LANGSUNG TAMPILKAN DASHBOARD
    if (isEmailVerified) {
      return const DashboardPage();
    }

    // JIKA BELUM, TAMPILKAN HALAMAN INSTRUKSI
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Email'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Email verifikasi telah dikirim!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Silakan cek kotak masuk (atau folder spam) email Anda dan klik link yang tersedia.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Tombol Kirim Ulang Email
            ElevatedButton.icon(
              onPressed: canResendEmail ? sendVerificationEmail : null,
              icon: const Icon(Icons.email),
              label: const Text('Kirim Ulang Email'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Manual Cek Verifikasi (Backup)
            ElevatedButton.icon(
              onPressed: checkEmailVerified,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Saya Sudah Verifikasi'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Tombol Batal
            TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text('Batal & Keluar'),
            ),
          ],
        ),
      ),
    );
  }
}
