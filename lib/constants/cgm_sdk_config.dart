class CgmSdkConfig {
  const CgmSdkConfig._();

  static const String _sampleAppId = '642434';
  static const String _sampleAppSecret = 'wtrWYS8bnRTxssyNwbbwsyNYccpYlkP8';

  static const String _appId = String.fromEnvironment(
    'CGM_SDK_APP_ID',
    defaultValue: _sampleAppId,
  );
  static const String _legacyAppId = String.fromEnvironment(
    'CGM_SDK_APPID',
    defaultValue: _sampleAppId,
  );

  static const String _appSecret = String.fromEnvironment(
    'CGM_SDK_APP_SECRET',
    defaultValue: _sampleAppSecret,
  );
  static const String _legacyAppSecret = String.fromEnvironment(
    'CGM_SDK_APP_SECRECT',
    defaultValue: _sampleAppSecret,
  );

  static const bool _skipSdkAuth = bool.fromEnvironment(
    'CGM_SDK_SKIP_AUTH',
    defaultValue: false,
  );

  static String get appId => _appId.isNotEmpty ? _appId : _legacyAppId;
  static String get appSecret =>
      _appSecret.isNotEmpty ? _appSecret : _legacyAppSecret;

  static bool get hasCredentials => appId.isNotEmpty && appSecret.isNotEmpty;
  static bool get skipSdkAuth => _skipSdkAuth;
}
