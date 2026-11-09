// Anonymous reports. Free of Supabase and Deno globals so it can be tested
// with fakes; index.ts supplies the real dependencies.
//
// PRIVACY: nothing here may log a user id, hash, report id or report text, and
// responses are built field by field in publicReport, so nothing about the
// author can reach a client even if a row carries it.

import { Buffer } from "node:buffer";

const CATEGORIES = ["noise", "hygiene", "damage", "safety", "other"];
const STATUSES = ["open", "in_progress", "resolved"];
const MAX_REPORTS_PER_DAY = 10;
const MAX_PHOTO_BASE64_LENGTH = 2_000_000;
const LIST_LIMIT = 100;

export interface Caller {
  id: string;
  role: "resident" | "manager";
}

export interface ReportRow {
  id: string;
  category: string;
  location: string;
  description: string;
  status: string;
  reply: string | null;
  has_photo: boolean;
  created_hour: string;
}

export interface NewReport {
  author_hash: string;
  category: string;
  location: string;
  description: string;
  photo_base64: string | null;
}

export interface ReportStore {
  countByAuthorSince(authorHash: string, since: Date): Promise<number>;
  insert(report: NewReport): Promise<ReportRow>;
  list(limit: number): Promise<ReportRow[]>;
  find(id: string): Promise<ReportRow | null>;
  votes(reportIds: string[]): Promise<{ report_id: string; vote_hash: string }[]>;
  addVote(voteHash: string, reportId: string): Promise<void>;
  removeVote(voteHash: string): Promise<void>;
  photo(reportId: string): Promise<string | null>;
  update(
    id: string,
    changes: { status: string; reply: string | null },
  ): Promise<ReportRow | null>;
}

export interface Deps {
  secret: string | undefined;
  /** The signed-in, active resident, or null. */
  authenticate(request: Request): Promise<Caller | null>;
  store: ReportStore;
  /** Returns a re-encoded JPEG with no metadata; throws if it isn't one. */
  sanitizePhoto(jpeg: Uint8Array): Uint8Array;
}

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

