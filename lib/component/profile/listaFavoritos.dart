import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../providers/auth_provider.dart'; // Ajusta la ruta según tu estructura
import '../card/card.dart'; // Ajusta la ruta según tu estructura

class FavoritosList extends StatefulWidget {
  const FavoritosList({super.key});

  @override
  State<FavoritosList> createState() => _FavoritosListState();
}

class _FavoritosListState extends State<FavoritosList> {
  List<String> _favoritos = [];
  bool _loading = true;
  String? _error;
  int _refreshKey = 0;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoritos();
  }
  
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _fetchFavoritos() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user == null || authProvider.profileLoading) {
      if (_mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }

    if (_mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final token = await authProvider.user!.getIdToken();
      final userId = authProvider.user!.uid;
      
      final response = await http.get(
        Uri.parse('http://localhost:4000/api/favorites/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!_mounted) return;

      if (response.statusCode != 200) {
        throw Exception('Error al cargar favoritos');
      }

      final List<dynamic> data = json.decode(response.body);
      final List<String> ids = data.map<String>((fav) {
        final dynamic propId = fav['propiedadId'] ?? 
                              fav['id'] ?? 
                              fav['propiedad']?['_id'] ?? 
                              fav['propiedad']?['id'] ?? 
                              '';
        return propId.toString();
      }).where((id) => id.isNotEmpty).toList();

      if (_mounted) {
        setState(() {
          _favoritos = ids;
          _loading = false;
        });
      }
    } catch (err) {
      debugPrint('Error obteniendo favoritos: $err');
      if (_mounted) {
        setState(() {
          _error = err.toString();
          _loading = false;
        });
      }
    }
  }

  void _refreshFavoritos() {
    if (_mounted) {
      setState(() {
        _refreshKey++;        // aquí incrementamos la key
      });
      _fetchFavoritos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.profileLoading || _loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_favoritos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No tienes propiedades favoritas aún.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      key: ValueKey(_refreshKey),      // aplicamos la key aquí
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 
            ? 3 
            : (MediaQuery.of(context).size.width > 800 ? 2 : 1),
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _favoritos.length,
      itemBuilder: (context, index) {
        return AccommodationCard(
          id: _favoritos[index],
          onFavoriteToggle: _refreshFavoritos,
        );
      },
    );
  }
}
