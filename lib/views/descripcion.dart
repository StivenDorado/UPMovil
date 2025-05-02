import 'package:flutter/material.dart';

class PaginaPropiedad extends StatefulWidget {
  const PaginaPropiedad({super.key});

  @override
  _PaginaPropiedadState createState() => _PaginaPropiedadState();
}

class _PaginaPropiedadState extends State<PaginaPropiedad> {
  // Datos simulados
  Map<String, dynamic> propiedad = {
    'titulo': 'Casa Moderna con Piscina',
    'precio': 200000,
    'imagenes': ['assets/img1.jpg', 'assets/img2.jpg'],
    'caracteristicas': {
      'Servicios': [
        'Energía',
        'Agua',
        'Piscina',
        'Terraza',
        'Nevera',
        'Jardín',
        'Amoblado',
      ],
    },
    'resenas': [],
    'fechasReserva': [],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propiedad'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitulo(),
              const SizedBox(height: 16),
              _buildGaleria(),
              const SizedBox(height: 24),
              _buildServicios(),
              const SizedBox(height: 24),
              _buildResenas(),
              const SizedBox(height: 24),
              _buildPrecioReserva(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  Widget _buildTitulo() {
    return Text(
      propiedad['titulo'],
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildGaleria() {
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
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              itemCount: propiedad['imagenes'].length,
              itemBuilder: (context, index) {
                return Image.asset(
                  propiedad['imagenes'][index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildPlaceholderImage(), _buildPlaceholderImage()],
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Text(
          'No hay imagen adicional',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildServicios() {
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
          children: propiedad['caracteristicas']['Servicios']
              .map<Widget>(
                (servicio) => Chip(
                  label: Text(servicio),
                  backgroundColor: Colors.blue[50],
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildResenas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Reseñas: ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('0.0 (0 calificaciones)', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Escribe tu comentario...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const Text(
          'No hay reseñas disponibles',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPrecioReserva() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del precio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${propiedad['precio']} COP',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Disponible',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Detalles del precio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildDetallePrecio('LLEGA N/A')),
              const SizedBox(width: 8),
              Expanded(child: _buildDetallePrecio('SALTA N/A')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildDetallePrecio('Mercial')),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDetallePrecio('Total del costo: \$400.000 COP'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // Acción de reserva
                  },
                  child: const Text(
                    'Reservar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // Acción de ofrecer precio
                  },
                  child: const Text(
                    'Ofrecer Precio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetallePrecio(String texto) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 60,
      color: Colors.blueAccent,
      child: const Center(
        child: Text(
          'Footer - Información adicional',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
