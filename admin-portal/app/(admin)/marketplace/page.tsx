export const dynamic = 'force-dynamic';

import { createClient } from '@supabase/supabase-js';
import MarketplaceClient, { type Product, type Order } from './MarketplaceClient';

async function getData() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const [{ data: products, error: pe }, { data: orders, error: oe }] = await Promise.all([
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
        seller:users!products_seller_id_fkey(id, display_name, email, avatar_url),
        category:product_categories!products_category_id_fkey(name)
      `)
      .order('created_at', { ascending: false })
      .limit(300),

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
        buyer:users!orders_buyer_id_fkey(id, display_name, email, avatar_url),
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
      .order('created_at', { ascending: false })
      .limit(300),
  ]);

  if (pe) throw pe;
  if (oe) throw oe;

  return {
    products: products ?? [],
    orders: orders ?? [],
  };
}

export default async function MarketplacePage() {
  const data = await getData();

  const activeProducts  = data.products.filter((p) => p.is_active).length;
  const pendingOrders   = data.orders.filter((o) => o.status === 'pending').length;
  const totalRevenue    = data.orders.reduce((sum, o) => sum + (o.total_amount ?? 0), 0);

  return (
    <div className="p-8">
      <div
        className="mb-6 overflow-hidden rounded-2xl shadow-md ring-1 ring-black/5"
        style={{ background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 50%, #2C6E69 100%)' }}
      >
        <div className="px-6 py-5 sm:px-8 sm:py-6">
          <h1 className="text-2xl font-bold tracking-tight text-white sm:text-[1.75rem]">
            Marketplace
          </h1>
          <p className="mt-1.5 text-sm text-white/70">
            {data.products.length} products ({activeProducts} active) · {data.orders.length} orders ({pendingOrders} pending) · PKR {totalRevenue.toLocaleString()} total revenue
          </p>
        </div>
      </div>
      <MarketplaceClient
        products={data.products as unknown as Product[]}
        orders={data.orders as unknown as Order[]}
      />
    </div>
  );
}
