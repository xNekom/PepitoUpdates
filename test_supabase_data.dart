import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pepito_updates/config/supabase_config.dart';

void main() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  final client = Supabase.instance.client;

  try {
    // Verificar si hay datos en la tabla
    final response = await client
        .from(SupabaseConfig.activitiesTable)
        .select()
        .limit(10);

    print('Datos encontrados en ${SupabaseConfig.activitiesTable}:');
    print('Número de registros: ${response.length}');

    if (response.isNotEmpty) {
      print('Primer registro:');
      print(response.first);

      // Verificar estructura de datos
      final firstItem = response.first;
      print('Campos disponibles: ${firstItem.keys.toList()}');

      // Verificar tipos de datos
      print('Tipo de timestamp: ${firstItem['timestamp'].runtimeType}');
      print('Tipo de type: ${firstItem['type'].runtimeType}');
    } else {
      print('No hay datos en la tabla ${SupabaseConfig.activitiesTable}');
    }

    // Obtener estadísticas usando el método del servicio
    final statsResponse = await client
        .from(SupabaseConfig.activitiesTable)
        .select();

    final data = statsResponse as List<dynamic>;
    print('\nEstadísticas calculadas:');
    print('Total de actividades: ${data.length}');

    final entries = data.where((item) =>
      item['type']?.toString().toLowerCase() == 'in' ||
      item['type']?.toString().toLowerCase() == 'entrada'
    ).length;

    final exits = data.where((item) =>
      item['type']?.toString().toLowerCase() == 'out' ||
      item['type']?.toString().toLowerCase() == 'salida'
    ).length;

    print('Total entradas: $entries');
    print('Total salidas: $exits');

  } catch (e) {
    print('Error: $e');
  }
}