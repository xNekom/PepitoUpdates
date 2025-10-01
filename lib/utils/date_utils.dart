import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';

class AppDateUtils {
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _weekdayFormat = DateFormat('EEEE');
  static final DateFormat _shortWeekdayFormat = DateFormat('EEE');

  /// Formatea una fecha como hora (HH:mm)
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Formatea una fecha como fecha (dd/MM/yyyy)
  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// Formatea una fecha como fecha y hora (dd/MM/yyyy HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Formatea una fecha como día y mes (dd MMM)
  static String formatDayMonth(DateTime dateTime) {
    return _dayMonthFormat.format(dateTime);
  }

  /// Formatea una fecha como mes y año (MMMM yyyy)
  static String formatMonthYear(DateTime dateTime) {
    return _monthYearFormat.format(dateTime);
  }

  /// Formatea una fecha como día de la semana (Lunes)
  static String formatWeekday(DateTime dateTime) {
    return _weekdayFormat.format(dateTime);
  }

  /// Formatea una fecha como día de la semana corto (Lun)
  static String formatShortWeekday(DateTime dateTime) {
    return _shortWeekdayFormat.format(dateTime);
  }

  /// Formatea una fecha como día corto (dd)
  static String formatDayShort(DateTime dateTime) {
    return DateFormat('dd').format(dateTime);
  }

  /// Devuelve una descripción relativa del tiempo (hace 5 minutos, ayer, etc.)
  static String getRelativeTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      if (difference.inSeconds < 5) {
        return AppLocalizations.of(context)!.aFewMomentsAgo;
      } else {
        return 'Hace ${difference.inSeconds} segundos';
      }
    } else if (difference.inMinutes < 60) {
      return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return AppLocalizations.of(context)!.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return 'Ayer a las ${formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${formatShortWeekday(dateTime)} a las ${formatTime(dateTime)}';
    } else {
      return formatDateTime(dateTime);
    }
  }

  /// Verifica si una fecha es hoy
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Verifica si una fecha es ayer
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// Verifica si una fecha es esta semana
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return dateTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        dateTime.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Obtiene el inicio del día
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Obtiene el final del día
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }

  /// Obtiene el inicio de la semana (lunes)
  static DateTime startOfWeek(DateTime dateTime) {
    final daysFromMonday = dateTime.weekday - 1;
    return startOfDay(dateTime.subtract(Duration(days: daysFromMonday)));
  }

  /// Obtiene el final de la semana (domingo)
  static DateTime endOfWeek(DateTime dateTime) {
    final daysToSunday = 7 - dateTime.weekday;
    return endOfDay(dateTime.add(Duration(days: daysToSunday)));
  }

  /// Obtiene el inicio del mes
  static DateTime startOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  /// Obtiene el final del mes
  static DateTime endOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month + 1, 0, 23, 59, 59, 999);
  }

  /// Obtiene una lista de fechas entre dos fechas
  static List<DateTime> getDaysBetween(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = startOfDay(start);
    final endDay = startOfDay(end);

    while (current.isBefore(endDay) || current.isAtSameMomentAs(endDay)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  /// Calcula la duración entre dos fechas en formato legible
  static String getDurationBetween(DateTime start, DateTime end) {
    final duration = end.difference(start);
    
    if (duration.inDays > 0) {
      return '${duration.inDays} días';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} horas';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutos';
    } else {
      return '${duration.inSeconds} segundos';
    }
  }

  /// Obtiene el saludo según la hora del día
  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  /// Obtiene el emoji según la hora del día
  static String getTimeEmoji() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 12) {
      return '🌅'; // Amanecer
    } else if (hour >= 12 && hour < 18) {
      return '☀️'; // Día
    } else if (hour >= 18 && hour < 21) {
      return '🌆'; // Atardecer
    } else {
      return '🌙'; // Noche
    }
  }

  /// Convierte una fecha a formato ISO 8601
  static String toIso8601(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Convierte una cadena ISO 8601 a DateTime
  static DateTime? fromIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Verifica si dos fechas son el mismo día
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Formatea una fecha en formato corto (dd/MM)
  static String formatDateShort(DateTime dateTime) {
    return DateFormat('dd/MM').format(dateTime);
  }

  /// Rangos de fecha predefinidos
  static DateRange get today {
    final now = DateTime.now();
    return DateRange(
      start: startOfDay(now),
      end: endOfDay(now),
    );
  }

  static DateRange get yesterday {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return DateRange(
      start: startOfDay(yesterday),
      end: endOfDay(yesterday),
    );
  }

  static DateRange get thisWeek {
    final now = DateTime.now();
    return DateRange(
      start: startOfWeek(now),
      end: endOfWeek(now),
    );
  }

  static DateRange get lastWeek {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    return DateRange(
      start: startOfWeek(lastWeek),
      end: endOfWeek(lastWeek),
    );
  }

  static DateRange get thisMonth {
    final now = DateTime.now();
    return DateRange(
      start: startOfMonth(now),
      end: endOfMonth(now),
    );
  }

  static DateRange get lastMonth {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    return DateRange(
      start: startOfMonth(lastMonth),
      end: endOfMonth(lastMonth),
    );
  }

  /// Obtiene los rangos de fecha predefinidos
  static Map<String, DateRange> getPredefinedRanges() {
    final now = DateTime.now();
    
    return {
      'Hoy': DateRange(
        start: startOfDay(now),
        end: endOfDay(now),
      ),
      'Ayer': DateRange(
        start: startOfDay(now.subtract(const Duration(days: 1))),
        end: endOfDay(now.subtract(const Duration(days: 1))),
      ),
      'Esta semana': DateRange(
        start: startOfWeek(now),
        end: endOfWeek(now),
      ),
      'Semana pasada': DateRange(
        start: startOfWeek(now.subtract(const Duration(days: 7))),
        end: endOfWeek(now.subtract(const Duration(days: 7))),
      ),
      'Este mes': DateRange(
        start: startOfMonth(now),
        end: endOfMonth(now),
      ),
      'Mes pasado': DateRange(
        start: startOfMonth(DateTime(now.year, now.month - 1)),
        end: endOfMonth(DateTime(now.year, now.month - 1)),
      ),
    };
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
        date.isBefore(end.add(const Duration(milliseconds: 1)));
  }

  Duration get duration => end.difference(start);

  @override
  String toString() {
    return 'DateRange(start: $start, end: $end)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}