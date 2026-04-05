enum RecoveryMode {
  secular,
  christian;

  String get storageValue => name;

  String get label {
    switch (this) {
      case RecoveryMode.secular:
        return 'Secular';
      case RecoveryMode.christian:
        return 'Christian';
    }
  }

  String get title {
    switch (this) {
      case RecoveryMode.secular:
        return 'Secular recovery path';
      case RecoveryMode.christian:
        return 'Christian recovery path';
    }
  }

  String get description {
    switch (this) {
      case RecoveryMode.secular:
        return 'Practical support without religious language. Calm, direct, and focused on the next right move.';
      case RecoveryMode.christian:
        return 'Recovery support with prayer, Scripture, and clearly Christian language rooted in grace and truth.';
    }
  }

  static RecoveryMode? fromStorage(String? value) {
    switch (value) {
      case 'secular':
        return RecoveryMode.secular;
      case 'christian':
        return RecoveryMode.christian;
      default:
        return null;
    }
  }
}
