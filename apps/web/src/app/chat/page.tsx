"use client";
import { useState } from "react";
import { ask } from "@/lib/api";

type Source = { doc_id:number; title:string; kind:string; chunk_index:number };

export default function ChatPage(){
  const [q, setQ] = useState("");
  const [answer, setAnswer] = useState("");
  const [sources, setSources] = useState<Source[]>([]);
  const [status, setStatus] = useState("");

  async function onAsk(e: React.FormEvent){
    e.preventDefault();
    setStatus("Thinking…");
    try {
      const res = await ask(q);
      setAnswer(res.answer);
      setSources(res.sources);
      setStatus("");
    } catch (err:any){
      setStatus(err.message ?? "Error");
    }
  }

  return (
    <div style={{maxWidth: 720, margin: "40px auto", padding: 16}}>
      <h1>Interview Copilot</h1>
      <form onSubmit={onAsk}>
        <input value={q} onChange={e=>setQ(e.target.value)} placeholder="Ask: What should I emphasize?" style={{width:"100%"}}/>
        <button type="submit" style={{marginTop:12}}>Ask</button>
      </form>

      {status && <p style={{marginTop:12}}>{status}</p>}

      {answer && (
        <>
          <h3 style={{marginTop:24}}>Answer</h3>
          <p>{answer}</p>
        </>
      )}

      {sources.length > 0 && (
        <>
          <h3 style={{marginTop:16}}>Sources</h3>
          <ul>
            {sources.map((s, i)=>(
              <li key={i}>[{s.kind.toUpperCase()}] {s.title} (chunk #{s.chunk_index})</li>
            ))}
          </ul>
        </>
      )}
    </div>
  );
}