import 'package:finsync/app/app.dart';
import 'package:finsync/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://wpyjftcnjwjkzzjokszw.supabase.co",
    publishableKey: "sb_publishable_Z4rKYk-2q9bgVJEDwmLZpg_CWjg-Li7",
  );

  await initDependencies();

  runApp(const App());
}
