'use client';

import { useState, useMemo, useTransition } from 'react';
import { Search, Eye, Trash2, X, Star, Package, ShoppingBag, ToggleLeft, ToggleRight } from 'lucide-react';
import Badge from '@/components/Badge';
import { timeAgo, formatDateTime } from '@/lib/utils';
import { updateProductStatus, deleteProduct, updateOrderStatus, deleteOrder } from '@/lib/admin-actions';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  currency: string;
  stock_quantity: number;
  pet_type: string | null;
  is_active: boolean;
  rating: number;
  total_reviews: number;
  total_sold: number;
  images: string[] | null;
  created_at: string;
  updated_at: string;
  seller: { id: string; display_name: string | null; email: string | null } | null;
  category: { name: string } | null;
}

interface OrderItem {
  id: string;
  quantity: number;
  unit_price: number;
  total_price: number;
  seller_status: string;
  product: { name: string } | null;
  seller: { display_name: string | null; email: string | null } | null;
}

interface Order {
  id: string;
  status: string;
  total_amount: number;
  currency: string;
  shipping_address: string;
  shipping_city: string | null;
  shipping_phone: string | null;
  payment_method: string | null;
  payment_status: string;
  tracking_number: string | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
  buyer: { id: string; display_name: string | null; email: string | null } | null;
  items: OrderItem[];
}

function orderStatusVariant(status: string): 'success' | 'warning' | 'danger' | 'info' | 'purple' | 'default' {
  switch (status) {
    case 'delivered': return 'success';
    case 'shipped': return 'info';
    case 'processing':
    case 'confirmed': return 'purple';
    case 'pending': return 'warning';
    case 'cancelled':
    case 'refunded': return 'danger';
    default: return 'default';
  }
}

function paymentVariant(status: string): 'success' | 'warning' | 'danger' | 'default' {
  switch (status) {
    case 'paid': return 'success';
    case 'pending': return 'warning';
    case 'failed':
    case 'refunded': return 'danger';
    default: return 'default';
  }
}

function InfoItem({ label, value }: { label: string; value: string | null | undefined }) {
  return (
    <div>
      <p className="text-xs text-gray-400">{label}</p>
      <p className="text-sm font-medium text-gray-700">{value || '—'}</p>
    </div>
  );
}

const ORDER_STATUSES = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded'];

