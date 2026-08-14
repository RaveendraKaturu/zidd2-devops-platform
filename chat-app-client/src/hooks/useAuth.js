import { useState } from "react";
import api from "../api";

export const useAuth = (currentUser, setCurrentUser) => {
  const [register, setRegister] = useState(false);
  const [loading, setLoading] = useState(false);

  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [error, setError] = useState("");

  const getCurrentUser = async () => {
    try {
      setLoading(true);
      setError("");

      const response = await api.get("/users/me");

      setCurrentUser(response.data);
    } catch (error) {
      console.log("Get current user error:", error);
      setCurrentUser(null);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const newEmail = email.trim();

    if (!newEmail) {
      setError("Please enter your email.");
      return;
    }

    if (!password) {
      setError("Please enter your password.");
      return;
    }

    try {
      setLoading(true);
      setError("");

      let response;

      /*
       * =========================
       * REGISTER
       * =========================
       */

      if (register) {
        response = await api.post("/auth/signup", {
          fullName: username.trim(),
          email: newEmail,
          password,
        });
      }

      /*
       * =========================
       * LOGIN
       * =========================
       */

      else {
        response = await api.post("/auth/login", {
          email: newEmail,
          password,
        });
      }

      const data = response.data;

      /*
       * =========================
       * TOKEN
       * =========================
       */

      const token = data.token;

      if (!token) {
        throw new Error("Authentication token was not received.");
      }

      localStorage.setItem("token", token);

      if (data.expiresIn !== undefined) {
        localStorage.setItem(
          "expiresIn",
          data.expiresIn
        );
      }

      /*
       * =========================
       * GET CURRENT USER
       * =========================
       */

      const userResponse = await api.get(
        "/users/me"
      );

      const user = userResponse.data;

      localStorage.setItem(
        "user",
        JSON.stringify(user)
      );

      /*
       * =========================
       * SUCCESS
       * =========================
       */

      setEmail("");
      setPassword("");
      setUsername("");
      setError("");

      setCurrentUser(user);

    } catch (error) {

      console.error(
        "Authentication error:",
        error
      );

      /*
       * =========================
       * HTTP ERROR
       * =========================
       */

      if (error.response) {

        const status =
          error.response.status;

        /*
         * Invalid login credentials
         */

        if (
          status === 401 ||
          status === 403
        ) {
          setError(
            "Invalid email or password."
          );
        }

        /*
         * Bad request
         */

        else if (status === 400) {

          const backendMessage =
            error.response.data?.message;

          setError(
            backendMessage ||
              "Invalid request. Please check your details."
          );
        }

        /*
         * Conflict / existing account
         */

        else if (status === 409) {

          const backendMessage =
            error.response.data?.message;

          setError(
            backendMessage ||
              "An account with this email already exists."
          );
        }

        /*
         * Server error
         */

        else if (status >= 500) {

          setError(
            "Server error. Please try again later."
          );
        }

        /*
         * Other HTTP errors
         */

        else {

          const backendMessage =
            error.response.data?.message;

          setError(
            backendMessage ||
              "Something went wrong. Please try again."
          );
        }
      }

      /*
       * =========================
       * NETWORK ERROR
       * =========================
       */

      else if (error.request) {

        setError(
          "Unable to connect to the server. Please check your connection."
        );
      }

      /*
       * =========================
       * UNKNOWN ERROR
       * =========================
       */

      else {

        setError(
          "Something went wrong. Please try again."
        );
      }

    } finally {
      setLoading(false);
    }
  };


  /*
   * =========================
   * LOGOUT
   * =========================
   */

  const handleLogout = () => {

    localStorage.removeItem("token");
    localStorage.removeItem("expiresIn");
    localStorage.removeItem("user");

    setCurrentUser(null);
  };


  return {
    loading,

    email,
    password,

    setEmail,
    setPassword,

    handleSubmit,
    handleLogout,

    getCurrentUser,

    currentUser,

    username,
    setUsername,

    register,
    setRegister,

    error,
    setError,
  };
};