import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'models/cart_model.dart';
import 'models/wishlist_model.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/wishlist_screen.dart';

import 'package:fashion_store/screens/product_listing/womens_screen.dart';
import 'package:fashion_store/screens/product_listing/mens_screen.dart';
import 'package:fashion_store/screens/product_listing/kids_screen.dart';
import 'package:fashion_store/screens/product_listing/teen_screen.dart';
import 'package:fashion_store/screens/product_listing/shoes_screen.dart';

import 'screens/checkout/checkout_screen.dart';
import 'screens/checkout/payment_success_screen.dart';
import 'screens/checkout/card_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CartModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => WishlistModel(),
        ),
      ],
      child: const UrbanVibeApp(),
    ),
  );
}

class UrbanVibeApp extends StatelessWidget {
  const UrbanVibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundGray = Color(0xFFF8F9FA);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UrbanVibe Fashion',

      theme: ThemeData(
        scaffoldBackgroundColor: backgroundGray,
        primaryColor: Colors.white,
        fontFamily: 'sans-serif',

        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundGray,
          elevation: 0,
          centerTitle: true,

          iconTheme: IconThemeData(
            color: Colors.black,
          ),

          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
            fontSize: 20,
          ),
        ),
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/cart': (context) => const CartScreen(),
        '/womens': (context) => const WomensScreen(),
        '/mens': (context) => const MensScreen(),
        '/kids': (context) => const KidsScreen(),
        '/teens': (context) => const TeenScreen(),
        '/shoes': (context) => const ShoesScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/paymentSuccess': (context) =>
            const PaymentSuccessScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/addCard') {
          final args =
              settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (context) => CardDetailsScreen(
              shippingData: args,
            ),
          );
        }

        return null;
      },
    );
  }
}