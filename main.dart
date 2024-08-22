import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/product.dart';  // นำเข้า Data Class Product
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // นำเข้า RatingBar package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IT@WU Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductListScreen(),  // หน้าหลักของแอปคือ ProductListScreen
    );
  }
}

// Stateful Widget สำหรับการดึงข้อมูลและแสดงผล
class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    getData();  // เรียกใช้ method สำหรับดึงข้อมูล
  }

  Future<void> getData() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _products = data.map((json) => Product.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IT@WU Shop'),
         backgroundColor: Colors.blue
      ),
      body: _products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(_products[index].image, width: 50, height: 50),
                  title: Text(_products[index].title),
                  subtitle: Text('\$${_products[index].price}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(product: _products[index]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// Stateful Widget สำหรับการแสดงรายละเอียดสินค้า
class DetailsScreen extends StatefulWidget {
  final Product product;

  DetailsScreen({required this.product});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child:SizedBox(
                height: 200, // ปรับความสูงของรูปภาพตามที่ต้องการ
                width: 200, 
                child: Image.network(
                  widget.product.image,
                  fit: BoxFit.contain, // ปรับให้รูปภาพเติมเต็มขนาดที่กำหนด
                ),
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                widget.product.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "\$${widget.product.price}",
                style: TextStyle(fontSize: 20),
              ),
            ),
            ListTile(
              title: Text(
                "Category",
                style: TextStyle(color: Colors.grey),
              ),
              subtitle: Text(
                "${widget.product.category}",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Text(
              "great outerwear jackets for Spring/Autumn/Winter, "
              "various occasions, such as working, hiking, climbing/rock climbing, "
              "cycling, traveling or other outdoor activities.",
              style: TextStyle(fontSize: 16),
            ),
            ListTile(
              title: Text(
                "Rating : ${widget.product.rating.rate}/5 of ${widget.product.rating.count}",
              ),
            ),
            RatingBar.builder(
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (value) => print(value),  // สามารถใช้เพื่อแสดงหรือบันทึกคะแนนที่ได้รับการอัปเดต
              minRating: 0,
              itemCount: 5,
              allowHalfRating: true,
              direction: Axis.horizontal,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              initialRating: widget.product.rating.rate ?? 0,  // ใช้ค่าจากข้อมูลที่ดึงมา
            ),
          ],
        ),
      ),
    );
  }
}
