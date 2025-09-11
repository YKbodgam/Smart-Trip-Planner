import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../../domain/entities/itinerary.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/itinerary/itinerary_day_card.dart';

class ItineraryDetailScreen extends ConsumerStatefulWidget {
  final String itineraryId;

  const ItineraryDetailScreen({super.key, required this.itineraryId});

  @override
  ConsumerState<ItineraryDetailScreen> createState() =>
      _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends ConsumerState<ItineraryDetailScreen> {
  Itinerary? _itinerary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  Future<void> _loadItinerary() async {
    try {
      final currentUser = await ref
          .read(authProvider.notifier)
          .getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final repository = ref.read(itineraryRepositoryProvider);
      final result = await repository.getItineraryById(widget.itineraryId);

      result.fold((failure) => throw Exception(failure.message), (itinerary) {
        if (mounted) {
          setState(() {
            _itinerary = itinerary;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load itinerary: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openInMaps() async {
    if (_itinerary == null || _itinerary!.days.isEmpty) return;

    final firstDay = _itinerary!.days.first;
    final firstLocation = firstDay.items.firstWhere(
      (item) => item.location != null,
      orElse: () => firstDay.items.first,
    );

    final query = firstLocation.location ?? firstLocation.activity;
    final url = 'https://maps.google.com/?q=${Uri.encodeComponent(query)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _copyItinerary() {
    if (_itinerary == null) return;

    final text = _itinerary!.days
        .map((day) {
          final activities = day.items
              .map((item) => '${item.time}: ${item.activity}')
              .join('\n');
          return 'Day ${_itinerary!.days.indexOf(day) + 1}: ${day.summary}\n$activities';
        })
        .join('\n\n');

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Itinerary copied to clipboard'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _saveOffline() async {
    if (_itinerary == null) return;

    try {
      final repository = ref.read(itineraryRepositoryProvider);
      final result = await repository.markItineraryOffline(widget.itineraryId);

      result.fold((failure) => throw Exception(failure.message), (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Itinerary saved offline'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save offline: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _regenerateItinerary() async {
    if (_itinerary == null) return;

    try {
      setState(() => _isLoading = true);

      final aiService = ref.read(aiServiceRepositoryProvider);
      final prompt =
          'Regenerate itinerary for ${_itinerary!.title} with similar duration and style but different activities';

      final result = await aiService.generateItinerary(
        prompt: prompt,
        existingItinerary: _itinerary,
      );

      result.fold((failure) => throw Exception(failure.message), (
        newItinerary,
      ) async {
        final repository = ref.read(itineraryRepositoryProvider);
        final saveResult = await repository.saveItinerary(newItinerary);

        saveResult.fold((failure) => throw Exception(failure.message), (
          savedItinerary,
        ) {
          if (mounted) {
            setState(() {
              _itinerary = savedItinerary;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Itinerary regenerated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        });
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to regenerate itinerary: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final user = ref
                  .watch(authProvider)
                  .maybeWhen(authenticated: (user) => user, orElse: () => null);

              final name =
                  user?.displayName ?? (user?.email.split('@').first ?? 'T');
              final avatarText = (name.isNotEmpty ? name[0] : 'T')
                  .toUpperCase();
              final avatarUrl = user?.photoUrl;

              return Container(
                width: 40.w,
                height: 40.w,
                margin: EdgeInsets.only(right: ScreenUtilHelper.spacing16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildAvatarText(context, avatarText);
                          },
                        ),
                      )
                    : _buildAvatarText(context, avatarText),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _itinerary == null
          ? const Center(child: Text('Itinerary not found'))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtilHelper.spacing16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ScreenUtilHelper.spacing16),

                  // Itinerary Header
                  _buildItineraryHeader(),

                  SizedBox(height: ScreenUtilHelper.spacing24),

                  // Days List
                  ..._itinerary!.days.map(
                    (day) => Padding(
                      padding: EdgeInsets.only(
                        bottom: ScreenUtilHelper.spacing16,
                      ),
                      child: ItineraryDayCard(
                        day: day,
                        onOpenMaps: _openInMaps,
                      ),
                    ),
                  ),

                  SizedBox(height: ScreenUtilHelper.spacing16),

                  // Action Buttons
                  _buildActionButtons(),

                  SizedBox(height: ScreenUtilHelper.spacing24),
                ],
              ),
            ),
    );
  }

  Widget _buildItineraryHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Itinerary Created',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: ScreenUtilHelper.spacing8),
            Text('🏝️', style: TextStyle(fontSize: 24.sp)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Maps and Action Buttons Row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyItinerary,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onBackground,
                  side: BorderSide(color: AppColors.outline),
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtilHelper.spacing12,
                  ),
                ),
              ),
            ),

            SizedBox(width: ScreenUtilHelper.spacing12),

            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saveOffline,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Save Offline'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onBackground,
                  side: BorderSide(color: AppColors.outline),
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtilHelper.spacing12,
                  ),
                ),
              ),
            ),

            SizedBox(width: ScreenUtilHelper.spacing12),

            Expanded(
              child: OutlinedButton.icon(
                onPressed: _regenerateItinerary,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Regenerate'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onBackground,
                  side: BorderSide(color: AppColors.outline),
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtilHelper.spacing12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarText(BuildContext context, String text) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
