// Ready for copy as is.
import 'package:api_contract/api_contract.dart';
import 'package:relic/relic.dart';

Middleware allowOrigins(List<String> origins) =>
    (Handler next) => (Request request) async {
      final origin = request.headers.origin?.toString();
      final allowed = origin != null && origins.contains(origin);
      if (request.method == Method.options) {
        return Response.noContent(
          headers: Headers.build((headers) => allowed ? _allow(headers, origin) : _vary(headers)),
        );
      }
      final result = await next(request);
      if (result is! Response) return result;
      return result.copyWith(
        headers: result.headers.transform((headers) => allowed ? _allow(headers, origin) : _vary(headers)),
      );
    };

void _allow(MutableHeaders headers, String origin) {
  headers['Access-Control-Allow-Origin'] = [origin];
  headers['Access-Control-Allow-Methods'] = ['GET, POST, DELETE, OPTIONS'];
  headers['Access-Control-Allow-Headers'] = ['Content-Type, ${ApiHeaders.userId}'];
  _vary(headers);
}

void _vary(MutableHeaders headers) => headers['Vary'] = ['Origin'];
