import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';

enum PaystackPaymentStatus { success, cancelled, failed }

class PaystackPaymentOutcome {
  final PaystackPaymentStatus status;
  final String reference;
  final String? message;

  const PaystackPaymentOutcome({
    required this.status,
    required this.reference,
    this.message,
  });

  bool get isSuccess => status == PaystackPaymentStatus.success;
}

/// Service for handling Paystack payment processing
class PaystackPaymentService {
  /// Generates reference required by Paystack.
  /// Requested format: DateTime.now().millisecondsSinceEpoch.toString()
  static String generateTransactionReference() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Opens Paystack built-in checkout popup.
  ///
  /// Required env values:
  /// - PAYSTACK_PUBLIC_KEY
  /// - PAYSTACK_SECRET_KEY
  static Future<PaystackPaymentOutcome> processPayment({
    required BuildContext context,
    required int units,
    required double unitPrice,
    required String email,
    String? reference,
  }) async {
    try {
      final amountInKobo = ((units * unitPrice) * 100).round();
      final transactionReference = reference ?? generateTransactionReference();

      if (amountInKobo <= 0) {
        return PaystackPaymentOutcome(
          status: PaystackPaymentStatus.failed,
          reference: transactionReference,
          message: 'Invalid amount. Please enter valid units and unit price.',
        );
      }

      final publicKey = dotenv.env['PAYSTACK_PUBLIC_KEY']?.trim();
      final secretKey = dotenv.env['PAYSTACK_SECRET_KEY']?.trim();
      const callbackUrl = 'https://google.com';

      if (publicKey == null || publicKey.isEmpty) {
        return PaystackPaymentOutcome(
          status: PaystackPaymentStatus.failed,
          reference: transactionReference,
          message: 'PAYSTACK_PUBLIC_KEY is missing in .env',
        );
      }

      if (secretKey == null || secretKey.isEmpty) {
        return PaystackPaymentOutcome(
          status: PaystackPaymentStatus.failed,
          reference: transactionReference,
          message: 'PAYSTACK_SECRET_KEY is missing in .env',
        );
      }

      final completer = Completer<PaystackPaymentOutcome>();

      print('💳 [PAYSTACK] Processing payment:');
      print('   Email: $email');
      print('   Units: $units');
      print('   Unit Price: ₦$unitPrice');
      print('   Total Kobo: $amountInKobo');
      print('   Reference: $transactionReference');

      await FlutterPaystackPlus.openPaystackPopup(
        context: context,
        customerEmail: email,
        amount: amountInKobo.toString(),
        reference: transactionReference,
        currency: 'NGN',
        callBackUrl: callbackUrl,
        publicKey: publicKey,
        secretKey: secretKey,
        onSuccess: () {
          if (!completer.isCompleted) {
            completer.complete(
              PaystackPaymentOutcome(
                status: PaystackPaymentStatus.success,
                reference: transactionReference,
              ),
            );
          }
        },
        onClosed: () {
          if (!completer.isCompleted) {
            completer.complete(
              PaystackPaymentOutcome(
                status: PaystackPaymentStatus.cancelled,
                reference: transactionReference,
                message: 'Payment was cancelled or not completed.',
              ),
            );
          }
        },
      );

      final outcome = await completer.future.timeout(
        const Duration(minutes: 10),
        onTimeout: () => PaystackPaymentOutcome(
          status: PaystackPaymentStatus.failed,
          reference: transactionReference,
          message: 'Timed out waiting for payment result.',
        ),
      );

      return outcome;
    } catch (e) {
      print('❌ [PAYSTACK] Error during payment: $e');
      return PaystackPaymentOutcome(
        status: PaystackPaymentStatus.failed,
        reference: reference ?? generateTransactionReference(),
        message: e.toString(),
      );
    }
  }

  /// Verify a payment with Paystack (Backend responsibility)
  /// Returns true if payment is verified
  static Future<bool> verifyPaymentOnBackend({
    required String reference,
  }) async {
    try {
      print('🔍 [PAYSTACK] Verifying payment reference: $reference');

      // In production, your backend would:
      // 1. Call Paystack API: GET /transaction/verify/$reference
      // 2. Check if status is 'success'
      // 3. Return verification result

      return true; // Placeholder
    } catch (e) {
      print('❌ [PAYSTACK] Verification error: $e');
      return false;
    }
  }
}



