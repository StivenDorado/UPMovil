// favoritos_list.dart
import 'package:flutter/material.dart';
import '../card.dart';

class FavoritosList extends StatelessWidget {
  final List<String> favoriteIds;

  const FavoritosList({super.key, required this.favoriteIds});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: favoriteIds.isEmpty
          ? Center(child: Text('No tienes propiedades favoritas aún.'))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: favoriteIds.length,
              itemBuilder: (context, index) => AccommodationCard(
                imageUrl: 'https://via.placeholder.com/300',
                title: 'Propiedad ${favoriteIds[index]}',
                price: '\$${(index + 1) * 500}K COP',
                address: 'Dirección ${index + 1}',
                views: (index + 1) * 10,
              ),
            ),
    );
  }
}