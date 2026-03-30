import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:girl_clan/UI/auth/splash_screen.dart';
import 'package:girl_clan/core/services/auth_services.dart';
import 'package:girl_clan/core/services/data_base_services.dart';
import 'package:girl_clan/UI/auth/auth_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => DatabaseServices()),
        ChangeNotifierProxyProvider<DatabaseServices, AuthServices>(
          create: (_) => AuthServices(),
          update: (context, db, auth) => auth!..setDatabaseServices(db),
        ),
        ChangeNotifierProxyProvider<AuthServices, AuthViewModel>(
          create:
              (context) => AuthViewModel(
                authServices: Provider.of<AuthServices>(context, listen: false),
              ),
          update:
              (context, authServices, authViewModel) =>
                  authViewModel ?? AuthViewModel(authServices: authServices),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Prime Tax',
            theme: ThemeData(
              primarySwatch: Colors.teal,
              fontFamily: 'Quicksand',
              scaffoldBackgroundColor: Colors.deepPurple[900],
              appBarTheme: const AppBarTheme(
                iconTheme: IconThemeData(color: Colors.white),
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
