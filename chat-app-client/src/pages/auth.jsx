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
  } = useAuth(null, setCurrentUser);

  return (
    <div style={styles.container}>
      {/* Branding */}
      <div style={styles.brandSection}>
        <div style={styles.logo}>Z</div>

        <h1 style={styles.brandName}>ZIDD 2.0</h1>

        <div style={styles.batchBadge}>BATCH 2</div>

        <p style={styles.tagline}>Build. Deploy. Collaborate.</p>
      </div>

      {/* Auth Card */}
      <div style={styles.card}>
        <div style={styles.cardHeader}>
          <h2 style={styles.heading}>
            {register ? "Create your account" : "Welcome back"}
          </h2>

          <p style={styles.subtitle}>
            {register
              ? "Join the ZIDD 2.0 community"
              : "Sign in to continue to your workspace"}
          </p>
        </div>

        <form style={styles.form} onSubmit={handleSubmit}>
          {register && (
            <div style={styles.fieldGroup}>
              <label style={styles.label}>Full Name</label>

              <input
                type="text"
                name="full-name"
                placeholder="Enter your full name"
                style={styles.input}
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
              />
            </div>
          )}

          <div style={styles.fieldGroup}>
            <label style={styles.label}>Email</label>

            <input
              type="email"
              placeholder="you@example.com"
              style={styles.input}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div style={styles.fieldGroup}>
            <label style={styles.label}>Password</label>

            <input
              type="password"
              placeholder="Enter your password"
              style={styles.input}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

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

          <div style={styles.switchSection}>
            <p style={styles.noAccount}>
              {register
                ? "Already have an account?"
                : "Don't have an account?"}

              <span
                style={styles.noAccountLink}
                onClick={() => setRegister((prev) => !prev)}
              >
                {register ? " Sign In" : " Create Account"}
              </span>
            </p>
          </div>
        </form>
      </div>

      {/* Footer */}
      <p style={styles.footer}>
        ZIDD 2.0 • Batch 2
      </p>
    </div>
  );
}

export default Auth;