import 'package:shared_preferences/shared_preferences.dart';

Future<void> setPrefIntegerValue(String key,int valu) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(key, valu);
}

Future<int> getPrefIntegerValue(String key, {int defaultValue = 0}) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key) ?? defaultValue;
}


Future<void> setPrefStringValue(String key,String valu) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, valu);
}

Future<String> getPrefStringValue(String key, {String defaultValue = ''}) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? defaultValue;
}
