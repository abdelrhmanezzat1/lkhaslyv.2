// =============================================================================
// Supabase Edge Function: paymob-webhook
// =============================================================================
//
// REQUIRED ENVIRONMENT VARIABLES (set via `supabase secrets set`):
//   - PAYMOB_HMAC_KEY     : Your Paymob HMAC secret key (server-side only, NEVER in client code)
//   - SUPABASE_URL        : Your Supabase project URL
//   - SUPABASE_SERVICE_ROLE_KEY : Supabase service role key (for server-side DB access)
//
// Set them via:
//   supabase secrets set PAYMOB_HMAC_KEY=your_hmac_secret_here
//
// NEVER commit these values to git.
//
// REGISTER THIS WEBHOOK IN THE PAYMOB DASHBOARD:
//   Go to Paymob Dashboard → Settings → Webhooks
//   Add the URL: https://<your-project-ref>.supabase.co/functions/v1/paymob-webhook
//   Select "Transaction Processed Callback" event type.
// =============================================================================

// @ts-nocheck: This file runs in the Deno runtime (Supabase Edge Functions).
// Deno globals (Deno.env, etc.) and bare specifiers are resolved at runtime.
// @ts-ignore: Deno std module resolved at runtime
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
// @ts-ignore: npm module resolved at runtime via esm.sh
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Paymob webhook payload structure (transaction processed callback)
interface PaymobWebhookPayload {
  obj: {
    id: number;
    order: {
      id: number;
      merchant_order_id: string; // our internal order ID
    };
    amount_cents: number;
    created_at: string;
    currency: string;
    success: boolean | string;
    pending: boolean | string;
    is_void: boolean;
    is_refunded: boolean;
    is_voided: boolean;
    is_auth: boolean;
    is_capture: boolean;
    is_standalone_payment: boolean;
    is_3d_secure: boolean;
    has_parent: boolean;
    error_occured: boolean | string;
    integration_id: number;
    hmac: string;
    owner?: number;
    source_data?: {
      pan?: string;
      sub_type?: string;
      type?: string;
    };
    // Additional fields Paymob may send
    [key: string]: unknown;
  };
  type: string;
}

/**
 * Verifies the HMAC signature from Paymob's webhook payload.
 *
 * Paymob's documented HMAC calculation:
 *   HMAC-SHA512(
 *     key = PAYMOB_HMAC_KEY,
 *     message = amount_cents + created_at + currency + error_occured + has_parent + id + integration_id + is_3d_secure + is_auth + is_capture + is_refunded + is_standalone_payment + is_voided + order.id + owner + pending + source_data_pan + source_data_sub_type + source_data_type + success
 *   )
 *
 * All values are concatenated as strings (no separators).
 */
async function verifyHmac(
  payload: PaymobWebhookPayload,
  hmacKey: string
): Promise<boolean> {
  try {
    const obj = payload.obj;

    // Build the HMAC message string following Paymob's documented order:
    // amount_cents + created_at + currency + error_occured + has_parent + id +
    // integration_id + is_3d_secure + is_auth + is_capture + is_refunded +
    // is_standalone_payment + is_voided + order.id + owner + pending +
    // source_data_pan + source_data_sub_type + source_data_type + success
    const messageParts: string[] = [
      String(obj.amount_cents),
      String(obj.created_at),
      String(obj.currency),
      String(obj.error_occured ?? ""),
      String(obj.has_parent ?? false),
      String(obj.id),
      String(obj.integration_id ?? ""),
      String(obj.is_3d_secure ?? false),
      String(obj.is_auth ?? false),
      String(obj.is_capture ?? false),
      String(obj.is_refunded ?? false),
      String(obj.is_standalone_payment ?? false),
      String(obj.is_voided ?? false),
      String(obj.order?.id ?? ""),
      String(obj.owner ?? ""),
      String(obj.pending ?? ""),
      String(obj.source_data?.pan ?? ""),
      String(obj.source_data?.sub_type ?? ""),
      String(obj.source_data?.type ?? ""),
      String(obj.success),
    ];

    const message = messageParts.join("");

    // Compute HMAC-SHA512
    const encoder = new TextEncoder();
    const keyData = encoder.encode(hmacKey);
    const messageData = encoder.encode(message);

    const cryptoKey = await crypto.subtle.importKey(
      "raw",
      keyData,
      { name: "HMAC", hash: "SHA-512" },
      false,
      ["sign"]
    );

    const signature = await crypto.subtle.sign(
      "HMAC",
      cryptoKey,
      messageData
    );

    // Convert signature to hex string
    const signatureArray = Array.from(new Uint8Array(signature));
    const computedHmac = signatureArray
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");

    const receivedHmac = obj.hmac ?? "";

    console.log("HMAC verification:");
    console.log("  Message:", message);
    console.log("  Computed HMAC:", computedHmac);
    console.log("  Received HMAC:", receivedHmac);

    // Constant-time comparison to prevent timing attacks
    return timingSafeEqual(computedHmac, receivedHmac);
  } catch (error) {
    console.error("HMAC verification error:", error);
    return false;
  }
}

