import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/purchase_item.dart';

class DatabaseHelper {
  static const String _databaseName = 'gasto_diario.db';
  static const int _databaseVersion = 1;
  static const String tableName = 'compras';

  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        cantidad REAL NOT NULL,
        precio REAL NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');
  }

  /// Inserta una compra en la base de datos
  Future<int> insert(PurchaseItem item) async {
    final db = await database;
    return await db.insert(
      tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene todas las compras registradas ordenadas por fecha descendente
  Future<List<PurchaseItem>> getAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'fecha DESC, id DESC',
    );
    return maps.map((map) => PurchaseItem.fromMap(map)).toList();
  }

  /// Obtiene las compras de una fecha específica (YYYY-MM-DD)
  Future<List<PurchaseItem>> getByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'fecha = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );
    return maps.map((map) => PurchaseItem.fromMap(map)).toList();
  }

  /// Actualiza una compra existente según su ID
  Future<int> updatePurchase(PurchaseItem purchase) async {
    if (purchase.id == null) return 0;
    final db = await database;
    return await db.update(
      tableName,
      purchase.toMap(),
      where: 'id = ?',
      whereArgs: [purchase.id],
    );
  }

  /// Elimina una compra según su ID
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Cierra la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
