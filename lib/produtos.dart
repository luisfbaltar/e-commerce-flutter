import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globals.dart' as globals;
import 'main.dart';

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
      home: ListScreenProducts(),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: productnameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Produto',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Preço Do Produto',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição Do Produto',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
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
      ),
    );
  }

  void registerProducts(BuildContext context) async {
    String productname = productnameController.text;
    String price = priceController.text;
    String description = descriptionController.text;
    String quantity = quantityController.text;

    if (productname.isEmpty ||
        price.isEmpty ||
        description.isEmpty ||
        quantity.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Campos Vazios'),
            content: Text('Todos os campos são obrigatórios'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    Products products = Products(
      id: '',
      productname: productname,
      price: price,
      description: description,
      quantity: quantity,
    );

    try {
      final response = await http.post(
        Uri.parse('https://serverest.dev/produtos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${globals.jwtToken}'
        },
        body: jsonEncode({
          'nome': products.productname,
          'preco': products.price,
          'descricao': products.description,
          'quantidade': products.quantity,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        products.id = responseData['_id'];

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
          MaterialPageRoute(builder: (context) => ListScreenProducts()),
        );
      } else {
        print('Produto não foi cadastrado: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao cadastrar produto'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar produto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class Products {
  String id;
  String productname;
  String price;
  String description;
  String quantity;

  Products({
    required this.id,
    required this.productname,
    required this.price,
    required this.description,
    required this.quantity,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['_id'],
      productname: json['nome'],
      price: json['preco'].toString(),
      description: json['descricao'],
      quantity: json['quantidade'].toString(),
    );
  }
}

class ListScreenProducts extends StatefulWidget {
  @override
  _ListScreenProductsState createState() => _ListScreenProductsState();
}

class _ListScreenProductsState extends State<ListScreenProducts> {
  List<Products> productsList = [];
  Cart cart = Cart();
  int _selectedIndex = 0;

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

  Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://serverest.dev/produtos/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${globals.jwtToken}'
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          productsList.removeWhere((product) => product.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produto deletado!'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        print('Failed to delete product: ${response.body}');
      }
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListScreenProducts()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginUserScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('Snet Shop',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                ))),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(cart: cart),
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4 / 6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: productsList.length,
        itemBuilder: (BuildContext context, int index) {
          return GridTile(
            child: Card(
              elevation: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Icon(
                    Icons.image_rounded,
                    color: Color.fromARGB(255, 194, 198, 202),
                    size: 125,
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        productsList[index].productname,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 1, 30, 54),
                            letterSpacing: 0.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Center(
                      child: Text(
                        'Preço: R\$ ${formatPrice(
                          productsList[index].price,
                        )},00',
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          setState(() {
                            cart.addToCart(productsList[index]);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Produto adicionado ao carrinho!'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteProduct(productsList[index].id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductsRegistrationScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Conta',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
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

class Cart {
  List<Products> items = [];

  void addToCart(Products product) {
    items.add(product);
  }

  void removeFromCart(Products product) {
    items.remove(product);
  }

  void clearCart() {
    items.clear();
  }

  List<Products> getCartItems() {
    return items;
  }
}

class CartScreen extends StatefulWidget {
  final Cart cart;

  CartScreen({required this.cart});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrinho de compras'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.getCartItems().length,
              itemBuilder: (BuildContext context, int index) {
                Products product = widget.cart.getCartItems()[index];
                return ListTile(
                  title: Text(product.productname),
                  subtitle: Text(
                      'Preço: ${product.price} - Quantidade: ${product.quantity} - Descrição: ${product.description}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_shopping_cart),
                    onPressed: () {
                      setState(() {
                        widget.cart.removeFromCart(product);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Produto removido'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Compra Concluida!'),
                  backgroundColor: Colors.blue,
                ),
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListScreenProducts(),
                ),
              );
            },
            child: Text('Concluir Compra'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.cart.clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Compra cancelada com sucesso!'),
                  backgroundColor: Colors.blue,
                ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListScreenProducts(),
                ),
              );
            },
            child: Text('Cancelar Compra'),
          ),
        ],
      ),
    );
  }
}

String formatPrice(String price) {
  if (price.length > 3) {
    int value = int.parse(price);
    return value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
  return price;
}
