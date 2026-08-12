export const authStyles = {
  container: {
    minHeight: "100dvh",
    width: "100%",
    boxSizing: "border-box",
    padding: "30px 20px",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    fontFamily:
      "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
    background:
      "radial-gradient(circle at top, #18213a 0%, #0b1120 45%, #060b16 100%)",
    color: "#f8fafc",
  },

  /* ZIDD Branding */
  brandSection: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    marginBottom: "25px",
  },

  logo: {
    width: "48px",
    height: "48px",
    borderRadius: "14px",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "24px",
    fontWeight: "800",
    color: "#ffffff",
    background: "linear-gradient(135deg, #6366f1, #8b5cf6)",
    boxShadow: "0 10px 30px rgba(99, 102, 241, 0.3)",
    marginBottom: "10px",
  },

  brandName: {
    margin: "0",
    fontSize: "28px",
    fontWeight: "800",
    letterSpacing: "0.5px",
  },

  batchBadge: {
    marginTop: "8px",
    padding: "4px 10px",
    borderRadius: "20px",
    fontSize: "10px",
    fontWeight: "700",
    letterSpacing: "1.5px",
    color: "#c7d2fe",
    background: "rgba(99, 102, 241, 0.15)",
    border: "1px solid rgba(99, 102, 241, 0.35)",
  },

  tagline: {
    margin: "10px 0 0",
    fontSize: "13px",
    color: "#94a3b8",
    letterSpacing: "0.3px",
  },

  /* Auth Card */
  card: {
    width: "100%",
    maxWidth: "430px",
    boxSizing: "border-box",
    padding: "30px",
    borderRadius: "18px",
    background: "rgba(17, 24, 39, 0.92)",
    border: "1px solid rgba(148, 163, 184, 0.12)",
    boxShadow: "0 25px 60px rgba(0, 0, 0, 0.35)",
    backdropFilter: "blur(12px)",
  },

  cardHeader: {
    marginBottom: "25px",
  },

  heading: {
    margin: "0",
    fontSize: "24px",
    fontWeight: "700",
    color: "#f8fafc",
  },

  subtitle: {
    margin: "8px 0 0",
    fontSize: "13px",
    lineHeight: "1.5",
    color: "#94a3b8",
  },

  form: {
    width: "100%",
  },

  fieldGroup: {
    marginBottom: "17px",
  },

  label: {
    display: "block",
    marginBottom: "7px",
    fontSize: "13px",
    fontWeight: "600",
    color: "#cbd5e1",
  },

  input: {
    width: "100%",
    boxSizing: "border-box",
    padding: "13px 14px",
    borderRadius: "9px",
    border: "1px solid #334155",
    outline: "none",
    fontSize: "14px",
    fontFamily:
      "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
    color: "#f8fafc",
    backgroundColor: "#0f172a",
  },

  button: {
    width: "100%",
    boxSizing: "border-box",
    padding: "13px",
    marginTop: "8px",
    borderRadius: "9px",
    border: "none",
    background: "linear-gradient(135deg, #6366f1, #7c3aed)",
    color: "#ffffff",
    cursor: "pointer",
    fontSize: "14px",
    fontWeight: "700",
    fontFamily:
      "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
    letterSpacing: "0.2px",
    boxShadow: "0 8px 20px rgba(99, 102, 241, 0.25)",
  },

  switchSection: {
    marginTop: "22px",
  },

  noAccount: {
    textAlign: "center",
    margin: "0",
    fontSize: "13px",
    color: "#94a3b8",
  },

  noAccountLink: {
    color: "#818cf8",
    cursor: "pointer",
    fontWeight: "700",
    marginLeft: "4px",
  },

  footer: {
    marginTop: "20px",
    marginBottom: "0",
    fontSize: "11px",
    color: "#64748b",
    letterSpacing: "0.5px",
  },
};