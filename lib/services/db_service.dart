import 'dart:io';

import 'package:async/async.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

import 'package:MyNews/models/article.dart';
import 'package:MyNews/models/news.dart';

import 'package:MyNews/shared/global_values.dart';

class DBservice {
  static const _kDbFileName = 'sqflite_ex.db';
  static const _kDbTableName = 'saved_articles_table';
  static const _kDBLocalNewsTableName = 'local_news_table';
  static const _kDBGlobalNewsTableName = 'global_news_table';
  static final AsyncMemoizer _memoizer = AsyncMemoizer();
  static List<Article> _savedArticles = [];
  static Database _db;
  static bool initDB;

  // _savedArticles getter
  static List<Article> get savedArticles => _savedArticles;

  /// Init DB, run only once
  static Future<bool> asyncInitDB() async {
    // Avoid this function to be called multiple times
    await _memoizer.runOnce(() async {
      initDB = await initDb();
      //return initDB;
    });
    return initDB;
  }

  // Opens a db local file. Creates the db table if it's not yet created.
  static Future<bool> initDb() async {
    try {
      // get database path directory
      final dbFolder = await getDatabasesPath();
      if (!await Directory(dbFolder).exists()) {
        await Directory(dbFolder).create(recursive: true);
      }
      final dbPath = join(dbFolder, _kDbFileName);
      // open db
      _db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (Database db, int version) async {
          // create saved articles table
          await _createSavedArticlesTable(db);
          // create 2 headlines news tables
          await _createHeadlinesTable(db);
          // create following news tables
          await _createFollowingTables(db);
        },
      );
      // get saved articles from db
      _savedArticles = await getArticles();
      return true;
    } catch (e) {
      // failed to init db
      print(e);
      return false;
    }
  }

  /// Delete the database
  static Future<void> deleteDB() async {
    final dbFolder = await getDatabasesPath();
    if (!await Directory(dbFolder).exists()) {
      await Directory(dbFolder).create(recursive: true);
    }
    final dbPath = join(dbFolder, _kDbFileName);
    await deleteDatabase(dbPath);
    _db = null;
    initDB = null;
    _savedArticles.clear();
  }

  // execute saved articles db tables
  static Future<void> _createSavedArticlesTable(Database db) async {
    //print('create $_kDbTableName table!');
    await db.execute('''
        CREATE TABLE $_kDbTableName(
          id INTEGER PRIMARY KEY, 
          url TEXT,
          urlToImage TEXT,
          title TEXT,
          source TEXT,
          date TEXT,
          textDirection TEXT)
        ''');
  }

  /// execute headlines db tables
  static Future<void> _createHeadlinesTable(Database db) async {
    for (var i = 0; i < 2; i++) {
      String tableName;
      if (i == 0) {
        tableName = _kDBLocalNewsTableName;
      } else {
        tableName = _kDBGlobalNewsTableName;
      }
      //print('create $tableName table!');
      await db.execute('''
        CREATE TABLE $tableName(
          id INTEGER PRIMARY KEY, 
          author TEXT,
          source TEXT,
          title TEXT,
          description TEXT,
          content TEXT,
          url TEXT,
          urlToImage TEXT,
          publishedAt TEXT,
          textDir TEXT,
          createTime TEXT
          )
        ''');
    }
  }

  /// execute following db tables
  static Future<void> _createFollowingTables(Database db) async {
    for (var i = 0; i < defaultsCategories.length; i++) {
      String following = defaultsCategories[i];
      print('create $following table!');
      await db.execute('''
        CREATE TABLE $following(
          id INTEGER PRIMARY KEY, 
          author TEXT,
          source TEXT,
          title TEXT,
          description TEXT,
          content TEXT,
          url TEXT,
          urlToImage TEXT,
          publishedAt TEXT,
          textDir TEXT,
          createTime TEXT
          )
        ''');
    }
  }

  /// execute following table with a given index
  static Future<void> createFollowingTable(String following) async {
    print('create $following table!');
    await _db.execute('''
        CREATE TABLE $following(
          id INTEGER PRIMARY KEY, 
          author TEXT,
          source TEXT,
          title TEXT,
          description TEXT,
          content TEXT,
          url TEXT,
          urlToImage TEXT,
          publishedAt TEXT,
          textDir TEXT,
          createTime TEXT
          )
        ''');
  }

  /// drop table from db
  static Future<void> dropTable(String following) async {
    print('drop $following table!');
    await _db.execute("DROP TABLE IF EXISTS $following");
  }

  /// clear following index table
  static Future<void> clearTable(String table) async {
    print('clear $table table!');
    await _db.rawDelete('''DELETE FROM $table''');
  }

  /// Retrieves rows from the db table.
  static Future<List<Article>> getArticles() async {
    List<Map> jsons = await _db.rawQuery('SELECT * FROM $_kDbTableName');
    //print('${jsons.length} rows retrieved from db $_kDbTableName!');
    return jsons.map((json) => Article.fromJsonMap(json)).toList();
  }

  /// delete all articles from the db table
  /// return [true/false] if successfuly deleted all articles from the table
  static Future<bool> deleteAllArticles() async {
    try {
      await _db.rawDelete('''
        DELETE FROM $_kDbTableName
      ''');
      _savedArticles.clear();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Inserts records to the db table.
  /// Note we don't need to explicitly set the primary key (id), it'll auto increment.
  /// return [true/false] if successfuly added new article to the table.
  static Future<bool> addArticle(Article article) async {
    try {
      await _db.transaction(
        (Transaction txn) async {
          int id = await txn.rawInsert('''
          INSERT INTO $_kDbTableName
            (url, urlToImage, title, source, date, textDirection)
          VALUES
            (
              "${article.url}",
              "${article.urlToImage}", 
              "${article.title}",
              "${article.source}",
              "${article.date}",
              "${article.textDirection}"
            )''');
          _savedArticles.add(article);
          print('Inserted Article with id=$id.');
        },
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Deletes records in the db table.
  /// return [true/false] if successfuly deleted article from the table
  static Future<bool> deleteArticle(String url) async {
    print('deleteArticle');
    try {
      final count = await _db.rawDelete('''
        DELETE FROM $_kDbTableName
        WHERE url = "$url"
      ''');
      _savedArticles.removeWhere((element) => element.url == url);
      print('Updated $count records in db.');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Updates records in the db table.
  /// return [true/false] if successfuly updated article
  static Future<bool> updateArticle(Article article) async {
    try {
      int count = await _db.rawUpdate(
        /*sql=*/ '''UPDATE $_kDbTableName
                    SET source = ?
                    WHERE id = ?''',
        /*args=*/ ['O.G MOBILE DEV', article.id],
      );
      print('Updated $count records in db.');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Return [true/false] if url exists in savedArticles
  static bool isSaved(String url) {
    for (var i = 0; i < _savedArticles.length; i++) {
      if (_savedArticles[i].url == url) {
        return true;
      }
    }
    return false;
  }

  /// insert temp news
  static Future<bool> insertTempNews(News news, int index,
      {String following}) async {
    String tableName;
    // following insert
    if (following != null) {
      tableName = following;
      print('insert $following temp news');
    }
    // headlines insert
    else {
      print('insert headlines$index temp news');
      if (index == 0) {
        tableName = _kDBLocalNewsTableName;
      } else if (index == 1) {
        tableName = _kDBGlobalNewsTableName;
      }
    }

    try {
      // delete existing table
      await _db.rawDelete('''
        DELETE FROM $tableName
      ''');
      // insert new element to the table
      await _db.transaction(
        (Transaction txn) async {
          await txn.rawInsert('''
          INSERT INTO $tableName
            (author, source, title, description, content, url,
             urlToImage, publishedAt, textDir, createTime)
          VALUES
            (
              "${news.author}",
              "${news.source}", 
              "${news.title}",
              "${news.description}",
              "${news.content}",
              "${news.url}",
              "${news.urlToImage}",
              "${news.publishedAt}",
              "${news.textDir}",
              "${news.createdTime}"
            )''');
        },
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Retrieves rows from the db table.
  static Future<List<News>> getTempNews(int index, {String following}) async {
    String tableName;
    if (following != null) {
      tableName = following;
    } else {
      if (index == 0) {
        tableName = _kDBLocalNewsTableName;
      } else if (index == 1) {
        tableName = _kDBGlobalNewsTableName;
      }
    }

    try {
      List<Map> jsons = await _db.rawQuery('SELECT * FROM $tableName');
      //print('${jsons.length} rows retrieved from db $tableName!');
      return jsons.map((json) {
        return News.fromDBmap(json);
      }).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }
}
