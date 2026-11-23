import 'package:api_client/api_client.dart';

import 'dependencies.dart';

BackofficeDependencies serverDependencies({required Uri baseUri}) =>
    BackofficeDependencies.server(baseUri: baseUri, tokens: MemoryTokenStore());
