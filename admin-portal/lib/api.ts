const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';

async function apiFetch<T>(
  path: string,
  options?: RequestInit
): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      ...options?.headers,
    },
  });
  if (!res.ok) {
    throw new Error(`API error: ${res.status} ${res.statusText}`);
  }
  return res.json();
}

export const api = {
  get: <T>(path: string, headers?: HeadersInit) =>
    apiFetch<T>(path, { method: 'GET', headers }),

  post: <T>(path: string, body: unknown, headers?: HeadersInit) =>
    apiFetch<T>(path, {
      method: 'POST',
      body: JSON.stringify(body),
      headers,
    }),

  put: <T>(path: string, body: unknown, headers?: HeadersInit) =>
    apiFetch<T>(path, {
      method: 'PUT',
      body: JSON.stringify(body),
      headers,
    }),

  delete: <T>(path: string, headers?: HeadersInit) =>
    apiFetch<T>(path, { method: 'DELETE', headers }),
};
