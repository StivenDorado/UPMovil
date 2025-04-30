// informacion_personal.dart
import 'package:flutter/material.dart';

class InformacionPersonal extends StatelessWidget {
  const InformacionPersonal({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información personal', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFormField('Nombre', 'Muriel'),
                _buildFormField('Apellido', 'Espencer'),
                _buildFormField('Correo electrónico', 'correo@ejemplo.com'),
                _buildFormField('Teléfono', '+1 234 567 890'),
                _buildFormField('Dirección', 'De La Cruz Barrio'),
                _buildFormField('Ciudad', 'Ciudad Ejemplo'),
              ],
            ),
            SizedBox(height: 24),
            Text('Biografía', style: TextStyle(color: Color(0xFF2A8C82))),
            SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Cuéntanos sobre ti...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text('Cancelar'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2A8C82),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text('Guardar cambios'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Color(0xFF2A8C82))),
        SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }
}