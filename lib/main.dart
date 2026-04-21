import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // File ini dihasilkan oleh FlutterFire CLI
import 'login_page.dart';
import 'register_page.dart';
import 'verify_email_page.dart'; // Aktifkan import ini
import 'dashboard_page.dart'; // Aktifkan import ini

void main() async {
  // Wajib dipanggil sebelum Firebase.initializeApp
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
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
      // AuthWrapper akan menentukan halaman mana yang muncul saat app dibuka
      home: const AuthWrapper(),

      // Definisikan Routes agar navigasi lebih mudah
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/verify-email': (context) => const VerifyEmailPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Jika user sudah login (snapshot memiliki data)
        if (snapshot.hasData) {
          final user = snapshot.data!;

          // AKTIFKAN KEMBALI LOGIKA INI:
          if (user.emailVerified) {
            return const DashboardPage(); // Jika sudah verif, ke Dashboard
          } else {
            return const VerifyEmailPage(); // Jika belum verif, ke halaman verifikasi
          }
        }

        // 3. Jika user tidak login (snapshot kosong/null)
        return const LoginPage();
      },
    );
  }
}
