'use server';

import { createClient } from '@supabase/supabase-js';

function getAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    { auth: { persistSession: false } }
  );
}

export async function updateVetVerification(vetId: string, isVerified: boolean) {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase
      .from('vet_profiles')
      .update({ is_verified: isVerified })
      .eq('id', vetId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (err) {
    return { success: false, error: String(err) };
  }
}
