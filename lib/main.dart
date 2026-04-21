import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // File ini dihasilkan oleh FlutterFire CLI

// Import halaman-halaman (nanti kamu buat file-filenya)
// import 'pages/login_page.dart';
// import 'pages/register_page.dart';
// import 'pages/verify_email_page.dart';
// import 'pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App UTS UAS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder ini memantau status login user secara real-time
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Jika sedang loading koneksi ke Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika user sudah login
        if (snapshot.hasData) {
          final user = snapshot.data!;

          // Cek apakah email sudah diverifikasi
          if (user.emailVerified) {
            return const DashboardPage(); // Ganti ke halaman Dashboard kamu
          } else {
            return const VerifyEmailPage(); // Ganti ke halaman Verifikasi kamu
          }
        }

        // Jika belum login, arahkan ke Login
        return const LoginPage(); // Ganti ke halaman Login kamu
      },
    );
  }
}

// --- PLACEHOLDER HALAMAN (Hapus jika sudah buat file terpisah) ---

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Halaman Login")));
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Halaman Dashboard")));
}

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Halaman Verifikasi Email")));
}
