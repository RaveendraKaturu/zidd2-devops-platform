import React from "react";

function Loading() {
  return (
    <div
      style={{
        minHeight: "100dvh",
        width: "100%",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background:
          "radial-gradient(circle at top, #18213a 0%, #0b1120 45%, #060b16 100%)",
        color: "#f8fafc",
        fontFamily:
          "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
      }}
    >
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          textAlign: "center",
        }}
      >
        {/* Logo */}
        <div
          style={{
            width: "58px",
            height: "58px",
            borderRadius: "16px",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: "28px",
            fontWeight: "800",
            background: "linear-gradient(135deg, #6366f1, #8b5cf6)",
            boxShadow: "0 12px 35px rgba(99, 102, 241, 0.3)",
            marginBottom: "16px",
          }}
        >
          Z
        </div>

        {/* Brand */}
        <div
          style={{
            fontSize: "25px",
            fontWeight: "800",
            letterSpacing: "0.5px",
          }}
        >
          ZIDD <span style={{ color: "#818cf8" }}>2.0</span>
        </div>

        <div
          style={{
            marginTop: "7px",
            fontSize: "10px",
            fontWeight: "700",
            letterSpacing: "1.5px",
            color: "#a5b4fc",
          }}
        >
          BATCH 2
        </div>

        <div
          style={{
            marginTop: "8px",
            fontSize: "13px",
            color: "#94a3b8",
          }}
        >
          Build. Deploy. Collaborate.
        </div>

        {/* Loader */}
        <div
          style={{
            width: "32px",
            height: "32px",
            marginTop: "28px",
            border: "3px solid #1e293b",
            borderTop: "3px solid #818cf8",
            borderRadius: "50%",
            animation: "zidd-spin 0.9s linear infinite",
          }}
        />

        <div
          style={{
            marginTop: "14px",
            fontSize: "12px",
            color: "#64748b",
          }}
        >
          Loading workspace...
        </div>
      </div>

      <style>
        {`
          @keyframes zidd-spin {
            from {
              transform: rotate(0deg);
            }
            to {
              transform: rotate(360deg);
            }
          }
        `}
      </style>
    </div>
  );
}

export default Loading;