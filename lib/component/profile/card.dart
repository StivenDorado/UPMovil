// accommodation_card.dart
import 'package:flutter/material.dart';

class AccommodationCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String address;
  final int views;

  const AccommodationCard({super.key, 
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.address,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Image.asset('assets/default-image.jpg'),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text('Activa', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(price,
                          style: TextStyle(color: Colors.blue[800])),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16),
                    SizedBox(width: 4),
                    Text(address, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16),
                    SizedBox(width: 4),
                    Text('$views vistas'),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.visibility, size: 16),
                        label: Text('Ver'),
                        onPressed: () {}, // <-- Acción aquí
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2A8C82),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {}, // <-- Acción aquí
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
