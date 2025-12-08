import 'package:drift/drift.dart';

import '../db/app_database.dart';

class CropRepository {
  CropRepository(this._db);

  final AppDatabase _db;

  Future<int> insertOrUpdateCropParams(CropParamsCompanion companion,
      {int? existingId}) async {
    if (existingId == null) {
      return _db.into(_db.cropParams).insert(companion);
    } else {
      await (_db.update(_db.cropParams)
            ..where((tbl) => tbl.id.equals(existingId)))
          .write(companion);
      return existingId;
    }
  }

  Future<int> insertCropImage(CropImagesCompanion companion) {
    return _db.into(_db.cropImages).insert(companion);
  }

  Future<List<CropParam>> getAllCropParams() {
    return _db.select(_db.cropParams).get();
  }

  Future<List<CropImage>> getImagesForCrop(int cropParamsId) {
    return (_db.select(_db.cropImages)
          ..where((tbl) => tbl.cropParamsId.equals(cropParamsId)))
        .get();
  }

  Future<List<CropImage>> getAllImages() {
    return _db.select(_db.cropImages).get();
  }

  Future<void> deleteCropParams(int id) async {
    // First delete associated images
    await (_db.delete(_db.cropImages)
          ..where((tbl) => tbl.cropParamsId.equals(id)))
        .go();
    // Then delete the crop params
    await (_db.delete(_db.cropParams)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<int> deleteAllCropParams() async {
    // Delete all images first
    await _db.delete(_db.cropImages).go();
    // Then delete all crop params
    return await _db.delete(_db.cropParams).go();
  }
}


