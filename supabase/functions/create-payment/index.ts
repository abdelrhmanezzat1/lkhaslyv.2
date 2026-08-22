// =============================================================================
// Supabase Edge Function: create-payment
// =============================================================================
//
// REQUIRED ENVIRONMENT VARIABLES (set via `supabase secrets set`):
//   - PAYMOB_SECRET_KEY   : Your Paymob secret key (server-side only, NEVER in client code)
//   - PAYMOB_PUBLIC_KEY   : Your Paymob public key (safe for client-side use)
//   - PAYMOB_INTEGRATION_ID : Your Paymob integration ID (for card payments)
//   - PAYMOB_IFRAME_ID    : Your Paymob iframe ID
//   - SUPABASE_URL        : Your Supabase project URL
//   - SUPABASE_SERVICE_ROLE_KEY : Supabase service role key (for server-side DB access)
//
// Set them via:
//   supabase secrets set PAYMOB_SECRET_KEY=sk_live_xxx
//   supabase secrets set PAYMOB_PUBLIC_KEY=pk_live_xxx
//   supabase secrets set PAYMOB_INTEGRATION_ID=123456
//   supabase secrets set PAYMOB_IFRAME_ID=789012
//
// NEVER commit these values to git.
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

interface CreatePaymentRequest {
  order_id: string;
  amount: number; // in EGP cents (e.g. 10000 = 100.00 EGP)
}

interface PaymobAuthResponse {
  token: string;
}

interface PaymobOrderResponse {
  id: number;
  token?: string;
}

interface PaymobPaymentKeyResponse {
  token: string;
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

    // Read secrets from environment (NEVER hardcoded)
    const secretKey = Deno.env.get("PAYMOB_SECRET_KEY");
    const publicKey = Deno.env.get("PAYMOB_PUBLIC_KEY");
    const integrationId = Deno.env.get("PAYMOB_INTEGRATION_ID");
    const iframeId = Deno.env.get("PAYMOB_IFRAME_ID");

    if (!secretKey || !publicKey || !integrationId || !iframeId) {
      console.error(
        "Missing Paymob environment variables. Ensure PAYMOB_SECRET_KEY, PAYMOB_PUBLIC_KEY, PAYMOB_INTEGRATION_ID, and PAYMOB_IFRAME_ID are set via supabase secrets set."
      );
      return new Response(
        JSON.stringify({ error: "Server configuration error" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Parse request body
    const payload: CreatePaymentRequest = await req.json();

    if (!payload.order_id || !payload.amount) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: order_id, amount" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (typeof payload.amount !== "number" || payload.amount <= 0) {
      return new Response(
        JSON.stringify({ error: "amount must be a positive number (in EGP cents)" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Step 1: Authenticate with Paymob to get an auth token
    console.log("Step 1: Authenticating with Paymob...");
    const authResponse = await fetch(
      "https://accept.paymob.com/api/auth/tokens",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ api_key: secretKey }),
      }
    );

    if (!authResponse.ok) {
      const errBody = await authResponse.text();
      console.error("Paymob auth failed:", errBody);
      return new Response(
        JSON.stringify({ error: "Failed to authenticate with Paymob" }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const authData: PaymobAuthResponse = await authResponse.json();
    const authToken = authData.token;
    console.log("Paymob auth token obtained.");

    // Step 2: Create a Paymob order
    console.log("Step 2: Creating Paymob order...");
    const orderResponse = await fetch(
      "https://accept.paymob.com/api/ecommerce/orders",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          auth_token: authToken,
          delivery_needed: false,
          amount_cents: payload.amount,
          currency: "EGP",
          items: [],
          merchant_order_id: payload.order_id,
        }),
      }
    );

    if (!orderResponse.ok) {
      const errBody = await orderResponse.text();
      console.error("Paymob order creation failed:", errBody);
      return new Response(
        JSON.stringify({ error: "Failed to create Paymob order" }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const orderData: PaymobOrderResponse = await orderResponse.json();
    const paymobOrderId = orderData.id;
    console.log(`Paymob order created: ${paymobOrderId}`);

    // Step 3: Get a payment key/token for the order
    console.log("Step 3: Requesting payment key...");
    const billingData = {
      apartment: "NA",
      email: "customer@example.com",
      floor: "NA",
      first_name: "Customer",
      street: "NA",
      building: "NA",
      phone_number: "+201000000000",
      shipping_method: "NA",
      postal_code: "NA",
      city: "NA",
      country: "EG",
      last_name: "User",
      state: "NA",
    };

    const paymentKeyResponse = await fetch(
      "https://accept.paymob.com/api/acceptance/payment_keys",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          auth_token: authToken,
          amount_cents: payload.amount,
          expiration: 3600,
          order_id: paymobOrderId,
          billing_data: billingData,
          currency: "EGP",
          integration_id: parseInt(integrationId),
          lock_order_when_paid: false,
        }),
      }
    );

    if (!paymentKeyResponse.ok) {
      const errBody = await paymentKeyResponse.text();
      console.error("Paymob payment key request failed:", errBody);
      return new Response(
        JSON.stringify({ error: "Failed to get payment key from Paymob" }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const paymentKeyData: PaymobPaymentKeyResponse = await paymentKeyResponse.json();
    const paymentToken = paymentKeyData.token;
    console.log("Payment token obtained.");

    // Step 4: Construct the iframe URL using the public key (safe for client)
    const iframeUrl =
      `https://accept.paymob.com/api/acceptance/iframes/${iframeId}?payment_token=${paymentToken}`;

    // Step 5: Store the Paymob order ID on our orders table for webhook reconciliation
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    if (supabaseUrl && supabaseServiceKey) {
      try {
        const supabase = createClient(supabaseUrl, supabaseServiceKey);
        await supabase
          .from("orders")
          .update({
            paymob_order_id: paymobOrderId,
          })
          .eq("id", payload.order_id);
        console.log(
          `Stored paymob_order_id=${paymobOrderId} on order ${payload.order_id}`
        );
      } catch (dbError) {
        // Non-fatal: the payment can still proceed even if we can't store the ID
        console.error("Failed to store paymob_order_id:", dbError);
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        iframe_url: iframeUrl,
        paymob_order_id: paymobOrderId,
        payment_token: paymentToken,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Unexpected error in create-payment:", error);
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