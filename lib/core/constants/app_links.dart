/// External policy URLs — override at build time, e.g.
/// `--dart-define=PRIVACY_POLICY_URL=https://example.com/privacy`
class AppLinks {
  AppLinks._();

  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: '',
  );

  static const String termsOfServiceUrl = String.fromEnvironment(
    'TERMS_OF_SERVICE_URL',
    defaultValue: '',
  );
}
