"use client";
import { useState } from "react";
import { ingest } from "@/lib/api";

export default function UploadPage() {
  const [title, setTitle] = useState("");
  const [kind, setKind] = useState<"cv" | "jd">("cv");
  const [file, setFile] = useState<File | undefined>();
  const [text, setText] = useState("");
  const [status, setStatus] = useState<string>("");

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setStatus("Uploading…");
    try {
      await ingest({ title, kind, file, text: file ? undefined : text });
      setStatus("Uploaded & embedded ✓");
      setTitle("");
      setText("");
      setFile(undefined);
    } catch (err: any) {
      setStatus(err.message ?? "Error");
    }
  }

  return (
    <div style={{ maxWidth: 720, margin: "40px auto", padding: 16 }}>
      <h1>Upload CV/JD</h1>
      <form onSubmit={onSubmit}>
        <label>
          Title
          <br />
          <input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            required
          />
        </label>
        <div style={{ marginTop: 12 }}>
          <label>
            Kind:
            <select
              value={kind}
              onChange={(e) => setKind(e.target.value as any)}
            >
              <option value="cv">CV</option>
              <option value="jd">JD</option>
            </select>
          </label>
        </div>
        <div style={{ marginTop: 12 }}>
          <label>
            PDF File (optional)
            <br />
            <input
              type="file"
              accept="application/pdf"
              onChange={(e) => setFile(e.target.files?.[0])}
            />
          </label>
        </div>
        {!file && (
          <div style={{ marginTop: 12 }}>
            <label>
              Or paste text
              <br />
              <textarea
                value={text}
                onChange={(e) => setText(e.target.value)}
                rows={6}
              />
            </label>
          </div>
        )}
        <button type="submit" style={{ marginTop: 16 }}>
          Ingest
        </button>
      </form>
      <p style={{ marginTop: 12 }}>{status}</p>
    </div>
  );
}
