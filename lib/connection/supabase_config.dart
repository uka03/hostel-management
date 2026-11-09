/// Connection details for the Supabase project.
///
/// The publishable key is designed to ship inside the app; row-level security
/// is what protects the data. Never put a secret key, `service_role` key or
/// database password here: anything in this file can be extracted from the app.
class SupabaseConfig {
  SupabaseConfig._();

  static const url = 'https://bzhwyiswabkofgxqhnxo.supabase.co';
  static const publishableKey =
      'sb_publishable_qhDBtoW3Gn37UdffR-XcmQ_-Z3epUTN';
}
