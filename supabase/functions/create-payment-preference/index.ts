const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Pega os dados (ATUALIZADO para receber token e parcelas)
    const { 
      transaction_amount, 
      description, 
      payment_method_id, 
      payer_email,
      booking_id,
      token,
      installments,
      issuer_id
    } = await req.json()

    const mpAccessToken = Deno.env.get('MP_ACCESS_TOKEN')
    if (!mpAccessToken) throw new Error('MP_ACCESS_TOKEN não configurado.')

    // --- 2. MONTA O CORPO DO PAGAMENTO (Checkout Transparente) ---
    const paymentData = {
      transaction_amount: Number(transaction_amount),
      token: token,
      installments: installments ? Number(installments) : 1,
      issuer_id: issuer_id,
      description: description,
      payment_method_id: payment_method_id, // ex: 'pix'
      payer: {
        email: payer_email,
      },
      external_reference: booking_id,
      // (Opcional) Notification URL para Webhooks do MP avisarem o Supabase
      // notification_url: "https://seu-projeto.supabase.co/functions/v1/payment-webhook"
    }

    // --- CHAMA A API v1/payments ---
    const mpResponse = await fetch('https://api.mercadopago.com/v1/payments', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${mpAccessToken}`,
        'X-Idempotency-Key': booking_id // Evita cobrança duplicada se o usuário clicar 2x
      },
      body: JSON.stringify(paymentData),
    })

    const mpData = await mpResponse.json()

    if (!mpResponse.ok) {
      console.error('Erro MP:', mpData)
      const msg = mpData.message || 'Erro ao processar pagamento';
      throw new Error(msg)
    }

    // --- RETORNA OS DADOS PARA O FLUTTER ---
    // Se for PIX, o 'mpData' contém o 'point_of_interaction' com o QR Code.
    return new Response(
      JSON.stringify(mpData), 
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido';
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})