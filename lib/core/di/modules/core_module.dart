import 'package:get_it/get_it.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/core/database/database_helper.dart';

void registerCoreModule(GetIt sl) {
  sl.registerSingletonAsync<Database>(() => DatabaseHelper.instance.database);
}
