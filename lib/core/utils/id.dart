import 'package:uuid/uuid.dart';

/// UUID v4 ids for every table, so a future cloud sync never collides on
/// auto-increment keys (05 §1).
typedef IdGenerator = String Function();

const _uuid = Uuid();

String newId() => _uuid.v4();
