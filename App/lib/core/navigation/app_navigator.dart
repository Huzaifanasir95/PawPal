import 'package:flutter/material.dart';
import 'package:pawpawl/features/marketplace/presentation/pages/marketplace_screen.dart';
import 'package:pawpawl/features/marketplace/presentation/pages/orders_screen.dart';
import 'package:pawpawl/features/vet/presentation/pages/vets_list_screen.dart';
import 'package:pawpawl/features/vet/presentation/pages/vet_detail_screen.dart';
import 'package:pawpawl/features/chat/presentation/pages/chats_list_screen.dart';
import 'package:pawpawl/features/chat/presentation/pages/chat_conversation_screen.dart';
import 'package:pawpawl/features/vet/presentation/pages/vet_home_screen.dart';
import 'package:pawpawl/features/community/presentation/pages/community_hub_page.dart';

/// Navigation helper for app-wide routing
class AppNavigator {
  /// Navigate to the vets list/browse screen
  static Future<void> navigateToVetsList(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VetsListScreen()),
    );
  }

  /// Navigate to a specific vet's profile detail
  static Future<void> navigateToVetDetail(
    BuildContext context, {
    required String vetId,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VetDetailScreen(vetId: vetId),
      ),
    );
  }

  /// Navigate to the user's chats list
  static Future<void> navigateToChats(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatsListScreen()),
    );
  }

  /// Navigate to a specific chat conversation
  static Future<void> navigateToConversation(
    BuildContext context, {
    required String chatId,
    String? otherUserName,
    String? otherUserPhoto,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationScreen(
          chatId: chatId,
          otherUserName: otherUserName,
          otherUserPhoto: otherUserPhoto,
        ),
      ),
    );
  }

  /// Navigate to the vet home/dashboard screen (vets only)
  static Future<void> navigateToVetHome(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VetHomeScreen()),
    );
  }

  /// Navigate to the marketplace/pet shop screen
  static Future<void> navigateToMarketplace(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
    );
  }

  /// Navigate to the user's orders screen
  static Future<void> navigateToOrders(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrdersScreen()),
    );
  }

  /// Start a chat with a vet and navigate to conversation
  /// Returns true if chat was created successfully
  static Future<bool> startChatWithVet(
    BuildContext context, {
    required String vetId,
  }) async {
    // This will be handled by ChatBloc.startChat event
    // For now, just navigate to chats list - the actual chat creation
    // should happen in the VetDetailScreen using ChatBloc
    await navigateToChats(context);
    return true;
  }

  /// Navigate to the Community Hub (forum, lost & found, adoption, events)
  static Future<void> navigateToCommunityHub(
    BuildContext context, {
    int initialTabIndex = 0,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CommunityHubPage(initialTabIndex: initialTabIndex),
      ),
    );
  }

  /// Pop back to previous screen
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  /// Pop until reaching a specific route predicate
  static void popUntil(BuildContext context, bool Function(Route) predicate) {
    Navigator.popUntil(context, predicate);
  }

  /// Pop to root/home screen
  static void popToRoot(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
