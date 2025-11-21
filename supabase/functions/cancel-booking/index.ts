import { createClient } from '@supabase/supabase-js'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { booking_id } = await req.json()
    
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const mpAccessToken = Deno.env.get('MP_ACCESS_TOKEN')!

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Busca dados da reserva e da viagem
    const { data: booking, error: fetchError } = await supabase
      .from('bookings')
      .select('*, trips(departure_time)')
      .eq('id', booking_id)
      .single()

    if (fetchError || !booking) {
      throw new Error('Reserva não encontrada.')
    }

    // Verifica a regra das 2 horas
    const departureTime = new Date(booking.trips.departure_time).getTime()
    const now = new Date().getTime()
    const hoursDifference = (departureTime - now) / (1000 * 60 * 60)

    let refundMessage = 'Cancelado sem reembolso (menos de 2h para a viagem).'

    // Lógica de Reembolso
    if (booking.status === 'paid' && booking.payment_id) {
      
      if (hoursDifference >= 2) {
        console.log(`Iniciando reembolso para pagamento ${booking.payment_id}`)

        const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${booking.payment_id}/refunds`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${mpAccessToken}`,
            'X-Idempotency-Key': `refund-${booking_id}`
          },
        })

        if (!mpResponse.ok) {
          const mpError = await mpResponse.json()
          console.error('Erro MP Refund:', mpError)
          throw new Error('Falha ao processar reembolso no Mercado Pago.')
        }

        refundMessage = 'Cancelado com sucesso. O valor será estornado.'
      } else {
        console.log('Cancelamento solicitado com menos de 2h. Sem reembolso.')
      }
    } else {
      refundMessage = 'Solicitação cancelada com sucesso.'
    }

    // Atualiza o status no banco
    const { error: updateError } = await supabase
      .from('bookings')
      .update({ 
        status: 'cancelled',
      })
      .eq('id', booking_id)

    if (updateError) {
      throw new Error('Erro ao atualizar status da reserva.')
    }

    return new Response(
      JSON.stringify({ success: true, message: refundMessage }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido';
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})