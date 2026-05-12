'use client';

import { useState, useMemo, useTransition, useEffect, type ReactNode } from 'react';
import { AnimatePresence, motion, useAnimation } from 'framer-motion';
import {
  Search, Eye, Trash2, X, Star, Package, ShoppingBag,
  ToggleLeft, ToggleRight, AlertTriangle, User, Tag,
  DollarSign, MapPin, Phone, Hash,
} from 'lucide-react';
import Badge from '@/components/Badge';
import { timeAgo } from '@/lib/utils';
import { updateProductStatus, deleteProduct, updateOrderStatus, deleteOrder } from '@/lib/admin-actions';

export interface Product {
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
  seller: { id: string; display_name: string | null; email: string | null; avatar_url: string | null } | null;
  category: { name: string } | null;
}

export interface OrderItem {
  id: string;
  quantity: number;
  unit_price: number;
  total_price: number;
  seller_status: string;
  product: { name: string } | null;
  seller: { display_name: string | null; email: string | null } | null;
}

export interface Order {
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
  buyer: { id: string; display_name: string | null; email: string | null; avatar_url: string | null } | null;
  items: OrderItem[];
}

// ── Animation constants ──────────────────────────────────────────────────────

const EASE_OUT = [0.16, 1, 0.3, 1] as const;
const EASE_IN  = [0.7, 0, 0.84, 0] as const;

const drawerVariants = {
  hidden: { x: '100%', opacity: 0 },
  show: {
    x: 0,
    opacity: 1,
    transition: { type: 'spring' as const, stiffness: 280, damping: 28, mass: 0.9 },
  },
  exit: { x: '100%', opacity: 0, transition: { duration: 0.22, ease: EASE_IN } },
};

const drawerItemVariants = {
  hidden: { opacity: 0, x: 18 },
  show: { opacity: 1, x: 0, transition: { duration: 0.28, ease: EASE_OUT } },
};

const drawerContentVariants = {
  show: { transition: { staggerChildren: 0.07, delayChildren: 0.08 } },
};

const backdropVariants = {
  hidden: { opacity: 0 },
  show:   { opacity: 1, transition: { duration: 0.25, ease: EASE_OUT } },
  exit:   { opacity: 0, transition: { duration: 0.2,  ease: EASE_IN  } },
};

const fadeUp = { hidden: { opacity: 0, y: 12 }, show: { opacity: 1, y: 0 } };

const rowVariants = {
  hidden: { opacity: 0, y: 6 },
  show: (i: number) => ({
    opacity: 1,
    y: 0,
    transition: { duration: 0.22, ease: EASE_OUT, delay: i * 0.03 },
  }),
};

const deleteBackdropVariants = {
  hidden: { opacity: 0, backgroundColor: 'rgba(220, 38, 38, 0.0)' },
  show: {
    opacity: 1,
    backgroundColor: ['rgba(220, 38, 38, 0.05)', 'rgba(220, 38, 38, 0.2)', 'rgba(220, 38, 38, 0.12)'],
    transition: { duration: 0.45, ease: EASE_OUT },
  },
  exit: { opacity: 0, backgroundColor: 'rgba(220, 38, 38, 0.0)', transition: { duration: 0.2 } },
};

const deleteModalVariants = {
  hidden: { opacity: 0, scale: 0.86, y: -8, rotateZ: -1 },
  show: {
    opacity: 1, scale: 1, y: 0, rotateZ: 0,
    transition: { type: 'spring' as const, stiffness: 520, damping: 26, mass: 0.7 },
  },
  exit: { opacity: 0, scale: 0.92, y: 16, transition: { duration: 0.2 } },
};

const deleteContentVariants = {
  show: { transition: { staggerChildren: 0.08, delayChildren: 0.05 } },
};

const deleteItemVariants = {
  hidden: { opacity: 0, y: 8 },
  show:   { opacity: 1, y: 0, transition: { duration: 0.22, ease: EASE_OUT } },
};

// ── Status helpers ───────────────────────────────────────────────────────────

const ORDER_STATUSES = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded'];

function orderStatusVariant(status: string): 'success' | 'warning' | 'danger' | 'info' | 'purple' | 'default' {
  switch (status) {
    case 'delivered':  return 'success';
    case 'shipped':    return 'info';
    case 'processing':
    case 'confirmed':  return 'purple';
    case 'pending':    return 'warning';
    case 'cancelled':
    case 'refunded':   return 'danger';
    default:           return 'default';
  }
}

