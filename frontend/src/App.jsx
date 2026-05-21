import { useState } from "react";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:8080";

export default function App() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [event, setEvent] = useState(null);

  const onPress = async () => {
    setLoading(true);
    setError("");

    try {
      const response = await fetch(`${API_BASE_URL}/api/click`, {
        method: "POST"
      });

      if (!response.ok) {
        throw new Error(`Request failed with status ${response.status}`);
      }

      const data = await response.json();
      setEvent(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Unknown error");
    } finally {
      setLoading(false);
    }
  };

  return (
    <main style={styles.main}>
      <section style={styles.panel}>
        <h1 style={styles.title}>Click Tracker</h1>
        <button style={styles.button} onClick={onPress} disabled={loading}>
          {loading ? "Saving..." : "Press me"}
        </button>

        {error && <p style={styles.error}>Error: {error}</p>}

        {event && (
          <p style={styles.result}>
            Saved event #{event.id} at {event.pressedAt} from {event.ipAddress}
          </p>
        )}
      </section>
    </main>
  );
}

const styles = {
  main: {
    minHeight: "100vh",
    display: "grid",
    placeItems: "center",
    padding: "1rem"
  },
  panel: {
    width: "min(640px, 100%)",
    background: "rgba(255,255,255,0.9)",
    borderRadius: "16px",
    padding: "2rem",
    boxShadow: "0 20px 40px rgba(30, 64, 175, 0.12)",
    textAlign: "center"
  },
  title: {
    marginTop: 0,
    marginBottom: "1.5rem"
  },
  button: {
    width: "100%",
    maxWidth: "420px",
    minHeight: "140px",
    border: "none",
    borderRadius: "16px",
    cursor: "pointer",
    fontSize: "2rem",
    fontWeight: 700,
    color: "white",
    background: "linear-gradient(135deg, #1d4ed8, #2563eb)",
    boxShadow: "0 12px 24px rgba(37,99,235,0.35)"
  },
  error: {
    marginTop: "1rem",
    color: "#b91c1c",
    fontWeight: 600
  },
  result: {
    marginTop: "1rem",
    color: "#065f46",
    fontWeight: 600,
    wordBreak: "break-word"
  }
};
