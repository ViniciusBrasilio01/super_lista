import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  // Exemplo de configuração base
  static DioClient create({String baseUrl = 'https://api.exemplo.com'}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    // Interceptor simples para log (apenas debug)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Request: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onError: (error, handler) {
          print('Erro: ${error.message}');
          return handler.next(error);
        },
      ),
    );
    return DioClient(dio);
  }

  Dio get dio => _dio;
}
