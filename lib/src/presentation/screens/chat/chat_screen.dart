import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/itinerary.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/chat_input_field.dart';
import '../../widgets/chat/itinerary_message_bubble.dart';
import '../../widgets/chat/loading_message_bubble.dart';
import '../../widgets/chat/error_message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? itineraryId;
  final String? initialPrompt;

  const ChatScreen({
    super.key,
    this.itineraryId,
    this.initialPrompt,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isThinking = false;
  Itinerary? _currentItinerary;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    if (widget.initialPrompt != null) {
      // Add initial user message and start generating itinerary
      final userMessage = ChatMessage(
        content: widget.initialPrompt!,
        isUser: true,
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(userMessage);
        _isLoading = true;
      });
      
      _generateItinerary(widget.initialPrompt!);
    } else if (widget.itineraryId != null) {
      // Load existing chat history
      _loadChatHistory();
    }
  }

  Future<void> _loadChatHistory() async {
    // TODO: Load chat history from repository
    // For now, show mock data
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockMessages = [
      ChatMessage(
        content: "7 days in Bali next April, 3 people, mid-range budget, wanted to explore less populated areas, it should be a peaceful trip!",
        isUser: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
    
    final mockItinerary = _createMockItinerary();
    
    setState(() {
      _messages.addAll(mockMessages);
      _currentItinerary = mockItinerary;
    });
  }

  Future<void> _generateItinerary(String prompt) async {
    setState(() => _isThinking = true);
    
    try {
      // TODO: Call AI service to generate itinerary
      await Future.delayed(const Duration(seconds: 3)); // Simulate API call
      
      final itinerary = _createMockItinerary();
      
      setState(() {
        _currentItinerary = itinerary;
        _isLoading = false;
        _isThinking = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isThinking = false;
      });
      
      _addErrorMessage("Oops! The LLM failed to generate answer. Please regenerate.");
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final userMessage = ChatMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isThinking = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // TODO: Send message to AI service
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      final aiResponse = ChatMessage(
        content: "I'll help you modify your itinerary. Let me update that for you.",
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiResponse);
        _isThinking = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() => _isThinking = false);
      _addErrorMessage("Failed to send message. Please try again.");
    }
  }

  void _addErrorMessage(String error) {
    final errorMessage = ChatMessage(
      content: error,
      isUser: false,
      timestamp: DateTime.now(),
      messageType: MessageType.error,
    );

    setState(() {
      _messages.add(errorMessage);
    });
    
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

  Future<void> _regenerateResponse() async {
    if (_messages.isNotEmpty && !_messages.last.isUser) {
      setState(() {
        _messages.removeLast(); // Remove the error message
        _isThinking = true;
      });
      
      // Regenerate based on the last user message
      final lastUserMessage = _messages.lastWhere((msg) => msg.isUser);
      await _generateItinerary(lastUserMessage.content);
    }
  }

  void _saveOffline() {
    if (_currentItinerary != null) {
      // TODO: Save itinerary offline
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Itinerary saved offline'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _followUpToRefine() {
    // Focus on the input field to encourage user to ask follow-up questions
    FocusScope.of(context).requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _currentItinerary?.title ?? '7 days in Bali...',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
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
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtilHelper.spacing16,
                vertical: ScreenUtilHelper.spacing8,
              ),
              itemCount: _messages.length + 
                         (_currentItinerary != null ? 1 : 0) + 
                         (_isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                // Show thinking indicator
                if (_isThinking && index == _messages.length + (_currentItinerary != null ? 1 : 0)) {
                  return const LoadingMessageBubble(message: "Thinking...");
                }
                
                // Show itinerary
                if (_currentItinerary != null && index == _messages.length) {
                  return ItineraryMessageBubble(
                    itinerary: _currentItinerary!,
                    onSaveOffline: _saveOffline,
                    onFollowUp: _followUpToRefine,
                  );
                }
                
                // Show regular messages
                final message = _messages[index];
                
                if (message.messageType == MessageType.error) {
                  return ErrorMessageBubble(
                    message: message.content,
                    onRegenerate: _regenerateResponse,
                  );
                }
                
                return ChatMessageBubble(message: message);
              },
            ),
          ),
          
          // Action Buttons (when itinerary is shown)
          if (_currentItinerary != null && !_isLoading && !_isThinking)
            _buildActionButtons(),
          
          // Chat Input
          ChatInputField(
            controller: _messageController,
            onSend: _sendMessage,
            onVoiceInput: () {
              // TODO: Implement voice input
            },
            enabled: !_isLoading && !_isThinking,
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
              onPressed: _followUpToRefine,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Follow up to refine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: EdgeInsets.symmetric(vertical: ScreenUtilHelper.spacing12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenUtilHelper.radius12),
                ),
              ),
            ),
          ),
          
          SizedBox(height: ScreenUtilHelper.spacing8),
          
          // Save offline button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _saveOffline,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Save Offline'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onBackground,
                side: BorderSide(color: AppColors.outline),
                padding: EdgeInsets.symmetric(vertical: ScreenUtilHelper.spacing12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenUtilHelper.radius12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Itinerary _createMockItinerary() {
    return Itinerary(
      title: "Kyoto 5-Day Solo Trip",
      startDate: "2025-04-10",
      endDate: "2025-04-15",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
              activity: "Check-in at a peaceful boutique hotel or villa in Ubud (e.g., Ubud Aura Retreat or Komaneka at Bisma).",
            ),
            ItineraryItem(
              time: "Afternoon",
              activity: "Explore Ubud's local area, walk around the tranquil rice terraces at Tegallalang.",
            ),
            ItineraryItem(
              time: "Evening",
              activity: "Dinner at Locavore (known for farm-to-table dishes in a peaceful setting)",
              location: "Mumbai to Bali, Indonesia | 11hrs 5mins",
            ),
          ],
        ),
      ],
    );
  }
}
