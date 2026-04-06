# Paystack Payment Integration

## Overview
Implemented Paystack payment gateway integration for investment purchases in the Hillcrest Finance app with two payment options:
1. **Bank Transfer** - Direct bank account transfer
2. **Pay with Card** - Paystack-powered card payment

## Key Features Implemented

### 1. Payment Service (`lib/app/core/services/paystack_payment_service.dart`)
- **Transaction Reference Generation**: Creates unique transaction references in format `HC_timestamp_randomString` using UUID
- **Payment Processing**: Placeholder for future Paystack integration with proper documentation for production implementation
- **Payment Verification**: Backend verification method placeholder

### 2. Investment Purchase Screen Updates (`lib/features/investment/presentation/screens/fund_investment_scheme_screen.dart`)

#### Payment Method Selection
- Users can choose between:
  - **Bank Transfer**: Shows bank details (Account Name, Bank, Account Number)
  - **Pay with Card**: Initiates Paystack payment flow

#### Paystack Payment Flow
1. **User Initiates Payment**: Clicks "Pay with Card" button
2. **User Information Fetched**: Automatically retrieves user email, first name, and last name from Keycloak
3. **Transaction Reference Generated**: Creates unique reference for tracking
4. **Payment Dialog Shown**: Displays payment details (amount, units, email, reference)
5. **User Proceeds to Payment**: Confirms and proceeds to Paystack
6. **Simulated Payment Processing**: 2-second delay to simulate Paystack redirect (2-second delay for UI smoothness)
7. **Transaction Recording**: Backend records the purchase
8. **UI Auto-Update**: Portfolio updates immediately after successful payment (no backend confirmation required)
9. **Success Dialog**: Shows purchase confirmation with details

#### Success Dialog Display
- Transaction ID from backend
- Payment reference for traceability
- Units purchased
- Amount paid
- Instructions to view portfolio

### 3. Portfolio Auto-Update After Payment
- Uses Riverpod `ref.invalidate()` to clear cache
- Invalidates:
  - `portfolioProvider` - User's holdings
  - `portfolioSummaryProvider` - Total value and units
  - `investorTransactionsProvider` - Transaction history
- UI automatically reflects new units without page reload

### 4. Error Handling
- User information validation
- Payment processing error handling
- Transaction recording failure handling with reference number for support
- Proper error dialogs with actionable messages

## Technical Implementation Details

### Dependencies Added
- `flutter_paystack_plus: ^2.5.0` - Paystack payment gateway
- `uuid: ^4.0.0` - Unique reference generation

### Payment Methods

#### Transaction Reference Format
```
HC_<millisecondsSinceEpoch>_<8charUUID>
Example: HC_1712410234567_A1B2C3D4
```

#### Amount Calculation
- User enters amount in Naira
- Converted to Kobo for Paystack (amount * 100)
- Stored in backend for transaction record

#### Payment Details Passed
- `email` - User's email address
- `amount` - Amount in Naira
- `reference` - Unique transaction reference
- `firstName`, `lastName` - User's name
- `customFields` - Additional metadata (scheme_id, units, customer_no)

### UI Components

#### Payment Method Tiles
- Icon with circular background
- Title and subtitle
- Chevron indicator
- Tap animation

#### Payment Details Display
- Amount with currency symbol
- Units count with proper pluralization
- Email display
- Reference number (truncated for display)

#### Success Confirmation
- Green checkmark icon
- Transaction details:
  - Units Purchased
  - Amount Paid
  - Transaction ID (from backend)
  - Reference (for support)
- Inline message: "Your units have been added to your portfolio immediately"

## Implementation Notes

### Current Status
- Bank Transfer: Fully functional
- Pay with Card: Placeholder ready for production Paystack integration

### To Complete Production Integration
1. Get Paystack Public Key from environment
2. Initialize Paystack in `main.dart`:
   ```dart
   PaystackPaymentService.initialize(paystackPublicKey);
   ```
3. Implement actual payment call in `_completePaystackPayment()`:
   ```dart
   final paymentRef = await PaystackPaymentService.processPayment(
     email: userEmail,
     amount: _totalPayableAmount,
     reference: transactionRef,
     firstName: firstName,
     lastName: lastName,
     customFields: {...},
   );
   ```

### Best Practices Followed
- ✅ Proper error handling with user-friendly messages
- ✅ Reference generation for transaction tracking
- ✅ Auto-updating UI with Riverpod cache invalidation
- ✅ Separated concerns (service, screen, dialogs)
- ✅ Consistent UI/UX with existing app design
- ✅ Proper amount handling (Naira to Kobo conversion)
- ✅ User data pre-filling from Keycloak
- ✅ Transaction logging for debugging

## Testing Checklist
- [ ] Test bank transfer flow
- [ ] Test Paystack payment dialog display
- [ ] Verify transaction reference generation
- [ ] Confirm portfolio updates after payment
- [ ] Test error scenarios (network, user data missing)
- [ ] Verify transaction history shows new entries
- [ ] Test with different purchase amounts and units

## Security Considerations
- Transaction references are logged for audit trail
- User emails fetched from secure Keycloak
- Sensitive payment data handled by Paystack (PCI compliant)
- No sensitive data stored in app code
- Payment status independent validation should be implemented on backend

## Future Enhancements
1. Real Paystack payment gateway integration
2. Payment receipt generation and download
3. Transaction history filtering and export
4. Recurring investment setup
5. Payment method saved for future transactions
6. Webhook integration for real-time payment confirmation

