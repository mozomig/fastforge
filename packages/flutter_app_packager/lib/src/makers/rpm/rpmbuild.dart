import 'package:plus_shell_executor/plus_shell_executor.dart';

class _RpmBuild extends Command {
  @override
  String get executable => 'rpmbuild';

  @override
  Future<void> install() {
    return Future.value();
  }
}

final rpmbuild = _RpmBuild();
