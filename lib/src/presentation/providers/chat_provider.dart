import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/ai_service_repository.dart';
import '../providers/repository_providers.dart';

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, int?>((
      ref,
      itineraryId,
    ) {
      final chatRepository = ref.watch(chatRepositoryProvider);
      final aiService = ref.watch(aiServiceRepositoryProvider);
      return ChatNotifier(chatRepository, aiService, itineraryId);
    });

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  final AIServiceRepository _aiService;
  final int? _itineraryId;

  ChatNotifier(this._chatRepository, this._aiService, this._itineraryId)
    : super(const ChatState.initial()) {
    loadChatHistory();
  }

  Future<void> loadChatHistory() async {
    state = const ChatState.loading();

    final result = await _chatRepository.getChatHistory(_itineraryId);
    result.fold(
      (failure) => state = ChatState.error(failure.message),
      (messages) => state = ChatState.loaded(messages, null),
    );
  }

  Future<void> sendMessage(String content) async {
    final userMessage = ChatMessage(
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      itineraryId: _itineraryId,
    );

    // Add user message to state
    final currentMessages = state.maybeWhen(
      loaded: (messages, itinerary) => messages,
      orElse: () => <ChatMessage>[],
    );

    final updatedMessages = [...currentMessages, userMessage];
    state = ChatState.loaded(updatedMessages, null);

    // Save user message
    await _chatRepository.saveMessage(userMessage);

    // Set thinking state
    state = ChatState.thinking(updatedMessages);

    // Generate AI response
    final chatHistory = updatedMessages.where((msg) => msg.isUser).toList();
    final result = await _aiService.generateItinerary(
      prompt: content,
      chatHistory: chatHistory,
    );

    result.fold(
      (failure) {
        final errorMessage = ChatMessage(
          content: failure.message,
          isUser: false,
          timestamp: DateTime.now(),
          messageType: MessageType.error,
          itineraryId: _itineraryId,
        );

        final messagesWithError = [...updatedMessages, errorMessage];
        state = ChatState.loaded(messagesWithError, null);
        _chatRepository.saveMessage(errorMessage);
      },
      (itinerary) {
        state = ChatState.loaded(updatedMessages, itinerary);
      },
    );
  }

  Future<void> refineItinerary(
    String refinementPrompt,
    Itinerary currentItinerary,
  ) async {
    final userMessage = ChatMessage(
      content: refinementPrompt,
      isUser: true,
      timestamp: DateTime.now(),
      itineraryId: _itineraryId,
    );

    final currentMessages = state.maybeWhen(
      loaded: (messages, itinerary) => messages,
      orElse: () => <ChatMessage>[],
    );

    final updatedMessages = [...currentMessages, userMessage];
    state = ChatState.thinking(updatedMessages);

    // Save user message
    await _chatRepository.saveMessage(userMessage);

    // Get refinement response
    final result = await _aiService.refineItinerary(
      prompt: refinementPrompt,
      currentItinerary: currentItinerary,
      chatHistory: currentMessages,
    );

    result.fold(
      (failure) {
        final errorMessage = ChatMessage(
          content: failure.message,
          isUser: false,
          timestamp: DateTime.now(),
          messageType: MessageType.error,
          itineraryId: _itineraryId,
        );

        final messagesWithError = [...updatedMessages, errorMessage];
        state = ChatState.loaded(messagesWithError, currentItinerary);
        _chatRepository.saveMessage(errorMessage);
      },
      (response) {
        final aiMessage = ChatMessage(
          content: response,
          isUser: false,
          timestamp: DateTime.now(),
          itineraryId: _itineraryId,
        );

        final messagesWithResponse = [...updatedMessages, aiMessage];
        state = ChatState.loaded(messagesWithResponse, currentItinerary);
        _chatRepository.saveMessage(aiMessage);
      },
    );
  }

  Future<void> regenerateLastResponse() async {
    final currentMessages = state.maybeWhen(
      loaded: (messages, itinerary) => messages,
      orElse: () => <ChatMessage>[],
    );

    if (currentMessages.isEmpty) return;

    // Remove last AI message if it exists
    final filteredMessages = currentMessages
        .where((msg) => !(msg.messageType == MessageType.error && !msg.isUser))
        .toList();

    // Find last user message
    final lastUserMessage = filteredMessages.lastWhere((msg) => msg.isUser);

    state = ChatState.thinking(filteredMessages);

    // Regenerate response
    final result = await _aiService.generateItinerary(
      prompt: lastUserMessage.content,
      chatHistory: filteredMessages.where((msg) => msg.isUser).toList(),
    );

    result.fold(
      (failure) {
        final errorMessage = ChatMessage(
          content: failure.message,
          isUser: false,
          timestamp: DateTime.now(),
          messageType: MessageType.error,
          itineraryId: _itineraryId,
        );

        final messagesWithError = [...filteredMessages, errorMessage];
        state = ChatState.loaded(messagesWithError, null);
        _chatRepository.saveMessage(errorMessage);
      },
      (itinerary) {
        state = ChatState.loaded(filteredMessages, itinerary);
      },
    );
  }

  Future<void> clearChat() async {
    await _chatRepository.clearChatHistory(_itineraryId);
    state = const ChatState.loaded([], null);
  }
}

class ChatState {
  const ChatState();

  const factory ChatState.initial() = _ChatInitial;
  const factory ChatState.loading() = _ChatLoading;
  const factory ChatState.loaded(
    List<ChatMessage> messages,
    Itinerary? itinerary,
  ) = _ChatLoaded;
  const factory ChatState.thinking(List<ChatMessage> messages) = _ChatThinking;
  const factory ChatState.error(String message) = _ChatError;

  T maybeWhen<T>({
    T Function(List<ChatMessage> messages, Itinerary? itinerary)? loaded,
    T Function(List<ChatMessage> messages)? thinking,
    T Function(String message)? error,
    T Function()? initial,
    T Function()? loading,
    required T Function() orElse,
  }) {
    if (this is _ChatLoaded && loaded != null) {
      final s = this as _ChatLoaded;
      return loaded(s.messages, s.itinerary);
    } else if (this is _ChatThinking && thinking != null) {
      final s = this as _ChatThinking;
      return thinking(s.messages);
    } else if (this is _ChatError && error != null) {
      final s = this as _ChatError;
      return error(s.message);
    } else if (this is _ChatInitial && initial != null) {
      return initial();
    } else if (this is _ChatLoading && loading != null) {
      return loading();
    }
    return orElse();
  }
}

class _ChatInitial extends ChatState {
  const _ChatInitial();
}

class _ChatLoading extends ChatState {
  const _ChatLoading();
}

class _ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final Itinerary? itinerary;
  const _ChatLoaded(this.messages, this.itinerary);
}

class _ChatThinking extends ChatState {
  final List<ChatMessage> messages;
  const _ChatThinking(this.messages);
}

class _ChatError extends ChatState {
  final String message;
  const _ChatError(this.message);
}
