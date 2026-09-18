import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aminci/features/active_sessions/presentation/screens/active_sessions_screen.dart';
import 'package:aminci/features/app/app_shell.dart';
import 'package:aminci/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:aminci/features/hotspot/presentation/screens/hotspot_screen.dart';
import 'package:aminci/features/login/presentation/screens/login_screen.dart';
import 'package:aminci/features/launch/presentation/screens/launch_screen.dart';
import 'package:aminci/features/profiles/presentation/screens/profiles_screen.dart';
import 'package:aminci/features/routers/presentation/screens/routers_screen.dart';
import 'package:aminci/features/setup/presentation/screens/setup_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/launch',
  routes: [
    GoRoute(path: '/launch', builder: (ctx, s) => const LaunchScreen()),
    GoRoute(path: '/setup', builder: (ctx, s) => const SetupScreen()),
    GoRoute(path: '/login', builder: (ctx, s) => const LoginScreen()),
    GoRoute(path: '/routers', builder: (ctx, s) => const RoutersScreen()),
    GoRoute(path: '/hotspots', builder: (ctx, s) => const HotspotScreen()),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (ctx, s) => const DashboardScreen()),
        GoRoute(path: '/sessions', builder: (ctx, s) => const ActiveSessionsScreen()),
        GoRoute(path: '/profiles', builder: (ctx, s) => const ProfilesScreen()),
        GoRoute(path: '/history', builder: (ctx, s) => const Placeholder()),
      ],
    ),
  ],
);
