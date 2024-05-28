import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';

void main() => runApp(MaterialApp(
      title: 'Network',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyApp12(),
    ));

class MyApp12 extends StatefulWidget {
  const MyApp12({super.key});

  @override
  State<MyApp12> createState() => _MyAppState();
}

Future<List<Product>> fetchProduct() async {
  final res = await http.get(Uri.parse('http://127.0.0.1:8000/api/products'));
  if (res.statusCode == 200) {
    var data = jsonDecode(res.body) as List;
    return data.map((json) => Product.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}

Future<Map<String, dynamic>> addProduct(String name, String description,
    String processor, String memory, String storage, String price) async {
  final res = await http.post(
    Uri.parse('http://127.0.0.1:8000/api/products'),
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode(<String, String>{
      'name': name,
      'description': description,
      'processor': processor,
      'memory': memory,
      'storage': storage,
      'price': price
    }),
  );
  if (res.statusCode == 201) {
    return jsonDecode(res.body);
  } else {
    throw Exception('Failed to add product');
  }
}

class _MyAppState extends State<MyApp12> {
  late Future<List<Product>> products;
  final inputName = TextEditingController();
  final inputDescription = TextEditingController();
  final inputProcessor = TextEditingController();
  final inputMemory = TextEditingController();
  final inputStorage = TextEditingController();
  final inputPrice = TextEditingController();

  @override
  void initState() {
    super.initState();
    products = fetchProduct();
  }

  @override
  void dispose() {
    inputName.dispose();
    inputDescription.dispose();
    inputProcessor.dispose();
    inputMemory.dispose();
    inputStorage.dispose();
    inputPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<Product>>(
          future: products,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Tidak ada data'),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.name,
                              style: const TextStyle(fontSize: 20),
                            ),
                            Text(
                              item.description,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              item.processor,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              item.memory,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              item.storage,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              item.price.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: const Text('Add New Product'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Name',
                          ),
                          controller: inputName,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Description',
                          ),
                          controller: inputDescription,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Processor',
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Processor',
                          ),
                          controller: inputProcessor,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Memory',
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Memory',
                          ),
                          controller: inputMemory,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Storage',
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Storage',
                          ),
                          controller: inputStorage,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Price',
                          ),
                          controller: inputPrice,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          child: const Text('Save'),
                          onPressed: () async {
                            try {
                              var res = await addProduct(
                                  inputName.text,
                                  inputDescription.text,
                                  inputProcessor.text,
                                  inputMemory.text,
                                  inputStorage.text,
                                  inputPrice.text);
                              if (res['status']) {
                                setState(() {
                                  products = fetchProduct();
                                });
                              }
                              Navigator.of(context).pop();
                              var snackBar = SnackBar(
                                content: Text(res['message']),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } catch (e) {
                              var snackBar = SnackBar(
                                content: Text('Failed to add product: $e'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