/**
 * Constant-time string comparison to prevent timing attacks.
 */
function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) {
    return false;
  }
  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return result === 0;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Only accept POST
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed. Use POST." }),
        {
          status: 405,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Read HMAC key from environment (NEVER hardcoded)
    const hmacKey = Deno.env.get("PAYMOB_HMAC_KEY");
    if (!hmacKey) {
      console.error(
        "Missing PAYMOB_HMAC_KEY environment variable. Set it via: supabase secrets set PAYMOB_HMAC_KEY=your_hmac_secret"
      );
      return new Response(
        JSON.stringify({ error: "Server configuration error" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Parse the webhook payload
    const payload: PaymobWebhookPayload = await req.json();

    console.log("Received Paymob webhook:", JSON.stringify(payload));

    // Verify HMAC signature
    const isValid = await verifyHmac(payload, hmacKey);

    if (!isValid) {
      console.warn(
        "⚠️ INVALID HMAC SIGNATURE — potential spoofed webhook request. " +
        "Request body:",
        JSON.stringify(payload)
      );
      return new Response(
        JSON.stringify({ error: "Invalid HMAC signature" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    console.log("HMAC signature verified successfully.");

    // Check if the transaction was successful
    const obj = payload.obj;
    const isSuccess = obj.success === true || String(obj.success) === "true";

    if (!isSuccess) {
      console.log(
        `Transaction ${obj.id} was not successful (success=${obj.success}). No action taken.`
      );
      return new Response(
        JSON.stringify({ message: "Transaction not successful, no action taken" }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Get our internal order ID from the merchant_order_id
    const merchantOrderId = obj.order?.merchant_order_id;
    if (!merchantOrderId) {
      console.error(
        "No merchant_order_id found in webhook payload. Cannot update order."
      );
      return new Response(
        JSON.stringify({ error: "Missing merchant_order_id" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    console.log(
      `Transaction successful. Updating order ${merchantOrderId} to paid...`
    );

    // Update the order in Supabase
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error(
        "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables."
      );
      return new Response(
        JSON.stringify({ error: "Server configuration error" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Update the order: set payment_status to 'paid', status to 'paid',
    // and record the payment method as 'card' (Paymob)
    const { error: updateError } = await supabase
      .from("orders")
      .update({
        status: "paid",
        payment_status: "paid",
        payment_method: "card",
        completed_at: new Date().toISOString(),
        paymob_transaction_id: obj.id,
      })
      .eq("id", merchantOrderId);

    if (updateError) {
      console.error(
        `Failed to update order ${merchantOrderId}:`,
        updateError
      );
      return new Response(
        JSON.stringify({
          error: "Failed to update order",
          details: updateError.message,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    console.log(
      `Order ${merchantOrderId} successfully marked as paid via Paymob webhook.`
    );

    // Note: The technician mirror logic (completeOrderAfterPayment) is handled
    // client-side in the Flutter app via PayOrderUseCase. The webhook only
    // updates the database record. The client app will pick up the change
    // when it polls/refreshes the order status.

    return new Response(
      JSON.stringify({
        success: true,
        message: `Order ${merchantOrderId} marked as paid`,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Unexpected error in paymob-webhook:", error);
    return new Response(
      JSON.stringify({
        error: "Internal server error",
        details: error instanceof Error ? error.message : String(error),
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});