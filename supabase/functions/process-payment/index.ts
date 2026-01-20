import { createClient } from '@supabase/supabase-js'

// --- Interfaces (Contrato de Dados) ---

interface IncomingBody {
  booking_id: string;
  payment_method_id: string; // 'pix', 'visa', 'master', etc.
  payer_email: string;
  token?: string;            // Obrigatório para Cartão
  installments?: number;     // Obrigatório para Cartão
  issuer_id?: string;        // Banco emissor (Cartão)
  doc_number?: string;       // CPF do pagador (Melhora aprovação)
}

interface MercadoPagoPayload {
  transaction_amount: number;
  description: string;
  payment_method_id: string;
  external_reference: string;
  payer: {
    email: string;
    first_name?: string;
    identification?: {
      type: string;
      number: string;
    };
  };
  token?: string;
  installments?: number;
  issuer_id?: number;
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req: Request) => {
  // 1. Pre-flight CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body = await req.json() as IncomingBody;
    const { 
      booking_id, 
      payment_method_id, 
      payer_email, 
      token, 
      installments, 
      issuer_id, 
      doc_number 
    } = body

    console.log(`[PROCESS-PAYMENT] Iniciando. ID: ${booking_id} | Método: ${payment_method_id}`)

    // 2. Validação de Variáveis de Ambiente
    const mpAccessToken = Deno.env.get('MP_ACCESS_TOKEN')
    if (mpAccessToken) {
      console.log(`[DEBUG TOKEN] Tamanho: ${mpAccessToken.length}, Começa com: ${mpAccessToken.substring(0, 5)}...`)
    } else {
      console.error('[DEBUG TOKEN] O Token está NULL ou VAZIO!')
    }
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    // Usa MY_SERVICE_ROLE_KEY se disponível (local), senão a padrão (prod)
    const supabaseKey = Deno.env.get('MY_SERVICE_ROLE_KEY') || Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!mpAccessToken || !supabaseUrl || !supabaseKey) {
      throw new Error('Configuração de servidor incompleta (Secrets ausentes).')
    }

    // 3. Validação de Entrada
    if (!booking_id || !payment_method_id || !payer_email) {
      throw new Error('Dados obrigatórios faltando (ID, Método ou Email).')
    }

    // 4. Busca da Reserva (Server-Side Validation)
    // Usamos o cliente com Service Role para ignorar RLS e garantir acesso
    const supabase = createClient(supabaseUrl, supabaseKey)

    const { data: booking, error: bookingError } = await supabase
      .from('bookings')
      .select('id, total_price, status, origin_name, destination_name') 
      .eq('id', booking_id)
      .single()

    if (bookingError || !booking) {
      console.error('[DB ERROR]', JSON.stringify(bookingError))
      throw new Error('Reserva não encontrada.')
    }

    // Verifica se já está paga ou expirada
    if (booking.status === 'paid' || booking.status === 'confirmed') {
      throw new Error('Esta reserva já foi paga.')
    }

    // 5. Montagem do Payload MP
    const description = `Viagem: ${booking.origin_name} > ${booking.destination_name}`.substring(0, 100);
    
    const payload: MercadoPagoPayload = {
      transaction_amount: Number(booking.total_price),
      description: description,
      payment_method_id: payment_method_id,
      external_reference: booking_id,
      payer: {
        email: payer_email,
        first_name: "Passageiro",
      }
    };

    // Adiciona CPF se enviado (Sanitizado)
    if (doc_number) {
      payload.payer.identification = {
        type: "CPF",
        number: doc_number.replace(/\D/g, '') // Remove pontos e traços
      };
    }

    // Lógica Específica: Pix vs Cartão
    if (payment_method_id === 'pix') {
       console.log('[DEBUG] Configurando Pix...');
       // Pix não precisa de token/installments
    } else {
       // Cartão
       if (!token || !installments) {
         throw new Error('Dados do cartão incompletos (Token ou Parcelas).')
       }
       payload.token = token;
       payload.installments = Number(installments);
       if (issuer_id) {
         payload.issuer_id = Number(issuer_id);
       }
    }

    // 6. Envio para Mercado Pago
    console.log('[MP] Enviando requisição...');

    const mpResponse = await fetch('https://api.mercadopago.com/v1/payments', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Idempotency-Key': `pay_${booking_id}_${new Date().getTime()}`,
        'Authorization': `Bearer ${mpAccessToken}`,
      },
      body: JSON.stringify(payload)
    })

    const mpData = await mpResponse.json()

    // 7. Tratamento de Erros da API MP
    if (!mpResponse.ok) {
      console.error('[ERRO MP]', JSON.stringify(mpData))
      
      // Tenta extrair mensagem amigável
      const cause = mpData.cause && Array.isArray(mpData.cause) && mpData.cause.length > 0 
        ? mpData.cause[0].description 
        : mpData.message;

      if (mpResponse.status === 401) {
        throw new Error('Erro de Configuração: Credenciais inválidas (401).')
      }

      throw new Error(`Pagamento recusado: ${cause}`)
    }

    console.log('[SUCESSO] ID MP:', mpData.id)

    // 8. Retorno
    return new Response(JSON.stringify(mpData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    const msg = error instanceof Error ? error.message : 'Erro interno.'
    console.error('[CATCH]', msg)
    
    return new Response(JSON.stringify({ error: msg }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})