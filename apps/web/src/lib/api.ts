export const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL!;

export async function ingest({
  title,
  kind,
  file,
  text,
}: {
  title: string;
  kind: "cv" | "jd";
  file?: File;
  text?: string;
}) {
  const form = new FormData();
  form.set("title", title);
  form.set("kind", kind);
  if (file) form.set("file", file);
  if (text) form.set("text", text);

  const res = await fetch(`${API_BASE}/api/ingests`, {
    method: "POST",
    body: form,
  });
  if (!res.ok) throw new Error(`Ingest failed: ${await res.text()}`);
  return res.json() as Promise<{ id: number }>;
}

export async function ask(question: string) {
  const res = await fetch(`${API_BASE}/api/queries`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ question }),
  });
  if (!res.ok) throw new Error(`Query failed: ${await res.text()}`);
  return res.json() as Promise<{
    answer: string;
    sources: Array<{
      doc_id: number;
      title: string;
      kind: string;
      chunk_index: number;
    }>;
  }>;
}
