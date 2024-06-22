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
      title: 'Cadastro de Produtos',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ProductsRegistrationScreen(),
    );
  }
}

class ProductsRegistrationScreen extends StatefulWidget {
  @override
  _ProductsRegistrationScreenState createState() =>
      _ProductsRegistrationScreenState();
}

class _ProductsRegistrationScreenState
    extends State<ProductsRegistrationScreen> {
  TextEditingController productnameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  List<Products> productsList = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response =
          await http.get(Uri.parse('https://serverest.dev/produtos'));

      if (response.statusCode == 200) {
        List<dynamic> productsJson = json.decode(response.body)['produtos'];
        setState(() {
          productsList =
              productsJson.map((json) => Products.fromJson(json)).toList();
        });
      } else {
        print('Failed to load products: ${response.body}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Produtos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: productnameController,
              decoration: InputDecoration(
                labelText: 'Nome do Produto',
              ),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'Preço Do Produto',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Descrição Do Produto',
              ),
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Quantidade',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                registerProducts(context);
              },
              child: Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  void registerProducts(BuildContext context) async {
    String productname = productnameController.text;
    String price = priceController.text;
    String description = descriptionController.text;
    String quantity = quantityController.text;

    Products products = Products(
        productname: productname,
        price: price,
        description: description,
        quantity: quantity);

    try {
      final response = await http.post(
        Uri.parse('https://serverest.dev/produtos'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nome': products.productname,
          'preco': products.price,
          'descricao': products.description,
          'quantidade': products.quantity,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          productsList.add(products);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produto cadastrado com sucesso!'),
            backgroundColor: Colors.blue,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ListScreenProducts(productsList: productsList)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao cadastrar produto '),
            backgroundColor: Colors.red,
          ),
        );
      }

      productnameController.clear();
      priceController.clear();
      descriptionController.clear();
      quantityController.clear();
    } catch (e) {
      print('Produto não foi cadastrado: $e');
    }
  }
}

class Products {
  String productname;
  String price;
  String description;
  String quantity;

  Products({
    required this.productname,
    required this.price,
    required this.description,
    required this.quantity,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      productname: json['nome'],
      price: json['preco'].toString(),
      description: json['descricao'],
      quantity: json['quantidade'].toString(),
    );
  }
}

class ListScreenProducts extends StatelessWidget {
  final List<Products> productsList;

  const ListScreenProducts({Key? key, required this.productsList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista De Produtos'),
      ),
      body: ListView.builder(
        itemCount: productsList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(productsList[index].productname),
            subtitle: Text(
                'Preço: ${productsList[index].price} - Quantidade: ${productsList[index].quantity}'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                editProducts(context, productsList[index]);
              },
            ),
          );
        },
      ),
    );
  }

  void editProducts(BuildContext context, Products products) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProductsScreen(products: products)),
    );
  }
}

class EditProductsScreen extends StatelessWidget {
  final Products products;

  const EditProductsScreen({Key? key, required this.products})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Produto'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: TextEditingController(text: products.productname),
              decoration: InputDecoration(
                labelText: 'Nome Do Produto',
              ),
            ),
            TextField(
              controller: TextEditingController(text: products.price),
              decoration: InputDecoration(
                labelText: 'Preço',
              ),
            ),
            TextField(
              controller: TextEditingController(text: products.description),
              decoration: InputDecoration(
                labelText: 'Descrição',
              ),
            ),
            TextField(
              controller: TextEditingController(text: products.quantity),
              decoration: InputDecoration(
                labelText: 'Quantidade',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                updateProducts(context);
              },
              child: Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  void updateProducts(BuildContext context) {}
}