export async function hmac(secret: string, message: string): Promise<string> {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(message),
  );
  return [...new Uint8Array(signature)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

const voteHash = (secret: string, userId: string, reportId: string) =>
  hmac(secret, userId + reportId);

function roundedToHour(value: string): string {
  const date = new Date(value);
  date.setUTCMinutes(0, 0, 0);
  return date.toISOString();
}

/** The only shape a report ever leaves this function in. */
function publicReport(row: ReportRow, voteCount: number, voted: boolean) {
  return {
    id: row.id,
    category: row.category,
    location: row.location,
    description: row.description,
    status: row.status,
    reply: row.reply,
    has_photo: row.has_photo,
    created_at: roundedToHour(row.created_hour),
    vote_count: voteCount,
    voted,
  };
}

async function publicReports(
  deps: Deps,
  secret: string,
  caller: Caller,
  rows: ReportRow[],
) {
  const votes = await deps.store.votes(rows.map((r) => r.id));
  return Promise.all(rows.map(async (row) => {
    const hashes = votes.filter((v) => v.report_id === row.id);
    const mine = await voteHash(secret, caller.id, row.id);
    return publicReport(
      row,
      hashes.length,
      hashes.some((v) => v.vote_hash === mine),
    );
  }));
}

const isText = (value: unknown, max: number): value is string =>
  typeof value === "string" &&
  value.trim().length >= 1 &&
  value.trim().length <= max;

async function create(
  deps: Deps,
  secret: string,
  caller: Caller,
  // deno-lint-ignore no-explicit-any
  body: any,
) {
  if (
    !CATEGORIES.includes(body.category) ||
    !isText(body.location, 80) ||
    !isText(body.description, 500)
  ) {
    return json(400, { error_code: "invalid_report" });
  }

  const authorHash = await hmac(secret, caller.id);
  const dayAgo = new Date(Date.now() - 86_400_000);
  const recent = await deps.store.countByAuthorSince(authorHash, dayAgo);
  if (recent >= MAX_REPORTS_PER_DAY) {
    return json(429, { error_code: "over_report_limit" });
  }

  let photo: string | null = null;
  if (body.photo_base64 !== undefined && body.photo_base64 !== null) {
    if (
      typeof body.photo_base64 !== "string" ||
      body.photo_base64.length > MAX_PHOTO_BASE64_LENGTH
    ) {
      return json(400, { error_code: "invalid_photo" });
    }
    try {
      const clean = deps.sanitizePhoto(Buffer.from(body.photo_base64, "base64"));
      photo = Buffer.from(clean).toString("base64");
    } catch {
      return json(400, { error_code: "invalid_photo" });
    }
  }

  const row = await deps.store.insert({
    author_hash: authorHash,
    category: body.category,
    location: body.location.trim(),
    description: body.description.trim(),
    photo_base64: photo,
  });
  return json(200, { report: publicReport(row, 0, false) });
}

async function vote(
  deps: Deps,
  secret: string,
  caller: Caller,
  reportId: unknown,
  on: unknown,
) {
  if (typeof reportId !== "string" || typeof on !== "boolean") {
    return json(400, { error_code: "invalid_vote" });
  }
  if (!(await deps.store.find(reportId))) {
    return json(404, { error_code: "report_not_found" });
  }
  const hash = await voteHash(secret, caller.id, reportId);
  if (on) {
    await deps.store.addVote(hash, reportId);
  } else {
    await deps.store.removeVote(hash);
  }
  return json(200, { ok: true });
}

async function update(
  deps: Deps,
  caller: Caller,
  reportId: unknown,
  status: unknown,
  reply: unknown,
) {
  if (caller.role !== "manager") {
    return json(403, { error_code: "not_manager" });
  }
  const replyText = typeof reply === "string" && reply.trim() !== ""
    ? reply.trim()
    : null;
  if (
    typeof reportId !== "string" ||
    typeof status !== "string" ||
    !STATUSES.includes(status) ||
    (reply !== null && reply !== undefined && typeof reply !== "string") ||
    (replyText !== null && replyText.length > 500)
  ) {
    return json(400, { error_code: "invalid_update" });
  }
  const row = await deps.store.update(reportId, { status, reply: replyText });
  if (!row) return json(404, { error_code: "report_not_found" });
  return json(200, { ok: true });
}

export async function handle(request: Request, deps: Deps): Promise<Response> {
  if (request.method !== "POST") return json(405, { error_code: "method" });

  const secret = deps.secret;
  if (!secret) {
    console.error("REPORTS_HMAC_SECRET is not set");
    return json(500, { error_code: "not_configured" });
  }

  try {
    const caller = await deps.authenticate(request);
    if (!caller) return json(401, { error_code: "not_authorized" });

    const body = await request.json();
    switch (body.action) {
      case "list": {
        const rows = await deps.store.list(LIST_LIMIT);
        return json(200, {
          reports: await publicReports(deps, secret, caller, rows),
        });
      }
      case "create":
        return await create(deps, secret, caller, body);
      case "vote":
        return await vote(deps, secret, caller, body.report_id, body.voted);
      case "photo": {
        if (typeof body.report_id !== "string") {
          return json(400, { error_code: "invalid_report" });
        }
        const photo = await deps.store.photo(body.report_id);
        if (photo === null) return json(404, { error_code: "photo_not_found" });
        return json(200, { photo_base64: photo });
      }
      case "update":
        return await update(
          deps,
          caller,
          body.report_id,
          body.status,
          body.reply,
        );
      default:
        return json(400, { error_code: "invalid_action" });
    }
  } catch (e) {
    // The name only: error messages can quote the values involved.
    console.error(`reports failed: ${e instanceof Error ? e.name : "unknown"}`);
    return json(500, { error_code: "internal" });
  }
}
