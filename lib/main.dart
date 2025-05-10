import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/init/navigation/navigation_route.dart';
import 'features/auth/viewmodel/auth_view_model.dart';
import 'features/auth/service/auth_service.dart';
import 'firebase_options.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    print('Firebase başlatılıyor...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase başarıyla başlatıldı');

    timeago.setLocaleMessages('tr', timeago.TrMessages());

    runApp(const MyApp());
  } catch (e) {
    print('Firebase başlatma hatası: $e');
    // Firebase başlatılamazsa uygulama hata ekranı gösterebilir
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: Center(
            child: Text(
              'Uygulama başlatılırken bir hata oluştu.\nLütfen internet bağlantınızı kontrol edip tekrar deneyin.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'Globe Connect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        onGenerateRoute: NavigationRoute.instance.generateRoute,
        home: const AuthCheckWidget(),
      ),
    );
  }
}

class AuthCheckWidget extends StatefulWidget {
  const AuthCheckWidget({super.key});

  @override
  State<AuthCheckWidget> createState() => _AuthCheckWidgetState();
}

class _AuthCheckWidgetState extends State<AuthCheckWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
          );
        }

        // Kullanıcı durumunu kontrol et
        final user = snapshot.data;
        print('Auth State Changed - User: ${user?.email}');

        if (user != null) {
          // Kullanıcı giriş yapmışsa ana sayfaya yönlendir
          print('Kullanıcı giriş yapmış, ana sayfaya yönlendiriliyor...');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          });
        } else {
          // Kullanıcı giriş yapmamışsa giriş sayfasına yönlendir
          print('Kullanıcı giriş yapmamış, giriş sayfasına yönlendiriliyor...');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/auth',
              (route) => false,
            );
          });
        }

        // Yükleme ekranını göster
        return const Scaffold(
          backgroundColor: Color(0xFF121212),
          body: Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          ),
        );
      },
    );
  }
}
