// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_billing_qa_config.dart
// Purpose: Compile-time gate for the internal Test Store QA console.
// Notes: Normal builds are OFF by default.
// ------------------------------------------------------------

class BreakWaveBillingQaConfig {
  const BreakWaveBillingQaConfig._();

  static const bool enabled = bool.fromEnvironment(
    'BREAKWAVE_REVENUECAT_TEST_STORE_QA',
    defaultValue: false,
  );
}
