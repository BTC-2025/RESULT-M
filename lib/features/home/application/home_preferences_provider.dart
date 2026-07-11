import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final homeInterestTagsProvider = FutureProvider<Set<String>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs
      .getStringList('user_interests')
      ?.map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toSet() ??
      const <String>{};
});
