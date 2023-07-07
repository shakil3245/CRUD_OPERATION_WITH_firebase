import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _pricecontroller = TextEditingController();
// for update product
  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _namecontroller.text = documentSnapshot['name'];
      _pricecontroller.text = documentSnapshot['price'].toString();
    }

    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            children: [
              TextField(
                controller: _namecontroller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter product name"),
              ),
              SizedBox(
                height: 8,
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _pricecontroller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter product price"),
              ),
              SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final String name = _namecontroller.text;
                    final double? price =
                        double.tryParse(_pricecontroller.text);

                    if (price != null) {
                      await _products
                          .doc(documentSnapshot!.id)
                          .update({"name": name, "price": price});
                      _namecontroller.text = '';
                      _pricecontroller.text = '';
                    }
                  },
                  child: Text("Submit"))
            ],
          );
        });
  }
//for create product
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _namecontroller.text = documentSnapshot['name'];
      _pricecontroller.text = documentSnapshot['price'].toString();
    }

    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            children: [
              TextField(
                controller: _namecontroller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter product name"),
              ),
              SizedBox(
                height: 8,
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _pricecontroller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter product price"),
              ),
              SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final String name = _namecontroller.text;
                    final double? price =
                        double.tryParse(_pricecontroller.text);

                    if (price != null) {
                      await _products.add({
                        'name': name, // John Doe
                        'price': price, // Stokes and Sons
                      })
                          .then((value) => print("User Added"))
                          .catchError((error) => print("Failed to add user: $error"));

                      _namecontroller.text = '';
                      _pricecontroller.text = '';
                    }
                  },
                  child: Text("Submit"))
            ],
          );
        });
  }

  Future<void> _delete(String productId) async {
    await _products
        .doc(productId)
        .delete()
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          _create();
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _products.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    snapshot.data!.docs[index];
                return Card(
                  child: ListTile(
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(documentSnapshot['price'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _update(documentSnapshot);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _delete(documentSnapshot.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
