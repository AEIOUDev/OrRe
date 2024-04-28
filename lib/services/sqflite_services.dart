import 'package:sqflite/sqflite.dart';
import 'package:orre/model/store_info_model.dart';

class SqfliteService {
  static Future<Database> getDatabase() async {
    return openDatabase(
      'store_info.db',
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE store_info(
            storeCode INTEGER PRIMARY KEY,
            storeName TEXT,
            storeIntroduce TEXT,
            storeCategory TEXT,
            storeInfoVersion INTEGER,
            numberOfTeamsWaiting INTEGER,
            estimatedWaitingTime INTEGER,
            menuInfo TEXT,
            storeImageMain TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertOrUpdateStoreInfo(StoreDetailInfo storeInfo) async {
    final db = await getDatabase();
    await db.insert(
      'store_info',
      storeInfo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<StoreDetailInfo?> getStoreInfoByVersion(
      int storeCode, int storeInfoVersion) async {
    final db = await getDatabase();
    final result = await db.query(
      'store_info',
      where: 'storeCode = ? AND storeInfoVersion = ?',
      whereArgs: [storeCode, storeInfoVersion],
    );
    if (result.isNotEmpty) {
      final storeDetailInfo = StoreDetailInfo.fromJson(result.first);
      if (storeDetailInfo.storeInfoVersion == storeInfoVersion) {
        return storeDetailInfo;
      }
    }
    return null;
  }
}
