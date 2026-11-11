class PurchaseItem {
  final int? id;
  final String nombre;
  final double cantidad;
  final double precio;
  final String fecha; // Formato ISO: YYYY-MM-DD

  const PurchaseItem({
    this.id,
    required this.nombre,
    required this.cantidad,
    required this.precio,
    required this.fecha,
  });

  /// Calcula automáticamente el subtotal (cantidad * precio)
  double get subtotal => cantidad * precio;

  /// Convierte el objeto a Map para SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'cantidad': cantidad,
      'precio': precio,
      'fecha': fecha,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Crea un objeto a partir de un Map de SQLite
  factory PurchaseItem.fromMap(Map<String, dynamic> map) {
    return PurchaseItem(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      cantidad: (map['cantidad'] as num).toDouble(),
      precio: (map['precio'] as num).toDouble(),
      fecha: map['fecha'] as String,
    );
  }

  PurchaseItem copyWith({
    int? id,
    String? nombre,
    double? cantidad,
    double? precio,
    String? fecha,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      precio: precio ?? this.precio,
      fecha: fecha ?? this.fecha,
    );
  }

  @override
  String toString() {
    return 'PurchaseItem(id: $id, nombre: $nombre, cantidad: $cantidad, precio: $precio, fecha: $fecha, subtotal: $subtotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseItem &&
        other.id == id &&
        other.nombre == nombre &&
        other.cantidad == cantidad &&
        other.precio == precio &&
        other.fecha == fecha;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nombre.hashCode ^
        cantidad.hashCode ^
        precio.hashCode ^
        fecha.hashCode;
  }
}
