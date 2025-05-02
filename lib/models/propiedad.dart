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

  // Método para convertir JSON en una instancia de Propiedad
  factory Propiedad.fromJson(Map<String, dynamic> json) {
    return Propiedad(
      id: json['id'] ?? '',
      imagenes: (json['imagenes'] as List<dynamic>?)
              ?.map((e) => Imagen.fromJson(e))
              .toList() ??
          [],
      titulo: json['titulo'] ?? '',
      direccion: json['direccion'] ?? '',
      precio: json['precio'] ?? 0,
    );
  }
}

// Clase auxiliar para manejar las imágenes
class Imagen {
  final String url;

  Imagen({required this.url});

  // Método para convertir JSON en una instancia de Imagen
  factory Imagen.fromJson(Map<String, dynamic> json) {
    return Imagen(url: json['url'] ?? '');
  }
}
