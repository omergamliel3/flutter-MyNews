import 'package:MyNews/helpers/custom_extentions.dart';

import 'package:MyNews/scoped-models/main.dart';

import 'package:MyNews/shared/global_values.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Prefs class
class Prefs {
  static SharedPreferences _sharedPreferences;
  static const String _sourcesSplitPattern = '\n';
  static const String _hiddenSourcePrefsKey = 'HiddenSources';

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

  /// return [true/false] if hidden sources list contains [source]
  static bool isSourceHidden(String source) {
    // get raw hidden sources string from prefs
    String rawSources = _sharedPreferences.getString(_hiddenSourcePrefsKey);
    if (rawSources != null && rawSources.isNotEmpty) {
      // split raw hidden sources to strings list
      List<String> hiddenSources = rawSources.split(_sourcesSplitPattern);
      // return whatever hiddenSources contains souce
      return hiddenSources.contains(source);
    }
    // return source if rawSources is null or empty
    return false;
  }

  /// returns list of all hidden sources
  static List<String> getHiddenSources() {
    String rawSources = _sharedPreferences.getString(_hiddenSourcePrefsKey);
    if (rawSources != null && rawSources.isNotEmpty) {
      List<String> hiddenSources = rawSources.split(_sourcesSplitPattern);
      if (hiddenSources != null && hiddenSources.isNotEmpty) {
        return hiddenSources;
      }
    }

    return null;
  }

  /// add source to hidden sources prefs
  static void addHiddenSource(String source, MainModel model) {
    // remove hidden source news data from model
    model.removeHiddenSources(source);
    // get raw hidden sources string from prefs
    String hiddenSources = _sharedPreferences.getString(_hiddenSourcePrefsKey);
    if (hiddenSources == null || hiddenSources.isEmpty) {
      hiddenSources = source;
    } else {
      List<String> hiddenSourcesList =
          hiddenSources.split(_sourcesSplitPattern);
      // if hidden sources contains source return
      if (hiddenSourcesList.contains(source)) {
        return;
      }
      hiddenSources += '$_sourcesSplitPattern$source';
    }

    print('add hidden source');
    print('source to hide: $source');
    print('Hidden sources:\n$hiddenSources');
    // set updated hidden sources in prefs
    _sharedPreferences.setString(_hiddenSourcePrefsKey, hiddenSources);
  }

  /// remove last source from hidden source prefs
  static void removeHiddenSource(MainModel model, [String source]) {
    String sourceToRemove;
    model.restoreNewsDataSnapState();
    // get raw hidden sources string from prefs
    String rawSources = _sharedPreferences.getString(_hiddenSourcePrefsKey);
    if (rawSources != null && rawSources.isNotEmpty) {
      // split rawSources to strings list
      List<String> hiddenSources = rawSources.split(_sourcesSplitPattern);
      if (source == null) {
        sourceToRemove = hiddenSources.last;
      } else {
        sourceToRemove = source;
      }
      // remove source from hiddenSources
      hiddenSources.remove(sourceToRemove);
      if (hiddenSources.length == 0) {
        _sharedPreferences.remove(_hiddenSourcePrefsKey);
      } else {
        // set updated hidden sources in prefs
        _sharedPreferences.setString(
            _hiddenSourcePrefsKey, hiddenSources.join(_sourcesSplitPattern));
      }

      print('source to remove from hidden sources: $sourceToRemove');
      print('remove hidden sources');
      print(hiddenSources.join(', '));
    }
  }
}
