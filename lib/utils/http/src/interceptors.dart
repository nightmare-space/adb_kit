part of http;

class HeaderInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) async {
    options.connectTimeout = 1000 * 15;
    options.receiveTimeout = 10000 * 15;
    options.cancelToken = DioUtils.cancelToken = CancelToken();
    options.headers['content-type'] = Headers.jsonContentType;
    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) {
    DioUtils.cancelToken = null;
    return super.onResponse(response);
  }
}

class ErrorInterceptor extends InterceptorsWrapper {
  @override
  Future onError(DioError err) {
    switch (err.type) {
      case DioErrorType.RESPONSE:
        String message = '';
        final String content = err.response.data.toString();
        if (content != '') {
          try {
            final Map<String, dynamic> decode =
                err.response.data as Map<String, dynamic>;
            message = decode['error'] as String;
          } catch (error) {
            message = error.toString();
          }
        }
        final int status = err.response.statusCode;
        switch (status) {
          case HttpStatus.unauthorized:
            throw AuthorizationException(status: status, message: message);
            break;
          case HttpStatus.unprocessableEntity:
            throw ValidationException(status: status, message: message);
            break;
          default:
            throw StatusException(status: status, message: message);
        }
        break;
      case DioErrorType.CANCEL:
        DioUtils.cancelToken = null;
        throw CancelRequestException(
            status: HttpStatus.clientClosedRequest, message: err.toString());
        break;
      default:
        // Log.d('$this ---->default');
        throw NetworkException(
            status: HttpStatus.networkConnectTimeoutError,
            message: err.message);
    }
  }
}
