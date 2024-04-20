import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MS_KEY', obfuscate: true)
  static final String msApiKey = _Env.msApiKey;
}