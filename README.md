# flutter_application_1

A Flutter application with Supabase backend, Paymob payment integration, and push notifications.

## Getting Started

This project is a Flutter application with the following key features:
- User authentication (Supabase Auth)
- Car service management
- Order placement and tracking
- Payment processing via Paymob (card) and cash/wallet
- Push notifications (Firebase Cloud Messaging)
- Technician job management

### Prerequisites

- Flutter SDK ^3.12.2
- Supabase project (with Edge Functions enabled)
- Paymob merchant account
- Firebase project (for push notifications)

### Local Development

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## Paymob Payment Integration — Deployment Guide

This project integrates Paymob for card payments using two Supabase Edge Functions and a Flutter WebView-based payment screen.

### Architecture Overview

```
Flutter App (payment_screen)
    │
    │  POST { order_id, amount }
    ▼
Supabase Edge Function: create-payment
    │
    │  Paymob API calls: /auth/tokens → /ecommerce/orders → /payment_keys
    ▼
Returns iframe URL + payment token
    │
    ▼
Flutter WebView loads Paymob iframe
    │
    │  User completes payment in iframe
    ▼
Paymob sends webhook → Supabase Edge Function: paymob-webhook
    │
    │  Verifies HMAC signature
    │  Updates order status → 'paid'
    ▼
Flutter polls order status → navigates away on success
```

### Files Created/Changed

| File | Action | Description |
|------|--------|-------------|
| `supabase/functions/create-payment/index.ts` | **Created** | Edge Function: authenticates with Paymob, creates order, returns iframe URL |
| `supabase/functions/paymob-webhook/index.ts` | **Created** | Edge Function: receives Paymob transaction callback, verifies HMAC, updates order status |
| `lib/features/orders/presentation/payment_screen.dart` | **Modified** | Added card payment flow via Edge Function + WebView |
| `pubspec.yaml` | **Modified** | Added `webview_flutter: ^4.10.0` dependency |

### Step 1: Set Supabase Secrets

Run these commands from the project root to set the required environment variables for the Edge Functions:

```bash
# For create-payment function
supabase secrets set PAYMOB_SECRET_KEY=sk_live_xxxxxxxxxxxxx
supabase secrets set PAYMOB_PUBLIC_KEY=pk_live_xxxxxxxxxxxxx
supabase secrets set PAYMOB_INTEGRATION_ID=123456
supabase secrets set PAYMOB_IFRAME_ID=789012

# For paymob-webhook function
supabase secrets set PAYMOB_HMAC_KEY=your_hmac_secret_from_paymob_dashboard

# Supabase connection (may already be set)
supabase secrets set SUPABASE_URL=https://your-project.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=sb_secret_xxxxxxxxxxxxx
```

> **Security**: Never commit these values to git. They are stored encrypted in Supabase and injected at runtime.

### Step 2: Deploy Edge Functions

```bash
# Deploy both functions
supabase functions deploy create-payment
supabase functions deploy paymob-webhook

# Verify deployment
supabase functions list
```

### Step 3: Configure Paymob Webhook

1. Log in to your [Paymob Dashboard](https://accept.paymob.com/portal/)
2. Navigate to **Settings → Webhooks**
3. Add a new webhook with:
   - **URL:** `https://<your-project-ref>.supabase.co/functions/v1/paymob-webhook`
   - **Event:** Transaction Processed Callback
4. Copy the HMAC secret from the webhook configuration and set it as `PAYMOB_HMAC_KEY` (see Step 1)

### Step 4: Database Schema

Ensure the `orders` table has the following columns for payment tracking:

| Column | Type | Description |
|--------|------|-------------|
| `payment_status` | `text` | Tracks payment state: `pending`, `paid`, `failed` |
| `payment_method` | `text` | Method used: `card`, `cash`, `wallet` |
| `paymob_order_id` | `text` | Paymob's internal order ID (set by `create-payment`) |
| `paymob_transaction_id` | `text` | Paymob's transaction ID (set by `paymob-webhook`) |
| `completed_at` | `timestamptz` | Timestamp when payment was completed |

### Step 5: Test the Integration

1. **Test the Edge Function directly:**
   ```bash
   curl -X POST https://<your-project>.supabase.co/functions/v1/create-payment \
     -H "Authorization: Bearer <anon-key>" \
     -H "Content-Type: application/json" \
     -d '{"order_id": "test-order-id", "amount": 10000}'
   ```

2. **Test the webhook locally:**
   ```bash
   supabase functions serve paymob-webhook --env-file .env.local
   ```

3. **End-to-end test:**
   - Launch the Flutter app
   - Create an order
   - Navigate to the payment screen
   - Select "Card" payment method
   - Complete payment in the Paymob iframe
   - Verify the order status updates to `paid`

### Payment Flow Details

1. User selects "Card" payment on the payment screen
2. Flutter calls `create-payment` Edge Function with `order_id` and `amount`
3. Edge Function authenticates with Paymob, creates a Paymob order, and returns an iframe URL
4. Flutter opens the iframe URL in a WebView
5. User completes payment in the Paymob iframe
6. Paymob sends a webhook to `paymob-webhook` Edge Function
7. Webhook verifies the HMAC signature, then updates the order status to `paid`
8. Flutter polls the order status and navigates away on success

### Troubleshooting

| Issue | Solution |
|-------|----------|
| Edge Function returns 500 | Check `supabase secrets list` — ensure all required secrets are set |
| HMAC verification fails | Verify `PAYMOB_HMAC_KEY` matches the secret in Paymob dashboard |
| WebView doesn't load | Ensure `webview_flutter` is in `pubspec.yaml` and `flutter pub get` was run |
| Order not updating after payment | Check webhook URL is correctly registered in Paymob dashboard |
| CORS errors | Edge Functions include CORS headers; verify the function is deployed correctly |
