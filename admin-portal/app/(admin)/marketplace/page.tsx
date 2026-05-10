export const dynamic = 'force-dynamic';

import { createClient } from '@supabase/supabase-js';
import MarketplaceClient, { type Product, type Order } from './MarketplaceClient';

async function getData() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const [{ data: products }, { data: orders }] = await Promise.all([
    supabase
      .from('products')
      .select(`
        id,
        name,
        description,
        price,
        currency,
        stock_quantity,
        pet_type,
        is_active,
        rating,
        total_reviews,
        total_sold,
        images,
        created_at,
        updated_at,
        seller:users!products_seller_id_fkey(id, display_name, email),
        category:product_categories!products_category_id_fkey(name)
      `)
      .order('created_at', { ascending: false }),

    supabase
      .from('orders')
      .select(`
        id,
        status,
        total_amount,
        currency,
        shipping_address,
        shipping_city,
        shipping_phone,
        payment_method,
        payment_status,
        tracking_number,
        notes,
        created_at,
        updated_at,
        buyer:users!orders_buyer_id_fkey(id, display_name, email),
        items:order_items(
          id,
          quantity,
          unit_price,
          total_price,
          seller_status,
          product:products!order_items_product_id_fkey(name),
          seller:users!order_items_seller_id_fkey(display_name, email)
        )
      `)
      .order('created_at', { ascending: false }),
  ]);

  return {
    products: products ?? [],
    orders: orders ?? [],
  };
}

export default async function MarketplacePage() {
  const data = await getData();
  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Marketplace</h1>
        <p className="mt-1 text-sm text-gray-500">
          {data.products.length} products · {data.orders.length} orders
        </p>
      </div>
      <MarketplaceClient
        products={data.products as unknown as Product[]}
        orders={data.orders as unknown as Order[]}
      />
    </div>
  );
}
