/// "Hapus semua data" (PRD F-10): removes everything the user entered.
abstract interface class DataReset {
  /// Empties every table in one transaction and seeds the default
  /// categories again, leaving the database as after a fresh install.
  Future<void> deleteEverything();
}
