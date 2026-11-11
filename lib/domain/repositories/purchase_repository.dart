import '../models/purchase_item.dart';

abstract class PurchaseRepository {
  /// Obtiene todas las compras registradas
  Future<List<PurchaseItem>> getPurchases();

  /// Inserta una nueva compra y retorna el ID autogenerado
  Future<int> insertPurchase(PurchaseItem purchase);

  /// Actualiza una compra existente y retorna la cantidad de filas afectadas
  Future<int> updatePurchase(PurchaseItem purchase);

  /// Elimina una compra por su ID y retorna la cantidad de filas afectadas
  Future<int> deletePurchase(int id);

  /// Obtiene las compras registradas en una fecha específica (formato YYYY-MM-DD)
  Future<List<PurchaseItem>> getPurchasesByDate(String date);
}
