import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
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
    // Jika sudah verifikasi, halaman ini secara otomatis akan tertutup
    // karena logika di AuthWrapper (main.dart) kamu akan mengarahkan ke Dashboard.

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
            ElevatedButton.icon(
              onPressed: canResendEmail ? sendVerificationEmail : null,
              icon: const Icon(Icons.email),
              label: const Text('Kirim Ulang Email'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 8),
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
