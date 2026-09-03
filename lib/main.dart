import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'providers/subscription_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase Client Service
  await SupabaseService().initialize();

  runApp(
    const ProviderScope(
      child: BiggoptiApp(),
    ),
  );
}

class BiggoptiApp extends ConsumerWidget {
  const BiggoptiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subscriptionProvider);

    return MaterialApp(
      title: 'Biggopti - AI Bangla Notice Digest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: subState.isSubscribed ? const HomeScreen() : const LoginScreen(),
    );
  }
}
