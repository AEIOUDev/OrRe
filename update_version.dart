import 'dart:io';

void main() {
  final pubspec = File('pubspec.yaml');
  final lines = pubspec.readAsLinesSync();
  final versionLine = lines.firstWhere((line) => line.startsWith('version:'));
  final version = versionLine.split(':')[1].trim();
  final versionNumber = version.split('+')[0];
  final buildNumber = version.split('+')[1];

  updateAndroidVersion(versionNumber, buildNumber);
  updateiOSVersion(versionNumber, buildNumber);
}

void updateAndroidVersion(String version, String build) {
  final gradleFile = File('android/gradle.properties');
  final lines = gradleFile.readAsLinesSync();
  final newLines = lines.map((line) {
    if (line.startsWith('VERSION_CODE=')) {
      return 'VERSION_CODE=$build';
    } else if (line.startsWith('VERSION_NAME=')) {
      return 'VERSION_NAME=$version';
    } else {
      return line;
    }
  }).toList();
  gradleFile.writeAsStringSync(newLines.join('\n'));
}

void updateiOSVersion(String version, String build) {
  final pbxprojFile = File('ios/Runner.xcodeproj/project.pbxproj');
  final lines = pbxprojFile.readAsLinesSync();
  final newLines = lines.map((line) {
    if (line.contains('CURRENT_PROJECT_VERSION')) {
      return line.replaceFirst(RegExp(r'CURRENT_PROJECT_VERSION = \d+;'),
          'CURRENT_PROJECT_VERSION = $build;');
    } else if (line.contains('MARKETING_VERSION')) {
      return line.replaceFirst(RegExp(r'MARKETING_VERSION = \d+\.\d+\.\d+;'),
          'MARKETING_VERSION = $version;');
    } else {
      return line;
    }
  }).toList();
  pbxprojFile.writeAsStringSync(newLines.join('\n'));
}
