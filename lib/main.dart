import 'package:aminci/features/login/presentation/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:aminci/core/di/service_locator.dart';
import 'package:aminci/core/router/app_router.dart';
import 'package:aminci/core/theme/app_theme.dart';
import 'package:aminci/features/active_sessions/presentation/bloc/active_sessions_bloc.dart';
import 'package:aminci/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:aminci/features/hotspot/presentation/bloc/hotspot_bloc.dart';
import 'package:aminci/features/launch/presentation/bloc/launch_bloc.dart';
import 'package:aminci/features/logout/presentation/bloc/logout_bloc.dart';
import 'package:aminci/features/profiles/presentation/bloc/profiles_bloc.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';
import 'package:aminci/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  sqfliteFfiInit();

  const options = WindowOptions(center: true, title: 'Aminci', titleBarStyle: TitleBarStyle.normal);

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await setupServiceLocator();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LaunchBloc>(create: (_) => sl<LaunchBloc>()),
        BlocProvider<LoginBloc>(create: (_) => sl<LoginBloc>()),
        BlocProvider<LogoutBloc>(create: (_) => sl<LogoutBloc>()),
        BlocProvider<SetupBloc>(create: (_) => sl<SetupBloc>()),
        BlocProvider<RoutersBloc>(create: (_) => sl<RoutersBloc>()..add(const RoutersLoadRequested())),
        BlocProvider<HotspotBloc>(create: (_) => sl<HotspotBloc>()),
        BlocProvider<ProfilesBloc>(create: (_) => sl<ProfilesBloc>()),
        BlocProvider<ActiveSessionsBloc>(create: (_) => sl<ActiveSessionsBloc>()),
        BlocProvider<DashboardBloc>(create: (_) => sl<DashboardBloc>()),
      ],
      child: const AminciApp(),
    ),
  );
}

class AminciApp extends StatelessWidget {
  const AminciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aminci',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppThemeDark.dark,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
