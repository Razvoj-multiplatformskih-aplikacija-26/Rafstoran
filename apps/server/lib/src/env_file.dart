// Ready for copy as is.
import 'dart:io';

Map<String, String> readEnvFile(File file) {
  if (!file.existsSync()) return const {};
  return {
    for (final line in file.readAsLinesSync())
      if (line.indexOf('=') case final split when split > 0 && !line.trimLeft().startsWith('#'))
        line.substring(0, split).trim(): line.substring(split + 1).trim(),
  };
}

Map<String, String> serverEnvironment() => {...readEnvFile(File('../../.env')), ...Platform.environment};
