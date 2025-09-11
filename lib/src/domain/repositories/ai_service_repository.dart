import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/itinerary.dart';
import '../entities/chat_message.dart';

abstract class AIServiceRepository {
  Future<Either<Failure, Itinerary>> generateItinerary({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  });
  
  Future<Either<Failure, String>> refineItinerary({
    required String prompt,
    required Itinerary currentItinerary,
    required List<ChatMessage> chatHistory,
  });
  
  Stream<Either<Failure, String>> streamResponse({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  });
  
}
