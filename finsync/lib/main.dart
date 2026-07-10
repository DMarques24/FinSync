import 'package:finsync/app/app.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // ! Estavas variagevei nao devem estar aqui ("NÃO DEVE SER MUITO SEGURO")
    url: "https://wpyjftcnjwjkzzjokszw.supabase.co/rest/v1/",
    publishableKey: "sb_publishable_Z4rKYk-2q9bgVJEDwmLZpg_CWjg-Li7",
  );

  runApp(const App());
}
