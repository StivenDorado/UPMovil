// lib/pages/landing_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../services/theme_service.dart';
import '../widgets/user_menu_modal.dart';
import '../component/card/card.dart'; // AccommodationCard u otro nombre según tu componente

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

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
        final separator = endpoint.contains('?') ? '&' : '?';
        endpoint += '$separator categoria=${Uri.encodeComponent(_selectedCategory)}';
      }

      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode != 200) {
        throw Exception('Error: ${response.statusCode}');
      }

      final raw = json.decode(response.body);
      List data;
      if (raw is Map<String, dynamic> && raw['data'] is List) {
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
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
            ),
          ),
          child: SearchBar(
            controller: _searchController,
            onSearch: _performSearch,
            isLoading: _isLoading,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          const UserMenuButton(),
          IconButton(
            icon: Icon(
                themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeService.toggleTheme(),
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
                            child: Text(
                              _searchTerm.isNotEmpty
                                  ? 'No hay resultados para "$_searchTerm"'
                                  : 'No se encontraron propiedades',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8),
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context)
                                            .size
                                            .width >
                                        600
                                    ? 4
                                    : 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _propertyIds.length,
                              itemBuilder: (context, index) {
                                return AccommodationCard(
                                    id: _propertyIds[index]);
                              },
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
                  color: Theme.of(context).brightness ==
                          Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[700],
                ),
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
  final ValueChanged<String> onSearch;
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
