// lib/pages/landing_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../widgets/user_menu_modal.dart';
import '../component/card/card.dart'; // Import correcto de AccommodationCard

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
        endpoint =
            'http://localhost:4000/api/propiedades/search?q=${Uri.encodeComponent(_searchTerm)}';
      } else {
        endpoint = 'http://localhost:4000/api/alojamientos';
      }

      if (_selectedCategory != 'Todos') {
        final sep = endpoint.contains('?') ? '&' : '?';
        endpoint += '$sep categoria=${Uri.encodeComponent(_selectedCategory)}';
      }

      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode != 200) {
        throw Exception('Error: ${response.statusCode}');
      }

      final raw = json.decode(response.body);
      List data;
      if (raw is Map && raw['data'] is List) {
        data = raw['data'];
      } else if (raw is List) {
        data = raw;
      } else {
        data = [];
      }

      _propertyIds = data.map((e) => (e['id'] ?? e['_id']).toString()).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
        _isSearching = false;
      });
    }
  }

  Future<void> _performSearch(String q) async {
    _searchTerm = q;
    await _fetchPropertyIds();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeService>(context);

    // Mostrar indicador de carga o error
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: SearchBar(
          controller: _searchController,
          onSearch: _performSearch,
          isLoading: _isLoading,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          const UserMenuButton(),
          IconButton(
            icon: Icon(
                theme.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: theme.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: Row(
              children: _categories.map((c) {
                final selected = c.name == _selectedCategory;
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
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCategory = c.name;
                        });
                        _fetchPropertyIds();
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.icon, size: 18),
                          const SizedBox(height: 4),
                          Text(c.name,
                              style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _propertyIds.isEmpty
                ? Center(
                    child: Text(_searchTerm.isEmpty
                        ? 'No se encontraron propiedades'
                        : 'No hay resultados para "$_searchTerm"'),
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
                      itemBuilder: (ctx, i) => AccommodationCard(
                        id: _propertyIds[i],
                        onFavoriteToggle: () {
                          // Lógica adicional si es necesario
                        },
                      ),
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.grey[200],
            child: Center(
              child: Text(
                '© 2025 UPMovil',
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[700]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final bool isLoading;

  const SearchBar({
    required this.controller,
    required this.onSearch,
    this.isLoading = false,
    super.key,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  Future<void>? _debounce;

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
                      valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).colorScheme.primary),
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
      onChanged: (v) {
        _debounce?.ignore();
        _debounce = Future.delayed(
          const Duration(milliseconds: 500),
          () => widget.onSearch(v),
        );
      },
    );
  }
}

class Category {
  final String name;
  final IconData icon;
  const Category(this.name, this.icon);
}
