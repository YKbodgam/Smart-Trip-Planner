import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../providers/itinerary_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart';
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
  void initState() {
    super.initState();
    // Load offline itineraries on enter
    Future.microtask(
      () => ref.read(itineraryListProvider.notifier).loadOfflineItineraries(),
    );
  }

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
      final prompt = _tripController.text.trim();
      context.go('/home/chat?prompt=${Uri.encodeComponent(prompt)}');
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
    context.go('/home/itinerary/$itineraryId');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final username = authState.maybeWhen(
      authenticated: (user) => (user.displayName?.trim().isNotEmpty == true)
          ? user.displayName!
          : (user.email.split('@').first),
      orElse: () => 'Traveler',
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeAppBar(onProfileTap: () => context.go('/home/profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtilHelper.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: ScreenUtilHelper.spacing24),

            // Greeting
            Text(
              'Hey $username 👋',
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
              onVoiceInput: null, // Not part of MVP
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

            // Recent Chats (offline, without itinerary)
            Text(
              'Recent Chats',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: ScreenUtilHelper.spacing12),

            _buildRecentChatsList(),

            SizedBox(height: ScreenUtilHelper.spacing24),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedItinerariesList() {
    final state = ref.watch(itineraryListProvider);
    return state.maybeWhen(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (message) => Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
      ),
      loaded: (itineraries) => Column(
        children: itineraries
            .where((i) => i.isOfflineAvailable)
            .map(
              (itinerary) => Padding(
                padding: EdgeInsets.only(bottom: ScreenUtilHelper.spacing12),
                child: SavedItineraryCard(
                  title: itinerary.title,
                  isOffline: itinerary.isOfflineAvailable,
                  onTap: () => _onSavedItineraryTap(itinerary.id ?? ''),
                ),
              ),
            )
            .toList(),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildRecentChatsList() {
    return FutureBuilder(
      future: ref.read(chatRepositoryProvider).getChatHistory(null),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final either = snapshot.data!;
        return either.fold(
          (failure) => Text(
            failure.message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
          ),
          (messages) {
            final userPrompts = messages
                .where((m) => m.isUser)
                .toList()
                .reversed
                .take(5)
                .toList();
            if (userPrompts.isEmpty) return const Text('No recent chats');
            return Column(
              children: userPrompts
                  .map(
                    (m) => GestureDetector(
                      onTap: () {
                        // Navigate to chat with the message content
                        context.go('/home/chat?prompt=${Uri.encodeComponent(m.content)}');
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: ScreenUtilHelper.spacing8,
                        ),
                        padding: EdgeInsets.all(ScreenUtilHelper.spacing12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            ScreenUtilHelper.radius12,
                          ),
                          border: Border.all(
                            color: AppColors.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                m.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.onSurface),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        );
      },
    );
  }
}
