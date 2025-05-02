// mis_propiedades.dart
import 'package:flutter/material.dart';
import '../card.dart';

class MisPropiedades extends StatelessWidget {
  final List<String> propiedades;

  const MisPropiedades({super.key, required this.propiedades});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.home, color: Color(0xFF2A8C82)),
                    SizedBox(width: 8),
                    Text(
                      'Mis Propiedades',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A8C82),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva propiedad'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A8C82),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: propiedades.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.home_work,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No tienes propiedades',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          const Text('Publica tu primera propiedad para empezar'),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                            label: const Text('Crear propiedad'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A8C82),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: propiedades.length,
                      itemBuilder: (context, index) {
                        return AccommodationCard(
                          imageUrl: 'https://via.placeholder.com/300',
                          title: 'Propiedad ${propiedades[index]}',
                          price: '\$${(index + 1) * 500}K COP',
                          address: 'Dirección ${index + 1}',
                          views: (index + 1) * 10,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
