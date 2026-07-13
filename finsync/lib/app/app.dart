import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:finsync/app/app_router.dart';
import 'package:finsync/core/di/injection.dart';
import 'package:finsync/presentation/pages/home/home_bloc.dart';
import 'package:finsync/presentation/pages/desire/desire_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(create: (_) => sl<HomeBloc>()),
        BlocProvider<DesireBloc>(create: (_) => sl<DesireBloc>()),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }
}
