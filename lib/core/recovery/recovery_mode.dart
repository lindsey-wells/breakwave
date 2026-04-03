enum RecoveryMode {
  secular,
  christian;

  String get storageValue => name;

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
        return 'Practical, non-religious recovery support.';
      case RecoveryMode.christian:
        return 'Recovery support with prayer, Scripture, and explicitly Christian language.';
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