function paymentVariant(status: string): 'success' | 'warning' | 'danger' | 'default' {
  switch (status) {
    case 'paid':     return 'success';
    case 'pending':  return 'warning';
    case 'failed':
    case 'refunded': return 'danger';
    default:         return 'default';
  }
}

// ── Small helpers ────────────────────────────────────────────────────────────

function MktField({ icon, label, value }: { icon: ReactNode; label: string; value: ReactNode }) {
  return (
    <div className="min-w-0">
      <div className="mb-1 flex items-center gap-1">
        <span className="text-[#0B1629]/50">{icon}</span>
        <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">{label}</p>
      </div>
      <div className="break-words text-sm font-semibold text-gray-800">{value}</div>
    </div>
  );
}

// ── Main component ───────────────────────────────────────────────────────────

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
        if (selectedProduct?.id === id)
          setSelectedProduct((prev) => prev ? { ...prev, is_active: !currentActive } : null);
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
      } else {
        alert('Failed to delete: ' + res.error);
      }
    });
  }

  function handleOrderStatus(id: string, status: string) {
    startTransition(async () => {
      const res = await updateOrderStatus(id, status);
      if (res.success) {
        setOrders((prev) => prev.map((o) => o.id === id ? { ...o, status } : o));
        if (selectedOrder?.id === id)
          setSelectedOrder((prev) => prev ? { ...prev, status } : null);
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
      } else {
        alert('Failed to delete: ' + res.error);
      }
    });
  }

  return (
    <>
      {/* Tabs */}
      <motion.div
        className="mb-5 flex gap-1 rounded-xl border border-gray-200 bg-white p-1 w-fit"
        initial="hidden" animate="show" variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT }}
      >
        <button
          onClick={() => { setTab('products'); setSearch(''); setStatusFilter('all'); }}
          className={`flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium transition-colors ${tab === 'products' ? 'bg-[#0B1629] text-white' : 'text-gray-600 hover:text-gray-900'}`}
        >
          <Package className="h-4 w-4" /> Products ({products.length})
        </button>
        <button
          onClick={() => { setTab('orders'); setSearch(''); setStatusFilter('all'); }}
          className={`flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium transition-colors ${tab === 'orders' ? 'bg-[#0B1629] text-white' : 'text-gray-600 hover:text-gray-900'}`}
        >
          <ShoppingBag className="h-4 w-4" /> Orders ({orders.length})
        </button>
      </motion.div>

      {/* Search + Filters */}
      <motion.div
        className="mb-4 flex flex-wrap items-center gap-3"
        initial="hidden" animate="show" variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT, delay: 0.04 }}
      >
        <div className="relative flex-1 min-w-[220px]">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={tab === 'products' ? 'Search product, seller, category…' : 'Search buyer, city…'}
            className="w-full rounded-xl border border-gray-200 bg-white py-2 pl-10 pr-4 text-sm focus:border-[#0B1629] focus:outline-none focus:ring-1 focus:ring-[#0B1629]"
          />
        </div>

        {tab === 'products' ? (
          <div className="flex gap-1.5">
            {(['all', 'active', 'inactive'] as const).map((f) => (
              <button
                key={f}
                onClick={() => setStatusFilter(f)}
                className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${statusFilter === f ? 'bg-[#0B1629] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
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
                className={`rounded-lg px-3 py-1.5 text-xs font-medium capitalize transition-colors ${statusFilter === f ? 'bg-[#0B1629] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
              >
                {f}
              </button>
            ))}
          </div>
        )}
      </motion.div>

      {/* Products Table */}
      {tab === 'products' && (
        <motion.div
          className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm"
          initial="hidden" animate="show" variants={fadeUp}
          transition={{ duration: 0.35, ease: EASE_OUT, delay: 0.08 }}
        >
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-gray-100 bg-[#0B1629]">
                  {['Product', 'Category', 'Seller', 'Price', 'Stock', 'Rating', 'Sold', 'Status', 'Actions'].map((h) => (
                    <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filteredProducts.length === 0 ? (
                  <tr><td colSpan={9} className="py-16 text-center text-sm text-gray-400">No products found</td></tr>
                ) : (
                  filteredProducts.map((p, i) => (
                    <motion.tr
                      key={p.id}
                      custom={i}
                      variants={rowVariants}
                      initial="hidden"
                      animate="show"
                      className="border-b border-gray-50 last:border-0 hover:bg-[#0B1629]/5 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-3">
                          {p.images?.[0] ? (
                            <img src={p.images[0]} alt={p.name} className="h-9 w-9 rounded-lg object-cover" />
                          ) : (
                            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-[#0B1629]/10 text-[#0B1629]">
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
                          <motion.button
                            type="button"
                            onClick={() => setSelectedProduct(p)}
                            className="rounded-lg p-1.5 text-gray-400 hover:bg-[#0B1629]/5 hover:text-[#0B1629] transition-colors"
                            title="View details"
                            whileHover={{ scale: 1.08, y: -1 }}
                            whileTap={{ scale: 0.96 }}
                          >
                            <Eye className="h-4 w-4" />
                          </motion.button>
                          <motion.button
                            type="button"
                            onClick={() => handleToggleProduct(p.id, p.is_active)}
                            disabled={isPending}
                            className={`rounded-lg p-1.5 transition-colors disabled:opacity-50 ${p.is_active ? 'text-gray-400 hover:bg-yellow-50 hover:text-yellow-600' : 'text-gray-400 hover:bg-green-50 hover:text-green-600'}`}
                            title={p.is_active ? 'Deactivate' : 'Activate'}
                            whileHover={{ scale: 1.08 }}
                            whileTap={{ scale: 0.96 }}
                          >
                            {p.is_active ? <ToggleRight className="h-4 w-4" /> : <ToggleLeft className="h-4 w-4" />}
                          </motion.button>
                          <motion.button
                            type="button"
                            onClick={() => setDeleteProductTarget(p)}
                            className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors"
                            title="Delete"
                            whileHover={{ x: [0, -1.5, 1.5, -1, 1, 0] }}
                            whileTap={{ scale: 0.95 }}
                            transition={{ duration: 0.35 }}
                          >
                            <Trash2 className="h-4 w-4" />
                          </motion.button>
                        </div>
                      </td>
                    </motion.tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </motion.div>
      )}

      {/* Orders Table */}
      {tab === 'orders' && (
        <motion.div
          className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm"
          initial="hidden" animate="show" variants={fadeUp}
          transition={{ duration: 0.35, ease: EASE_OUT, delay: 0.08 }}
        >
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-gray-100 bg-[#0B1629]">
                  {['Order', 'Buyer', 'Items', 'Amount', 'Payment', 'Status', 'Actions'].map((h) => (
                    <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filteredOrders.length === 0 ? (
                  <tr><td colSpan={7} className="py-16 text-center text-sm text-gray-400">No orders found</td></tr>
                ) : (
                  filteredOrders.map((o, i) => (
                    <motion.tr
                      key={o.id}
                      custom={i}
                      variants={rowVariants}
                      initial="hidden"
                      animate="show"
                      className="border-b border-gray-50 last:border-0 hover:bg-[#0B1629]/5 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <p className="font-mono text-xs font-semibold text-[#0B1629]">{o.id.slice(0, 8).toUpperCase()}</p>
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
                          <motion.button
                            type="button"
                            onClick={() => setSelectedOrder(o)}
                            className="rounded-lg p-1.5 text-gray-400 hover:bg-[#0B1629]/5 hover:text-[#0B1629] transition-colors"
                            title="View details"
                            whileHover={{ scale: 1.08, y: -1 }}
                            whileTap={{ scale: 0.96 }}
                          >
                            <Eye className="h-4 w-4" />
                          </motion.button>
                          <motion.button
                            type="button"
                            onClick={() => setDeleteOrderTarget(o)}
                            className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors"
                            title="Delete"
                            whileHover={{ x: [0, -1.5, 1.5, -1, 1, 0] }}
                            whileTap={{ scale: 0.95 }}
                            transition={{ duration: 0.35 }}
                          >
                            <Trash2 className="h-4 w-4" />
                          </motion.button>
                        </div>
                      </td>
                    </motion.tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </motion.div>
      )}

      {/* ── Product Detail Drawer ── */}
      <AnimatePresence>
        {selectedProduct && (
          <>
            <motion.div
              className="fixed inset-0 z-40 bg-black/40 backdrop-blur-[3px]"
              variants={backdropVariants}
              initial="hidden"
              animate="show"
              exit="exit"
              onClick={() => setSelectedProduct(null)}
            />
            <motion.aside
              className="fixed inset-y-0 right-0 z-50 flex w-full max-w-md flex-col bg-white shadow-2xl"
              variants={drawerVariants}
              initial="hidden"
              animate="show"
              exit="exit"
            >
              {/* Gradient header */}
              <div
                className="relative flex-shrink-0 overflow-hidden px-6 pb-6 pt-7"
                style={{ background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 55%, #2C6E69 100%)' }}
              >
                <motion.div
                  className="pointer-events-none absolute inset-0 skew-x-[-20deg] bg-white/5"
                  animate={{ x: ['-120%', '220%'] }}
                  transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut', repeatDelay: 3 }}
                />
                <div className="pointer-events-none absolute -right-10 -top-10 h-48 w-48 rounded-full bg-white/5" />

                <button
                  type="button"
                  onClick={() => setSelectedProduct(null)}
                  className="absolute right-4 top-4 rounded-xl p-2 text-white/60 transition hover:bg-white/10 hover:text-white"
                  aria-label="Close"
                >
                  <X className="h-5 w-5" />
                </button>

                <div className="relative flex items-start gap-4">
                  <div className="relative flex-shrink-0">
                    {selectedProduct.images?.[0] ? (
                      <img
                        src={selectedProduct.images[0]}
                        alt={selectedProduct.name}
                        className="h-14 w-14 rounded-2xl object-cover ring-2 ring-white/30 shadow-lg"
                      />
                    ) : (
                      <div
                        className="flex h-14 w-14 items-center justify-center rounded-2xl ring-2 ring-white/30 shadow-lg"
                        style={{ background: 'linear-gradient(135deg, #0B1629, #1a3a5c)' }}
                      >
                        <Package className="h-7 w-7 text-white/80" />
                      </div>
                    )}
                  </div>

                  <div className="min-w-0 flex-1 pr-8">
                    <p className="text-xl font-black text-white leading-tight truncate">{selectedProduct.name}</p>
                    <p className="mt-0.5 text-sm text-white/55 truncate">{selectedProduct.category?.name || 'Uncategorized'}</p>
                    <div className="mt-2.5 flex flex-wrap items-center gap-2">
                      <Badge variant={selectedProduct.is_active ? 'success' : 'default'} className="border-0 bg-white/20 text-white ring-1 ring-white/25">
                        {selectedProduct.is_active ? 'Active' : 'Inactive'}
                      </Badge>
                      <span className="inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-1 text-[11px] font-semibold text-white ring-1 ring-white/15">
                        <DollarSign className="h-3 w-3" />
                        {selectedProduct.currency} {selectedProduct.price.toLocaleString()}
                      </span>
                      <span className="inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-1 text-[11px] font-semibold text-white ring-1 ring-white/15">
                        <Star className="h-3 w-3 fill-amber-400 text-amber-400" />
                        {selectedProduct.rating?.toFixed(1) || '0.0'}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Scrollable body */}
              <motion.div
                className="flex-1 overflow-y-auto"
                variants={drawerContentVariants}
                initial="hidden"
                animate="show"
              >
                <div className="space-y-4 p-6">

                  {/* Images grid */}
                  {selectedProduct.images && selectedProduct.images.length > 0 && (
                    <motion.section variants={drawerItemVariants}>
                      <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]">Photos</p>
                      <div className={`grid gap-2 ${selectedProduct.images.length === 1 ? 'grid-cols-1' : 'grid-cols-3'}`}>
                        {selectedProduct.images.slice(0, 3).map((url, i) => (
                          <motion.div
                            key={i}
                            className="overflow-hidden rounded-xl shadow-sm"
                            initial={{ opacity: 0, scale: 0.95 }}
                            animate={{ opacity: 1, scale: 1 }}
                            transition={{ duration: 0.3, delay: 0.1 + i * 0.07, ease: EASE_OUT }}
                            whileHover={{ scale: 1.02 }}
                          >
                            <img src={url} alt="" className="h-28 w-full object-cover" />
                          </motion.div>
                        ))}
                      </div>
                    </motion.section>
                  )}

                  {/* Description */}
                  {selectedProduct.description && (
                    <motion.div
                      className="rounded-2xl border border-[#0B1629]/15 bg-[#0B1629]/5 p-4"
                      style={{ borderLeft: '3px solid #0B1629' }}
                      variants={drawerItemVariants}
                    >
                      <p className="mb-1 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]">Description</p>
                      <p className="text-sm text-gray-700 leading-relaxed line-clamp-4">{selectedProduct.description}</p>
                    </motion.div>
                  )}

                  {/* Product details */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/15 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <Package className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]">Product Details</h3>
                    </div>
                    <div className="grid grid-cols-2 gap-x-6 gap-y-3 sm:grid-cols-3">
                      <MktField icon={<DollarSign className="h-3 w-3" />} label="Price" value={`${selectedProduct.currency} ${selectedProduct.price.toLocaleString()}`} />
                      <MktField icon={<Hash className="h-3 w-3" />} label="Stock" value={String(selectedProduct.stock_quantity)} />
                      <MktField icon={<Tag className="h-3 w-3" />} label="Pet Type" value={selectedProduct.pet_type || 'All'} />
                      <MktField icon={<ShoppingBag className="h-3 w-3" />} label="Total Sold" value={String(selectedProduct.total_sold)} />
                      <MktField icon={<Star className="h-3 w-3" />} label="Rating" value={`${selectedProduct.rating?.toFixed(1)} (${selectedProduct.total_reviews} reviews)`} />
                      <MktField icon={<Tag className="h-3 w-3" />} label="Category" value={selectedProduct.category?.name || '—'} />
                    </div>
                  </motion.section>

                  {/* Seller */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/15 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <User className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]">Seller</h3>
                    </div>
                    <div className="flex items-center gap-3 rounded-xl bg-white/70 px-4 py-3 shadow-sm">
                      {selectedProduct.seller?.avatar_url ? (
                        <img
                          src={selectedProduct.seller.avatar_url}
                          alt={selectedProduct.seller.display_name || ''}
                          className="h-10 w-10 flex-shrink-0 rounded-xl object-cover shadow-sm"
                        />
                      ) : (
                        <div
                          className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl text-sm font-black text-white shadow-sm"
                          style={{ background: 'linear-gradient(135deg, #0B1629, #1a3a5c)' }}
                        >
                          {(selectedProduct.seller?.display_name || selectedProduct.seller?.email || '?')[0].toUpperCase()}
                        </div>
                      )}
                      <div className="min-w-0">
                        <p className="font-bold text-gray-900 text-sm truncate">{selectedProduct.seller?.display_name || 'Unknown'}</p>
                        <p className="text-xs text-gray-400 truncate">{selectedProduct.seller?.email || '—'}</p>
                      </div>
                    </div>
                  </motion.section>

                  {/* Toggle status */}
                  <motion.section variants={drawerItemVariants}>
                    <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-gray-400">Product Status</p>
                    <button
                      type="button"
                      onClick={() => handleToggleProduct(selectedProduct.id, selectedProduct.is_active)}
                      disabled={isPending}
                      className={`rounded-xl border px-4 py-2 text-sm font-medium transition-colors disabled:opacity-50 ${selectedProduct.is_active ? 'border-yellow-200 text-yellow-700 hover:bg-yellow-50' : 'border-green-200 text-green-700 hover:bg-green-50'}`}
                    >
                      {selectedProduct.is_active ? 'Deactivate Product' : 'Activate Product'}
                    </button>
                  </motion.section>
                </div>
              </motion.div>

              {/* Sticky footer */}
              <div className="flex flex-shrink-0 flex-wrap items-center justify-between gap-3 border-t border-gray-100 bg-gray-50/60 px-6 py-4">
                <motion.button
                  type="button"
                  onClick={() => setSelectedProduct(null)}
                  className="rounded-xl border border-gray-200 bg-white px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-100"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.97 }}
                >
                  Close
                </motion.button>
                <motion.button
                  type="button"
                  onClick={() => { setSelectedProduct(null); setDeleteProductTarget(selectedProduct); }}
                  className="flex items-center gap-2 rounded-xl bg-red-500 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-red-600"
                  whileHover={{ scale: 1.02, x: [0, -2, 2, -1, 1, 0] }}
                  whileTap={{ scale: 0.97 }}
                  transition={{ duration: 0.35 }}
                >
                  <Trash2 className="h-4 w-4" />
                  Delete
                </motion.button>
              </div>
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      {/* ── Order Detail Drawer ── */}
      <AnimatePresence>
        {selectedOrder && (
          <>
            <motion.div
              className="fixed inset-0 z-40 bg-black/40 backdrop-blur-[3px]"
              variants={backdropVariants}
              initial="hidden"
              animate="show"
              exit="exit"
              onClick={() => setSelectedOrder(null)}
            />
            <motion.aside
              className="fixed inset-y-0 right-0 z-50 flex w-full max-w-md flex-col bg-white shadow-2xl"
              variants={drawerVariants}
              initial="hidden"
              animate="show"
              exit="exit"
            >
              {/* Gradient header */}
              <div
                className="relative flex-shrink-0 overflow-hidden px-6 pb-6 pt-7"
                style={{ background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 55%, #2C6E69 100%)' }}
              >
                <motion.div
                  className="pointer-events-none absolute inset-0 skew-x-[-20deg] bg-white/5"
                  animate={{ x: ['-120%', '220%'] }}
                  transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut', repeatDelay: 3 }}
                />
                <div className="pointer-events-none absolute -right-10 -top-10 h-48 w-48 rounded-full bg-white/5" />

                <button
                  type="button"
                  onClick={() => setSelectedOrder(null)}
                  className="absolute right-4 top-4 rounded-xl p-2 text-white/60 transition hover:bg-white/10 hover:text-white"
                  aria-label="Close"
                >
                  <X className="h-5 w-5" />
                </button>

                <div className="relative flex items-start gap-4">
                  <div
                    className="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-2xl bg-white/15 text-white shadow-lg ring-2 ring-white/25"
                    aria-hidden
                  >
                    <ShoppingBag className="h-7 w-7 opacity-90" />
                  </div>
                  <div className="min-w-0 flex-1 pr-8">
                    <p className="font-mono text-lg font-black tracking-tight text-white">
                      #{selectedOrder.id.slice(0, 8).toUpperCase()}
                    </p>
                    <p className="mt-0.5 text-sm text-white/55">{selectedOrder.buyer?.display_name || selectedOrder.buyer?.email || 'Unknown buyer'}</p>
                    <div className="mt-2.5 flex flex-wrap items-center gap-2">
                      <Badge variant={orderStatusVariant(selectedOrder.status)} className="border-0 bg-white/20 text-white ring-1 ring-white/25 capitalize">
                        {selectedOrder.status}
                      </Badge>
                      <Badge variant={paymentVariant(selectedOrder.payment_status)} className="border-0 bg-white/20 text-white ring-1 ring-white/25">
                        {selectedOrder.payment_status}
                      </Badge>
                      <span className="inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-1 text-[11px] font-semibold text-white ring-1 ring-white/15">
                        <DollarSign className="h-3 w-3" />
                        {selectedOrder.currency} {selectedOrder.total_amount.toLocaleString()}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Scrollable body */}
              <motion.div
                className="flex-1 overflow-y-auto"
                variants={drawerContentVariants}
                initial="hidden"
                animate="show"
              >
                <div className="space-y-4 p-6">

                  {/* Buyer + Shipping */}
                  <motion.div className="grid grid-cols-1 gap-3 sm:grid-cols-2" variants={drawerItemVariants}>
                    <div className="rounded-xl bg-[#0B1629]/5 p-4 ring-1 ring-[#0B1629]/10">
                      <p className="mb-2 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]">
                        <User className="h-3.5 w-3.5" /> Buyer
                      </p>
                      <div className="flex items-center gap-2">
                        {selectedOrder.buyer?.avatar_url ? (
                          <img
                            src={selectedOrder.buyer.avatar_url}
                            alt={selectedOrder.buyer.display_name || ''}
                            className="h-8 w-8 flex-shrink-0 rounded-lg object-cover"
                          />
                        ) : (
                          <div
                            className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg text-xs font-bold text-white"
                            style={{ background: 'linear-gradient(135deg, #0B1629, #1a3a5c)' }}
                          >
                            {(selectedOrder.buyer?.display_name || selectedOrder.buyer?.email || '?')[0].toUpperCase()}
                          </div>
                        )}
                        <div className="min-w-0">
                          <p className="text-sm font-bold text-gray-900 truncate">{selectedOrder.buyer?.display_name || '—'}</p>
                          <p className="text-xs text-gray-500 truncate">{selectedOrder.buyer?.email}</p>
                        </div>
                      </div>
                    </div>
                    <div className="rounded-xl bg-[#0B1629]/5 p-4 ring-1 ring-[#0B1629]/10">
                      <p className="mb-2 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]">
                        <MapPin className="h-3.5 w-3.5" /> Shipping
                      </p>
                      <p className="text-sm font-bold text-gray-900">{selectedOrder.shipping_city || '—'}</p>
                      <p className="text-xs text-gray-500 line-clamp-2">{selectedOrder.shipping_address}</p>
                    </div>
                  </motion.div>

                  {/* Order details */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/15 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <ShoppingBag className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]">Order Details</h3>
                    </div>
                    <div className="grid grid-cols-2 gap-x-6 gap-y-3 sm:grid-cols-3">
                      <MktField icon={<DollarSign className="h-3 w-3" />} label="Total" value={`${selectedOrder.currency} ${selectedOrder.total_amount.toLocaleString()}`} />
                      <MktField icon={<Tag className="h-3 w-3" />} label="Payment" value={selectedOrder.payment_method?.replace(/_/g, ' ') || '—'} />
                      <MktField icon={<Phone className="h-3 w-3" />} label="Phone" value={selectedOrder.shipping_phone || '—'} />
                      <MktField icon={<Hash className="h-3 w-3" />} label="Tracking #" value={selectedOrder.tracking_number || '—'} />
                    </div>
                    {selectedOrder.notes && (
                      <div className="mt-3 rounded-xl border border-gray-100 bg-white/60 px-3 py-2">
                        <p className="text-[11px] font-semibold uppercase text-gray-400">Notes</p>
                        <p className="mt-0.5 text-sm text-gray-700">{selectedOrder.notes}</p>
                      </div>
                    )}
                  </motion.section>

                  {/* Items */}
                  {selectedOrder.items && selectedOrder.items.length > 0 && (
                    <motion.section variants={drawerItemVariants}>
                      <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]">
                        Items ({selectedOrder.items.length})
                      </p>
                      <div className="space-y-2">
                        {selectedOrder.items.map((item) => (
                          <div key={item.id} className="flex items-center justify-between rounded-xl bg-gray-50 px-3 py-2 text-xs">
                            <div>
                              <p className="font-medium text-gray-800">{item.product?.name || '—'}</p>
                              <p className="text-gray-400">by {item.seller?.display_name || item.seller?.email}</p>
                            </div>
                            <div className="text-right">
                              <p className="font-semibold text-gray-800">
                                x{item.quantity} · {selectedOrder.currency} {item.total_price.toLocaleString()}
                              </p>
                              <Badge
                                variant={item.seller_status === 'delivered' ? 'success' : item.seller_status === 'cancelled' ? 'danger' : 'warning'}
                                className="text-[10px]"
                              >
                                {item.seller_status}
                              </Badge>
                            </div>
                          </div>
                        ))}
                      </div>
                    </motion.section>
                  )}

                  {/* Update status */}
                  <motion.section variants={drawerItemVariants}>
                    <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-gray-400">Change Status</p>
                    <div className="flex flex-wrap gap-2">
                      {ORDER_STATUSES.map((s) => (
                        <button
                          key={s}
                          type="button"
                          disabled={isPending || selectedOrder.status === s}
                          onClick={() => handleOrderStatus(selectedOrder.id, s)}
                          className={`rounded-lg px-3 py-1.5 text-xs font-medium capitalize transition-colors disabled:opacity-40 ${selectedOrder.status === s ? 'bg-[#0B1629] text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}`}
                        >
                          {s}
                        </button>
                      ))}
                    </div>
                  </motion.section>
                </div>
              </motion.div>

              {/* Sticky footer */}
              <div className="flex flex-shrink-0 flex-wrap items-center justify-between gap-3 border-t border-gray-100 bg-gray-50/60 px-6 py-4">
                <motion.button
                  type="button"
                  onClick={() => setSelectedOrder(null)}
                  className="rounded-xl border border-gray-200 bg-white px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-100"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.97 }}
                >
                  Close
                </motion.button>
                <motion.button
                  type="button"
                  onClick={() => { setSelectedOrder(null); setDeleteOrderTarget(selectedOrder); }}
                  className="flex items-center gap-2 rounded-xl bg-red-500 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-red-600"
                  whileHover={{ scale: 1.02, x: [0, -2, 2, -1, 1, 0] }}
                  whileTap={{ scale: 0.97 }}
                  transition={{ duration: 0.35 }}
                >
                  <Trash2 className="h-4 w-4" />
                  Delete
                </motion.button>
              </div>
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      {/* ── Delete Product Modal ── */}
      <DeleteConfirmModal
        open={!!deleteProductTarget}
        isPending={isPending}
        title="Delete product?"
        description={<>Permanently delete <strong>{deleteProductTarget?.name}</strong>? This will also remove all reviews and cart items.</>}
        preview={
          deleteProductTarget?.images?.[0] ? (
            <img src={deleteProductTarget.images[0]} alt="" className="h-10 w-10 rounded-xl object-cover" />
          ) : (
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-[#0B1629] ring-1 ring-red-100">
              <Package className="h-5 w-5" />
            </div>
          )
        }
        previewLabel={deleteProductTarget?.name || ''}
        previewSub={deleteProductTarget?.category?.name || '—'}
        onCancel={() => !isPending && setDeleteProductTarget(null)}
        onConfirm={() => deleteProductTarget && handleDeleteProduct(deleteProductTarget.id)}
      />

      {/* ── Delete Order Modal ── */}
      <DeleteConfirmModal
        open={!!deleteOrderTarget}
        isPending={isPending}
        title="Delete order?"
        description={<>Permanently delete order <strong>#{deleteOrderTarget?.id.slice(0, 8).toUpperCase()}</strong>? This will remove all order items.</>}
        preview={
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white font-mono text-xs font-bold text-[#0B1629] ring-1 ring-red-100">
            #
          </div>
        }
        previewLabel={`#${deleteOrderTarget?.id.slice(0, 8).toUpperCase() || ''}`}
        previewSub={deleteOrderTarget?.buyer?.display_name || deleteOrderTarget?.buyer?.email || '—'}
        onCancel={() => !isPending && setDeleteOrderTarget(null)}
        onConfirm={() => deleteOrderTarget && handleDeleteOrder(deleteOrderTarget.id)}
      />
    </>
  );
}

// ── Shared animated delete confirmation modal ────────────────────────────────

function DeleteConfirmModal({
  open,
  isPending,
  title,
  description,
  preview,
  previewLabel,
  previewSub,
  onCancel,
  onConfirm,
}: {
  open: boolean;
  isPending: boolean;
  title: string;
  description: ReactNode;
  preview: ReactNode;
  previewLabel: string;
  previewSub: string;
  onCancel: () => void;
  onConfirm: () => void;
}) {
  const warningControls = useAnimation();

  useEffect(() => {
    if (open) {
      warningControls.start({
        scale: [1, 1.15, 1],
        rotate: [0, -8, 8, 0],
        transition: { duration: 0.5, ease: [0.16, 1, 0.3, 1] },
      });
    }
  }, [open, warningControls]);

  return (
    <AnimatePresence>
      {open && (
        <motion.div className="fixed inset-0 z-[60] flex items-center justify-center p-4">
          <motion.div
            className="absolute inset-0 backdrop-blur-[2px]"
            onClick={onCancel}
            variants={deleteBackdropVariants}
            initial="hidden"
            animate="show"
            exit="exit"
          />
          <motion.div
            className="relative w-full max-w-md overflow-hidden rounded-3xl bg-white shadow-2xl ring-1 ring-red-200/40"
            variants={deleteModalVariants}
            initial="hidden"
            animate="show"
            exit="exit"
            style={{ transformOrigin: '85% 15%', transformPerspective: 1200 }}
          >
            <motion.div
              className="px-6 py-5"
              variants={deleteContentVariants}
              initial="hidden"
              animate="show"
            >
              <motion.div className="flex items-start gap-4" variants={deleteItemVariants}>
                <motion.div
                  className="flex h-12 w-12 items-center justify-center rounded-2xl bg-red-50 text-red-600 ring-1 ring-red-100"
                  animate={warningControls}
                >
                  <AlertTriangle className="h-6 w-6" />
                </motion.div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
                  <p className="mt-1 text-sm text-gray-500">{description}</p>
                </div>
              </motion.div>

              <motion.div
                className="mt-4 flex items-center gap-3 rounded-2xl border border-red-100 bg-red-50/40 p-3"
                variants={deleteItemVariants}
              >
                {preview}
                <div className="min-w-0">
                  <p className="truncate text-sm font-semibold text-gray-900">{previewLabel}</p>
                  <p className="truncate text-xs text-gray-500">{previewSub}</p>
                </div>
              </motion.div>

              <motion.div className="mt-5 flex gap-3" variants={deleteItemVariants}>
                <button
                  type="button"
                  disabled={isPending}
                  onClick={onCancel}
                  className="flex-1 rounded-xl border border-gray-200 bg-white py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-50 disabled:opacity-50"
                >
                  Cancel
                </button>
                <motion.button
                  type="button"
                  disabled={isPending}
                  onClick={onConfirm}
                  className="flex-1 rounded-xl bg-red-500 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-red-600 disabled:opacity-50"
                  whileHover={!isPending ? { scale: 1.02 } : {}}
                  whileTap={!isPending ? { scale: 0.98 } : {}}
                >
                  {isPending ? (
                    <span className="inline-flex items-center justify-center gap-2">
                      <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/70 border-t-transparent" />
                      Deleting…
                    </span>
                  ) : (
                    'Delete'
                  )}
                </motion.button>
              </motion.div>
            </motion.div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
