import 'package:plus_unified_distributor/plus_unified_distributor.dart';

Future<void> main(List<String> args) async {
  final cli = UnifiedDistributorCommandLineInterface(
    'fastforge',
    'Package and publish your apps with ease.',
    packageName: 'fastforge',
    displayName: 'Fastforge',
  );
  return await cli.run(args);
}
