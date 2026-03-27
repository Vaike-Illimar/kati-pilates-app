import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kati_pilates/models/class_definition.dart';
import 'package:kati_pilates/models/class_instance.dart';

class ClassRepository {
  final SupabaseClient _client;

  ClassRepository(this._client);

  /// Fetch the schedule for a given date from the class_instances_with_counts view.
  Future<List<ClassInstanceWithDetails>> getScheduleForDate(
    DateTime date,
  ) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final data = await _client
        .from('class_instances_with_counts')
        .select()
        .eq('date', dateStr)
        .order('start_time');
    return data
        .map((json) => ClassInstanceWithDetails.fromJson(json))
        .toList();
  }

  /// Fetch a single class instance with its details.
  Future<ClassInstanceWithDetails> getClassInstance(String id) async {
    final data = await _client
        .from('class_instances_with_counts')
        .select()
        .eq('id', id)
        .single();
    return ClassInstanceWithDetails.fromJson(data);
  }

  /// Fetch all class definitions (templates).
  Future<List<ClassDefinition>> getClassDefinitions() async {
    final data = await _client
        .from('class_definitions')
        .select()
        .eq('is_active', true)
        .order('day_of_week')
        .order('start_time');
    return data.map((json) => ClassDefinition.fromJson(json)).toList();
  }
}
