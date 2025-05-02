import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Reserva {
  final int id;
  final String nombre;
  final DateTime fechaCreacion;
  String estado;
  final String monto;
  DateTime? fechaEstado;
  final String propiedad;
  final String? fotoPerfil;

  Reserva({
    required this.id,
    required this.nombre,
    required this.fechaCreacion,
    required this.estado,
    required this.monto,
    this.fechaEstado,
    required this.propiedad,
    this.fotoPerfil,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    DateTime fecha = DateTime.parse(json['fecha_creacion']);
    String estadoRaw = json['estado'];
    String estado = estadoRaw == 'pendiente' ? 'en espera' : estadoRaw;
    DateTime? fechaEst;
    if (estado != 'en espera') {
      fechaEst = fecha;
    }
    String montoStr = NumberFormat.currency(
      locale: 'es_CO', symbol: 'COP ', decimalDigits: 0
    ).format(json['monto_reserva']);
    return Reserva(
      id: json['reserva_id'],
      nombre: json['usuario']['nombre'] ?? 'Sin nombre',
      fechaCreacion: fecha,
      estado: estado,
      monto: montoStr,
      fechaEstado: fechaEst,
      propiedad: json['propiedad']['titulo'],
      fotoPerfil: json['usuario']['fotoPerfil'],
    );
  }
}

class OfertasPrecioScreen extends StatefulWidget {
  @override
  _OfertasPrecioScreenState createState() => _OfertasPrecioScreenState();
}

class _OfertasPrecioScreenState extends State<OfertasPrecioScreen> {
  List<Reserva> _reservas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReservas();
  }

  Future<void> _fetchReservas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:4000/api/reserva'));
      if (response.statusCode != 200) {
        throw Exception('Error al cargar reservas');
      }
      List data = json.decode(response.body);
      _reservas = data.map((json) => Reserva.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cambiarEstado(int id, String nuevoEstado) async {
    try {
      String endpoint = nuevoEstado == 'aceptada' ? 'aceptar' : 'cancelar';
      final response = await http.put(
        Uri.parse('http://localhost:4000/api/reserva/$id/$endpoint'),
      );
      if (response.statusCode != 200) throw Exception('Error al $nuevoEstado reserva');
      setState(() {
        final index = _reservas.indexWhere((res) => res.id == id);
        if (index != -1) {
          _reservas[index].estado = nuevoEstado;
          _reservas[index].fechaEstado = DateTime.now();
        }
      });
    } catch (e) {
      // Manejo de error opcional
    }
  }

  String _formatearFecha(DateTime fecha) {
    return DateFormat("d 'de' MMMM 'de' y", 'es_ES').format(fecha);
  }

  Widget _buildEstado(Reserva res) {
    switch (res.estado) {
      case 'en espera':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [Icon(Icons.attach_money, color: Color(0xFF2A8C82)),
                SizedBox(width: 4),
                Text(res.monto, style: TextStyle(color: Color(0xFF2A8C82), fontWeight: FontWeight.w500)),
              ],
            ),
            Text('Solicitud en espera...', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        );
      case 'cancelada':
      case 'aceptada':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [Icon(Icons.access_time, color: Color(0xFF275950)),
                SizedBox(width: 4),
                Text(_formatearFecha(res.fechaEstado!), style: TextStyle(color: Color(0xFF275950), fontWeight: FontWeight.w500)),
              ],
            ),
            Text(
              res.estado == 'aceptada' ? 'Reserva aceptada' : 'Reserva cancelada',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildAccion(Reserva res) {
    switch (res.estado) {
      case 'en espera':
        return Row(
          children: [
            TextButton.icon(
              onPressed: () => _cambiarEstado(res.id, 'aceptada'),
              icon: Icon(Icons.check, color: Colors.green),
              label: Text('Aceptar', style: TextStyle(color: Colors.green)),
            ),
            SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => _cambiarEstado(res.id, 'cancelada'),
              icon: Icon(Icons.close, color: Colors.red),
              label: Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      case 'cancelada':
        return Row(
          children: [Icon(Icons.close, color: Colors.grey), SizedBox(width: 4), Text('Cancelada', style: TextStyle(color: Colors.grey))],
        );
      case 'aceptada':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Color(0xFF41BFB3), borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [Icon(Icons.check, color: Colors.white, size: 16), SizedBox(width: 4), Text('Aceptada', style: TextStyle(color: Colors.white))],
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error', style: TextStyle(color: Colors.red)));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2A8C82),
        title: Row(
          children: [Icon(Icons.attach_money), SizedBox(width: 8), Text('SOLICITUD DE RESERVAS')],
        ),
      ),
      body: ListView.builder(
        itemCount: _reservas.length,
        itemBuilder: (context, index) {
          final res = _reservas[index];
          return InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xFF91F2E9).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: res.fotoPerfil != null
                          ? NetworkImage(res.fotoPerfil!)
                          : null,
                      ),
                    ],
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(res.nombre, style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Row(
                          children: [Icon(Icons.access_time, size: 14, color: Colors.grey), SizedBox(width: 4), Text(_formatearFecha(res.fechaCreacion), style: TextStyle(fontSize: 12, color: Colors.grey))],
                        ),
                        SizedBox(height: 4),
                        Text(res.propiedad, style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildEstado(res),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: _fetchReservas,
                          ),
                          _buildAccion(res),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OfertasPrecioScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
