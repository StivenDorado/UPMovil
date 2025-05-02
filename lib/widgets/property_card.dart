/* import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../views/pagina_propiedad.dart'; // Importa la pantalla de detalles
import '../models/propiedad.dart'; // Importa el modelo Propiedad
import '../services/image_helper.dart'; // Importa ImageHelper

class PropertyCard extends StatefulWidget {
  final String id;

  const PropertyCard({super.key, required this.id});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool _loading = true;
  String? _error;
  Propiedad? _propiedad;
  final _imageHelper = ImageHelper();

  @override
  void initState() {
    super.initState();
    _fetchDetalle();
  }

  Future<void> _fetchDetalle() async {
    try {
      final url =
          'http://localhost:4000/api/propiedades/publicacion/${widget.id}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Error al cargar la propiedad: ${response.statusCode}');
      }
      final data = json.decode(response.body);
      setState(() {
        _propiedad = Propiedad.fromJson(data['data'] ?? data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Card(
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Card(
        child: Center(
          child: Text(
            'Error: $_error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final prop = _propiedad!;
    String imageUrl = prop.imagenes.isNotEmpty ? prop.imagenes.first.url : '';

    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de detalles
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaginaPropiedad(id: widget.id),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _imageHelper.buildNetworkImage(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prop.titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.place, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          prop.direccion,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${prop.precio}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} */