export default function MarketplaceClient({
  products: initialProducts,
  orders: initialOrders,
}: {
  products: Product[];
  orders: Order[];
}) {
  const [tab, setTab] = useState<'products' | 'orders'>('products');
  const [products, setProducts] = useState(initialProducts);
  const [orders, setOrders] = useState(initialOrders);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [deleteProductTarget, setDeleteProductTarget] = useState<Product | null>(null);
  const [deleteOrderTarget, setDeleteOrderTarget] = useState<Order | null>(null);
  const [isPending, startTransition] = useTransition();

  const filteredProducts = useMemo(() => {
    return products.filter((p) => {
      const q = search.toLowerCase();
      const matchesSearch =
        !q ||
        p.name.toLowerCase().includes(q) ||
        (p.seller?.display_name ?? '').toLowerCase().includes(q) ||
        (p.seller?.email ?? '').toLowerCase().includes(q) ||
        (p.category?.name ?? '').toLowerCase().includes(q);
      const matchesStatus =
        statusFilter === 'all' ||
        (statusFilter === 'active' && p.is_active) ||
        (statusFilter === 'inactive' && !p.is_active);
      return matchesSearch && matchesStatus;
    });
  }, [products, search, statusFilter]);

  const filteredOrders = useMemo(() => {
    return orders.filter((o) => {
      const q = search.toLowerCase();
      const matchesSearch =
        !q ||
        (o.buyer?.display_name ?? '').toLowerCase().includes(q) ||
        (o.buyer?.email ?? '').toLowerCase().includes(q) ||
        (o.shipping_city ?? '').toLowerCase().includes(q);
      const matchesStatus = statusFilter === 'all' || o.status === statusFilter;
      return matchesSearch && matchesStatus;
    });
  }, [orders, search, statusFilter]);

  function handleToggleProduct(id: string, currentActive: boolean) {
    startTransition(async () => {
      const res = await updateProductStatus(id, !currentActive);
      if (res.success) {
        setProducts((prev) => prev.map((p) => p.id === id ? { ...p, is_active: !currentActive } : p));
        if (selectedProduct?.id === id) setSelectedProduct((prev) => prev ? { ...prev, is_active: !currentActive } : null);
      }
    });
  }

  function handleDeleteProduct(id: string) {
    startTransition(async () => {
      const res = await deleteProduct(id);
      if (res.success) {
        setProducts((prev) => prev.filter((p) => p.id !== id));
        setDeleteProductTarget(null);
        if (selectedProduct?.id === id) setSelectedProduct(null);
      }
    });
  }

  function handleOrderStatus(id: string, status: string) {
    startTransition(async () => {
      const res = await updateOrderStatus(id, status);
      if (res.success) {
        setOrders((prev) => prev.map((o) => o.id === id ? { ...o, status } : o));
        if (selectedOrder?.id === id) setSelectedOrder((prev) => prev ? { ...prev, status } : null);
      }
    });
  }

  function handleDeleteOrder(id: string) {
    startTransition(async () => {
      const res = await deleteOrder(id);
      if (res.success) {
        setOrders((prev) => prev.filter((o) => o.id !== id));
        setDeleteOrderTarget(null);
        if (selectedOrder?.id === id) setSelectedOrder(null);
      }
    });
  }

  return (
    <>
      {/* Tabs */}
      <div className="mb-5 flex gap-1 rounded-xl border border-gray-200 bg-white p-1 w-fit">
        <button
          onClick={() => { setTab('products'); setSearch(''); setStatusFilter('all'); }}
          className={`flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium transition-colors ${tab === 'products' ? 'bg-[#2C6E69] text-white' : 'text-gray-600 hover:text-gray-900'}`}
        >
          <Package className="h-4 w-4" /> Products ({products.length})
        </button>
        <button
          onClick={() => { setTab('orders'); setSearch(''); setStatusFilter('all'); }}
          className={`flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium transition-colors ${tab === 'orders' ? 'bg-[#2C6E69] text-white' : 'text-gray-600 hover:text-gray-900'}`}
        >
          <ShoppingBag className="h-4 w-4" /> Orders ({orders.length})
        </button>
      </div>

      {/* Search + Filters */}
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[220px]">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={tab === 'products' ? 'Search product, seller, category…' : 'Search buyer, city…'}
            className="w-full rounded-xl border border-gray-200 bg-white py-2 pl-10 pr-4 text-sm focus:border-[#2C6E69] focus:outline-none focus:ring-1 focus:ring-[#2C6E69]"
          />
        </div>

        {tab === 'products' ? (
          <div className="flex gap-1.5">
            {(['all', 'active', 'inactive'] as const).map((f) => (
              <button
                key={f}
                onClick={() => setStatusFilter(f)}
                className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${statusFilter === f ? 'bg-[#2C6E69] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
              >
                {f === 'all' ? 'All' : f.charAt(0).toUpperCase() + f.slice(1)}
              </button>
            ))}
          </div>
        ) : (
          <div className="flex flex-wrap gap-1.5">
            {['all', ...ORDER_STATUSES].map((f) => (
              <button
                key={f}
                onClick={() => setStatusFilter(f)}
                className={`rounded-lg px-3 py-1.5 text-xs font-medium capitalize transition-colors ${statusFilter === f ? 'bg-[#2C6E69] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
              >
                {f}
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Products Table */}
      {tab === 'products' && (
        <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-gray-100 bg-gray-50/60">
                  {['Product', 'Category', 'Seller', 'Price', 'Stock', 'Rating', 'Sold', 'Status', 'Actions'].map((h) => (
                    <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filteredProducts.length === 0 ? (
                  <tr><td colSpan={9} className="py-16 text-center text-sm text-gray-400">No products found</td></tr>
                ) : (
                  filteredProducts.map((p) => (
                    <tr key={p.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors">
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-3">
                          {p.images?.[0] ? (
                            <img src={p.images[0]} alt={p.name} className="h-9 w-9 rounded-lg object-cover" />
                          ) : (
                            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-[#B3E0DB] text-[#2C6E69]">
                              <Package className="h-4 w-4" />
                            </div>
                          )}
                          <div>
                            <p className="font-medium text-gray-800 line-clamp-1">{p.name}</p>
                            <p className="text-xs text-gray-400">{timeAgo(p.created_at)}</p>
                          </div>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-600">{p.category?.name || '—'}</td>
                      <td className="px-4 py-3 text-xs text-gray-600">
                        <p>{p.seller?.display_name || '—'}</p>
                        <p className="text-gray-400">{p.seller?.email}</p>
                      </td>
                      <td className="px-4 py-3 text-sm font-semibold text-gray-800">{p.currency} {p.price.toLocaleString()}</td>
                      <td className="px-4 py-3 text-center">
                        <span className={`text-sm font-medium ${p.stock_quantity === 0 ? 'text-red-500' : 'text-gray-700'}`}>{p.stock_quantity}</span>
                      </td>
                      <td className="px-4 py-3">
                        <span className="flex items-center gap-1 text-amber-600 text-xs">
                          <Star className="h-3 w-3 fill-amber-400 text-amber-400" />
                          {p.rating?.toFixed(1) || '0.0'} ({p.total_reviews})
                        </span>
                      </td>
                      <td className="px-4 py-3 text-center text-sm text-gray-600">{p.total_sold}</td>
                      <td className="px-4 py-3">
                        <Badge variant={p.is_active ? 'success' : 'default'}>{p.is_active ? 'Active' : 'Inactive'}</Badge>
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-1">
                          <button onClick={() => setSelectedProduct(p)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69]" title="View">
                            <Eye className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => handleToggleProduct(p.id, p.is_active)}
                            disabled={isPending}
                            className={`rounded-lg p-1.5 transition-colors disabled:opacity-50 ${p.is_active ? 'text-gray-400 hover:bg-yellow-50 hover:text-yellow-600' : 'text-gray-400 hover:bg-green-50 hover:text-green-600'}`}
                            title={p.is_active ? 'Deactivate' : 'Activate'}
                          >
                            {p.is_active ? <ToggleRight className="h-4 w-4" /> : <ToggleLeft className="h-4 w-4" />}
                          </button>
                          <button onClick={() => setDeleteProductTarget(p)} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500" title="Delete">
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Orders Table */}
      {tab === 'orders' && (
        <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-gray-100 bg-gray-50/60">
                  {['Order', 'Buyer', 'Items', 'Amount', 'Payment', 'Status', 'Actions'].map((h) => (
                    <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filteredOrders.length === 0 ? (
                  <tr><td colSpan={7} className="py-16 text-center text-sm text-gray-400">No orders found</td></tr>
                ) : (
                  filteredOrders.map((o) => (
                    <tr key={o.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors">
                      <td className="px-4 py-3">
                        <p className="font-mono text-xs font-semibold text-[#2C6E69]">{o.id.slice(0, 8).toUpperCase()}</p>
                        <p className="text-xs text-gray-400">{timeAgo(o.created_at)}</p>
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-600">
                        <p className="font-medium">{o.buyer?.display_name || '—'}</p>
                        <p className="text-gray-400">{o.buyer?.email}</p>
                      </td>
                      <td className="px-4 py-3 text-center text-gray-700">{o.items?.length || 0}</td>
                      <td className="px-4 py-3 text-sm font-semibold text-gray-800">{o.currency} {o.total_amount.toLocaleString()}</td>
                      <td className="px-4 py-3">
                        <div className="space-y-1">
                          <Badge variant={paymentVariant(o.payment_status)}>{o.payment_status}</Badge>
                          <p className="text-xs text-gray-400 capitalize">{o.payment_method?.replace(/_/g, ' ')}</p>
                        </div>
                      </td>
                      <td className="px-4 py-3">
                        <Badge variant={orderStatusVariant(o.status)} className="capitalize">{o.status}</Badge>
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-1">
                          <button onClick={() => setSelectedOrder(o)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69]" title="View">
                            <Eye className="h-4 w-4" />
                          </button>
                          <button onClick={() => setDeleteOrderTarget(o)} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500" title="Delete">
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Product Detail Drawer */}
      {selectedProduct && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelectedProduct(null)} />
          <div className="relative w-full max-w-lg overflow-y-auto bg-white shadow-2xl">
            <div className="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-6 py-4">
              <div>
                <h2 className="text-lg font-bold text-gray-900 line-clamp-1">{selectedProduct.name}</h2>
                <div className="mt-1 flex items-center gap-2">
                  <Badge variant={selectedProduct.is_active ? 'success' : 'default'}>{selectedProduct.is_active ? 'Active' : 'Inactive'}</Badge>
                  {selectedProduct.category && <Badge variant="info">{selectedProduct.category.name}</Badge>}
                </div>
              </div>
              <button onClick={() => setSelectedProduct(null)} className="rounded-lg p-2 hover:bg-gray-100"><X className="h-5 w-5" /></button>
            </div>
            <div className="space-y-6 p-6">
              {selectedProduct.images && selectedProduct.images.length > 0 && (
                <div className="grid grid-cols-3 gap-2">
                  {selectedProduct.images.slice(0, 3).map((url, i) => (
                    <img key={i} src={url} alt="" className="h-28 w-full rounded-lg object-cover" />
                  ))}
                </div>
              )}
              <div>
                <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Description</p>
                <p className="text-sm text-gray-700 line-clamp-4">{selectedProduct.description}</p>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <InfoItem label="Price" value={`${selectedProduct.currency} ${selectedProduct.price.toLocaleString()}`} />
                <InfoItem label="Stock" value={String(selectedProduct.stock_quantity)} />
                <InfoItem label="Pet Type" value={selectedProduct.pet_type || 'All'} />
                <InfoItem label="Total Sold" value={String(selectedProduct.total_sold)} />
                <InfoItem label="Rating" value={`${selectedProduct.rating?.toFixed(1)} (${selectedProduct.total_reviews} reviews)`} />
                <InfoItem label="Seller" value={selectedProduct.seller?.display_name || selectedProduct.seller?.email || '—'} />
                <InfoItem label="Created" value={formatDateTime(selectedProduct.created_at)} />
                <InfoItem label="Updated" value={formatDateTime(selectedProduct.updated_at)} />
              </div>
              <div className="flex gap-3">
                <button
                  onClick={() => handleToggleProduct(selectedProduct.id, selectedProduct.is_active)}
                  disabled={isPending}
                  className={`flex-1 rounded-xl border py-2.5 text-sm font-medium transition-colors disabled:opacity-50 ${selectedProduct.is_active ? 'border-yellow-200 text-yellow-700 hover:bg-yellow-50' : 'border-green-200 text-green-700 hover:bg-green-50'}`}
                >
                  {selectedProduct.is_active ? 'Deactivate Product' : 'Activate Product'}
                </button>
                <button
                  onClick={() => { setSelectedProduct(null); setDeleteProductTarget(selectedProduct); }}
                  className="flex-1 rounded-xl border border-red-200 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50"
                >
                  Delete
                </button>
              </div>
              <p className="text-xs text-gray-300">ID: {selectedProduct.id}</p>
            </div>
          </div>
        </div>
      )}

      {/* Order Detail Drawer */}
      {selectedOrder && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelectedOrder(null)} />
          <div className="relative w-full max-w-lg overflow-y-auto bg-white shadow-2xl">
            <div className="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-6 py-4">
              <div>
                <h2 className="text-lg font-bold text-gray-900">Order #{selectedOrder.id.slice(0, 8).toUpperCase()}</h2>
                <div className="mt-1 flex items-center gap-2">
                  <Badge variant={orderStatusVariant(selectedOrder.status)} className="capitalize">{selectedOrder.status}</Badge>
                  <Badge variant={paymentVariant(selectedOrder.payment_status)}>{selectedOrder.payment_status}</Badge>
                </div>
              </div>
              <button onClick={() => setSelectedOrder(null)} className="rounded-lg p-2 hover:bg-gray-100"><X className="h-5 w-5" /></button>
            </div>
            <div className="space-y-6 p-6">
              <div className="grid grid-cols-2 gap-4">
                <InfoItem label="Buyer" value={selectedOrder.buyer?.display_name || selectedOrder.buyer?.email || '—'} />
                <InfoItem label="Total" value={`${selectedOrder.currency} ${selectedOrder.total_amount.toLocaleString()}`} />
                <InfoItem label="Payment Method" value={selectedOrder.payment_method?.replace(/_/g, ' ') || '—'} />
                <InfoItem label="Shipping City" value={selectedOrder.shipping_city} />
                <InfoItem label="Phone" value={selectedOrder.shipping_phone} />
                <InfoItem label="Tracking #" value={selectedOrder.tracking_number} />
              </div>
              <InfoItem label="Shipping Address" value={selectedOrder.shipping_address} />
              {selectedOrder.notes && <InfoItem label="Notes" value={selectedOrder.notes} />}

              {selectedOrder.items && selectedOrder.items.length > 0 && (
                <div>
                  <p className="mb-2 text-xs font-semibold uppercase text-gray-400">Items ({selectedOrder.items.length})</p>
                  <div className="space-y-2">
                    {selectedOrder.items.map((item) => (
                      <div key={item.id} className="flex items-center justify-between rounded-xl bg-gray-50 px-3 py-2 text-xs">
                        <div>
                          <p className="font-medium text-gray-800">{item.product?.name || '—'}</p>
                          <p className="text-gray-400">by {item.seller?.display_name || item.seller?.email}</p>
                        </div>
                        <div className="text-right">
                          <p className="font-semibold text-gray-800">x{item.quantity} · {selectedOrder.currency} {item.total_price.toLocaleString()}</p>
                          <Badge variant={item.seller_status === 'delivered' ? 'success' : item.seller_status === 'cancelled' ? 'danger' : 'warning'} className="text-[10px]">{item.seller_status}</Badge>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              <div>
                <p className="mb-2 text-xs font-semibold uppercase text-gray-400">Update Status</p>
                <div className="flex flex-wrap gap-2">
                  {ORDER_STATUSES.map((s) => (
                    <button
                      key={s}
                      disabled={isPending || selectedOrder.status === s}
                      onClick={() => handleOrderStatus(selectedOrder.id, s)}
                      className={`rounded-lg px-3 py-1.5 text-xs font-medium capitalize transition-colors disabled:opacity-40 ${selectedOrder.status === s ? 'bg-[#2C6E69] text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}`}
                    >
                      {s}
                    </button>
                  ))}
                </div>
              </div>

              <p className="text-xs text-gray-300">ID: {selectedOrder.id}</p>
              <button
                onClick={() => { setSelectedOrder(null); setDeleteOrderTarget(selectedOrder); }}
                className="w-full rounded-xl bg-red-50 py-2.5 text-sm font-medium text-red-600 hover:bg-red-100"
              >
                Delete Order
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Product Confirm */}
      {deleteProductTarget && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="absolute inset-0 bg-black/30" onClick={() => !isPending && setDeleteProductTarget(null)} />
          <div className="relative w-full max-w-sm rounded-2xl bg-white p-6 shadow-2xl">
            <h3 className="text-lg font-bold text-gray-900">Delete Product?</h3>
            <p className="mt-2 text-sm text-gray-500">Permanently delete <strong>{deleteProductTarget.name}</strong>? This will also remove all reviews and cart items.</p>
            <div className="mt-5 flex gap-3">
              <button onClick={() => setDeleteProductTarget(null)} disabled={isPending} className="flex-1 rounded-xl border border-gray-200 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50">Cancel</button>
              <button onClick={() => handleDeleteProduct(deleteProductTarget.id)} disabled={isPending} className="flex-1 rounded-xl bg-red-600 py-2 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-50">{isPending ? 'Deleting…' : 'Delete'}</button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Order Confirm */}
      {deleteOrderTarget && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="absolute inset-0 bg-black/30" onClick={() => !isPending && setDeleteOrderTarget(null)} />
          <div className="relative w-full max-w-sm rounded-2xl bg-white p-6 shadow-2xl">
            <h3 className="text-lg font-bold text-gray-900">Delete Order?</h3>
            <p className="mt-2 text-sm text-gray-500">Permanently delete order <strong>#{deleteOrderTarget.id.slice(0, 8).toUpperCase()}</strong>? This will remove all order items.</p>
            <div className="mt-5 flex gap-3">
              <button onClick={() => setDeleteOrderTarget(null)} disabled={isPending} className="flex-1 rounded-xl border border-gray-200 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50">Cancel</button>
              <button onClick={() => handleDeleteOrder(deleteOrderTarget.id)} disabled={isPending} className="flex-1 rounded-xl bg-red-600 py-2 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-50">{isPending ? 'Deleting…' : 'Delete'}</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
