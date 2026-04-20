import 'package:aminci/features/profiles/presentation/bloc/profiles_bloc.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';
import 'package:aminci/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:aminci/features/vouchers/presentation/bloc/vouchers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/core/di/service_locator.dart';
import 'package:aminci/core/theme/app_theme.dart';
import 'package:aminci/core/theme/theme_cubit.dart';
import 'package:aminci/features/app/presentation/bloc/app_bloc.dart';
import 'package:aminci/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aminci/features/launch/presentation/bloc/launch_bloc.dart';
import 'package:aminci/features/launch/presentation/screens/launch_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  sqfliteFfiInit();

  const options = WindowOptions(
    size: Size(1366, 800),
    minimumSize: Size(1280, 800),
    center: true,
    title: 'Aminci',
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await setupServiceLocator();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<LaunchBloc>(create: (_) => sl<LaunchBloc>()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<AppBloc>(create: (_) => sl<AppBloc>()),
        BlocProvider<SetupBloc>(create: (_) => sl<SetupBloc>()),
        BlocProvider<RoutersBloc>(create: (_) => sl<RoutersBloc>()),
        BlocProvider<ProfilesBloc>(create: (_) => sl<ProfilesBloc>()),
        BlocProvider<VouchersBloc>(create: (_) => sl<VouchersBloc>()),
      ],
      child: const AminciApp(),
    ),
  );
}

class AminciApp extends StatelessWidget {
  const AminciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Aminci',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppThemeDark.dark,
          themeMode: themeMode,
          home: const LaunchScreen(),
        );
      },
    );
  }
}
