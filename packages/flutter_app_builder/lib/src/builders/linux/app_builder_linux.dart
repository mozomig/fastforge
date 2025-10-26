import 'dart:io';

import 'package:plus_flutter_app_builder/src/build_result.dart';
import 'package:plus_flutter_app_builder/src/builders/app_builder.dart';
import 'package:plus_flutter_app_builder/src/builders/linux/build_linux_result.dart';

class AppBuilderLinux extends AppBuilder {
  @override
  String get platform => 'linux';

  @override
  bool get isSupportedOnCurrentPlatform => Platform.isLinux;

  @override
  BuildResultResolver get resultResolver => BuildLinuxResultResolver();
}
