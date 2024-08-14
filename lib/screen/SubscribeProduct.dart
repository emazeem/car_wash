import 'package:carwash/constants.dart';
import 'package:carwash/model/Product.dart';
import 'package:flutter/material.dart';

class SubscribeProduct extends StatelessWidget {
  final Product product;

  SubscribeProduct(this.product);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Const.appbar('Provide Car Details'),
      body: ListView(
        children: [
          Stack(
            children: [
              Container(
                height: Const.hi(context)/3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/car_wash.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Const.primaryColor,
                  padding: EdgeInsets.all(16.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.title}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),

                    ],
                  )
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Make of Car'),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Model of Car'),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Plate Number'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Implement subscription logic here
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Const.primaryColor, // Set the background color
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32), // Set padding
                  ),
                  child: Text('Subscribe Product'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
