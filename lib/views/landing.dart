import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String _searchTerm = '';
  bool _isLoading = true;
  String? _error;
  List<String> _propertyIds = [];
  String _selectedCategory = 'Todos';

  final List<Category> _categories = [
    Category('Todos', Icons.home),
    Category('Apartamentos', Icons.apartment),
    Category('Casas', Icons.house),
    Category('Estudios', Icons.book),
    Category('Habitaciones', Icons.bed),
  ];

  @override
  void initState() {
    super.initState();
    _fetchPropertyIds();
  }

  Future<void> _fetchPropertyIds() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final endpoint = _searchTerm.isNotEmpty
          ? 'http://localhost:4000/api/propiedades/search?q=${Uri.encodeComponent(_searchTerm)}'
          : 'http://localhost:4000/api/alojamientos';
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode != 200) {
        throw Exception('Error cargando propiedades');
      }
      final List data = json.decode(response.body);
      _propertyIds = data
          .map<String>((item) => (item['id'] ?? item['_id']).toString())
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A8C82),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar propiedades...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (val) {
            _searchTerm = val;
            _fetchPropertyIds();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {}, // TODO: abrir modal de filtros
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF2A8C82),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _categories.map((cat) {
                final bool selected = cat.name == _selectedCategory;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9BF2EA),
                        foregroundColor: const Color(0xFF275950),
                        elevation: selected ? 4 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCategory = cat.name;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat.icon),
                          const SizedBox(width: 6),
                          Text(cat.name),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(
                          'Error: $_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : _propertyIds.isEmpty
                        ? Center(
                            child: Text(_searchTerm.isNotEmpty
                                ? 'No hay resultados para "$_searchTerm"'
                                : 'No se encontraron propiedades'),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8),
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 600
                                        ? 4
                                        : 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _propertyIds.length,
                              itemBuilder: (context, index) {
                                return PropertyCard(id: _propertyIds[index]);
                              },
                            ),
                          ),
          ),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16),
            child: const Center(child: Text('© 2025 Tu Compañía')),
          ),
        ],
      ),
    );
  }
}

class Category {
  final String name;
  final IconData icon;
  const Category(this.name, this.icon);
}

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
  bool _isFavorite = false;

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
        throw Exception('Error al cargar la propiedad');
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
      return const Card(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null) {
      return Card(
        child: Center(child: Text('Error: $_error')),
      );
    }
    
    final prop = _propiedad!;
    String imageUrl = '';
    
    // Construcción correcta de la URL usando Uri
    if (prop.imagenes.isNotEmpty) {
      final rawUrl = prop.imagenes.first.url;
      if (rawUrl.startsWith('http')) {
        imageUrl = rawUrl;
      } else if (rawUrl.isNotEmpty) {
        imageUrl = Uri.parse('http://localhost:4000').replace(path: rawUrl).toString();
      }
    }
    
    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/default-image.jpg',
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/default-image.jpg',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isFavorite = !_isFavorite);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white70,
                      radius: 16,
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey[800],
                        size: 18,
                      ),
                    ),
                  ),
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
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          prop.direccion,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Disponible',
                    style: TextStyle(
                      fontSize: 12, 
                      color: Colors.green, 
                      height: 1.2
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'es_CO', 
                      symbol: '\$', 
                      decimalDigits: 0
                    ).format(prop.precio),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 14
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                      child: const Text('Ver detalles'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Propiedad {
  final String id;
  final List<Imagen> imagenes;
  final String titulo;
  final String direccion;
  final num precio;

  Propiedad({
    required this.id,
    required this.imagenes,
    required this.titulo,
    required this.direccion,
    required this.precio,
  });

  factory Propiedad.fromJson(Map<String, dynamic> json) {
    final String id = (json['_id'] ?? json['id'] ?? '').toString();
    
    List<Imagen> imagenes = [];
    try {
      final imagenesList = json['imagenes'] as List<dynamic>? ?? [];
      imagenes = imagenesList.map((e) => Imagen.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error al parsear imágenes: $e');
    }
    
    num precio = 0;
    try {
      final precioValue = json['precio'];
      if (precioValue is num) {
        precio = precioValue;
      } else if (precioValue is String) {
        precio = num.tryParse(precioValue) ?? 0;
      }
    } catch (e) {
      print('Error al parsear precio: $e');
    }
    
    return Propiedad(
      id: id,
      imagenes: imagenes,
      titulo: json['titulo']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      precio: precio,
    );
  }
}

class Imagen {
  final String url;
  
  Imagen({required this.url});
  
  factory Imagen.fromJson(Map<String, dynamic> json) {
    return Imagen(url: json['url']?.toString() ?? '');
  }
}