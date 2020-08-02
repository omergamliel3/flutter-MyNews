import 'package:MyNews/services/custom_services.dart';
import 'package:MyNews/shared/global_values.dart';
import 'package:MyNews/shared/keys.dart';

// Url Helper class

class UrlHelper {
  /// news API local top-headlines endpoint with a given country
  static String localHeadlinesEndpoint(String country) {
    // get iscoCountry from countriesMap with country as key
    String isoCountry = countriesMap[country];
    return 'https://newsapi.org/v2/top-headlines?country=$isoCountry&category=general&language=en&pageSize=100&apiKey=$newsApiKey';
  }

  /// news API global top-headlines endpoint
  static String globalHeadlinesEndpoint() {
    return 'https://newsapi.org/v2/top-headlines?language=en&pageSize=100&apiKey=$newsApiKey';
  }

  /// news API everything endpoint with search as -q- perameter (Use for categories search)
  static String everythingEndpoint(
      String search, DateTime fromDate, DateTime toDate) {
    // calculate today's date to fit the News API 'from' parameter.
    String date = Helpers.calculateDate(fromDate, toDate);
    return 'https://newsapi.org/v2/everything?q=$search$date&sortBy=popularity&language=en&pageSize=100&apiKey=$newsApiKey';
  }

  /// news API everything endpoint with search as -qInTitle- perameter (Use for topics search)
  static String everythingTitleEndpoint(
      String search, DateTime fromDate, DateTime toDate) {
    // calculate today's date to fit the News API 'from' parameter.
    String date = Helpers.calculateDate(fromDate, toDate);
    return 'https://newsapi.org/v2/everything?qInTitle=+$search$date&sortBy=popularity&language=en&pageSize=100&apiKey=$newsApiKey';
  }

  /// google geocode API to get user local country from the device position
  static String googleGeoCodeAPI(double latitude, double longitude) {
    return 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$geoCodingApiKey';
  }
}
