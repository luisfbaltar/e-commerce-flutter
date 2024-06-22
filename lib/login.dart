import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login de Usuário',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginUserScreen(),
    );
  }
}

class LoginUserScreen extends StatefulWidget {
  @override
  _LoginUserScreenState createState() => _LoginUserScreenState();
}

class _LoginUserScreenState extends State<LoginUserScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login de Usuário'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  loginUser(context);
                },
                child: Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginUser(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('https://serverest.dev/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['message'] == 'Login realizado com sucesso') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login realizado com sucesso!'),
              backgroundColor: Colors.blue,
            ),
          );
          fetchUsers(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Falha ao efetuar login: ${responseData['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao efetuar login: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      emailController.clear();
      passwordController.clear();
    } catch (e) {
      print('Erro ao efetuar login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao efetuar login'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void fetchUsers(BuildContext context) async {
    try {
      final response =
          await http.get(Uri.parse('https://serverest.dev/usuarios'));

      if (response.statusCode == 200) {
        List<dynamic> usersJson = json.decode(response.body)['usuarios'];
        List<User> userList =
            usersJson.map((json) => User.fromJson(json)).toList();

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListScreen(userList: userList)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Falha ao carregar lista de usuários: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao buscar lista de usuários: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar lista de usuários'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class User {
  String name;
  String email;

  User({required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['nome'],
      email: json['email'],
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
        title: Text('Lista De Usuários'),
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
