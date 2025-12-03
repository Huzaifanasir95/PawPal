import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorHandler {
  static String handleErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email address.';
        case 'wrong-password':
          return 'Invalid credentials. Please check your password.';
        case 'invalid-credential':
          return 'Invalid credentials. Please check your email and password.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled. Please contact support.';
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'weak-password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'requires-recent-login':
          return 'Please log out and log back in to perform this action.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'timeout':
          return 'Request timed out. Please try again.';
        case 'expired-action-code':
          return 'This link has expired. Please request a new one.';
        case 'invalid-action-code':
          return 'Invalid or expired link. Please request a new one.';
        case 'missing-email':
          return 'Please enter your email address.';
        case 'missing-password':
          return 'Please enter your password.';
        case 'account-exists-with-different-credential':
          return 'An account with this email already exists with a different sign-in method.';
        case 'credential-already-in-use':
          return 'This credential is already associated with another account.';
        case 'invalid-verification-code':
          return 'Invalid verification code. Please try again.';
        case 'invalid-verification-id':
          return 'Invalid verification ID. Please try again.';
        case 'app-deleted':
          return 'This Firebase app has been deleted.';
        case 'app-not-authorized':
          return 'This app is not authorized to use Firebase Authentication.';
        case 'argument-error':
          return 'Invalid argument provided.';
        case 'invalid-api-key':
          return 'Invalid API key provided.';
        case 'invalid-user-token':
          return 'Your authentication token is invalid. Please sign in again.';
        case 'user-token-expired':
          return 'Your authentication token has expired. Please sign in again.';
        case 'null-user':
          return 'No user is currently signed in.';
        case 'internal-error':
          return 'An internal error occurred. Please try again.';
        default:
          // Always check for 'email already in use' in the error message as well
          final msg = error.message ?? '';
          if (msg.toLowerCase().contains('email already in use') ||
              msg.toLowerCase().contains('email address is already') ||
              msg.toLowerCase().contains('the email address is already in use by another account.')) {
            return 'An account with this email already exists.';
          }
          // Check the error message for additional context
          return _parseErrorMessage(msg.isNotEmpty ? msg : 'An error occurred. Please try again.');
      }
    }
    
    // Handle other types of errors by parsing the message
    return _parseErrorMessage(error.toString());
  }

  static String _parseErrorMessage(String errorMessage) {
    String lowerMessage = errorMessage.toLowerCase();
    
    // Handle specific Firebase error messages
    if (lowerMessage.contains('auth credential is incorrect') || 
        lowerMessage.contains('malformed') || 
        lowerMessage.contains('has expired') ||
        lowerMessage.contains('supplied auth credential')) {
      return 'Invalid credentials. Please check your email and password.';
    }
    
    if (lowerMessage.contains('user not found') || lowerMessage.contains('no user record')) {
      return 'No account found with this email address.';
    }
    
    if (lowerMessage.contains('wrong password') || lowerMessage.contains('incorrect password')) {
      return 'Invalid credentials. Please check your password.';
    }
    
    if (lowerMessage.contains('email already in use') ||
        lowerMessage.contains('email address is already') ||
        lowerMessage.contains('the email address is already in use by another account.')) {
      return 'An account with this email already exists.';
    }

    if (lowerMessage.contains('header x-firebase-locale because its value was null')) {
      return 'An internal error occurred. Please try again.';
    }
    
    if (lowerMessage.contains('weak password') || lowerMessage.contains('password should be at least')) {
      return 'Password is too weak. Please choose a stronger password.';
    }
    
    if (lowerMessage.contains('invalid email') || lowerMessage.contains('badly formatted email')) {
      return 'Please enter a valid email address.';
    }
    
    if (lowerMessage.contains('too many requests') || lowerMessage.contains('blocked due to unusual activity')) {
      return 'Too many failed attempts. Please try again later.';
    }
    
    if (lowerMessage.contains('network') || lowerMessage.contains('connection') || lowerMessage.contains('unreachable')) {
      return 'Network error. Please check your internet connection.';
    }
    
    if (lowerMessage.contains('timeout') || lowerMessage.contains('deadline exceeded')) {
      return 'Request timed out. Please try again.';
    }
    
    if (lowerMessage.contains('user disabled') || lowerMessage.contains('account has been disabled')) {
      return 'This account has been disabled. Please contact support.';
    }
    
    if (lowerMessage.contains('operation not allowed') || lowerMessage.contains('sign-in method')) {
      return 'This sign-in method is not enabled. Please contact support.';
    }
    
    if (lowerMessage.contains('recaptcha') || lowerMessage.contains('captcha')) {
      return 'Security verification failed. Please try again.';
    }
    
    if (lowerMessage.contains('quota exceeded') || lowerMessage.contains('limit exceeded')) {
      return 'Service limit exceeded. Please try again later.';
    }
    
    // Default fallback for unknown errors
    return 'An unexpected error occurred. Please try again.';
  }
}