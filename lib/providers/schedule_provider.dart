import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kati_pilates/models/class_instance.dart';
import 'package:kati_pilates/repositories/class_repository.dart';

final classRepositoryProvider = Provider<ClassRepository>((ref) {
  return ClassRepository(Supabase.instance.client);
});

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

final scheduleProvider =
    FutureProvider.autoDispose.family<List<ClassInstanceWithDetails>, DateTime>(
  (ref, date) async {
    final classRepo = ref.watch(classRepositoryProvider);
    return classRepo.getScheduleForDate(date);
  },
);
