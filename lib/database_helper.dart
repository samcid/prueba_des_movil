import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'user_model.dart';

/// Clase que maneja la conexión y operaciones de la base de datos.
///
/// Proporciona métodos para inicializar la base de datos, 
/// crear tablas, insertar y recuperar usuarios.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Obtiene la instancia de la base de datos.
  ///
  /// Si la base de datos ya está inicializada, 
  /// se devuelve la instancia existente. 
  /// De lo contrario, se inicializa y devuelve una nueva instancia.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  /// Inicializa la base de datos en el archivo especificado.
  ///
  /// Crea el archivo de base de datos en la ubicación adecuada
  /// y devuelve una instancia de la base de datos.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Crea las tablas necesarias en la base de datos.
  ///
  /// Este método se llama al crear la base de datos por primera vez
  /// y establece la estructura de la tabla de usuarios.
  Future _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        address TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');
  }

  /// Inserta un nuevo usuario en la base de datos.
  ///
  /// Toma un objeto `User` y lo inserta en la tabla de usuarios.
  /// Devuelve el ID del usuario insertado.
  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  /// Recupera la lista de usuarios desde la base de datos.
  ///
  /// Devuelve una lista de objetos `User` que representan
  /// todos los usuarios almacenados en la base de datos.
  Future<List<User>> fetchUsers() async {
    final db = await instance.database;
    final users = await db.query('users');
    return users.map((json) => User.fromMap(json)).toList();
  }

  /// Cierra la conexión a la base de datos.
  ///
  /// Este método libera los recursos asociados
  /// con la conexión a la base de datos.
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
