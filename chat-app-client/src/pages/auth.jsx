import { useAuth } from "../hooks/useAuth";
import { authStyles as styles } from "../utils/styles";

function Auth({ setCurrentUser }) {

  const {
    email,
    setEmail,

    password,
    setPassword,

    handleSubmit,

    loading,

    username,
    setUsername,

    register,
    setRegister,

    error,
    setError,

  } = useAuth(null, setCurrentUser);


  const handleModeChange = () => {
    setRegister((prev) => !prev);
    setError("");
    setEmail("");
    setPassword("");
    setUsername("");
  };


  return (
    <div style={styles.container}>

      {/* =========================
          BRANDING
          ========================= */}

      <div style={styles.brandSection}>

        <div style={styles.logo}>
          Z
        </div>

        <h1 style={styles.brandName}>
          ZIDD 2.0
        </h1>

        <div style={styles.batchBadge}>
          BATCH 2
        </div>

        <p style={styles.tagline}>
          Build. Deploy. Collaborate.
        </p>

      </div>


      {/* =========================
          AUTH CARD
          ========================= */}

      <div style={styles.card}>

        <div style={styles.cardHeader}>

          <h2 style={styles.heading}>
            {register
              ? "Create your account"
              : "Welcome back"}
          </h2>

          <p style={styles.subtitle}>
            {register
              ? "Join the ZIDD 2.0 community"
              : "Sign in to continue to your workspace"}
          </p>

        </div>


        {/* =========================
            ERROR MESSAGE
            ========================= */}

        {error && (
          <div
            style={{
              marginTop: "16px",
              marginBottom: "4px",
              padding: "10px 12px",
              borderRadius: "8px",
              border: "1px solid rgba(239, 68, 68, 0.35)",
              background:
                "rgba(239, 68, 68, 0.10)",
              color: "#fca5a5",
              fontSize: "13px",
              lineHeight: "1.4",
            }}
            role="alert"
          >
            {error}
          </div>
        )}


        {/* =========================
            FORM
            ========================= */}

        <form
          style={styles.form}
          onSubmit={handleSubmit}
        >

          {/* Full Name */}

          {register && (
            <div style={styles.fieldGroup}>

              <label style={styles.label}>
                Full Name
              </label>

              <input
                type="text"
                name="full-name"
                placeholder="Enter your full name"
                style={styles.input}
                value={username}
                onChange={(e) => {
                  setUsername(e.target.value);
                  setError("");
                }}
                required
              />

            </div>
          )}


          {/* Email */}

          <div style={styles.fieldGroup}>

            <label style={styles.label}>
              Email
            </label>

            <input
              type="email"
              placeholder="you@example.com"
              style={styles.input}
              value={email}
              onChange={(e) => {
                setEmail(e.target.value);
                setError("");
              }}
              required
            />

          </div>


          {/* Password */}

          <div style={styles.fieldGroup}>

            <label style={styles.label}>
              Password
            </label>

            <input
              type="password"
              placeholder="Enter your password"
              style={styles.input}
              value={password}
              onChange={(e) => {
                setPassword(e.target.value);
                setError("");
              }}
              required
            />

          </div>


          {/* Submit */}

          <button
            type="submit"
            style={styles.button}
            disabled={loading}
          >

            {loading
              ? register
                ? "Creating Account..."
                : "Signing In..."
              : register
              ? "Create Account"
              : "Sign In"}

          </button>


          {/* Switch */}

          <div style={styles.switchSection}>

            <p style={styles.noAccount}>

              {register
                ? "Already have an account?"
                : "Don't have an account?"}

              <span
                style={styles.noAccountLink}
                onClick={handleModeChange}
              >
                {register
                  ? " Sign In"
                  : " Create Account"}
              </span>

            </p>

          </div>

        </form>

      </div>


      {/* =========================
          FOOTER
          ========================= */}

      <p style={styles.footer}>
        ZIDD 2.0 • Batch 2
      </p>

    </div>
  );
}

export default Auth;