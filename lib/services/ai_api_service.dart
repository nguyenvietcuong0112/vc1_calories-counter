
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/services.dart'; // Required for PlatformException

class AiApiService {
  final GenerativeModel _model;

  AiApiService(this._model);

  // A specific error message for quota issues
  static const String quotaExceededMessage =
      'The service is temporarily unavailable due to high demand. Please try again later.';

  Future<String> generateHealthTip() async {
    try {
      final response = await _model.generateContent([Content.text(
          'Generate a short, actionable health tip of the day. For example: "Don\'t forget to drink at least 8 glasses of water today to stay hydrated."')]);
      return response.text ?? 'Could not generate a health tip at this moment.';
    } on PlatformException catch (e) {
      if (e.message?.contains('resource-exhausted') ?? false) {
        return quotaExceededMessage;
      }
      return 'Error generating health tip: ${e.message}';
    }
    catch (e) {
      return 'Error generating health tip: ${e.toString()}';
    }
  }

  Future<String> getChatResponse(String prompt) async {
    if (prompt.isEmpty) {
      return 'Please provide a prompt.';
    }
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response from model.';
    } on PlatformException catch (e) {
      // Check if the error message contains the resource exhausted code.
      if (e.message?.contains('resource-exhausted') ?? false) {
        return quotaExceededMessage;
      }
      return 'Error getting response: ${e.message}';
    }
    catch (e) {
      return 'Error getting response: ${e.toString()}';
    }
  }

  Future<String> predictWeight(Map<String, dynamic> userProfile) async {
    final prompt = 'Based on the following user profile, predict their weight in 30 days. ' 
                   'User Profile: $userProfile. ' 
                   'Return only the predicted weight as a string, e.g., "78 kg".';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Could not predict weight at this moment.';
    } on PlatformException catch (e) {
      if (e.message?.contains('resource-exhausted') ?? false) {
        return quotaExceededMessage;
      }
      return 'Error predicting weight: ${e.message}';
    }
    catch (e) {
      return 'Error predicting weight: ${e.toString()}';
    }
  }

  Future<String> analyzeDiet(String foodLog) async {
    final prompt = 'Analyze the following daily food log (in JSON format). \n'
        'Food Log: $foodLog\n'
        'Calculate the total calories, protein, carbs, and fat. \n'
        'Provide feedback on whether the user met their calorie goals (assuming a 2000 calorie goal). \n'
        'Offer actionable suggestions for improvement. \n'
        'Return the analysis as a formatted string.';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Could not analyze diet at this moment.';
    } on PlatformException catch (e) {
      if (e.message?.contains('resource-exhausted') ?? false) {
        return quotaExceededMessage;
      }
      return 'Error analyzing diet: ${e.message}';
    }
    catch (e) {
      return 'Error analyzing diet: ${e.toString()}';
    }
  }

  Future<String> generateMealPlan(Map<String, dynamic> userProfile, int days) async {
    final prompt = 'Generate a meal plan for $days day(s) based on the following user profile: \n'
        'User Profile: $userProfile\n'
        'The meal plan should include breakfast, lunch, dinner, and snacks. \n'
        'For each meal, provide the food item and its approximate calories, protein, carbs, and fat. \n'
        'The total daily calories should align with the user\'s goal. \n'
        'Return the meal plan as a JSON object where keys are day numbers and values are meal details.';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Could not generate a meal plan at this moment.';
    } on PlatformException catch (e) {
      if (e.message?.contains('resource-exhausted') ?? false) {
        return quotaExceededMessage;
      }
      return 'Error generating meal plan: ${e.message}';
    }
    catch (e) {
      return 'Error generating meal plan: ${e.toString()}';
    }
  }
}
