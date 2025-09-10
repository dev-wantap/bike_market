import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// CORS 헤더 설정 (중요)
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // OPTIONS 요청(preflight) 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Supabase 클라이언트 생성 (서비스 역할 키 사용)
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, // ★★★ 서비스 역할 키 사용
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    // 2. 요청 본문에서 productId 가져오기
    const { productId } = await req.json()
    if (!productId) {
      throw new Error('Product ID is required.')
    }

    // 3. 현재 로그인한 사용자 정보 가져오기
    const { data: { user } } = await supabaseClient.auth.getUser()
    if (!user) {
      throw new Error('User not authenticated.')
    }
    
    // 4. 삭제할 상품 정보를 DB에서 가져오기 (이미지 URL 확보 및 소유권 확인)
    const { data: product, error: selectError } = await supabaseClient
      .from('products')
      .select('seller_id, image_urls')
      .eq('id', productId)
      .single()

    if (selectError) throw selectError
    if (!product) throw new Error('Product not found.')

    // 5. 소유권 확인 (중요!)
    if (product.seller_id !== user.id) {
      return new Response(JSON.stringify({ error: 'Permission denied. You are not the owner of this product.' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 403, // Forbidden
      })
    }

    // 6. DB 레코드 삭제
    const { error: deleteError } = await supabaseClient
      .from('products')
      .delete()
      .eq('id', productId)
      
    if (deleteError) throw deleteError

    // 7. 스토리지 파일 삭제 (DB 삭제 성공 시에만 실행)
    const imageUrls = product.image_urls as string[]
    if (imageUrls && imageUrls.length > 0) {
      const filePaths = imageUrls.map(url => 
        url.substring(url.indexOf('product-images/') + 'product-images/'.length)
      )
      
      const { error: storageError } = await supabaseClient
        .storage
        .from('product-images')
        .remove(filePaths)

      if (storageError) {
        // DB는 삭제되었지만 스토리지는 실패한 경우 (로깅 등으로 추적)
        console.error(`Storage deletion failed for product ${productId}:`, storageError.message)
      }
    }

    // 8. 성공 응답 반환
    return new Response(JSON.stringify({ message: 'Product deleted successfully' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
