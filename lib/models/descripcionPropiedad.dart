import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaginaPropiedad extends StatefulWidget {
  final String id;

  const PaginaPropiedad({super.key, required this.id});

  @override
  _PaginaPropiedadState createState() => _PaginaPropiedadState();
}

class _PaginaPropiedadState extends State<PaginaPropiedad> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _propiedad;

  @override
  void initState() {
    super.initState();
    _fetchPropiedad();
  }

  Future<void> _fetchPropiedad() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:4000/api/propiedades/publicacion/${widget.id}'),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cargar la propiedad: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      setState(() {
        _propiedad = data['data'] ?? data;
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
      return Scaffold(
        appBar: AppBar(title: const Text('Propiedad')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Propiedad')),
        body: Center(
          child: Text(
            'Error: $_error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final propiedad = _propiedad!;
    final imagenes = propiedad['imagenes'] as List<dynamic>? ?? [];
    final servicios =
        propiedad['caracteristicas']?['Servicios'] as List<dynamic>? ?? [];
    final precio = propiedad['precio'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(propiedad['titulo'] ?? 'Propiedad'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGaleria(imagenes),
              const SizedBox(height: 16),
              _buildServicios(servicios),
              const SizedBox(height: 16),
              _buildPrecioReserva(precio),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGaleria(List<dynamic> imagenes) {
    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              itemCount: imagenes.length,
              itemBuilder: (context, index) {
                return Image.network(
                  imagenes[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicios(List<dynamic> servicios) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios que este lugar ofrece:',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: servicios
              .map<Widget>(
                (servicio) => Chip(
                  label: Text(servicio.toString()),
                  backgroundColor: Colors.blue[50],
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPrecioReserva(num precio) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$$precio COP',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Acción de reserva
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Reservar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
