import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro do Usuario',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: UserRegistrationScreen(),
    );
  }
}

class UserRegistrationScreen extends StatefulWidget {
  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  List<User> userList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome Completo',
              ),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                registerUser(context);
              },
              child: Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  void registerUser(BuildContext context) async {
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    User user = User(name: name, email: email, password: password);

    try {
      final response = await http.post(
        Uri.parse('https://serverest.dev/usuarios'),
        body: {
          'nome': user.name,
          'email': user.email,
          'password': user.password,
          'administrador': 'false'
        },
      );

      if (response.statusCode == 201) {
        setState(() {
          userList.add(user);
        });

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListScreen(userList: userList)),
        );
      } else {
        print('Failed to register user: ${response.body}');
      }

      nameController.clear();
      emailController.clear();
      passwordController.clear();
    } catch (e) {
      print('Usuario não foi cadastrado: $e');
    }
  }
}

class User {
  String name;
  String email;
  String password;

  User({required this.name, required this.email, required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['nome'],
      email: json['email'],
      password: json['password'],
    );
  }
}

class ListScreen extends StatelessWidget {
  final List<User> userList;

  const ListScreen({Key? key, required this.userList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista De Usuario'),
      ),
      body: ListView.builder(
        itemCount: userList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(userList[index].name),
            subtitle: Text(userList[index].email),
          );
        },
      ),
    );
  }
}
