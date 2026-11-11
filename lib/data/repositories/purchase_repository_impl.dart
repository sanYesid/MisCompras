import '../../domain/models/purchase_item.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/database_helper.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final DatabaseHelper _databaseHelper;

  PurchaseRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<PurchaseItem>> getPurchases() async {
    return await _databaseHelper.getAll();
  }

  @override
  Future<int> insertPurchase(PurchaseItem purchase) async {
    return await _databaseHelper.insert(purchase);
  }

  @override
  Future<int> updatePurchase(PurchaseItem purchase) async {
    return await _databaseHelper.updatePurchase(purchase);
  }

  @override
  Future<int> deletePurchase(int id) async {
    return await _databaseHelper.delete(id);
  }

  @override
  Future<List<PurchaseItem>> getPurchasesByDate(String date) async {
    return await _databaseHelper.getByDate(date);
  }
}
