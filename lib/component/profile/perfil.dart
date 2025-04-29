import 'package:flutter/material.dart';

class PerfilComponent extends StatelessWidget {
  const PerfilComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simular datos de usuario para el ejemplo
    final Map<String, dynamic> usuario = {
      'nombre': 'Carlos Pérez',
      'email': 'carlos@ejemplo.com',
      'photoURL': null,
      'esArrendador': false,
      'fechaRegistro': '15/03/2023',
      'totalVisitas': 23,
      'propiedadesFavoritas': 7,
      'ultimaConexion': '29/04/2025',
    };

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto de perfil
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: usuario['photoURL'] != null
                  ? NetworkImage(usuario['photoURL'])
                  : null,
              child: usuario['photoURL'] == null
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 16),
            
            // Nombre del usuario
            Text(
              usuario['nombre'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Correo
            Text(
              usuario['email'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            
            // Tipo de usuario
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: usuario['esArrendador']
                    ? const Color(0xFF0D9488)
                    : Colors.blue,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                usuario['esArrendador'] ? "Arrendador" : "Aprendiz",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Estadísticas de usuario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEstadisticaItem(
                  icon: Icons.visibility,
                  valor: usuario['totalVisitas'].toString(),
                  etiqueta: 'Visitas',
                ),
                _buildEstadisticaItem(
                  icon: Icons.favorite,
                  valor: usuario['propiedadesFavoritas'].toString(),
                  etiqueta: 'Favoritos',
                ),
                _buildEstadisticaItem(
                  icon: Icons.calendar_today,
                  valor: usuario['fechaRegistro'],
                  etiqueta: 'Registro',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Última conexión
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última conexión',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario['ultimaConexion'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Botón de editar perfil
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Acción para editar perfil
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar Perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem({
    required IconData icon,
    required String valor,
    required String etiqueta,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F7F5),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0D9488),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          etiqueta,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}