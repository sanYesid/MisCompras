import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../domain/models/purchase_item.dart';
import '../../domain/repositories/purchase_repository.dart';

class PurchaseProvider with ChangeNotifier {
  final PurchaseRepository _repository;

  List<PurchaseItem> _items = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  PurchaseProvider(this._repository) {
    loadPurchasesByDate(_selectedDate);
  }

  // Getters
  List<PurchaseItem> get items => List.unmodifiable(_items);
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fecha en formato ISO 'YYYY-MM-DD'
  String get formattedDateIso => DateFormat('yyyy-MM-dd').format(_selectedDate);

  /// Fecha formateada amigable para mostrar en la interfaz
  String get displayFormattedDate => DateFormat('EEEE, d MMMM yyyy', 'es').format(_selectedDate);

  /// Calcula automáticamente el total acumulado gastado en el día seleccionado
  double get totalGastoDia {
    return _items.fold(0.0, (previousValue, item) => previousValue + item.subtotal);
  }

  /// Total de artículos o compras registradas en el día
  int get totalArticulosDia => _items.length;

  /// Cambia la fecha seleccionada y recarga las compras
  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
    await loadPurchasesByDate(_selectedDate);
  }

  /// Navega al día anterior
  Future<void> previousDay() async {
    await setSelectedDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  /// Navega al día siguiente
  Future<void> nextDay() async {
    await setSelectedDate(_selectedDate.add(const Duration(days: 1)));
  }

  /// Selecciona el día de hoy
  Future<void> goToToday() async {
    await setSelectedDate(DateTime.now());
  }

  /// Carga las compras para una fecha específica
  Future<void> loadPurchasesByDate(DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateIso = DateFormat('yyyy-MM-dd').format(date);
      _items = await _repository.getPurchasesByDate(dateIso);
    } catch (e) {
      _errorMessage = 'Error al cargar las compras: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Agrega una nueva compra a la base de datos
  Future<bool> addPurchase({
    required String nombre,
    required double cantidad,
    required double precio,
    required String fecha,
  }) async {
    try {
      final newItem = PurchaseItem(
        nombre: nombre.trim(),
        cantidad: cantidad,
        precio: precio,
        fecha: fecha,
      );

      final id = await _repository.insertPurchase(newItem);
      final itemWithId = newItem.copyWith(id: id);

      // Si la compra pertenece al día seleccionado actualmente, actualizar la lista local
      if (fecha == formattedDateIso) {
        _items = [itemWithId, ..._items];
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = 'Error al registrar la compra: $e';
      notifyListeners();
      return false;
    }
  }

  /// Actualiza una compra existente y recarga las compras de la fecha activa
  Future<void> updatePurchase(PurchaseItem purchase) async {
    _errorMessage = null;
    try {
      await _repository.updatePurchase(purchase);
      await loadPurchasesByDate(_selectedDate);
    } catch (e) {
      _errorMessage = 'Error al actualizar la compra: $e';
      notifyListeners();
    }
  }

  /// Elimina una compra por su ID
  Future<bool> deletePurchase(int id) async {
    try {
      await _repository.deletePurchase(id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar la compra: $e';
      notifyListeners();
      return false;
    }
  }
}
