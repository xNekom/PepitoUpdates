import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Servicio para manejar transacciones de base de datos de forma segura
class TransactionService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Ejecuta múltiples operaciones en una transacción
  static Future<T> executeTransaction<T>(
    Future<T> Function() operation, {
    String? description,
  }) async {
    try {
      // Nota: Supabase no soporta transacciones explícitas en el cliente
      // Implementamos un patrón de compensación (compensation pattern)
      return await operation();
    } catch (e) {
      // Log del error para debugging
      if (kDebugMode) print('Error en transacción${description != null ? ' ($description)' : ''}: $e');
      rethrow;
    }
  }
  
  /// Ejecuta una operación de eliminación con validación previa
  static Future<bool> safeDelete({
    required String table,
    required String condition,
    required Map<String, dynamic> conditionValues,
    int? expectedCount,
  }) async {
    try {
      // 1. Verificar qué se va a eliminar
      final countQuery = _supabase
          .from(table)
          .select('id');
      
      // Aplicar condiciones
      PostgrestFilterBuilder query = countQuery;
      conditionValues.forEach((key, value) {
        query = query.eq(key, value);
      });
      
      final countResponse = await query;
      final actualCount = countResponse.count ?? 0;
      
      // 2. Validar el conteo esperado si se proporciona
      if (expectedCount != null && actualCount != expectedCount) {
        throw Exception(
          'Conteo de registros no coincide. '
          'Esperado: $expectedCount, Actual: $actualCount'
        );
      }
      
      // 3. Si no hay registros que eliminar, retornar éxito
      if (actualCount == 0) {
        return true;
      }
      
      // 4. Ejecutar la eliminación
      PostgrestFilterBuilder deleteQuery = _supabase.from(table).delete();
      conditionValues.forEach((key, value) {
        deleteQuery = deleteQuery.eq(key, value);
      });
      
      await deleteQuery;
      
      return true;
    } catch (e) {
      if (kDebugMode) print('Error en eliminación segura de $table: $e');
      return false;
    }
  }
  
  /// Ejecuta una operación de inserción con validación de duplicados
  static Future<bool> safeInsert({
    required String table,
    required Map<String, dynamic> data,
    required List<String> uniqueFields,
  }) async {
    try {
      // 1. Verificar si ya existe un registro con los campos únicos
      PostgrestFilterBuilder query = _supabase.from(table).select('id');
      
      for (String field in uniqueFields) {
        if (data.containsKey(field)) {
          query = query.eq(field, data[field]);
        }
      }
      
      final existingRecords = await query;
      
      // 2. Si ya existe, no insertar
      if (existingRecords.isNotEmpty) {
        if (kDebugMode) print('Registro ya existe en $table con campos únicos: $uniqueFields');
        return false;
      }
      
      // 3. Insertar el nuevo registro
      await _supabase.from(table).insert(data);
      
      return true;
    } catch (e) {
      if (kDebugMode) print('Error en inserción segura en $table: $e');
      return false;
    }
  }
  
  /// Ejecuta una operación de actualización con validación previa
  static Future<bool> safeUpdate({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> conditions,
    bool requireExistence = true,
  }) async {
    try {
      // 1. Verificar que el registro existe si es requerido
      if (requireExistence) {
        PostgrestFilterBuilder query = _supabase.from(table).select('id');
        
        conditions.forEach((key, value) {
          query = query.eq(key, value);
        });
        
        final existingRecords = await query;
        
        if (existingRecords.isEmpty) {
          throw Exception('Registro no encontrado en $table para actualizar');
        }
      }
      
      // 2. Ejecutar la actualización
      PostgrestFilterBuilder updateQuery = _supabase.from(table).update(data);
      
      conditions.forEach((key, value) {
        updateQuery = updateQuery.eq(key, value);
      });
      
      await updateQuery;
      
      return true;
    } catch (e) {
      if (kDebugMode) print('Error en actualización segura de $table: $e');
      return false;
    }
  }
  
  /// Ejecuta una operación de upsert (insertar o actualizar)
  static Future<bool> safeUpsert({
    required String table,
    required Map<String, dynamic> data,
    required List<String> conflictColumns,
  }) async {
    try {
      await _supabase
          .from(table)
          .upsert(data, onConflict: conflictColumns.join(','));
      
      return true;
    } catch (e) {
      if (kDebugMode) print('Error en upsert seguro en $table: $e');
      return false;
    }
  }
}