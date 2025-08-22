import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/home/trip_input_card.dart';
import '../../widgets/home/saved_itinerary_card.dart';
import '../../widgets/home/home_app_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _tripController = TextEditingController();
  bool _isCreatingItinerary = false;

  @override
  void dispose() {
    _tripController.dispose();
    super.dispose();
  }

  Future<void> _createItinerary() async {
    if (_tripController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your trip vision'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isCreatingItinerary = true);

    try {
      // TODO: Implement itinerary creation logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        // Navigate to chat screen with the prompt
        context.go('/chat?prompt=${Uri.encodeComponent(_tripController.text)}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create itinerary: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingItinerary = false);
      }
    }
  }

  void _onSavedItineraryTap(String itineraryId) {
    context.go('/itinerary/$itineraryId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeAppBar(onProfileTap: () => context.go('/profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtilHelper.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: ScreenUtilHelper.spacing24),

            // Greeting
            Text(
              'Hey Shubham 👋',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: ScreenUtilHelper.spacing32),

            // Trip Vision Question
            Text(
              "What's your vision\nfor this trip?",
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.onBackground,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),

            SizedBox(height: ScreenUtilHelper.spacing24),

            // Trip Input Card
            TripInputCard(
              controller: _tripController,
              onVoiceInput: () {
                // TODO: Implement voice input
              },
            ),

            SizedBox(height: ScreenUtilHelper.spacing24),

            // Create Itinerary Button
            CustomButton(
              text: 'Create My Itinerary',
              onPressed: _isCreatingItinerary ? null : _createItinerary,
              isLoading: _isCreatingItinerary,
            ),

            SizedBox(height: ScreenUtilHelper.spacing40),

            // Offline Saved Itineraries Section
            Text(
              'Offline Saved Itineraries',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: ScreenUtilHelper.spacing16),

            // Saved Itineraries List
            _buildSavedItinerariesList(),

            SizedBox(height: ScreenUtilHelper.spacing24),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedItinerariesList() {
    // Mock data for saved itineraries
    final savedItineraries = [
      {
        'id': '1',
        'title': 'Japan Trip, 20 days vacation,explore ky...',
        'isOffline': true,
      },
      {
        'id': '2',
        'title': 'India Trip, 7 days work trip, suggest affor...',
        'isOffline': true,
      },
      {
        'id': '3',
        'title': 'Europe trip, include Paris, Berlin, Dortmun...',
        'isOffline': true,
      },
      {
        'id': '4',
        'title': 'Two days weekend getaway to somewhe...',
        'isOffline': true,
      },
    ];

    return Column(
      children: savedItineraries.map((itinerary) {
        return Padding(
          padding: EdgeInsets.only(bottom: ScreenUtilHelper.spacing12),
          child: SavedItineraryCard(
            title: itinerary['title'] as String,
            isOffline: itinerary['isOffline'] as bool,
            onTap: () => _onSavedItineraryTap(itinerary['id'] as String),
          ),
        );
      }).toList(),
    );
  }
}
