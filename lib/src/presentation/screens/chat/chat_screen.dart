// lib/src/presentation/screens/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../providers/chat_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../../domain/entities/chat_message.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/chat_input_field.dart';
import '../../widgets/chat/itinerary_message_bubble.dart';
import '../../widgets/chat/loading_message_bubble.dart';
import '../../widgets/chat/error_message_bubble.dart';

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
    await ref.read(chatProvider(widget.itineraryId).notifier).sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
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

                if (itinerary != null)
                  ItineraryMessageBubble(
                    itinerary: itinerary,
                    onSaveOffline: () {
                      // Optional UX hook (repos already handle persistence as needed)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Itinerary ready — saved entry available in Trips.',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    onFollowUp: () {
                      // focus management for follow-up prompt (kept minimal)
                      FocusScope.of(context).unfocus();
                    },
                  ),

                if (isThinking)
                  const LoadingMessageBubble(message: 'Planning your trip…'),

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
            onVoiceInput: () {
              // TODO: Voice input (later chunk)
            },
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
                // place caret in input (keep behavior simple)
                FocusScope.of(context).unfocus();
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved for offline'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
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
