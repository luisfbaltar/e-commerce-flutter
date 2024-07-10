import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cadastro.dart';
import 'produtos.dart';
import 'main.dart';

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

final List<Widget> _pages = [
  LoginUserScreen(),
  UserRegistrationScreen(),
  ListScreenProducts(),
];

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
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response =
          await http.get(Uri.parse('https://serverest.dev/usuarios'));

      if (response.statusCode == 200) {
        List<dynamic> usersJson = json.decode(response.body)['usuarios'];
        setState(() {
          userList = usersJson.map((json) => User.fromJson(json)).toList();
        });
      } else {
        print(': ${response.body}');
      }
    } catch (e) {
      print('Não foi possivel fazer o cadastro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Usuários'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
          'administrador': 'true',
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário cadastrado com sucesso!'),
            backgroundColor: Colors.blue,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginUserScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao cadastrar usuário'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      nameController.clear();
      emailController.clear();
      passwordController.clear();
    } catch (e) {
      print('Erro ao cadastrar usuário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar usuário'),
          backgroundColor: Colors.red,
        ),
      );
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
      password: '',
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
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                editUser(context, userList[index]);
              },
            ),
          );
        },
      ),
    );
  }

  void editUser(BuildContext context, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditUserScreen(user: user)),
    );
  }
}

class EditUserScreen extends StatelessWidget {
  final User user;

  const EditUserScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Usuario'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: TextEditingController(text: user.name),
              decoration: InputDecoration(
                labelText: 'Nome Completo',
              ),
            ),
            TextField(
              controller: TextEditingController(text: user.email),
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: TextEditingController(text: user.password),
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                updateUser(context);
              },
              child: Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  void updateUser(BuildContext context) {}
}
