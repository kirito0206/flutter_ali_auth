import 'dart:js_interop';

// 引入全局 JS 对象 PhoneNumberServer（构造函数）
@JS('PhoneNumberServer')
@staticInterop
class PhoneNumberServer {
  external factory PhoneNumberServer();
}

extension PhoneNumberServerExtension on PhoneNumberServer {
  // 方法：获取网络连接状态（返回 Promise）
  external JSPromise<JSString?> getConnection();

  // 方法：设置日志开关
  external void setLoggerEnable(bool isEnable);

  // 方法：获取 SDK 版本（返回 Promise）
  external JSPromise<JSString?> getVersion();

  // 方法：鉴权（通过回调通知结果）
  external void checkAuthAvailable(Params params);

  // 方法：获取 Token（通过回调通知结果）
  external void getVerifyToken(Params params);
}

// 匿名参数对象，用于传递回调
@JS()
@anonymous
@staticInterop
class Params {
  external factory Params({
    String? accessToken,
    String? jwtToken,
    JSFunction? success,
    JSFunction? error,
  });
}

/// 阿里云号码认证 Web 插件（Dart 封装）
class AliAuthPluginWebApi {
  PhoneNumberServer? _server;

  PhoneNumberServer get _phoneNumberServer {
    final server = _server;
    if (server != null) {
      return server;
    }

    try {
      return _server = PhoneNumberServer();
    } catch (error) {
      throw StateError(
        'AliAuth Web SDK is not loaded correctly. '
        'Add <script src="js/numberAuth-web-sdk.js"></script> to web/index.html '
        'before Flutter starts, and make sure it defines window.PhoneNumberServer. '
        'Original error: $error',
      );
    }
  }

  /// 网络类型检查接口
  Future<String?> getConnection() async {
    final result = await _phoneNumberServer.getConnection().toDart;
    return result?.toDart;
  }

  /// 设置 SDK 是否开启日志。开启后会在控制台打印更多内容便于排查问题。
  Future<void> setLoggerEnable(bool isEnable) async {
    _phoneNumberServer.setLoggerEnable(isEnable);
  }

  /// 获取版本号
  Future<String?> getVersion() async {
    final result = await _phoneNumberServer.getVersion().toDart;
    return result?.toDart;
  }

  /// 调用之前先去用户服务端获取 accessToken 和 jwtToken
  Future<void> checkAuthAvailable(
    String accessToken,
    String jwtToken,
    void Function(dynamic status) success,
    void Function(dynamic status) error,
  ) async {
    final jsSuccess = ((JSAny? status) => success(status)).toJS;
    final jsError = ((JSAny? status) => error(status)).toJS;

    _phoneNumberServer.checkAuthAvailable(
      Params(
        accessToken: accessToken,
        jwtToken: jwtToken,
        success: jsSuccess,
        error: jsError,
      ),
    );
  }

  /// 身份鉴权成功后才可调用获取 Token 接口
  Future<void> getVerifyToken(
    void Function(dynamic status) success,
    void Function(dynamic status) error,
  ) async {
    final jsSuccess = ((JSAny? status) => success(status)).toJS;
    final jsError = ((JSAny? status) => error(status)).toJS;

    _phoneNumberServer.getVerifyToken(
      Params(success: jsSuccess, error: jsError),
    );
  }
}
