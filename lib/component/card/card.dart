import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../services/image_helper.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Modelo para Propiedad
class Propiedad {
  final String id;
  final List<Imagen> imagenes;
  final String titulo;
  final String direccion;
  final Caracteristicas? caracteristicas;
  final num precio;

  Propiedad({
    required this.id,
    required this.imagenes,
    required this.titulo,
    required this.direccion,
    this.caracteristicas,
    required this.precio,
  });

  factory Propiedad.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? json['propiedadId'] ?? '').toString();
    final imagenes = <Imagen>[];
    if (json['imagenes'] is List) {
      for (var item in json['imagenes'] as List) {
        if (item is Map<String, dynamic>) {
          imagenes.add(Imagen.fromJson(item));
        }
      }
    }
    Caracteristicas? car;
    if (json['caracteristicas'] is Map<String, dynamic>) {
      car = Caracteristicas.fromJson(
        Map<String, dynamic>.from(json['caracteristicas'] as Map)
      );
    }
    num precio = 0;
    final p = json['precio'];
    if (p is num) precio = p;
    else if (p is String) precio = num.tryParse(p) ?? 0;

    return Propiedad(
      id: id,
      imagenes: imagenes,
      titulo: json['titulo']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? json['ubicacion']?.toString() ?? '',
      caracteristicas: car,
      precio: precio,
    );
  }
}

/// Modelo para Imagen
class Imagen {
  final String url;
  Imagen({required this.url});

  factory Imagen.fromJson(Map<String, dynamic> json) {
    return Imagen(url: json['url']?.toString() ?? '');
  }
}

/// Modelo para Caracteristicas
class Caracteristicas {
  final String? tipoVivienda;
  final int? habitaciones;
  final int? banos;

  Caracteristicas({this.tipoVivienda, this.habitaciones, this.banos});

  factory Caracteristicas.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }
    return Caracteristicas(
      tipoVivienda: json['tipo_vivienda']?.toString(),
      habitaciones: parseInt(json['habitaciones']),
      banos: parseInt(json['banos']),
    );
  }
}

/// Widget que muestra indicador de carga
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) => const Card(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
}

/// Widget que muestra mensaje de error
class _ErrorCard extends StatelessWidget {
  final String? error;
  const _ErrorCard(this.error);
  @override
  Widget build(BuildContext context) => Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              error ?? 'Error al cargar la propiedad',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
}

/// Tarjeta de alojamiento con toggle de favorito
class AccommodationCard extends StatefulWidget {
  final String id;
  final VoidCallback? onFavoriteToggle;

  const AccommodationCard({
    Key? key,
    required this.id,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  _AccommodationCardState createState() => _AccommodationCardState();
}

class _AccommodationCardState extends State<AccommodationCard> {
  bool _loading = true;
  String? _error;
  Propiedad? _propiedad;
  bool _isFavorite = false;
  bool _showDetails = false;
  bool _showLoginPrompt = false;
  final ImageHelper _imageHelper = ImageHelper();

  @override
  void initState() {
    super.initState();
    _fetchPropiedad();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkFavoriteStatus();
  }

  Future<void> _fetchPropiedad() async {
    try {
      final resp = await http.get(
        Uri.parse('http://localhost:4000/api/propiedades/publicacion/${widget.id}'),
      );
      if (!mounted) return;
      if (resp.statusCode != 200) {
        throw Exception('Error ${resp.statusCode}');
      }
      final raw = json.decode(resp.body);
      final data = (raw is Map && raw['data'] is Map)
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _propiedad = Propiedad.fromJson(data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) return;
    try {
      final token = await auth.user!.getIdToken();
      final uid = auth.user!.uid;
      final resp = await http.get(
        Uri.parse('http://localhost:4000/api/favorites/$uid'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final list = json.decode(resp.body) as List<dynamic>;
        final fav = list.any((item) {
          final map = item as Map<String, dynamic>;
          final fid = map['propiedadId'] ?? map['id'] ?? map['propiedad']?['_id'];
          return fid?.toString() == widget.id;
        });
        setState(() => _isFavorite = fav);
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) {
      if (!mounted) return;
      setState(() => _showLoginPrompt = true);
      return;
    }
    try {
      final token = await auth.user!.getIdToken();
      final uid = auth.user!.uid;
      late http.Response resp;
      if (_isFavorite) {
        resp = await http.delete(
          Uri.parse('http://localhost:4000/api/favorites/$uid/${widget.id}'),
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        resp = await http.post(
          Uri.parse('http://localhost:4000/api/favorites'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'usuarioUid': uid, 'propiedadId': widget.id}),
        );
      }
      if (!mounted) return;
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        setState(() => _isFavorite = !_isFavorite);
        widget.onFavoriteToggle?.call();
      } else {
        throw Exception('Status ${resp.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _navigateDetails() async {
    try {
      await http.post(
        Uri.parse('http://localhost:4000/api/propiedades/${widget.id}/vistas'),
        headers: {'Content-Type': 'application/json'},
      );
      if (!mounted) return;
      Navigator.pushNamed(context, '/descripcionPropiedad/${widget.id}');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _LoadingCard();
    if (_error != null || _propiedad == null) return _ErrorCard(_error);

    final prop = _propiedad!;
    final img = prop.imagenes.isNotEmpty ? prop.imagenes.first.url : '';
    final feats = [
      prop.caracteristicas?.tipoVivienda ?? '',
      '${prop.caracteristicas?.habitaciones ?? 1} hab.',
      '${prop.caracteristicas?.banos ?? 1} baños',
    ].where((e) => e.isNotEmpty).toList();

    return Stack(
      children: [
        GestureDetector(
          onTap: _navigateDetails,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            margin: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _imageHelper.buildNetworkImage(
                      imageUrl: img,
                      height: 180,
                      width: double.infinity,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: _toggleFavorite,
                        child: CircleAvatar(
                          backgroundColor:
                              const Color.fromRGBO(255, 255, 255, 0.9),
                          radius: 18,
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                _isFavorite ? Colors.red : Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prop.titulo,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.place,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(prop.direccion,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Disponible',
                          style: TextStyle(
                              fontSize: 13, color: Colors.green)),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: NumberFormat.currency(
                                      locale: 'es_CO',
                                      symbol: '\$',
                                      decimalDigits: 0)
                                  .format(prop.precio),
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            TextSpan(
                                text: ' Por mes',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(
                            () => _showDetails = !_showDetails),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.teal,
                            padding: EdgeInsets.zero),
                        child: Text(_showDetails
                            ? 'Ocultar detalles'
                            : 'Ver detalles'),
                      ),
                      if (_showDetails)
                        Container(
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: Colors.grey[200]!))),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: feats
                                .map((f) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: Colors.grey[300]!)),
                                      child: Text(f,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700])),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        if (_showLoginPrompt)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Acceso requerido',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text(
                            'Debes iniciar sesión para guardar favoritos',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => setState(
                                  () => _showLoginPrompt = false),
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(
                                    () => _showLoginPrompt = false);
                                Navigator.pushNamed(
                                    context, '/login');
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF41BFB3)),
                              child: const Text('Iniciar sesión',
                                  style: TextStyle(
                                      color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
