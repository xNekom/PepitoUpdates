import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/adaptive/adaptive_activity_card.dart';
import '../../widgets/adaptive/adaptive_skeleton.dart';
import '../../widgets/material_expressive/animated_svg_widget.dart';
import '../../utils/theme_utils.dart';
import '../../providers/pepito_providers.dart';
import '../../generated/app_localizations.dart';

class HomeRecentActivities extends ConsumerWidget {
  final int limit;
  final int offset;
  final VoidCallback? onViewAll;

  const HomeRecentActivities({
    super.key,
    this.limit = 5,
    this.offset = 0,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(
      activitiesProvider(ActivitiesParams(limit: limit, offset: offset)),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.recentActivities,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getColors(context).onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                activitiesAsync.when(
                  data: (activities) {
                    if (activities.isNotEmpty) {
                      final now = DateTime.now();
                      final hasRecentActivity = activities.any((activity) {
                        final difference = now.difference(
                          activity.dateTime,
                        );
                        return difference.inMinutes < 10;
                      });

                      if (hasRecentActivity) {
                        return HeartBeatWidget(
                          size: 20,
                          color: AppTheme.primaryColor,
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onViewAll,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(AppLocalizations.of(context)!.viewAll),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            activitiesAsync.when(
              data: (activities) {
                if (activities.isEmpty) {
                  return const EmptyActivities();
                }
                return Column(
                  children: activities
                      .map(
                        (activity) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AdaptiveActivityCard(
                            activity: activity,
                            compact: true,
                            showDate: false,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const LoadingActivities(),
              error: (error, stack) =>
                  ErrorActivities(error: error.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingActivities extends StatelessWidget {
  const LoadingActivities({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AdaptiveSkeleton(height: 80, borderRadius: 12),
        ),
      ),
    );
  }
}

class ErrorActivities extends StatelessWidget {
  final String error;

  const ErrorActivities({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor),
            const SizedBox(height: 8),
            Text(
              'Error al cargar actividades',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getColors(
                  context,
                ).onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyActivities extends StatelessWidget {
  const EmptyActivities({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/cat_sleeping.svg',
                  width: 48,
                  height: 48,
                  colorFilter: ColorFilter.mode(
                    AppTheme.primaryColor.withValues(alpha: 0.7),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay actividades recientes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.getColors(
                  context,
                ).onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.pepitoActivitiesWillAppearHere,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.getColors(
                  context,
                ).onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
