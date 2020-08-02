// Article Data class

class Article {
  final int id;
  final String url;
  final String urlToImage;
  final String title;
  final String source;
  final String date;
  final String textDirection;

  Article(
      {this.id,
      this.url,
      this.urlToImage,
      this.title,
      this.source,
      this.date,
      this.textDirection});

  Article.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'],
        url = map['url'],
        urlToImage = map['urlToImage'],
        title = map['title'],
        source = map['source'],
        date = map['date'],
        textDirection = map['textDirection'];

  Map<String, dynamic> toJsonMap() => {
        'id': id,
        'url': url,
        'urlToImage': urlToImage,
        'title': title,
        'source': source,
        'date': date,
        'textDirection': textDirection
      };
}
