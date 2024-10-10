/// Representa un usuario en el sistema.
class User {
  /// El identificador único del usuario.
  int? id;

  /// El nombre del usuario.
  String name;

  /// El correo electrónico del usuario.
  String email;

  /// La fecha de nacimiento del usuario.
  String birthDate;

  /// La dirección del usuario.
  String address;

  /// La contraseña del usuario.
  String password;

  /// Crea una nueva instancia de [User].
  ///
  /// Los parámetros [name], [email], [birthDate], [address], y [password]
  /// son obligatorios y no pueden ser nulos.
  User({
    this.id,
    required this.name,
    required this.email,
    required this.birthDate,
    required this.address,
    required this.password,
  });

  /// Convierte la instancia de [User] a un mapa.
  ///
  /// Retorna un mapa donde las claves son los nombres de las propiedades
  /// del usuario y los valores son los valores correspondientes.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birthDate': birthDate,
      'address': address,
      'password': password,
    };
  }

  /// Crea una instancia de [User] a partir de un mapa.
  ///
  /// El [map] debe contener las claves 'id', 'name', 'email',
  /// 'birthDate', 'address' y 'password'.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      birthDate: map['birthDate'],
      address: map['address'],
      password: map['password'],
    );
  }
}
