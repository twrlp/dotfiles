export function duration(minutes) {
  if (minutes === 300) return "5h";
  if (minutes === 10080) return "week";
  if (!minutes) return "limit";
  if (minutes % 1440 === 0) return `${minutes / 1440}d`;
  return minutes % 60 === 0 ? `${minutes / 60}h` : `${minutes}m`;
}

export function countdown(seconds) {
  if (seconds <= 0) return "awaiting update";
  const mins = Math.ceil(seconds / 60);
  if (mins < 60) return `${mins}m`;
  if (mins < 1440) return `${Math.floor(mins / 60)}h ${mins % 60}m`;
  return `${Math.floor(mins / 1440)}d ${Math.floor((mins % 1440) / 60)}h`;
}

export function view(reading, error, now, providerId = "codex", status = null) {
  const emptyStates = { signed_out: "not signed in", not_installed: "not installed", no_limits: "no subscription limits", error: "unavailable" };
  // An auth/account state change invalidates the former account's reading.
  if (["signed_out", "not_installed", "no_limits"].includes(status)) {
    return { rows: [], dim: true, detail: error || emptyStates[status], status: emptyStates[status] };
  }
  const stale = Boolean(reading && now - reading.observedAt > 900);
  const dim = Boolean(error || stale);
  const details = reading ? [`Updated ${new Date(reading.observedAt * 1000).toLocaleTimeString()}`] : [];
  if (error) details.unshift(error);
  if (stale) details.unshift("Stale reading");
  const rows = (reading?.windows ?? []).map((w) => {
    const label = `${w.name === providerId ? "" : `${w.name} `}${duration(w.minutes)}`;
    const expired = w.resetsAt != null && w.resetsAt <= now;
    const used = expired ? "—" : `${Math.round(w.used)}%`;
    const remaining = expired ? "—" : `${Math.round(Math.max(0, Math.min(100, 100 - w.used)))}%`;
    const compactLabel = w.minutes === 300 ? "5h" : w.minutes === 10080 ? "7d" : duration(w.minutes);
    const resetAt = w.resetsAt ? new Date(w.resetsAt * 1000).toLocaleString([], {
      weekday: "short", hour: "numeric", minute: "2-digit",
    }) : null;
    details.push(`${label}: ${remaining}${expired ? " (awaiting update)" : " remaining"}${w.resetsAt ? ` · resets ${new Date(w.resetsAt * 1000).toLocaleString()}` : ""}`);
    return { label, compactLabel, used, remaining, resetAt, reset: w.resetsAt ? countdown(w.resetsAt - now) : null,
      level: expired ? "dim" : w.used >= 90 ? "hot" : w.used >= 70 ? "warn" : "normal" };
  });
  return { rows, dim, detail: details.join("\n"), status: error ? (reading ? "!" : "unavailable") : stale ? "stale" : reading ? "" : "…" };
}
