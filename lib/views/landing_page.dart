import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/image_helper.dart';
import '../services/theme_service.dart';
import '../widgets/user_menu_modal.dart'; // Importación del nuevo componente

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
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPropertyIds() async {
    if (_isSearching) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _isSearching = true;
    });

    try {
      String endpoint;
      if (_searchTerm.isNotEmpty) {
        endpoint = 'http://localhost:4000/api/propiedades/search?q=${Uri.encodeComponent(_searchTerm)}';
      } else {
        endpoint = 'http://localhost:4000/api/alojamientos';
      }
      if (_selectedCategory != 'Todos') {
        final separator = endpoint.contains('?') ? '&' : '?';
        endpoint += '$separator categoria=${Uri.encodeComponent(_selectedCategory)}';
      }

      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode != 200) {
        throw Exception('Error cargando propiedades: ${response.statusCode}');
      }

      final dynamic responseData = json.decode(response.body);
      List<dynamic> data;
      if (responseData is Map<String, dynamic>) {
        data = responseData['data'] as List<dynamic>? ?? [];
      } else if (responseData is List<dynamic>) {
        data = responseData;
      } else {
        throw Exception('Formato de respuesta desconocido');
      }

      _propertyIds = data
          .map<String>((item) => (item['id'] ?? item['_id']).toString())
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
        _isSearching = false;
      });
    }
  }

  Future<void> _performSearch(String value) async {
    _searchTerm = value;
    await _fetchPropertyIds();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              hintStyle: TextStyle(color: Colors.grey[600]),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          child: SearchBar(
            controller: _searchController,
            onSearch: _performSearch,
            isLoading: _isLoading,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: abrir modal de filtros
            },
          ),
          // Nuevo botón de menú de usuario
          const UserMenuButton(),
          IconButton(
            icon: Icon(themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeService.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // FILTROS OCUPANDO TODO EL ANCHO
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: _categories.map((cat) {
                final bool selected = cat.name == _selectedCategory;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        foregroundColor: selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                        elevation: selected ? 4 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCategory = cat.name;
                          _fetchPropertyIds();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, size: 18),
                            const SizedBox(height: 4),
                            Text(
                              cat.name,
                              style: const TextStyle(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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
                                ? 'No hay resultados para \"$_searchTerm\"'
                                : 'No se encontraron propiedades'),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8),
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 600 ? 4 : 2,
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
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.grey[200],
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '© 2025 UPMovil',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// === WIDGETS AUXILIARES ===

class SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final bool isLoading;

  const SearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  Future<void>? _searchDebounce;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: 'Buscar propiedades...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  widget.onSearch('');
                },
              )
            : widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        _searchDebounce?.ignore();
        _searchDebounce = Future.delayed(const Duration(milliseconds: 500), () {
          widget.onSearch(value);
        });
      },
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
  final _imageHelper = ImageHelper();

  @override
  void initState() {
    super.initState();
    _fetchDetalle();
  }

  Future<void> _fetchDetalle() async {
    try {
      final url = 'http://localhost:4000/api/propiedades/publicacion/${widget.id}';
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
      return Card(child: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Card(child: Center(child: Text('Error: $_error')));
    }
    final prop = _propiedad!;
    String imageUrl = prop.imagenes.isNotEmpty ? prop.imagenes.first.url : '';
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
                _imageHelper.buildNetworkImage(
                  imageUrl: imageUrl,
                  height: 140,
                  width: double.infinity,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _isFavorite = !_isFavorite),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  const Text(
                    'Disponible',
                    style: TextStyle(fontSize: 12, color: Colors.green, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'es_CO',
                      symbol: '\$',
                      decimalDigits: 0,
                    ).format(prop.precio),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
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
    } catch (_) {}
    num precio = 0;
    try {
      final precioValue = json['precio'];
      if (precioValue is num) {
        precio = precioValue;
      } else if (precioValue is String) {
        precio = num.tryParse(precioValue) ?? 0;
      }
    } catch (_) {}
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