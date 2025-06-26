import React, { useState, useEffect } from "react";
import { auth, db } from "/src/firebase.js";
import {
  signInWithEmailAndPassword,
  onAuthStateChanged,
  sendPasswordResetEmail,
} from "firebase/auth";
import {
  doc,
  setDoc,
  getDoc,
  updateDoc,
  serverTimestamp,
} from "firebase/firestore";
import { useNavigate } from "react-router-dom";
import "../styles/AdminLogin.css";
import Illustration from "../assets/EM-logo.jpg";

// Simulate sending verification code email (replace with Cloud Functions in production)
const sendVerificationCodeEmail = async (email, code) => {
  console.log(`Verification code ${code} sent to ${email}`);
  // In production, use Firebase Cloud Functions or an email service to send:
  // Subject: "Your Admin Verification Code"
  // Body: "Your verification code is: ${code}. It expires in 10 minutes."
};

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [showForgotPassword, setShowForgotPassword] = useState(false);
  const [showVerifyCode, setShowVerifyCode] = useState(false);
  const [resetEmail, setResetEmail] = useState("");
  const [verificationCode, setVerificationCode] = useState("");
  const [userUid, setUserUid] = useState(null);
  const [failedAttempts, setFailedAttempts] = useState(0); // New state for tracking failed login attempts

  const navigate = useNavigate();

  // Generate a 6-digit verification code
  const generateVerificationCode = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
  };

  // Check auth state and redirect based on role
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        try {
          const idTokenResult = await user.getIdTokenResult(true);
          const role = idTokenResult.claims?.role || null;

          if (role === "admin") {
            const userDocRef = doc(db, "users", user.uid);
            const userDoc = await getDoc(userDocRef);
            if (userDoc.exists() && userDoc.data().verified) {
              navigate("/dashboard");
            } else {
              setShowVerifyCode(true);
              setUserUid(user.uid);
            }
          } else if (role === "teacher") {
            const teacherDocRef = doc(db, "teacherRequests", user.uid);
            const teacherDoc = await getDoc(teacherDocRef);
            if (
              teacherDoc.exists() &&
              teacherDoc.data().status === "Approved"
            ) {
              navigate("/teacher-dashboard");
            } else {
              await auth.signOut();
              setError("Your account is not yet approved by an admin.");
            }
          } else {
            await auth.signOut();
            setError("Access denied: Invalid role.");
          }
        } catch (err) {
          setError(err.message || "An error occurred during authentication.");
        }
      }
    });

    return () => unsubscribe();
  }, [navigate]);

  const handleLogin = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);
    setSuccess(null);

    try {
      const userCredential = await signInWithEmailAndPassword(
        auth,
        email,
        password
      );
      const user = userCredential.user;

      const idTokenResult = await user.getIdTokenResult(true);
      const role = idTokenResult.claims?.role;

      if (role !== "admin") {
        await auth.signOut();
        throw new Error("Access denied: Only admins can sign in at this time.");
      }

      // Reset failed attempts on successful login
      setFailedAttempts(0);

      // Generate and store verification code
      const code = generateVerificationCode();
      const userDocRef = doc(db, "users", user.uid);
      await setDoc(
        userDocRef,
        {
          email: user.email,
          verificationCode: code,
          codeTimestamp: serverTimestamp(),
          verified: false,
          createdAt: serverTimestamp(),
        },
        { merge: true }
      );

      // Send verification code
      await sendVerificationCodeEmail(user.email, code);

      setShowVerifyCode(true);
      setUserUid(user.uid);
      setSuccess("A verification code has been sent to your email.");
    } catch (err) {
      const newFailedAttempts = failedAttempts + 1;
      setFailedAttempts(newFailedAttempts);

      if (newFailedAttempts >= 4) {
        setError(
          "You have exceeded the maximum login attempts. Please reset your password."
        );
        setShowForgotPassword(true); // Force password reset
        setEmail(""); // Clear email input
        setPassword(""); // Clear password input
      } else if (err.code === "auth/invalid-credential") {
        setError(
          `Invalid admin credentials. ${
            4 - newFailedAttempts
          } attempt(s) remaining.`
        );
      } else {
        setError(err.message);
      }
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerifyCode = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);
    setSuccess(null);

    try {
      const userDocRef = doc(db, "users", userUid);
      const userDoc = await getDoc(userDocRef);
      if (!userDoc.exists()) {
        throw new Error("User not found.");
      }

      const { verificationCode: storedCode, codeTimestamp } = userDoc.data();
      const now = new Date();
      const codeAge = codeTimestamp
        ? (now - codeTimestamp.toDate()) / 1000 / 60
        : Infinity;

      if (codeAge > 10) {
        throw new Error("Verification code has expired. Please sign in again.");
      }

      if (storedCode !== verificationCode) {
        throw new Error("Invalid verification code.");
      }

      // Mark user as verified
      await updateDoc(userDocRef, {
        verified: true,
        verificationCode: null,
        codeTimestamp: null,
      });

      navigate("/dashboard");
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleForgotPassword = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);
    setSuccess(null);

    try {
      await sendPasswordResetEmail(auth, resetEmail);
      setSuccess("Password reset email sent. Please check your inbox.");
      setShowForgotPassword(false);
      setResetEmail("");
      setFailedAttempts(0); // Reset failed attempts after initiating password reset
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="illustration">
        <img
          src={Illustration}
          alt="Logo"
          className="illustration-image"
          onError={(e) => {
            e.target.style.display = "none";
            setError("Failed to load illustration.");
          }}
        />
      </div>
      <div className="login-form">
        <h2>
          {showForgotPassword
            ? "Forgot Password"
            : showVerifyCode
            ? "Verify Code"
            : "Admin"}
        </h2>
        {!showForgotPassword && !showVerifyCode ? (
          <form onSubmit={handleLogin} autoComplete="off">
            <div className="input-group">
              <span className="icon">
                <i className="fas fa-user"></i>
              </span>
              <input
                type="email"
                name="email-12345"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Email"
                required
                disabled={isLoading}
                autoComplete="new-email"
              />
            </div>
            <div className="input-group">
              <span className="icon">
                <i className="fas fa-lock"></i>
              </span>
              <input
                type="password"
                name="password-12345"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Password"
                required
                disabled={isLoading}
                autoComplete="new-password"
              />
            </div>
            <p
              className="forgot-password"
              onClick={() => setShowForgotPassword(true)}
              style={{
                color: "#3d5d53",
                cursor: "pointer",
                textAlign: "right",
                margin: "5px 0",
              }}
            >
              Forgot Password?
            </p>
            {error && <p className="error">{error}</p>}
            {success && <p className="success">{success}</p>}
            <button type="submit" className="login-button" disabled={isLoading}>
              {isLoading ? "Signing In..." : "SIGN IN"}
            </button>
          </form>
        ) : showForgotPassword ? (
          <form onSubmit={handleForgotPassword} autoComplete="off">
            <div className="input-group">
              <span className="icon">
                <i className="fas fa-envelope"></i>
              </span>
              <input
                type="email"
                value={resetEmail}
                onChange={(e) => setResetEmail(e.target.value)}
                placeholder="Enter your email"
                required
                disabled={isLoading}
                autoComplete="new-email"
              />
            </div>
            {error && <p className="error">{error}</p>}
            {success && <p className="success">{success}</p>}
            <button type="submit" className="login-button" disabled={isLoading}>
              {isLoading ? "Sending..." : "Send Reset Email"}
            </button>
          </form>
        ) : (
          <form onSubmit={handleVerifyCode} autoComplete="off">
            <div className="input-group">
              <span className="icon">
                <i className="fas fa-key"></i>
              </span>
              <input
                type="text"
                value={verificationCode}
                onChange={(e) => setVerificationCode(e.target.value)}
                placeholder="Enter 6-digit code"
                required
                disabled={isLoading}
                autoComplete="off"
                maxLength="6"
              />
            </div>
            {error && <p className="error">{error}</p>}
            {success && <p className="success">{success}</p>}
            <button type="submit" className="login-button" disabled={isLoading}>
              {isLoading ? "Verifying..." : "Verify Code"}
            </button>
            <p
              className="back-to-login"
              onClick={async () => {
                await auth.signOut();
                setShowVerifyCode(false);
                setError(null);
                setSuccess(null);
                setVerificationCode("");
                setUserUid(null);
              }}
              style={{
                color: "#3d5d53",
                cursor: "pointer",
                textAlign: "center",
                marginTop: "10px",
              }}
            >
              Back to Sign In
            </p>
          </form>
        )}
        <div className="signup-login-toggle">
          <p>
            {showForgotPassword || showVerifyCode ? "Remember your email?" : ""}
            <span
              onClick={() => {
                setShowForgotPassword(false);
                setShowVerifyCode(false);
                setError(null);
                setSuccess(null);
                setResetEmail("");
                setVerificationCode("");
              }}
              style={{ color: "#3d5d53", cursor: "pointer" }}
            >
              {showForgotPassword || showVerifyCode ? "Sign In" : ""}
            </span>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
