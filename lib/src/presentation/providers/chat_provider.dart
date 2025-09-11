import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/ai_service_repository.dart';
import '../providers/repository_providers.dart';

import '../../core/error/failures.dart';

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String?>((
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
  final String? _itineraryId;

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

  Future<void> sendMessageStreamed(String content) async {
    final userMessage = ChatMessage(
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      itineraryId: _itineraryId,
    );

    final currentMessages = state.maybeWhen(
      loaded: (messages, itinerary) => messages,
      orElse: () => <ChatMessage>[],
    );
    final updatedMessages = [...currentMessages, userMessage];
    state = ChatState.loaded(updatedMessages, null);
    await _chatRepository.saveMessage(userMessage);

    // Add interim assistant message
    ChatMessage? interimAssistant;
    String interimContent = '';
    state = ChatState.thinking(updatedMessages);

    final chatHistory = updatedMessages.where((msg) => msg.isUser).toList();
    await for (final chunk in _aiService.streamResponse(
      prompt: content,
      chatHistory: chatHistory,
    )) {
      chunk.fold(
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
        (partial) {
          interimContent += partial;
          if (interimAssistant == null) {
            interimAssistant = ChatMessage(
              content: interimContent,
              isUser: false,
              timestamp: DateTime.now(),
              itineraryId: _itineraryId,
              messageType: MessageType.text,
            );
            final messagesWithInterim = [...updatedMessages, interimAssistant!];
            state = ChatState.thinking(
              List<ChatMessage>.from(messagesWithInterim),
            );
            _chatRepository.saveMessage(interimAssistant!);
          } else {
            interimAssistant = interimAssistant!.copyWith(
              content: interimContent,
            );
            final messagesWithInterim = [...updatedMessages, interimAssistant!];
            state = ChatState.thinking(
              List<ChatMessage>.from(messagesWithInterim),
            );
            _chatRepository.saveMessage(interimAssistant!);
          }
        },
      );
    }
    // Finalize assistant message
    if (interimAssistant != null) {
      final finalAssistant = interimAssistant!.copyWith(
        content: interimContent,
      );
      final messagesWithFinal = [...updatedMessages, finalAssistant];
      state = ChatState.loaded(messagesWithFinal, null);
      await _chatRepository.saveMessage(finalAssistant);
    }
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

    // Check connectivity for offline handling
    try {
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
            content: _getOfflineErrorMessage(failure),
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
    } catch (e) {
      final errorMessage = ChatMessage(
        content:
            'Unable to generate itinerary. Please check your internet connection and try again.',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.error,
        itineraryId: _itineraryId,
      );

      final messagesWithError = [...updatedMessages, errorMessage];
      state = ChatState.loaded(messagesWithError, null);
      _chatRepository.saveMessage(errorMessage);
    }
  }

  String _getOfflineErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'You\'re currently offline. Please check your internet connection and try again.';
    } else if (failure is ConfigurationFailure) {
      return 'Service configuration error. Please try again later.';
    } else {
      return 'Unable to generate itinerary. Please try again.';
    }
  }

  Future<void> _regenerateItineraryWithRefinement(
    Itinerary currentItinerary,
    String refinementPrompt,
  ) async {
    // Create a new prompt that includes the original itinerary and refinement
    final originalPrompt = 'Create a ${currentItinerary.days.length}-day itinerary for ${currentItinerary.title}';
    final refinedPrompt = '$originalPrompt. Refinement: $refinementPrompt';
    
    // Generate updated itinerary
    final result = await _aiService.generateItinerary(
      prompt: refinedPrompt,
      chatHistory: [],
      existingItinerary: currentItinerary,
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

        final currentMessages = state.maybeWhen(
          loaded: (messages, itinerary) => messages,
          orElse: () => <ChatMessage>[],
        );

        final messagesWithError = [...currentMessages, errorMessage];
        state = ChatState.loaded(messagesWithError, currentItinerary);
        _chatRepository.saveMessage(errorMessage);
      },
      (updatedItinerary) {
        final currentMessages = state.maybeWhen(
          loaded: (messages, itinerary) => messages,
          orElse: () => <ChatMessage>[],
        );

        state = ChatState.loaded(currentMessages, updatedItinerary);
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

        // If response contains updated plan, regenerate the itinerary
        Itinerary? updatedItinerary = currentItinerary;
        if (response.contains('updated plan') || response.contains('added')) {
          // Trigger a regeneration to get the updated itinerary
          _regenerateItineraryWithRefinement(currentItinerary, refinementPrompt);
          return;
        }

        state = ChatState.loaded(messagesWithResponse, updatedItinerary);
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
