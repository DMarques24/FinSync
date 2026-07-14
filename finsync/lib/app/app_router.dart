import 'package:finsync/presentation/pages/createAcount/create_acount_page.dart';
import 'package:finsync/presentation/pages/login/login_page.dart';
import 'package:go_router/go_router.dart';
import 'package:finsync/presentation/pages/main_page.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/createAcount',
      builder: (context, state) => const CreateAcountPage(),
    ),
    GoRoute(path: '/', builder: (context, state) => const MainPage()),
  ],
);
