import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app.dart';
import 'data/local_system.dart';

void main() {
  const server = String.fromEnvironment('SERVER', defaultValue: 'http://localhost:8080');
  runApp(ConsoleApp(client: http.Client(), server: Uri.parse(server), local: createLocalSystem()));
}
