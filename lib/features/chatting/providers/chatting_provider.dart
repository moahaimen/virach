import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../chatting/models/chatting_model.dart';
import '../services/api_client.dart'; // Make sure this is your correct path

class ChattingRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;

  ChattingRetroDisplayGetProvider(String token) {
    Dio dio = Dio();
    dio.options.headers["Authorization"] = "JWT $token";
    _apiClient = ApiClient(dio);
  }

  Future<List<ChattingModel>> fetchMessages({
    required String currentUserId, // Pass current user ID dynamically
    required String doctorId, // Pass doctor ID dynamically
  }) async {
    try {
      print(
          "Fetching messages for sender: $currentUserId and receiver: $doctorId");

      // Call the API and fetch the raw response
      final List<dynamic> response = await _apiClient.getMessages({
        "sender": currentUserId,
        "receiver": doctorId,
      });

      // Print raw response for debugging
      print("Raw API Response: $response");

      // Parse the response into a list of ChattingModel objects
      List<ChattingModel> messages = response
          .map((json) => ChattingModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Print parsed messages for debugging
      print("Parsed Messages: ${messages.map((m) => m.toJson()).toList()}");

      return messages;
    } catch (e, stackTrace) {
      print("Error fetching messages: $e");
      print("Stack trace: $stackTrace");
      return [];
    }
  }

  Future<ChattingModel?> sendMessage({
    required String messageText, // Message content
    required String currentUserId, // Pass current user ID dynamically
    required String doctorId, // Pass doctor ID dynamically
  }) async {
    try {
      // Construct the message payload
      final message = {
        "sender":
            "f565f1ff-51ea-4832-b0d3-7e1bd9f87976", // Current user as sender
        "receiver": doctorId, // Current doctor as receiver
        "message_text": messageText,
      };

      print("Sending message with payload: $message");

      // Send the message via the API
      ChattingModel response = await _apiClient.sendMessage(message);

      print("Message sent successfully: ${response.toJson()}");
      return response;
    } catch (e) {
      print("Error sending message: $e");
      return null;
    }
  }
}
