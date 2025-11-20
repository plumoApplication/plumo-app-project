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
    const url = new URL(req.url)
    const body = await req.json().catch(() => ({}))
    const queryId = url.searchParams.get('id') || url.searchParams.get('data.id')
    
    let paymentId = queryId
    if (!paymentId && body.data && body.data.id) {
      paymentId = body.data.id
    }
    
    if (!paymentId || (body.type !== 'payment' && body.topic !== 'payment')) {
      return new Response(JSON.stringify({ message: 'Ignored' }), { headers: corsHeaders, status: 200 })
    }

    console.log(`Recebido aviso de pagamento: ${paymentId}`)

    const mpAccessToken = Deno.env.get('MP_ACCESS_TOKEN')
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!mpAccessToken || !supabaseUrl || !supabaseServiceKey) {
      throw new Error('Configurações de ambiente faltando.')
    }

    const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: {
        'Authorization': `Bearer ${mpAccessToken}`,
      },
    })

    if (!mpResponse.ok) {
      throw new Error('Erro ao consultar Mercado Pago')
    }

    const paymentData = await mpResponse.json()
    const status = paymentData.status
    const externalReference = paymentData.external_reference

    console.log(`Status do pagamento ${paymentId}: ${status}`)

    if (status === 'approved' && externalReference) {
      const supabase = createClient(supabaseUrl, supabaseServiceKey)

      const { error } = await supabase
        .from('bookings')
        .update({ 
          status: 'paid',
          payment_id: String(paymentId)
        })
        .eq('id', externalReference)

      if (error) {
        console.error('Erro ao atualizar Supabase:', error)
        // Não jogamos erro aqui para não travar o webhook do MP, apenas logamos
      } else {
        console.log(`Reserva ${externalReference} atualizada para 'paid'.`)
      }
    }

    return new Response(JSON.stringify({ message: 'OK' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    console.error(error)
    
    // 2. CORREÇÃO: Verificação de tipo do erro
    const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido';

    return new Response(JSON.stringify({ error: errorMessage }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200, // Retornamos 200 para o MP parar de tentar reenviar se for erro de lógica nossa
    })
  }
})