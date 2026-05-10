'use client';

import { useState, useTransition } from 'react';
import Badge from '@/components/Badge';
import { Search, Eye, Trash2, X, MessageSquare } from 'lucide-react';
import { timeAgo, formatDateTime } from '@/lib/utils';
import { deleteChat, deleteMessage } from '@/lib/admin-actions';

interface ChatMessage {
  id: string;
  chat_id: string;
  sender_id: string;
  content: string;
  is_read: boolean;
  created_at: string;
  sender: { name: string | null; email: string | null; avatar: string | null } | null;
}

interface Chat {
  id: string;
  pet_owner_id: string;
  vet_id: string;
  pet_id: string | null;
  last_message: string | null;
  last_message_at: string | null;
  unread_count_owner: number;
  unread_count_vet: number;
  created_at: string;
  updated_at: string;
  owner: { name: string | null; email: string | null; avatar: string | null } | null;
  vet: { name: string | null; email: string | null; avatar: string | null } | null;
  messages: ChatMessage[];
  message_count: number;
}

export default function ChatsClient({ chats: initialChats }: { chats: Chat[] }) {
  const [chats, setChats] = useState(initialChats);
  const [search, setSearch] = useState('');
  const [selectedChat, setSelectedChat] = useState<Chat | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Chat | null>(null);
  const [isPending, startTransition] = useTransition();

  const filtered = chats.filter((chat) => {
    const q = search.toLowerCase();
    if (!q) return true;
    return (
      (chat.owner?.name ?? '').toLowerCase().includes(q) ||
      (chat.owner?.email ?? '').toLowerCase().includes(q) ||
      (chat.vet?.name ?? '').toLowerCase().includes(q) ||
      (chat.vet?.email ?? '').toLowerCase().includes(q) ||
      (chat.last_message ?? '').toLowerCase().includes(q)
    );
  });

  const totalMessages = chats.reduce((sum, c) => sum + c.message_count, 0);

  function handleDeleteChat(id: string) {
    startTransition(async () => {
      const res = await deleteChat(id);
      if (res.success) {
        setChats((prev) => prev.filter((c) => c.id !== id));
        setDeleteTarget(null);
        if (selectedChat?.id === id) setSelectedChat(null);
      }
    });
  }

  function handleDeleteMessage(msgId: string) {
    startTransition(async () => {
      const res = await deleteMessage(msgId);
      if (res.success) {
        setChats((prev) =>
          prev.map((c) => ({
            ...c,
            messages: c.messages.filter((m) => m.id !== msgId),
            message_count: c.messages.filter((m) => m.id !== msgId).length,
          }))
        );
        if (selectedChat) {
          setSelectedChat((prev) =>
            prev
              ? {
                  ...prev,
                  messages: prev.messages.filter((m) => m.id !== msgId),
                  message_count: prev.messages.filter((m) => m.id !== msgId).length,
                }
              : prev
          );
        }
      }
    });
  }

  function displayName(user: { name: string | null; email: string | null } | null) {
    return user?.name || user?.email || 'Unknown';
  }

  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Chats & Messages</h1>
        <p className="mt-1 text-sm text-gray-500">
          {chats.length} conversations — {totalMessages} total messages
        </p>
      </div>

      {/* Search */}
      <div className="mb-4">
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by participant name, email, or message…"
            className="w-full rounded-xl border border-gray-200 bg-white py-2 pl-10 pr-4 text-sm focus:border-[#2C6E69] focus:outline-none focus:ring-1 focus:ring-[#2C6E69]"
          />
        </div>
      </div>

      {/* Chat List */}
      <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-[#0B1629]">
                {['Pet Owner', 'Vet', 'Last Message', 'Messages', 'Unread', 'Last Active', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-white">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-16 text-center text-sm text-gray-400">
                    No chats found
                  </td>
                </tr>
              ) : (
                filtered.map((chat) => (
                  <tr key={chat.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        {chat.owner?.avatar ? (
                          <img src={chat.owner.avatar} alt="" className="h-7 w-7 rounded-full object-cover" />
                        ) : (
                          <div className="flex h-7 w-7 items-center justify-center rounded-full bg-blue-100 text-xs font-bold text-blue-600">
                            {(chat.owner?.name ?? '?')[0]?.toUpperCase()}
                          </div>
                        )}
                        <span className="text-sm text-gray-700">{displayName(chat.owner)}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        {chat.vet?.avatar ? (
                          <img src={chat.vet.avatar} alt="" className="h-7 w-7 rounded-full object-cover" />
                        ) : (
                          <div className="flex h-7 w-7 items-center justify-center rounded-full bg-[#B3E0DB] text-xs font-bold text-[#2C6E69]">
                            {(chat.vet?.name ?? '?')[0]?.toUpperCase()}
                          </div>
                        )}
                        <span className="text-sm text-gray-700">{displayName(chat.vet)}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-500 max-w-[200px] truncate">
                      {chat.last_message || '—'}
                    </td>
                    <td className="px-4 py-3">
                      <Badge variant="default">
                        <MessageSquare className="mr-1 inline h-3 w-3" />
                        {chat.message_count}
                      </Badge>
                    </td>
                    <td className="px-4 py-3">
                      {(chat.unread_count_owner + chat.unread_count_vet) > 0 ? (
                        <Badge variant="warning">{chat.unread_count_owner + chat.unread_count_vet}</Badge>
                      ) : (
                        <span className="text-xs text-gray-400">0</span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-400">
                      {chat.last_message_at ? timeAgo(chat.last_message_at) : timeAgo(chat.updated_at)}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1">
                        <button onClick={() => setSelectedChat(chat)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69]">
                          <Eye className="h-4 w-4" />
                        </button>
                        <button onClick={() => setDeleteTarget(chat)} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500">
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

      {/* Message Viewer Drawer */}
      {selectedChat && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelectedChat(null)} />
          <div className="relative flex w-full max-w-lg flex-col bg-white shadow-2xl">
            {/* Header */}
            <div className="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-6 py-4">
              <div>
                <h2 className="text-lg font-bold text-gray-900">Chat Messages</h2>
                <p className="text-xs text-gray-500">
                  {displayName(selectedChat.owner)} ↔ {displayName(selectedChat.vet)}
                </p>
              </div>
              <button onClick={() => setSelectedChat(null)} className="rounded-lg p-2 hover:bg-gray-100">
                <X className="h-5 w-5" />
              </button>
            </div>

            {/* Chat Info */}
            <div className="border-b bg-gray-50 px-6 py-3">
              <div className="flex items-center justify-between text-xs text-gray-500">
                <span>{selectedChat.message_count} messages</span>
                <span>Started {formatDateTime(selectedChat.created_at)}</span>
              </div>
            </div>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto p-4 space-y-3">
              {selectedChat.messages.length === 0 ? (
                <p className="py-8 text-center text-sm text-gray-400">No messages in this chat</p>
              ) : (
                selectedChat.messages.map((msg) => {
                  const isOwner = msg.sender_id === selectedChat.pet_owner_id;
                  return (
                    <div key={msg.id} className={`flex ${isOwner ? 'justify-start' : 'justify-end'}`}>
                      <div className={`group relative max-w-[80%] rounded-xl px-3 py-2 ${
                        isOwner ? 'bg-gray-100 text-gray-800' : 'bg-[#2C6E69] text-white'
                      }`}>
                        <p className={`text-[10px] font-semibold mb-0.5 ${isOwner ? 'text-gray-500' : 'text-white/70'}`}>
                          {msg.sender?.name || msg.sender?.email || 'Unknown'}
                          {isOwner ? ' (Owner)' : ' (Vet)'}
                        </p>
                        <p className="text-sm whitespace-pre-wrap">{msg.content}</p>
                        <p className={`text-[10px] mt-1 ${isOwner ? 'text-gray-400' : 'text-white/60'}`}>
                          {formatDateTime(msg.created_at)}
                          {!msg.is_read && <span className="ml-1">• unread</span>}
                        </p>
                        <button
                          onClick={() => handleDeleteMessage(msg.id)}
                          className={`absolute -top-2 -right-2 hidden group-hover:flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-white text-xs shadow`}
                          title="Delete message"
                        >
                          ×
                        </button>
                      </div>
                    </div>
                  );
                })
              )}
            </div>

            {/* Footer */}
            <div className="border-t bg-white px-6 py-4 space-y-3">
              <p className="text-xs text-gray-300">Chat ID: {selectedChat.id}</p>
              <button
                onClick={() => { setSelectedChat(null); setDeleteTarget(selectedChat); }}
                className="w-full rounded-xl bg-red-50 py-2.5 text-sm font-medium text-red-600 hover:bg-red-100 transition-colors"
              >
                Delete Entire Chat
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Modal */}
      {deleteTarget && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div className="absolute inset-0 bg-black/30" onClick={() => setDeleteTarget(null)} />
          <div className="relative w-full max-w-sm rounded-2xl bg-white p-6 shadow-2xl">
            <h3 className="text-lg font-bold text-gray-900">Delete Chat</h3>
            <p className="mt-2 text-sm text-gray-500">
              Permanently delete the conversation between <strong>{displayName(deleteTarget.owner)}</strong> and{' '}
              <strong>{displayName(deleteTarget.vet)}</strong>? All {deleteTarget.message_count} messages will be removed. This cannot be undone.
            </p>
            <div className="mt-5 flex gap-3">
              <button onClick={() => setDeleteTarget(null)} className="flex-1 rounded-xl border border-gray-200 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">
                Cancel
              </button>
              <button
                disabled={isPending}
                onClick={() => handleDeleteChat(deleteTarget.id)}
                className="flex-1 rounded-xl bg-red-600 py-2 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-50"
              >
                {isPending ? 'Deleting…' : 'Delete'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
