import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/dependencies.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // A fonte embutida (Manrope, licença OFL) exige que a licença acompanhe o app
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(['Manrope'], await rootBundle.loadString('assets/fonts/Manrope-OFL.txt'));
  });
  await initializeDateFormatting('pt_BR');
  runApp(VendaquiClienteApp(dependencies: AppDependencies.create(AppConfig.fromEnvironment())));
}
