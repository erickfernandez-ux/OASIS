import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized Supabase client wrapper.
/// All backend operations must go through here.
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
}
