import '../../../core/utils/connectivity_helper.dart';
import '../../../core/error/failures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/chat_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../../domain/entities/chat_message.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/chat_input_field.dart';
import '../../widgets/chat/itinerary_message_bubble.dart';
import '../../widgets/chat/loading_message_bubble.dart';
import '../../widgets/chat/error_message_bubble.dart';
import '../../widgets/chat/typing_indicator_bubble.dart';
import '../../widgets/common/user_avatar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? itineraryId;
  final String? initialPrompt;

  const ChatScreen({super.key, this.itineraryId, this.initialPrompt});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  ProviderSubscription<ChatState>? _chatStateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prompt = widget.initialPrompt?.trim();
      if (prompt != null && prompt.isNotEmpty) {
        await ref
            .read(chatProvider(widget.itineraryId).notifier)
            .sendMessage(prompt);
        _messageController.clear();
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatStateSubscription?.close();
    super.dispose();
  }

  Future<void> _onSend(String text) async {
    if (text.trim().isEmpty) return;
    final online = await ConnectivityHelper.isOnline();
    if (!online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are offline. Please connect to the internet.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Use streaming mode
    try {
      final notifier = ref.read(chatProvider(widget.itineraryId).notifier);
      await notifier.sendMessageStreamed(text);
      _messageController.clear();
      _scrollToBottom();
    } on RateLimitFailure {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rate limit exceeded. Please wait a moment and try again.',
          ),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is NetworkFailure
                ? 'Network error. Please check your connection and try again.'
                : 'An error occurred. Please try again.',
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _regenerateResponse() async {
    await ref
        .read(chatProvider(widget.itineraryId).notifier)
        .regenerateLastResponse();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveItineraryOffline() async {
    final state = ref.read(chatProvider(widget.itineraryId));
    final itinerary = state.maybeWhen(
      loaded: (messages, itinerary) => itinerary,
      orElse: () => null,
    );

    if (itinerary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No itinerary to save'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Save itinerary to local storage
      final itineraryRepo = ref.read(itineraryRepositoryProvider);
      final result = await itineraryRepo.saveItinerary(itinerary);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (savedItinerary) async {
          // Mark as available offline
          await itineraryRepo.markItineraryOffline(savedItinerary.id ?? '');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Itinerary saved for offline access'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving itinerary: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes and scroll to bottom
    _chatStateSubscription ??= ref.listenManual<ChatState>(
      chatProvider(widget.itineraryId),
      (previous, next) {
        _scrollToBottom();
      },
    );

    final state = ref.watch(chatProvider(widget.itineraryId));

    final messages = state.maybeWhen(
      loaded: (messages, itinerary) => messages,
      thinking: (messages) => messages,
      error: (message) => <ChatMessage>[],
      orElse: () => <ChatMessage>[],
    );

    final itinerary = state.maybeWhen(
      loaded: (messages, itinerary) => itinerary,
      orElse: () => null,
    );

    final isThinking = state.maybeWhen(
      thinking: (messages) => true,
      orElse: () => false,
    );

    final errorText = state.maybeWhen(
      error: (message) => message,
      orElse: () => null,
    );

    final titleText =
        itinerary?.title ??
        (messages.isNotEmpty
            ? messages
                  .firstWhere(
                    (m) => m.isUser,
                    orElse: () => ChatMessage(
                      content: 'Plan a trip',
                      isUser: true,
                      timestamp: DateTime.now(),
                    ),
                  )
                  .content
            : 'Smart Trip Planner');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          titleText,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: ScreenUtilHelper.spacing16),
            child: const UserAvatar(size: 40),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages + itinerary
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtilHelper.spacing16,
                vertical: ScreenUtilHelper.spacing8,
              ),
              children: [
                for (final message in messages)
                  if (message.messageType == MessageType.error)
                    ErrorMessageBubble(
                      message: message.content,
                      onRegenerate: _regenerateResponse,
                    )
                  else
                    ChatMessageBubble(message: message),

                // Remove GoogleSearchResultsBubble and List<SearchResult> logic
                if (itinerary != null)
                  ItineraryMessageBubble(
                    itinerary: itinerary,
                    onSaveOffline: _saveItineraryOffline,
                    onFollowUp: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      _messageController.text =
                          "Can you refine this itinerary by ";
                      _messageController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _messageController.text.length),
                      );
                    },
                  ),

                if (isThinking)
                  state.maybeWhen(
                    thinking: (messages) {
                      // Find the interim assistant message if it exists
                      final interimMessage = messages.lastWhere(
                        (m) => !m.isUser,
                        orElse: () => ChatMessage(
                          content: '',
                          isUser: false,
                          timestamp: DateTime.now(),
                        ),
                      );
                      return TypingIndicatorBubble(
                        partialText: interimMessage.content,
                      );
                    },
                    orElse: () =>
                        const LoadingMessageBubble(message: 'Typing…'),
                  ),

                if (errorText != null && messages.isEmpty)
                  ErrorMessageBubble(
                    message: errorText,
                    onRegenerate: _regenerateResponse,
                  ),
              ],
            ),
          ),

          // Action Buttons (when itinerary is shown)
          if (itinerary != null && !isThinking) _buildActionButtons(),

          // Chat Input
          ChatInputField(
            controller: _messageController,
            onSend: _onSend,
            onVoiceInput: () {},
            enabled: !isThinking,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtilHelper.spacing16,
        vertical: ScreenUtilHelper.spacing12,
      ),
      child: Column(
        children: [
          // Follow up to refine button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Focus on input field for refinement
                FocusScope.of(context).requestFocus(FocusNode());
                _messageController.clear();
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Follow up to refine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtilHelper.spacing12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ScreenUtilHelper.radius12,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: ScreenUtilHelper.spacing8),
          // Save offline button (UX feedback)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _saveItineraryOffline(),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Save Offline'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onBackground,
                side: BorderSide(color: AppColors.outline),
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtilHelper.spacing12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ScreenUtilHelper.radius12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
