import '../entities/water_entry.dart';

/// Calculates total water intake for a specific day.
/// In production, this would query a WaterRepository.
class GetDailyWater {
  const GetDailyWater();

  int call(List<WaterEntry> entries, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return entries
        .where((e) =>
            !e.dateTime.isBefore(startOfDay) && e.dateTime.isBefore(endOfDay))
        .fold<int>(0, (sum, e) => sum + e.amountMl);
  }
}
