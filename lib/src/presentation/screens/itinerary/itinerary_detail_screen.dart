import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../../domain/entities/itinerary.dart';
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
      // TODO: Load itinerary from repository
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading

      // Mock itinerary data
      final mockItinerary = Itinerary(
        id: int.parse(widget.itineraryId),
        title: "Kyoto 5-Day Solo Trip",
        startDate: "2025-04-10",
        endDate: "2025-04-15",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isOfflineAvailable: true,
        days: [
          ItineraryDay(
            date: "2025-04-10",
            summary: "Arrival in Bali & Settle in Ubud",
            items: [
              ItineraryItem(
                time: "Morning",
                activity: "Arrive in Bali, Denpasar Airport.",
              ),
              ItineraryItem(
                time: "Transfer",
                activity: "Private driver to Ubud (around 1.5 hours).",
              ),
              ItineraryItem(
                time: "Accommodation",
                activity:
                    "Check-in at a peaceful boutique hotel or villa in Ubud (e.g., Ubud Aura Retreat or Komaneka at Bisma).",
              ),
              ItineraryItem(
                time: "Afternoon",
                activity:
                    "Explore Ubud's local area, walk around the tranquil rice terraces at Tegallalang.",
              ),
              ItineraryItem(
                time: "Evening",
                activity:
                    "Dinner at Locavore (known for farm-to-table dishes in a peaceful setting)",
              ),
            ],
          ),
        ],
      );

      setState(() {
        _itinerary = mockItinerary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
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
    // TODO: Open maps with itinerary locations
    const url = 'https://maps.google.com/?q=Ubud,Bali';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _copyItinerary() {
    // TODO: Copy itinerary to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Itinerary copied to clipboard'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _saveOffline() {
    // TODO: Save itinerary offline
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Itinerary saved offline'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _regenerateItinerary() {
    // TODO: Regenerate itinerary
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Regenerating itinerary...'),
        backgroundColor: AppColors.info,
      ),
    );
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
          Container(
            width: 40.w,
            height: 40.w,
            margin: EdgeInsets.only(right: ScreenUtilHelper.spacing16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Center(
              child: Text(
                'S',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
}
