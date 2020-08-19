import 'package:MyNews/helpers/custom_extentions.dart';

import 'package:MyNews/scoped-models/main.dart';

import 'package:MyNews/shared/global_values.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Prefs class
class Prefs {
  static SharedPreferences _sharedPreferences;
  static const String _sourcesSplitPattern = '\n';
  static const String _hiddenSourcePrefsKey = 'HiddenSources';
  static const String _prioritizeSourcesPrefsKey = 'PrioritizeScources';

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
    // safety check
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
    // get raw hidden sources string from prefs
    String rawSources = _sharedPreferences.getString(_hiddenSourcePrefsKey);
    // safety check
    if (rawSources != null && rawSources.isNotEmpty) {
      // split rawSources to Strings list
      List<String> hiddenSources = rawSources.split(_sourcesSplitPattern);
      if (hiddenSources != null && hiddenSources.isNotEmpty) {
        return hiddenSources;
      }
    }
    // return null if rawSources is empty or null
    return null;
  }

  /// add source to hidden sources prefs
  static void addHiddenSource(String source, MainModel model) {
    // [source] safety check
    if (source == null || source.isEmpty) return;
    // remove hidden source news data from model
    model.removeHiddenSources(source);
    // get raw hidden sources string from prefs
    String hiddenSources = _sharedPreferences.getString(_hiddenSourcePrefsKey);
    // safety check
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
    // remove source from prioritize sources if exists
    unPrioritizeSource(source);
    // set updated hidden sources in prefs
    _sharedPreferences.setString(_hiddenSourcePrefsKey, hiddenSources);
  }

  /// remove last source from hidden source prefs
  static void removeHiddenSource(MainModel model, [String source]) {
    String sourceToRemove;

    // get raw hidden sources string from prefs
    String rawSources = _sharedPreferences.getString(_hiddenSourcePrefsKey);
    if (rawSources != null && rawSources.isNotEmpty) {
      // split rawSources to strings list
      List<String> hiddenSources = rawSources.split(_sourcesSplitPattern);
      if (source == null) {
        sourceToRemove = hiddenSources.last;
        // restore news data state only if restore last hidden source case
        model.restoreNewsDataSnapState();
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
    }
  }

  /// add source to prioritizes list
  static void prioritizeSource(String source) {
    // [source] safety check
    if (source == null || source.isEmpty) return;
    // get raw prioritize sources string from prefs
    String rawStr = _sharedPreferences.getString(_prioritizeSourcesPrefsKey);
    String prioritize;
    if (rawStr == null || rawStr.isEmpty) {
      prioritize = source;
    } else {
      // split rawStr to List prioritize sources
      List<String> prioritizeSources = rawStr.split(_sourcesSplitPattern);
      // stops method if prioritizeSources contains [soource]
      if (prioritizeSources.contains(source)) {
        return;
      }
      // concatenation updated prioritize sources
      prioritize = rawStr + _sourcesSplitPattern + source;
    }
    // save updated prioritize sources in prefs
    _sharedPreferences.setString(_prioritizeSourcesPrefsKey, prioritize);
  }

  /// remove source from prioritizes list
  static void unPrioritizeSource(String source) {
    // [source] safety check
    if (source == null || source.isEmpty) return;
    // get raw prioritize sources string from prefs
    String rawStr = _sharedPreferences.getString(_prioritizeSourcesPrefsKey);
    if (rawStr == null || rawStr.isEmpty) return;
    // split rawStr to List prioritize sources
    List<String> prioritizeSources = rawStr.split(_sourcesSplitPattern);
    if (prioritizeSources.contains(source)) {
      // remove source from prioritize sources
      prioritizeSources.remove(source);
      // save updated prioritize sources in prefs
      _sharedPreferences.setString(_prioritizeSourcesPrefsKey,
          prioritizeSources.join(_sourcesSplitPattern));
    }
  }

  /// returns [true/false] whatever source is prioritize
  static bool isSourcePrioritize(String source) {
    // [source] safety check
    if (source == null || source.isEmpty) return false;
    // get raw prioritize sources string from prefs
    String rawStr = _sharedPreferences.getString(_prioritizeSourcesPrefsKey);
    // null and empty check
    if (rawStr == null || rawStr.isEmpty) {
      return false;
    }
    List<String> prioritizeSources = rawStr.split(_sourcesSplitPattern);
    return prioritizeSources.contains(source);
  }

  /// returns [true/false] whatever pioritize sources
  static bool isPioritizeSourcesEmpty() {
    // get raw prioritize sources string from prefs
    String rawStr = _sharedPreferences.getString(_prioritizeSourcesPrefsKey);
    // null and empty check
    if (rawStr == null || rawStr.isEmpty) {
      return true;
    }
    return false;
  }
}
