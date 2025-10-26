import 'dart:io';

import 'package:plus_parse_app_package/src/api/app_package_parser.dart';
import 'package:plus_parse_app_package/src/parsers/parsers.dart';

final List<AppPackageParser> _parsers = [
  AppPackageParserApk(),
  AppPackageParserIpa(),
];

Future<AppPackage> parseAppPackage(File file) {
  AppPackageParser parser = _parsers.firstWhere(
    (e) => file.path.endsWith('.${e.name}'),
  );
  return parser.parse(file);
}
