import 'package:MyNews/helpers/custom_extentions.dart';
import 'package:MyNews/shared/global_values.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Prefs class
class Prefs {
  static SharedPreferences _sharedPreferences;

  /// init prefs
  static Future<void> initPrefs() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  /// get suggestions method
  static Future<List<String>> getSuggestions(String search) async {
    search = search.trim().toLowerCase();
    List<String> suggestions = [];
    List<String> adjustSuggestions = [];

    if (search == '') return suggestions;

    String prefsKey = 'suggestions';
    String pattern = '\n';

    // get suggestions from prefs
    String savedSuggestions = _sharedPreferences.getString(prefsKey);
    if (savedSuggestions == null || savedSuggestions.isEmpty) {
      return suggestions;
    }

    // ensure there are nn invalid string objects in suggestions
    suggestions = savedSuggestions.split(pattern).toList();
    suggestions.removeWhere(
        (item) => item == '' || !item.contains(RegExp(r'[a-zA-Z]')));

    // iterate every object in suggestion list
    // if search chars exits in start of the object, add the object to adjustSuggestions
    for (var i = 0; i < suggestions.length; i++) {
      if (search == suggestions[i]) {
        return [search.upperCaseFirstChar()];
      }
      if (suggestions[i].startsWith(search, 0)) {
        adjustSuggestions.add((suggestions[i].upperCaseFirstChar()));
      }
    }
    return adjustSuggestions;
  }

  /// save suggestions method
  static void saveSuggestions(String search) async {
    // validate search string
    if (!search.contains(RegExp(r'[a-zA-Z]'))) {
      return;
    }

    search = search.trim().toLowerCase();
    String prefsKey = 'suggestions';
    String pattern = '\n';
    String savedSuggestions = _sharedPreferences.getString(prefsKey);
    // if suggestions is null set string prefs first time
    if (savedSuggestions == null) {
      String str = search + pattern;
      _sharedPreferences.setString(prefsKey, str);
      //print('newSuggestions (first time): $str');
      return;
    }
    // split savedSuggestions to list
    List<String> oldSuggestions = savedSuggestions.split(pattern).toList();
    //print('oldSuggestions: $oldSuggestions');
    // if search already exists return
    if (oldSuggestions.contains(search)) {
      return;
    }
    // set news suggestions
    String newSuggestions = savedSuggestions + search + pattern;
    //print('newSuggestions:\n$newSuggestions');
    _sharedPreferences.setString(prefsKey, newSuggestions);
  }

  /// savedInPrefs method to return true / false if showBottomSheet / WelcomeDialog / FavoritesDialog / SettingsDialog stored in SharedPreferences
  static Future<bool> savedInPrefs(String str) async {
    if (savedPrefsStr.contains(str)) {
      String prefsKey = str;
      if (_sharedPreferences.getBool(prefsKey) == null) {
        _sharedPreferences.setBool(prefsKey, true);
        return true;
      }
    }
    return false;
  }
}
