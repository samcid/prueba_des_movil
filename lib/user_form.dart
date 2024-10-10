import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Clase que maneja la fuente de datos para la tabla de usuarios.
class UserDataSource extends DataTableSource {
  final List<User> users;

  /// Crea una instancia de [UserDataSource] con la lista de usuarios proporcionada.
  UserDataSource(this.users);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= users.length) return null!;

    final user = users[index];

    return DataRow(cells: [
      DataCell(Text(user.name)),
      DataCell(Text(user.email)),
      DataCell(Text(user.birthDate)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;

  @override
  int get rowHeight => 48;
}

/// Clase que representa el formulario de registro de usuarios.
class UserForm extends StatefulWidget {
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String birthDate = '';
  String address = '';
  String password = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Método para registrar un nuevo usuario en la base de datos.
  ///
  /// Valida el formulario y, si es válido, crea un objeto [User]
  /// e inserta los datos en la base de datos.
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = User(
        name: name,
        email: email,
        birthDate: birthDate,
        address: address,
        password: password,
      );

      await DatabaseHelper.instance.insertUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario registrado con éxito')),
      );

      setState(() {});
    }
  }

  /// Método para obtener un usuario aleatorio desde una API.
  ///
  /// Realiza una solicitud HTTP a una API externa para obtener
  /// datos de un usuario aleatorio y actualiza el formulario con
  /// la información recibida.
  Future<void> _fetchUserFromAPI() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'][0];

      setState(() {
        name = '${data['name']['first']} ${data['name']['last']}';
        email = data['email'];
        birthDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(data['dob']['date']));
        address = '${data['location']['street']['number']} ${data['location']['street']['name']}, ${data['location']['city']}, ${data['location']['state']}, ${data['location']['country']}';
        password = data['login']['password'];

        _nameController.text = name;
        _emailController.text = email;
        _birthDateController.text = birthDate;
        _addressController.text = address;
        _passwordController.text = password;
      });
    } else {
      throw Exception('Error al obtener datos desde API');
    }
  }

  /// Método para recuperar la lista de usuarios desde la base de datos.
  ///
  /// Devuelve una lista de objetos [User] que representan
  /// todos los usuarios almacenados en la base de datos.
  Future<List<User>> _fetchUsers() async {
    return await DatabaseHelper.instance.fetchUsers();
  }

  /// Método para seleccionar una fecha de nacimiento usando un DatePicker.
  ///
  /// Muestra un selector de fechas y actualiza la fecha de nacimiento
  /// en el formulario según la fecha seleccionada.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthDate.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(birthDate)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        birthDate = DateFormat('yyyy-MM-dd').format(picked);
        _birthDateController.text = birthDate;
      });
    }
  }

  /// Método para construir la interfaz del formulario de usuario.
  ///
  /// Construye el widget que representa el formulario de registro,
  /// incluyendo campos de entrada y botones para registrar o
  /// obtener un usuario desde la API.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Formulario de Registro')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    onSaved: (value) => name = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Nombre es obligatorio';
                      } else if (value.length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                        return 'El nombre solo debe contener letras y espacios';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Correo'),
                    onSaved: (value) => email = value!,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'El campo Correo es obligatorio y debe ser válido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Fecha de Nacimiento'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Fecha de Nacimiento es obligatorio';
                      }
                      return null;
                    },
                    onTap: () => _selectDate(context),
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: 'Dirección'),
                    onSaved: (value) => address = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Dirección es obligatorio';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    onSaved: (value) => password = value!,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'El campo Contraseña es obligatorio y debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerUser,
                    child: Text('Registrar'),
                  ),
                  ElevatedButton(
                    onPressed: _fetchUserFromAPI,
                    child: Text('Obtener desde API'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: FutureBuilder<List<User>>(
                  future: _fetchUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No hay usuarios registrados'));
                    } else {
                      final users = snapshot.data!;
                      final userDataSource = UserDataSource(users);

                      return PaginatedDataTable(
                        header: Text('Lista de Usuarios'),
                        columns: [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Correo')),
                          DataColumn(label: Text('Fecha de Nacimiento')),
                        ],
                        source: userDataSource,
                        rowsPerPage: 5,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
