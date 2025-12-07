import "package:flutter/material.dart";

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            children: [
              buildOrderCard(),
              const SizedBox(width: 12),
              buildOrderCard(),
              const SizedBox(width: 12),
              buildOrderCard(),
            ],
          ),
        ),
      ], // <-- Column children closed
    ); // <-- Column closed
  }

  Widget buildOrderCard() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Image.network(
          'https://img.icons8.com/ios-filled/100/ffffff/delivery--v1.png',
          width: 80,
          height: 80,
        ),
      ),
    );
  }
}