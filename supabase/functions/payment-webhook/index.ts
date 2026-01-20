import { createClient } from '@supabase/supabase-js'

interface WebhookPayload {
  action?: string;
  type?: string;
  data?: { id?: string };
  id?: string | number;
}

// Interface para remover o 'any' e tipar o update do banco
interface BookingUpdateData {
  transaction_id: string;
  payment_method_id: string;
  updated_at: string;
  status?: string;
  payment_status?: string;
  payment_expires_at?: null;
  app_fee?: number;
  driver_amount?: number;
}

Deno.serve(async (req: Request) => {
  try {
    const url = new URL(req.url)
    
    let body: WebhookPayload = {}
    try { 
      body = await req.json() 
    } catch (_) {
      // O body pode vir vazio em alguns handshakes do MP, ignoramos erro de parse.
    }
    
    const topic = url.searchParams.get('topic') || url.searchParams.get('type')
    const id = body.data?.id || body.id || url.searchParams.get('data.id')

    console.log(`[WEBHOOK] Recebido. Tópico: ${topic} | ID: ${id}`)

    if (!id) {
      return new Response('Ignored: No ID', { status: 200 })
    }

    const mpAccessToken = Deno.env.get('MP_ACCESS_TOKEN')
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseKey = Deno.env.get('MY_SERVICE_ROLE_KEY') || Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!mpAccessToken || !supabaseUrl || !supabaseKey) {
        return new Response('Config Error', { status: 500 })
    }

    // 1. Validar status no Mercado Pago
    const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${id}`, {
      headers: { 'Authorization': `Bearer ${mpAccessToken}` }
    })

    if (!mpResponse.ok) {
      return new Response('Payment not found in MP', { status: 200 })
    }

    const paymentData = await mpResponse.json()
    const bookingId = paymentData.external_reference
    const status = paymentData.status // approved, pending, rejected
    const transactionAmount = Number(paymentData.transaction_amount)
    
    if (!bookingId) return new Response('Ignored: No External Ref', { status: 200 })

    console.log(`[WEBHOOK] Booking: ${bookingId} | Status: ${status}`)

    // 2. Atualizar Banco de Dados
    const supabase = createClient(supabaseUrl, supabaseKey)
    
    // Inicializa objeto tipado corretamente
    const updateData: BookingUpdateData = {
      transaction_id: String(id),
      payment_method_id: paymentData.payment_method_id,
      updated_at: new Date().toISOString()
    }

    if (status === 'approved') {
      const appFee = Number((transactionAmount * 0.12).toFixed(2));
      const driverAmount = Number((transactionAmount - appFee).toFixed(2));

      updateData.status = 'confirmed';
      updateData.payment_status = 'paid';
      updateData.payment_expires_at = null;
      updateData.app_fee = appFee;
      updateData.driver_amount = driverAmount;
      
      console.log(`[FINANCEIRO] App: ${appFee}, Driver: ${driverAmount}`);
    } else if (status === 'rejected' || status === 'cancelled') {
        updateData.payment_status = 'failed';
    }

    const { error } = await supabase
        .from('bookings')
        .update(updateData)
        .eq('id', bookingId)

    if (error) {
        console.error('[DB ERROR]', error)
        return new Response('Database Error', { status: 500 })
    }

    return new Response('OK', { status: 200 })

  } catch (e) {
    console.error(e)
    return new Response('Internal Error', { status: 500 })
  }
})