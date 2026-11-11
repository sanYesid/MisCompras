import 'package:flutter_test/flutter_test.dart';
import 'package:gasto_diario/domain/models/purchase_item.dart';
import 'package:gasto_diario/domain/repositories/purchase_repository.dart';
import 'package:gasto_diario/presentation/providers/purchase_provider.dart';
import 'package:intl/intl.dart';

class FakePurchaseRepository implements PurchaseRepository {
  final List<PurchaseItem> _storage = [];
  int _nextId = 1;

  @override
  Future<List<PurchaseItem>> getPurchases() async {
    return List.from(_storage);
  }

  @override
  Future<List<PurchaseItem>> getPurchasesByDate(String date) async {
    return _storage.where((item) => item.fecha == date).toList();
  }

  @override
  Future<int> insertPurchase(PurchaseItem purchase) async {
    final item = purchase.copyWith(id: _nextId++);
    _storage.add(item);
    return item.id!;
  }

  @override
  Future<int> updatePurchase(PurchaseItem purchase) async {
    final index = _storage.indexWhere((item) => item.id == purchase.id);
    if (index == -1) return 0;
    _storage[index] = purchase;
    return 1;
  }

  @override
  Future<int> deletePurchase(int id) async {
    final initialLength = _storage.length;
    _storage.removeWhere((item) => item.id == id);
    return initialLength - _storage.length;
  }
}

void main() {
  group('PurchaseItem Entity Tests', () {
    test('Calcula correctamente el subtotal (cantidad * precio)', () {
      const item = PurchaseItem(
        id: 1,
        nombre: 'Leche',
        cantidad: 3.0,
        precio: 2500.0,
        fecha: '2026-11-10',
      );

      expect(item.subtotal, 7500.0);
    });

    test('Serializa y deserializa correctamente hacia/desde Map para SQLite', () {
      const item = PurchaseItem(
        id: 42,
        nombre: 'Arroz',
        cantidad: 2.5,
        precio: 3500.0,
        fecha: '2026-11-10',
      );

      final map = item.toMap();
      expect(map['id'], 42);
      expect(map['nombre'], 'Arroz');
      expect(map['cantidad'], 2.5);
      expect(map['precio'], 3500.0);
      expect(map['fecha'], '2026-11-10');

      final reconstructed = PurchaseItem.fromMap(map);
      expect(reconstructed, equals(item));
      expect(reconstructed.subtotal, 8750.0);
    });
  });

  group('PurchaseProvider CRUD Tests', () {
    test('Agrega, actualiza y elimina compras recalculando el total del día', () async {
      final repo = FakePurchaseRepository();
      final provider = PurchaseProvider(repo);
      final todayIso = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Esperar la carga inicial del constructor
      await Future<void>.delayed(Duration.zero);
      expect(provider.items, isEmpty);
      expect(provider.totalGastoDia, 0.0);

      // 1. Insertar
      await provider.addPurchase(
        nombre: 'Pan',
        cantidad: 2,
        precio: 1500,
        fecha: todayIso,
      );

      expect(provider.items.length, 1);
      expect(provider.totalGastoDia, 3000.0);

      // 2. Actualizar (Edit)
      final addedItem = provider.items.first;
      final editedItem = addedItem.copyWith(
        nombre: 'Pan Integral',
        cantidad: 4,
        precio: 2000,
      );
      await provider.updatePurchase(editedItem);

      expect(provider.items.length, 1);
      expect(provider.items.first.nombre, 'Pan Integral');
      expect(provider.items.first.cantidad, 4.0);
      expect(provider.items.first.precio, 2000.0);
      expect(provider.totalGastoDia, 8000.0);

      // 3. Eliminar
      await provider.deletePurchase(addedItem.id!);
      expect(provider.items, isEmpty);
      expect(provider.totalGastoDia, 0.0);
    });
  });
}
