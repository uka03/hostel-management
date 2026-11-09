// Anonymous problem reports. See handler.ts for the privacy rules.
// Deploy with verify_jwt = false: authenticate() below checks the user.

import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2";
import { Caller, handle, ReportRow, ReportStore } from "./handler.ts";
import { sanitizePhoto } from "./photo.ts";

// Deliberately excludes author_hash, so it can't even reach the handler.
const COLUMNS =
  "id, category, location, description, status, reply, has_photo, created_hour";

function supabaseStore(db: SupabaseClient): ReportStore {
  return {
    async countByAuthorSince(authorHash, since) {
      const { count, error } = await db
        .from("reports")
        .select("id", { count: "exact", head: true })
        .eq("author_hash", authorHash)
        .gte("created_hour", since.toISOString());
      if (error) throw error;
      return count ?? 0;
    },
    async insert(report) {
      const { data, error } = await db
        .from("reports")
        .insert({
          author_hash: report.author_hash,
          category: report.category,
          location: report.location,
          description: report.description,
          has_photo: report.photo_base64 !== null,
        })
        .select(COLUMNS)
        .single();
      if (error) throw error;
      const row = data as ReportRow;
      if (report.photo_base64 !== null) {
        const { error: photoError } = await db
          .from("report_photos")
          .insert({ report_id: row.id, photo_base64: report.photo_base64 });
        if (photoError) {
          await db.from("reports").delete().eq("id", row.id);
          throw photoError;
        }
      }
      return row;
    },
    async list(limit) {
      const { data, error } = await db
        .from("reports")
        .select(COLUMNS)
        .order("created_hour", { ascending: false })
        .order("id")
        .limit(limit);
      if (error) throw error;
      return data as ReportRow[];
    },
    async find(id) {
      const { data, error } = await db
        .from("reports")
        .select(COLUMNS)
        .eq("id", id)
        .maybeSingle();
      if (error) throw error;
      return data as ReportRow | null;
    },
    async votes(reportIds) {
      if (reportIds.length === 0) return [];
      const { data, error } = await db
        .from("report_votes")
        .select("report_id, vote_hash")
        .in("report_id", reportIds);
      if (error) throw error;
      return data;
    },
    async addVote(voteHash, reportId) {
      const { error } = await db
        .from("report_votes")
        .upsert({ vote_hash: voteHash, report_id: reportId });
      if (error) throw error;
    },
    async removeVote(voteHash) {
      const { error } = await db
        .from("report_votes")
        .delete()
        .eq("vote_hash", voteHash);
      if (error) throw error;
    },
    async photo(reportId) {
      const { data, error } = await db
        .from("report_photos")
        .select("photo_base64")
        .eq("report_id", reportId)
        .maybeSingle();
      if (error) throw error;
      return data?.photo_base64 ?? null;
    },
    async update(id, changes) {
      const { data, error } = await db
        .from("reports")
        .update(changes)
        .eq("id", id)
        .select(COLUMNS)
        .maybeSingle();
      if (error) throw error;
      return data as ReportRow | null;
    },
  };
}

async function authenticate(
  db: SupabaseClient,
  request: Request,
): Promise<Caller | null> {
  const token = request.headers.get("Authorization")?.replace(/^Bearer /, "");
  if (!token) return null;
  const { data, error } = await db.auth.getUser(token);
  if (error || !data.user) return null;

  const { data: profile, error: profileError } = await db
    .from("profiles")
    .select("role, status")
    .eq("id", data.user.id)
    .maybeSingle();
  if (profileError) throw profileError;
  if (profile?.status !== "active") return null;
  return { id: data.user.id, role: profile.role };
}

Deno.serve((request) => {
  const db = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
  return handle(request, {
    secret: Deno.env.get("REPORTS_HMAC_SECRET"),
    authenticate: (r) => authenticate(db, r),
    store: supabaseStore(db),
    sanitizePhoto,
  });
});
