import 'package:get_it/get_it.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:aminci/core/di/modules/core_module.dart';
import 'package:aminci/core/di/modules/hotspot_module.dart';
import 'package:aminci/core/di/modules/login_module.dart';
import 'package:aminci/core/di/modules/logout_module.dart';
import 'package:aminci/core/di/modules/launch_module.dart';
import 'package:aminci/core/di/modules/profiles_module.dart';
import 'package:aminci/core/di/modules/routers_module.dart';
import 'package:aminci/core/di/modules/setup_module.dart';
import 'package:aminci/core/di/modules/vouchers_module.dart';

final sl = GetIt.instance;

/// Initialise toutes les dépendances de l'application.
/// À appeler une seule fois dans [main] avant [runApp].
Future<void> setupServiceLocator() async {
  registerCoreModule(sl);
  await sl.isReady<Database>();

  registerLaunchModule(sl);
  registerLoginModule(sl);
  registerLogoutModule(sl);
  registerSetupModule(sl);
  registerRoutersModule(sl);
  registerHotspotModule(sl);
  registerProfilesModule(sl);
  registerVouchersModule(sl);
}
