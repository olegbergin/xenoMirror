import 'package:supabase_flutter/supabase_flutter.dart';

/// Global getter for Supabase client
/// Usage: supabase.from('table_name').select()
final supabase = Supabase.instance.client;
