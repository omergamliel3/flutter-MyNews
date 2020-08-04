import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:geolocator/geolocator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:MyNews/models/news.dart';

import 'package:MyNews/helpers/custom_extentions.dart';
import 'package:MyNews/shared/global_values.dart';

import 'package:MyNews/services/custom_services.dart';
import 'package:MyNews/services/db_service.dart';
import 'package:MyNews/services/url_helper.dart';

enum SearchDateMode { Default, Custom, Week, Month }

/// MainModel Class
class MainModel extends Model {
  // Class Services

  // _sharedPreferences instance
  SharedPreferences _sharedPreferences;
  SharedPreferences get sharedPreferences => _sharedPreferences;
  Future<void> initSharedPrefrences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    //_sharedPreferences.clear();
  }

  // access model with ScopedModel.of(context)
  static MainModel of(BuildContext context) =>
      ScopedModel.of<MainModel>(context);

  // Class Attributes

  /// Master List<News> list to store all topics page List<News>
  List<List<News>> _newsList = [];

  /// Master List<News> list to store home page local and global List<News>
  List<List<News>> _homePageListNews = [[], []];

  /// following topics list values
  List<String> _followingTopicsList = [];

  /// string to save the search news title
  String _savedSearchNewsTitle = '';

  /// News list to store search News from the SearchPage
  List<News> _searchNews = [];

  int _tabBarIndex = 0; // tabBar index

  int _homePageTabBarIndex = 0; // home page tabBar index

  int get homePageTabBarindex => _homePageTabBarIndex;

  void setHomePageTabBarIndex(int index) {
    _homePageTabBarIndex = index;
  }

  int _pageIndex = 0; // navigation page index

  bool _isDark = false; // isDark bool to determine the theme mode
  int _selectedAccentColor;

  bool _privateSession = false; // Private Session
  String _searchCountry; // search country

  // fetch news fromDate -> toDate time
  DateTime _fromDate;
  DateTime _toDate;

  // searchDateMode enum
  SearchDateMode _searchDateMode;

  // not supported country string
  bool _countryNotSupported;
  // _searchCountryNotSupported get method
  bool get searchCountryNotSupported => _countryNotSupported;

  void setSearchCountryNotSupported(bool supported) {
    _countryNotSupported = supported;
  }

  // disable location bool value
  bool _disableLocation;
  // disable location getter
  bool get disableLocation => _disableLocation;
  // disable location setter
  void setDisableLocation(bool value) {
    if (value == null) return;
    _disableLocation = value;
    // implement disable location
    if (_disableLocation) {
      _searchCountry = null;
      _homePageListNews[0].clear();
      _sharedPreferences.remove('lastLocation');
    }
    _sharedPreferences.setBool('disableLocation', _disableLocation);

    notifyListeners();
  }

  // local news text direction (rtl / ltr)
  String _localTextDir;
  // _localTextDir getter
  String get localTextDir => _localTextDir;
  // local text dir set
  void setLocalTextDir(String dir) {
    _localTextDir = dir;
  }

  /// newsList getter
  List<List<News>> get getNewsList {
    if (_newsList == null) {
      return null;
    }
    return List.from(_newsList);
  }

  /// _homePageListNews getter
  List<List<News>> get homePageListNews {
    if (_homePageListNews == null || _homePageListNews.isEmpty) return null;

    return List.from(_homePageListNews);
  }

  /// followingTopicsList getter
  List<String> get getfollowingTopicsList {
    if (_followingTopicsList == null) {
      return null;
    }
    return List.from(_followingTopicsList);
  }

  /// set buttons nav bar method
  void setButtonNavBar(int index, String str) async {
    // drop exising following table
    await DBservice.dropTable(_followingTopicsList[index]);
    // create new table with the updated following topic
    await DBservice.createFollowingTable(str);

    // set the buttonNavBar according to the given index
    int listIndex = index;
    // set the navBar at index of _followingTopicsList
    _followingTopicsList[listIndex] = str;
    // set the news list object at index of _newsList to empty
    _newsList[listIndex] = [];

    // if current page index equals to current change NavBar,
    // call fetchNews method, and update searchMode

    if (_tabBarIndex == index) {
      fetchNews(
          forceFetch: true,
          saveSearchNews: false,
          headlines: false,
          index: index,
          search: str);
    }

    // update NavBars str in shared preferences
    // if true, set the update the NavBar str in prefs
    if (_sharedPreferences.getString('NavBar0') != null) {
      // Generate Concept
      _sharedPreferences.setString('NavBar$listIndex', str);
    }
    notifyListeners();
  }

  /// _searchNews getter
  List<News> get getSearchNews {
    if (_searchNews == null) {
      return null;
    }
    // return a copy of _searchNews
    return List.from(_searchNews);
  }

  // _isDark getter
  bool get isDark {
    return _isDark;
  }

  /// set theme method
  void setTheme(bool isDark) {
    // set _isDark
    _isDark = isDark;
  }

  /// change theme method
  void changeTheme() async {
    _isDark = !isDark;
    // if selectedAccentColor is not saved in prefs set the accent color to theme default
    if (_sharedPreferences.getInt('selectedAccentColor') == null) {
      _selectedAccentColor =
          isDark ? darkAccentColorIndex : lightAccentColorIndex;
    }

    notifyListeners();
  }

  /// init Theme Data
  Future<void> initThemeData() async {
    await initSharedPrefrences();
    bool isDark;
    // get the value from saredPreferences
    isDark = _sharedPreferences.getBool('isDark');
    // if getBool is null return false, and set theme to light
    if (isDark == null) {
      setTheme(false);
      // if get bool is not null, return _isDark and set theme to _isDark
    } else {
      setTheme(isDark);
    }

    // get selected accent color from prefs
    _selectedAccentColor = _sharedPreferences.getInt('selectedAccentColor');
    // set selected accent color according to app theme if not saved in prefs
    if (_selectedAccentColor == null) {
      _selectedAccentColor =
          _isDark ? darkAccentColorIndex : lightAccentColorIndex;
    }
  }

  // _selectedAccentColor getter
  int get selectedAccentColorIndex => _selectedAccentColor;

  // set accent color index
  void setSelectedAccentColorIndex(int index) async {
    _selectedAccentColor = index;
    _sharedPreferences.setInt('selectedAccentColor', _selectedAccentColor);
  }

  /// privateSession getter
  bool get privateSession {
    return _privateSession;
  }

  /// set privateSession method
  void setPrivateSession(bool privateSession) {
    _privateSession = privateSession;
    //_savedSearchNewsTitle = '';
  }

  /// savedSearchNewsTitle getter
  String get savedSearchNewsTitle {
    return _savedSearchNewsTitle;
  }

  /// savedSearchNewsTitle set method
  void setSavedSearchNewsTitle(String title) {
    if (title == null || title.isEmpty) {
      _savedSearchNewsTitle = null;
    }
    _savedSearchNewsTitle = title.trim();
  }

  /// _tabBarIndex getter
  int get tabBarIndex {
    return _tabBarIndex;
  }

  /// set tabBarIndex method
  void setTabBarIndex(int index) {
    if (index == null) return;
    _tabBarIndex = index;
  }

  /// _pageIndex getter
  int get pageIndex {
    return _pageIndex;
  }

  /// set pageIndex method
  void setPageIndex(int index) {
    _pageIndex = index;
  }

  /// searchCountry getter
  String get searchCountry {
    return _searchCountry;
  }

  /// set searchCountry method
  void setSearchCountry(String country) async {
    if (country == null || country.isEmpty) return;

    if (country == 'No Country') {
      _searchCountry = null;
      _countryNotSupported = true;
      _sharedPreferences.remove(searchCountryPrefsKey);
    } else {
      // save _searchCountry in prefs and local
      _searchCountry = country;
      _sharedPreferences.setString(searchCountryPrefsKey, country);
    }

    // clear local homePageListNews
    _homePageListNews[0].clear();
    notifyListeners();
  }

  /// fromDate getter
  DateTime get fromDate {
    return _fromDate;
  }

  /// set fromDate method
  void setFromDate(DateTime time) async {
    // set time in prefs fromDate key
    _sharedPreferences.setString(fromDatePrefsKey, time.toString());
    // update localy
    _fromDate = time;
    // clear _newsList to re-fetch with updated date search
    _newsList.forEach((List<News> element) {
      element.clear();
    });
    notifyListeners();
  }

  /// toDate getter
  DateTime get toDate {
    return _toDate;
  }

  /// set toDate method
  void setToDate(DateTime time) async {
    // set time in prefs toDate key
    _sharedPreferences.setString(toDatePrefsKey, time.toString());
    // update localy
    _toDate = time;
    // clear _newsList to re-fetch with updated date search
    _newsList.forEach((List<News> element) {
      element.clear();
    });
    notifyListeners();
  }

  /// SearchDateMode getter
  SearchDateMode get searchDateMode {
    return _searchDateMode;
  }

  /// set SearchDateMode method
  void setSearchDateMode(SearchDateMode searchDateMode) async {
    if (searchDateMode == null) return;
    // save searchDateMode in prefs
    _sharedPreferences.setString(
        searchDateModePrefsKey, searchDateMode.toString());
    // save searchDateMode localy
    _searchDateMode = searchDateMode;

    // if date mode is changed to default
    if (searchDateMode != SearchDateMode.Custom) {
      Duration subtract;
      if (searchDateMode == SearchDateMode.Default) {
        subtract = Duration(days: 1);
      } else if (searchDateMode == SearchDateMode.Week) {
        subtract = Duration(days: 7);
      } else if (searchDateMode == SearchDateMode.Month) {
        subtract = Duration(days: 30);
      }
      // set date values
      _fromDate = DateTime.now().subtract(subtract);
      _toDate = DateTime.now();
      // restore FromDate and ToDate prefs values to default
      _sharedPreferences.setString(fromDatePrefsKey, _fromDate.toString());
      _sharedPreferences.setString(toDatePrefsKey, _toDate.toString());
      // clear _newsList to re-fetch with updated date search
      _newsList.forEach((List<News> element) {
        element.clear();
      });
    }
    notifyListeners();
  }

  /// initalized prefs method
  Future<void> initAppData() async {
    // set page index
    _tabBarIndex = 0;

    // first time open the app, set all values in prefs
    if (_sharedPreferences.getString('NavBar0') == null) {
      _followingTopicsList =
          List<String>.generate(defaultsCategories.length, (index) {
        _newsList.add([]);
        _sharedPreferences.setString('NavBar$index', defaultsCategories[index]);
        return defaultsCategories[index];
      });

      //print(
      //'\n\n\nFirst time open the app\nsaved key: [NavBarLength], value: ${_followingTopicsList.length}\n\n\n');

      // set navBarLength in prefs
      _sharedPreferences.setInt('NavBarLength', _followingTopicsList.length);

      // set fetch DateTime local
      _fromDate = DateTime.now().subtract(Duration(days: 1));
      _toDate = DateTime.now();
      // set fetch DateTime in prefs
      _sharedPreferences.setString(fromDatePrefsKey, _fromDate.toString());
      _sharedPreferences.setString(toDatePrefsKey, _toDate.toString());
      // set searchDateMode to default
      _sharedPreferences.setString(
          searchDateModePrefsKey, 'SearchDateMode.Default');
      // set searchDateMode localy to default
      _searchDateMode = SearchDateMode.Default;

      // disable location default is false;
      _disableLocation = false;
      sharedPreferences.setBool('disableLocation', false);
    }
    // not first time open the app, get user data from prefs
    else {
      // create _followingTopicsList, _newsList from prefs NavBars values and length
      int navBarLength = _sharedPreferences.getInt('NavBarLength');
      //print(
      //'Not first time open the app.\nkey: [NavBarLength] --> value: $navBarLength\n\n\n');

      _followingTopicsList = List<String>.generate(navBarLength, (index) {
        String buttonNavBar =
            _sharedPreferences.getString('NavBar$index') ?? '';
        _newsList.add([]);
        return buttonNavBar;
      });

      // set search date mode, _fromDate, _toDate
      String searchDateModePrefsStr =
          _sharedPreferences.getString(searchDateModePrefsKey);

      // adjust default case
      if (searchDateModePrefsStr == 'Default') {
        searchDateModePrefsStr = 'SearchDateMode.Default';
      }

      // determine _searchDateMode, _fromDate, _toDate
      switch (searchDateModePrefsStr) {
        case 'SearchDateMode.Custom':
          _searchDateMode = SearchDateMode.Custom;
          _fromDate =
              DateTime.parse(_sharedPreferences.getString(fromDatePrefsKey));
          _toDate =
              DateTime.parse(_sharedPreferences.getString(toDatePrefsKey));
          break;
        case 'SearchDateMode.Week':
          // default search date mode, values set to DateTime now method
          _searchDateMode = SearchDateMode.Week;
          _fromDate = DateTime.now().subtract(Duration(days: 7));
          _toDate = DateTime.now();
          break;
        case 'SearchDateMode.Month':
          // default search date mode, values set to DateTime now method
          _searchDateMode = SearchDateMode.Month;
          _fromDate = DateTime.now().subtract(Duration(days: 30));
          _toDate = DateTime.now();
          break;
        default:
          searchDateModePrefsStr = 'SearchDateMode.Default';
          // default search date mode, values set to DateTime now method
          _searchDateMode = SearchDateMode.Default;
          _fromDate = DateTime.now().subtract(Duration(days: 1));
          _toDate = DateTime.now();
          break;
      }

      // set diableLocaton
      _disableLocation = sharedPreferences.getBool('disableLocation') ?? false;
    }
  }

  /// restore all saved prefs and local to defaults
  Future<void> restoreToDefaults() async {
    // clear prefs
    String location = _sharedPreferences.get('lastLocation');
    await _sharedPreferences.clear();
    // set last location to evoid alert when entering the app again with locatio service disalbe
    _sharedPreferences.setString('lastLocation', location);
    // evoid showing dialogs again
    savedPrefsStr.forEach((element) {
      _sharedPreferences.setBool(element, true);
    });
    // reset local
    setPrivateSession(false);
    setTheme(false);
    _selectedAccentColor = lightAccentColorIndex;
    setSavedSearchNewsTitle('');
    _searchNews.clear();
    _newsList.clear();
    _followingTopicsList.clear();
    setSearchDateMode(SearchDateMode.Default);
    await DBservice.deleteDB();
    await DBservice.initDb();
    notifyListeners();
  }

  /// fetch news from 'News API'
  Future<Map<String, dynamic>> fetchNews(
      {bool saveSearchNews = false,
      bool headlines = false,
      bool forceFetch = false,
      String search,
      int index}) async {
    print('fetchNews call');
    // connectivity check
    bool connectivity = await Connectivity.internetConnectivity();
    // headlines / topics page:
    // if not force fetch, check if news list already contains news.
    // if true, evoid fetch again.
    if (!forceFetch && !saveSearchNews) {
      List<News> newsList;
      // headlines case
      if (headlines)
        newsList = _homePageListNews[index];
      // topics case
      else
        newsList = _newsList[index];

      if (newsList.isNotEmpty) {
        print('newsList is not empty');
        notifyListeners();
        return connectivity
            ? {'error': false}
            : {'error': false, 'message': 'There is no internet connection'};
      }
    }

    if (!connectivity) {
      notifyListeners();
      return {'error': true, 'message': 'There is no internet connection'};
    }

    // store if tab page is local or global
    bool local = false;

    // start to fetch news. clear news lists at index.
    if (saveSearchNews) {
      _searchNews.clear();
    } else if (headlines) {
      // when index = 0, local tab, else index = 1, global tab.
      local = index == 0;
      _homePageListNews[index].clear();
    } else {
      _newsList[index].clear();
    }

    // notify list is empty
    notifyListeners();

    // http request to load news data from News API
    http.Response response;

    try {
      // fetch headlines (Headlines Page case)
      if (headlines) {
        if (local) {
          // get local news from top headlines endpoint with searchCountry as country value
          response = await http.get(
            UrlHelper.localHeadlinesEndpoint(_searchCountry),
          );
        } else if (index == 1) {
          // get global news
          response = await http.get(
            UrlHelper.globalHeadlinesEndpoint(),
          );
        }
        // fetch following / Search Page case
      } else {
        if (defaultsCategories.contains(search)) {
          response = await http.get(
            UrlHelper.everythingEndpoint(search, _fromDate, _toDate),
          );
        } else
          response = await http.get(
            UrlHelper.everythingTitleEndpoint(search, _fromDate, _toDate),
          );
      }
    } catch (e) {
      // http error
      print(e);
      return {
        'error': true,
        'message': 'Sorry, We have problems with our server'
      };
    }

    // NewsAPI.org server error
    if (response.statusCode != 200) {
      // error handling
      String errorMessage = "Somthing went wrong...";
      Map<String, dynamic> error;
      // decode json to Map to print error message
      error = json.decode(response.body);

      // print json error message
      if (error != null) {
        errorMessage = error['message'];
        print('\n\n\n\n$errorMessage\n\n\n');
      }
      return {
        'error': true,
        'message': 'Sorry, We have problems with our server'
      };
    }

    ////
    // if there are no errors, this code runs.
    ////

    // fetchedNewsList to store the News
    final List<News> fetchedNewsList = [];
    // convert the response json to Map newsListData to get all news data from the server
    final Map<String, dynamic> newsListData = json.decode(response.body);
    if (newsListData == null ||
        newsListData.isEmpty ||
        newsListData['articles'].length == 0) {
      // if the data is empty
      // return false when failed
      return {'error': true, 'message': 'Can\'t find articles'};
    }

    int articlesLength = newsListData['articles'].length;

    // set localTextDir
    if (local && _localTextDir == null) {
      _localTextDir = LanguageHelper.identifyLanguageWithRegEx(
          newsListData['articles'][0]['title']);
    }
    // store news list data in news instances
    for (var i = 0; i < articlesLength; i++) {
      // create a news fromMap Instance
      final News news = News.fromMap(
          newsData: newsListData['articles'][i],
          textDirection: local ? _localTextDir : 'ltr');
      // add the news to the fetchednewslist, if news title does not exists and title is not empty
      bool addArticle = true;
      if (news.title == '' || news.title == null) {
        addArticle = false;
      } else {
        for (var j = 0; j < fetchedNewsList.length; j++) {
          if (news.title == fetchedNewsList[j].title) {
            addArticle = false;
            break;
          }
        }
      }

      if (addArticle) fetchedNewsList.add(news);
    }

    // search page case
    if (saveSearchNews) {
      // save localy
      _searchNews = List.from(fetchedNewsList);
      // save SearchNews title (the search string) if private settion is false
      if (!_privateSession) setSavedSearchNewsTitle(search);
    }
    // headlines page case
    else if (headlines) {
      _homePageListNews[index] = List.from(fetchedNewsList);

      // insert fetchedNewsList to DB
      fetchedNewsList.forEach((element) async {
        await DBservice.insertTempNews(element, index);
      });
    }
    // topics page case
    else {
      // set _newsList to the local list
      _newsList[index] = List.from(fetchedNewsList);

      // insert fetchedNewsList to DB
      fetchedNewsList.forEach((element) async {
        await DBservice.insertTempNews(element, index, following: search);
      });
    }
    // notify the scoped-model widgets that something has change
    notifyListeners();
    // return future value true when success
    return {'error': false, 'message': 'success'};
  }

  /// add categories method
  Future<void> addFollowing(String followingTopic, Function addLocal) async {
    // call add local function
    addLocal(followingTopic);
    // trim and lower case string
    String addValue = followingTopic.trim().toLowerCase();
    // uppder case first char
    addValue = addValue.upperCaseFirstChar();
    _sharedPreferences.setString(
        'NavBar${_followingTopicsList.length}', followingTopic);
    _followingTopicsList.add(followingTopic);
    _newsList.add([]);
    _sharedPreferences.setInt('NavBarLength', _followingTopicsList.length);
    await DBservice.createFollowingTable(followingTopic);
    notifyListeners();
  }

  /// remove categories method
  Future<void> removeFollowing(int index) async {
    // remove from prefs
    _sharedPreferences.remove('NavBar$index');
    // remove from navBarList at index
    String removed = _followingTopicsList.removeAt(index);
    // remove from newsList at index
    _newsList.removeAt(index);
    // set new NavBarLength in prefs
    _sharedPreferences.setInt('NavBarLength', _followingTopicsList.length);
    // save all NavBar + index with the updated values
    for (var i = 0; i < _followingTopicsList.length; i++) {
      _sharedPreferences.setString('NavBar$i', _followingTopicsList[i]);
    }
    // drop removed following topic db table
    await DBservice.dropTable(removed);
    // notify model has changed
    notifyListeners();
  }

  /// get user location and fetch country name from google geocode API
  Future<bool> fetchLocation({bool refetch = false}) async {
    if (sharedPreferences.getBool('disableLocation') ?? false) {
      _searchCountry = null;
      return true;
    }
    if (!refetch) {
      // get lastLocation from prefs instance
      String lastLocation = _sharedPreferences.get('lastLocation');
      bool savedLastLocation = lastLocation != null;

      // return search country saved in prefs
      if (savedLastLocation) {
        _searchCountry = lastLocation;
        checkSupportedCountry(_searchCountry);
        return true;
      }
    }

    if (refetch) {
      // clear local headlines db table
      const String _kDBLocalNewsTableName = 'local_news_table';
      await DBservice.clearTable(_kDBLocalNewsTableName);
    }

    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    // return true if location service is enable, false if not
    bool locationServiceEnable = await geolocator.isLocationServiceEnabled();
    // position instace
    Position position;

    // if location service enable get current position
    if (locationServiceEnable) {
      try {
        // await current position
        position = await geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
      } catch (e) {
        print(e);
      }

      // if location service is not enable get last known position
    } else {
      try {
        // await last known position
        position = await geolocator.getLastKnownPosition(
            desiredAccuracy: LocationAccuracy.best);
      } catch (e) {
        print(e);
      }
    }

    // success get position
    if (position != null) {
      // get http request to google geocode API with the given device position
      http.Response response;
      response = await http.get(
          UrlHelper.googleGeoCodeAPI(position.latitude, position.longitude));

      if (response.statusCode == 200) {
        // decode response body to Map
        final Map<String, dynamic> responseData = json.decode(response.body);

        // try to get country from response data results address_components
        try {
          // find country long name in response data results array
          var locationData = responseData['results'][0]['address_components'];
          for (var i = 0; i < locationData.length; i++) {
            String element = locationData[i]['long_name'];
            // if element['long_name'] - country name in countries map
            if (countriesMap.containsKey(element)) {
              // set search country to element data
              _searchCountry = element;
              // check if country exists in News API supported countries
              // if not, set _countryNotSupported to true
              // if exists, save country in prefs
              checkSupportedCountry(_searchCountry);
              if (refetch) {
                _homePageListNews[0].clear();
                notifyListeners();
              }
              return true;
            }
          }
        } catch (e) {
          if (refetch) {
            return false;
          }
          // response data error
          print('Cant find country in response Data');
          print('Error $e');
          // location is enable but the API does not recognize the country
          _searchCountry = 'No Country';
          _countryNotSupported = true;
          return true;
        }

        // try get country from response data results - plus code - compoude code
        try {
          String element = responseData['results'][0]['plus_code']
                  ['compound_code']
              .split(', ')[1];

          if (countriesMap.containsKey(element)) {
            // set search country to element data
            _searchCountry = element;

            // check if country exists in News API supported countries
            // if not, set _countryNotSupported to true
            // if exists, save country in prefs
            checkSupportedCountry(_searchCountry);
            if (refetch) {
              _homePageListNews[0].clear();
              notifyListeners();
            }
            return true;
          }
        } catch (e) {
          print('Error $e');
          if (refetch) {
            return false;
          }
          // location is enable but the API does not recognize the country
          _searchCountry = 'No Country';
          _countryNotSupported = true;
          return true;
        }
      }
    }

    // position is null
    // cant get county from geo coding API
    // can't find country in response data
    // lastLocation from prefs in null, set search country to null

    if (refetch) {
      return false;
    }

    _searchCountry = null;
    return false;
  }

  /// check if country is supported by news API
  void checkSupportedCountry(String country) {
    if (_searchCountry == null) return;

    // if supported, save last location in prefs
    // set set _countryNotSupported to false
    if (apiCountries.contains(countriesMap[country])) {
      _sharedPreferences.setString('lastLocation', _searchCountry);
      _countryNotSupported = false;
    }
    // if not suppotred, set _countryNotSupported to true
    else {
      _countryNotSupported = true;
    }
  }

  /// fetch temp headlines news data from db at
  Future<void> fetchHeadlinesData([bool connectivity = false]) async {
    for (var i = 0; i < 2; i++) {
      // get temp saved localheadlinesNews from db
      List<News> localheadlinesNews = await DBservice.getTempNews(i);
      // if localheadlinesNews contains data
      if (localheadlinesNews != null && localheadlinesNews.isNotEmpty) {
        // data expire time validation
        DateTime createdTime =
            DateTime.parse(localheadlinesNews[0].createdTime);
        Duration difference = DateTime.now().difference(createdTime);
        // if connectivity is true or difference smaller than 1 hour
        if (difference.inMinutes < 59 || connectivity) {
          //print('fetch headlines news data from db!');
          // set homePageListNews to the saved db data.
          _homePageListNews[i] = List.from(localheadlinesNews);
        }
      }
    }
  }

  /// fetch temp following news data from db
  Future<void> fetchFollowingData([bool connectivity = false]) async {
    for (var i = 0; i < _followingTopicsList.length; i++) {
      // get temp following news data from db
      List<News> followingNews =
          await DBservice.getTempNews(i, following: _followingTopicsList[i]);

      if (followingNews != null && followingNews.isNotEmpty) {
        // data expire time validation
        DateTime createdTime = DateTime.parse(followingNews[0].createdTime);
        Duration difference = DateTime.now().difference(createdTime);
        // if connectivity is true or difference smaller than 1 hour
        if (difference.inMinutes < 59 || connectivity) {
          //print('fetch following news data from db!');
          // set local following news list to [followingNews]
          _newsList[i] = List.from(followingNews);
        }
      }
    }
  }

  /// notifyListeners that the model has changed
  void callNotifyListeners() {
    notifyListeners();
  }
}
