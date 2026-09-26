/// Reasons a write is rejected before it reaches the database. The UI maps
/// each value to a localized message.
enum ValidationError {
  nameEmpty,
  nameTooLong,
  amountNotPositive,
  amountNegative,
  noteTooLong,
  categoryKindMismatch,
  reduceNeedsCost,
  reduceNeedsWallet,
  reduceNeedsExpenseCategory,
  scheduleNeedsDays,
  timesPerWeekOutOfRange,
  countOutOfRange,
  archivedReference,
}

class ValidationException implements Exception {
  const ValidationException(this.error);

  final ValidationError error;

  @override
  String toString() => 'ValidationException(${error.name})';
}

/// Thrown when an id does not point at an existing row.
class NotFoundException implements Exception {
  const NotFoundException(this.entity, this.id);

  final String entity;
  final String id;

  @override
  String toString() => 'NotFoundException($entity, $id)';
}
