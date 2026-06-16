import 'package:flutter/material.dart';
import '../../widgets/adaptive/adaptive_activity_card.dart';
import '../../widgets/adaptive/adaptive_skeleton.dart';
import '../../utils/theme_utils.dart';
import '../../utils/supabase_cleanup.dart';
import '../../generated/app_localizations.dart';

void showActivityDetails(BuildContext context, dynamic activity) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppTheme.getColors(context).surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.getColors(
                    context,
                  ).onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.activityDetails,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.getColors(context).onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AdaptiveActivityCard(activity: activity, showDate: true),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> clearSupabaseData(BuildContext context) async {
  final authorized = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Limpiar Duplicados'),
      content: const Text(
        'Esta operación eliminará las actividades duplicadas de Supabase. '
        'Se preservará la actividad más reciente de la API.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Continuar'),
        ),
      ],
    ),
  );

  if (authorized != true) return;

  // Mostrar diálogo de progreso
  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: AdaptiveSkeleton(borderRadius: 20),
            ),
            SizedBox(height: 16),
            Text('Limpiando Supabase...'),
          ],
        ),
      ),
    );
  }

  try {
    final success = await SupabaseCleanup.clearAllActivities();

    // Cerrar diálogo de progreso
    if (context.mounted) Navigator.of(context).pop();

    // Mostrar resultado
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(success ? 'Éxito' : 'Error'),
          content: Text(
            success
                ? 'Supabase limpiado exitosamente. Las actividades duplicadas han sido eliminadas.'
                : 'Error durante la limpieza de Supabase.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    // Cerrar diálogo de progreso
    if (context.mounted) Navigator.of(context).pop();

    // Mostrar error
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error durante la limpieza: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
