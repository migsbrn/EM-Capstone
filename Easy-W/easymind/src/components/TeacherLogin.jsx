// TeacherLogin.jsx
import React, { useState, useEffect } from "react";
import { auth, db } from "../firebase";
import {
  signInWithEmailAndPassword,
  onAuthStateChanged,
  createUserWithEmailAndPassword,
  sendPasswordResetEmail,
  signOut,
  sendEmailVerification,
} from "firebase/auth";
import {
  doc,
  setDoc,
  updateDoc,
  serverTimestamp,
  getDoc,
  addDoc,
  collection,
}
  from "firebase/firestore";
import { useNavigate } from "react-router-dom";
import "../styles/TeacherLogin.css";
import Illustration from "../assets/EM-logo.jpg";
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import "bootstrap/dist/css/bootstrap.min.css";

const TeacherLogin = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [showSignUp, setShowSignUp] = useState(false);
  const [showForgotPassword, setShowForgotPassword] = useState(false);
  const [resetEmail, setResetEmail] = useState("");
  const [signUpData, setSignUpData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    contactNo: "",
    streetAddress: "",
    barangay: "",
    cityMunicipality: "",
    province: "",
    postalCode: "",
    qualification: "",
    dateOfBirth: "",
    password: "",
    confirmPassword: "",
  });
  const [formErrors, setFormErrors] = useState({});

  const navigate = useNavigate();

  useEffect(() => {
    // Sign out any existing user when the component mounts
    const handleSignOut = async () => {
      try {
        await signOut(auth);
        console.log("TeacherLogin - User signed out on page load");
      } catch (err) {
        console.error("TeacherLogin - Sign out error:", err);
      }
    };
    handleSignOut();

    // Listen for auth state changes after login
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        console.log("TeacherLogin - User authenticated:", user.uid, user.email);
        try {
          // Force token refresh
          await user.getIdToken(true);
          const idTokenResult = await user.getIdTokenResult();
          console.log("TeacherLogin - Token claims:", idTokenResult.claims);
          const role = idTokenResult.claims?.role || null;

          if (role === "teacher") {
            const teacherDocRef = doc(db, "teacherRequests", user.uid);
            console.log(
              "TeacherLogin - Fetching teacher doc for UID:",
              user.uid
            );
            const teacherDoc = await getDoc(teacherDocRef);
            if (teacherDoc.exists()) {
              const teacherData = teacherDoc.data();
              console.log("TeacherLogin - Teacher Doc Data:", teacherData);
              const status = teacherData.status;
              if (status === "Active") {
                console.log(
                  "TeacherLogin - Status is Active, navigating to /teacher-dashboard"
                );
                // Update lastLogin timestamp
                await updateDoc(teacherDocRef, {
                  lastLogin: serverTimestamp(),
                });
                console.log(
                  "TeacherLogin - Updated lastLogin for UID:",
                  user.uid
                );
                navigate("/teacher-dashboard");
              } else {
                console.log("TeacherLogin - Status is not Active:", status);
                setError(
                  "Your account is not yet active. Please wait for admin activation."
                );
                await signOut(auth);
              }
            } else {
              console.log(
                "TeacherLogin - Teacher document does not exist for UID:",
                user.uid
              );
              setError("Teacher request not found. Please contact an admin.");
              await signOut(auth);
            }
          } else {
            console.log("TeacherLogin - Role is not 'teacher':", role);
            setError(
              "Access denied: Only teachers can sign in to this portal."
            );
            await signOut(auth);
          }
        } catch (err) {
          console.error("TeacherLogin - Authentication error:", err);
          setError(
            "Authentication failed: " + (err.message || "Unknown error")
          );
          await signOut(auth);
        }
      } else {
        console.log("TeacherLogin - No user is authenticated");
      }
    });

    return () => unsubscribe();
  }, [navigate]);

  const handleLogin = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);

    try {
      console.log("TeacherLogin - Attempting login with email:", email);
      const userCredential = await signInWithEmailAndPassword(
        auth,
        email,
        password
      );
      const user = userCredential.user;
      console.log("TeacherLogin - Login successful for UID:", user.uid);

      // Fetch teacher data to get name
      const teacherDocRef = doc(db, "teacherRequests", user.uid);
      const teacherDoc = await getDoc(teacherDocRef);
      if (teacherDoc.exists()) {
        const teacherData = teacherDoc.data();
        const teacherName = `${teacherData.firstName} ${teacherData.lastName}`;

        // Log the login event to logs
        await addDoc(collection(db, "logs"), {
          teacherId: user.uid,
          teacherName: teacherName,
          activityDescription: "Logged in",
          createdAt: serverTimestamp(),
        });
        console.log("TeacherLogin - Login event logged for:", teacherName);

        // Log the login event to teacherLogins
        await addDoc(collection(db, "teacherLogins"), {
          teacherId: user.uid,
          loginTime: serverTimestamp(),
        });
        console.log("TeacherLogin - Teacher login logged for UID:", user.uid);
      } else {
        throw new Error("Teacher document not found");
      }

      // Force token refresh immediately after login
      await user.getIdToken(true);
      console.log("TeacherLogin - Token refreshed after login");
    } catch (err) {
      console.error("TeacherLogin - Login error:", err);
      if (
        err.code === "auth/wrong-password" ||
        err.code === "auth/user-not-found"
      ) {
        setError("Invalid email or password. Please try again.");
      } else {
        setError("Login failed: " + err.message);
      }
    } finally {
      setIsLoading(false);
    }
  };

  const validateForm = () => {
    const errors = {};
    if (!signUpData.firstName) errors.firstName = "First name is required";
    if (!signUpData.lastName) errors.lastName = "Last name is required";
    if (!signUpData.email) {
      errors.email = "Email is required";
    } else if (!/\S+@\S+\.\S+/.test(signUpData.email)) {
      errors.email = "Need valid email";
    }
    if (!signUpData.contactNo) {
      errors.contactNo = "Contact number is required";
    } else if (!/^\d{11}$/.test(signUpData.contactNo)) {
      errors.contactNo = "Contact number must be exactly 11 digits";
    }
    if (!signUpData.streetAddress)
      errors.streetAddress = "Street address is required";
    if (!signUpData.barangay) errors.barangay = "Barangay is required";
    if (!signUpData.cityMunicipality)
      errors.cityMunicipality = "City/Municipality is required";
    if (!signUpData.province) errors.province = "Province is required";
    if (!signUpData.postalCode) errors.postalCode = "Postal code is required";
    if (!signUpData.qualification)
      errors.qualification = "Qualification is required";
    if (!signUpData.dateOfBirth)
      errors.dateOfBirth = "Date of birth is required";
    if (!signUpData.password) errors.password = "Password is required";
    if (signUpData.password !== signUpData.confirmPassword) {
      errors.confirmPassword = "Passwords do not match";
    }
    return errors;
  };

  const handleSignUpChange = (e) => {
    const { name, value } = e.target;
    if (name === "contactNo") {
      const numericValue = value.replace(/[^0-9]/g, "");
      setSignUpData({ ...signUpData, [name]: numericValue });
    } else {
      setSignUpData({ ...signUpData, [name]: value });
    }
    const errors = { ...formErrors };
    if (errors[name]) {
      delete errors[name];
      setFormErrors(errors);
    }
  };

  const handleSignUp = async (e) => {
    e.preventDefault();
    const errors = validateForm();
    if (Object.keys(errors).length > 0) {
      setFormErrors(errors);
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      console.log(
        "TeacherLogin - Starting sign-up process with email:",
        signUpData.email
      );
      const userCredential = await createUserWithEmailAndPassword(
        auth,
        signUpData.email,
        signUpData.password
      );
      const user = userCredential.user;

      console.log("TeacherLogin - User authenticated, UID:", user.uid);
      await user.getIdToken(true);
      console.log(
        "TeacherLogin - Token refreshed, waiting for auth state to stabilize..."
      );

      let authStabilized = false;
      await new Promise((resolve, reject) => {
        const unsubscribe = onAuthStateChanged(
          auth,
          (currentUser) => {
            if (currentUser && currentUser.uid === user.uid) {
              console.log(
                "TeacherLogin - Auth state confirmed for UID:",
                currentUser.uid
              );
              console.log(
                "TeacherLogin - Current auth state:",
                !!auth.currentUser
              );
              authStabilized = true;
              unsubscribe();
              resolve();
            } else {
              console.log(
                "TeacherLogin - Auth state not yet confirmed, currentUser:",
                currentUser
              );
            }
          },
          (error) => {
            console.error("TeacherLogin - onAuthStateChanged error:", error);
            unsubscribe();
            reject(error);
          }
        );
        setTimeout(() => {
          unsubscribe();
          if (!authStabilized) {
            console.log(
              "TeacherLogin - Timeout reached, falling back to userCredential..."
            );
            resolve();
          }
        }, 15000); // Increased timeout to ensure stabilization
      });

      if (!auth.currentUser && !authStabilized) {
        console.log(
          "TeacherLogin - Falling back to initial userCredential:",
          user.uid
        );
      }

      await sendEmailVerification(user);
      console.log("TeacherLogin - Verification email sent to:", user.email);

      const userData = {
        firstName: signUpData.firstName,
        lastName: signUpData.lastName,
        email: signUpData.email,
        contactNo: signUpData.contactNo,
        streetAddress: signUpData.streetAddress,
        barangay: signUpData.barangay,
        cityMunicipality: signUpData.cityMunicipality,
        province: signUpData.province,
        postalCode: signUpData.postalCode,
        school: `${signUpData.streetAddress}, ${signUpData.barangay}, ${signUpData.cityMunicipality}, ${signUpData.province}, ${signUpData.postalCode}`,
        profilePhoto: null,
        qualification: signUpData.qualification,
        dateOfBirth: signUpData.dateOfBirth,
        role: "teacher",
        status: "Pending",
        createdAt: serverTimestamp(),
      };

      console.log("TeacherLogin - Saving user data to Firestore:", userData);
      await setDoc(doc(db, "teacherRequests", user.uid), userData);
      console.log(
        "TeacherLogin - User data saved successfully for UID:",
        user.uid
      );

      const savedDoc = await getDoc(doc(db, "teacherRequests", user.uid));
      if (!savedDoc.exists()) {
        throw new Error(
          "TeacherLogin - Failed to verify saved data in Firestore."
        );
      }
      console.log("TeacherLogin - Verified saved data:", savedDoc.data());

      setError(
        "Your account is pending admin approval. Please verify your email address by clicking the link sent to your inbox."
      );
      await signOut(auth);
      console.log("TeacherLogin - User signed out after sign-up.");
    } catch (err) {
      console.error("TeacherLogin - Sign-up error:", {
        code: err.code,
        message: err.message,
        stack: err.stack,
        name: err.name,
      });
      setError(`${err.code || "Unknown Error"}: ${err.message}`);
    } finally {
      setIsLoading(false);
      console.log("TeacherLogin - Sign-up process completed.");
    }
  };

  const handleForgotPassword = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);

    try {
      await sendPasswordResetEmail(auth, resetEmail);
      setError("Password reset email sent. Please check your inbox.");
      setShowForgotPassword(false);
      setResetEmail("");
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="t-login-container">
      <div className="t-illustration">
        <img
          src={Illustration}
          alt="Logo"
          className="t-illustration-image"
          onError={(e) => {
            e.target.style.display = "none";
            setError("Failed to load illustration.");
          }}
        />
      </div>
      <div className="t-login-form">
        <h2>
          {showSignUp
            ? "Create Account"
            : showForgotPassword
            ? "Forgot Password"
            : "Sign In"}
        </h2>
        {!showSignUp && !showForgotPassword ? (
          <form onSubmit={handleLogin} autoComplete="off">
            <div className="t-input-group">
              <span className="t-icon">
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
            <div className="t-input-group">
              <span className="t-icon">
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
              className="t-forgot-password"
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
            {error && <p className="t-error">{error}</p>}
            <button
              type="submit"
              className="t-login-button"
              disabled={isLoading}
            >
              {isLoading ? "Signing In..." : "SIGN IN"}
            </button>
          </form>
        ) : showForgotPassword ? (
          <form onSubmit={handleForgotPassword} autoComplete="off">
            <div className="t-input-group">
              <span className="t-icon">
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
            {error && <p className="t-error">{error}</p>}
            <button
              type="submit"
              className="t-login-button"
              disabled={isLoading}
            >
              {isLoading ? "Sending..." : "Send Reset Email"}
            </button>
            <p
              className="t-back-to-login"
              onClick={() => {
                setShowForgotPassword(false);
                setError(null);
                setResetEmail("");
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
        ) : (
          <form onSubmit={handleSignUp} autoComplete="off">
            <div className="t-input-row">
              <div className="t-input-group t-half-width">
                <label>
                  First Name <span className="t-asterisk">*</span>
                </label>
                <input
                  type="text"
                  name="firstName"
                  value={signUpData.firstName}
                  onChange={handleSignUpChange}
                  placeholder="ex: Juan"
                  required
                  disabled={isLoading}
                  autoComplete="new-text"
                />
                {formErrors.firstName && (
                  <p className="t-error">{formErrors.firstName}</p>
                )}
              </div>
              <div className="t-input-group t-half-width">
                <label>
                  Last Name <span className="t-asterisk">*</span>
                </label>
                <input
                  type="text"
                  name="lastName"
                  value={signUpData.lastName}
                  onChange={handleSignUpChange}
                  placeholder="ex: Dela Cruz"
                  required
                  disabled={isLoading}
                  autoComplete="new-text"
                />
                {formErrors.lastName && (
                  <p className="t-error">{formErrors.lastName}</p>
                )}
              </div>
            </div>
            <div className="t-input-row">
              <div className="t-input-group t-half-width">
                <label>
                  E-mail Address <span className="t-asterisk">*</span>
                </label>
                <input
                  type="email"
                  name="email"
                  value={signUpData.email}
                  onChange={handleSignUpChange}
                  placeholder="ex: myname@example.com"
                  required
                  disabled={isLoading}
                  autoComplete="new-email"
                />
                {formErrors.email && (
                  <p className="t-error">{formErrors.email}</p>
                )}
              </div>
              <div className="t-input-group t-half-width">
                <label>
                  Contact No <span className="t-asterisk">*</span>
                </label>
                <input
                  type="text"
                  name="contactNo"
                  value={signUpData.contactNo}
                  onChange={handleSignUpChange}
                  placeholder="ex: 09171234567"
                  required
                  disabled={isLoading}
                  maxLength="11"
                  autoComplete="new-text"
                />
                {formErrors.contactNo && (
                  <p className="t-error">{formErrors.contactNo}</p>
                )}
              </div>
            </div>
            <div className="t-input-group t-full-width">
              <div className="t-address-group">
                <div className="t-address-field">
                  <label>
                    Street Address <span className="t-asterisk">*</span>
                  </label>
                  <input
                    type="text"
                    name="streetAddress"
                    value={signUpData.streetAddress}
                    onChange={handleSignUpChange}
                    placeholder="ex: 123 Sampaguita St"
                    required
                    disabled={isLoading}
                    autoComplete="new-text"
                  />
                  {formErrors.streetAddress && (
                    <p className="t-error">{formErrors.streetAddress}</p>
                  )}
                </div>
                <div className="t-address-field">
                  <label>
                    Barangay <span className="t-asterisk">*</span>
                  </label>
                  <input
                    type="text"
                    name="barangay"
                    value={signUpData.barangay}
                    onChange={handleSignUpChange}
                    placeholder="ex: Bagong Silang"
                    required
                    disabled={isLoading}
                    autoComplete="new-text"
                  />
                  {formErrors.barangay && (
                    <p className="t-error">{formErrors.barangay}</p>
                  )}
                </div>
                <div className="t-address-field">
                  <label>
                    City/Municipality <span className="t-asterisk">*</span>
                  </label>
                  <input
                    type="text"
                    name="cityMunicipality"
                    value={signUpData.cityMunicipality}
                    onChange={handleSignUpChange}
                    placeholder="ex: Quezon City"
                    required
                    disabled={isLoading}
                    autoComplete="new-text"
                  />
                  {formErrors.cityMunicipality && (
                    <p className="t-error">{formErrors.cityMunicipality}</p>
                  )}
                </div>
                <div className="t-address-field">
                  <label>
                    Province <span className="t-asterisk">*</span>
                  </label>
                  <input
                    type="text"
                    name="province"
                    value={signUpData.province}
                    onChange={handleSignUpChange}
                    placeholder="ex: Metro Manila"
                    required
                    disabled={isLoading}
                    autoComplete="new-text"
                  />
                  {formErrors.province && (
                    <p className="t-error">{formErrors.province}</p>
                  )}
                </div>
                <div className="t-address-field">
                  <label>
                    Postal Code <span className="t-asterisk">*</span>
                  </label>
                  <input
                    type="text"
                    name="postalCode"
                    value={signUpData.postalCode}
                    onChange={handleSignUpChange}
                    placeholder="ex: 1101"
                    required
                    disabled={isLoading}
                    autoComplete="new-text"
                  />
                  {formErrors.postalCode && (
                    <p className="t-error">{formErrors.postalCode}</p>
                  )}
                </div>
              </div>
            </div>
            <div className="t-input-row">
              <div className="t-input-group t-full-width">
                <label>
                  Qualification <span className="t-asterisk">*</span>
                </label>
                <input
                  type="text"
                  name="qualification"
                  value={signUpData.qualification}
                  onChange={handleSignUpChange}
                  placeholder="ex: Bachelor of Education"
                  required
                  disabled={isLoading}
                  autoComplete="new-text"
                />
                {formErrors.qualification && (
                  <p className="t-error">{formErrors.qualification}</p>
                )}
              </div>
            </div>
            <div className="t-input-row">
              <div className="t-input-group t-half-width">
                <label>
                  Date of Birth <span className="t-asterisk">*</span>
                </label>
                <input
                  type="date"
                  name="dateOfBirth"
                  value={signUpData.dateOfBirth}
                  onChange={handleSignUpChange}
                  required
                  disabled={isLoading}
                  autoComplete="new-text"
                />
                {formErrors.dateOfBirth && (
                  <p className="t-error">{formErrors.dateOfBirth}</p>
                )}
              </div>
            </div>
            <div className="t-input-row">
              <div className="t-input-group t-half-width">
                <label>
                  Password <span className="t-asterisk">*</span>
                </label>
                <input
                  type="password"
                  name="password"
                  value={signUpData.password}
                  onChange={handleSignUpChange}
                  placeholder="ex: MySecurePassword123"
                  required
                  disabled={isLoading}
                  autoComplete="new-password"
                />
                {formErrors.password && (
                  <p className="t-error">{formErrors.password}</p>
                )}
              </div>
              <div className="t-input-group t-half-width">
                <label>
                  Confirm Password <span className="t-asterisk">*</span>
                </label>
                <input
                  type="password"
                  name="confirmPassword"
                  value={signUpData.confirmPassword}
                  onChange={handleSignUpChange}
                  placeholder="ex: MySecurePassword123"
                  required
                  disabled={isLoading}
                  autoComplete="new-password"
                />
                {formErrors.confirmPassword && (
                  <p className="t-error">{formErrors.confirmPassword}</p>
                )}
              </div>
            </div>
            {error && <p className="t-error">{error}</p>}
            <button
              type="submit"
              className="t-login-button"
              disabled={isLoading}
            >
              {isLoading ? "Submitting..." : "SUBMIT"}
            </button>
          </form>
        )}
        <div className="t-signup-login-toggle">
          <p>
            {showSignUp
              ? "Have an account? "
              : showForgotPassword
              ? "Remember your password? "
              : "Don't have an account? "}
            <span
              onClick={() => {
                setShowSignUp(!showSignUp);
                setShowForgotPassword(false);
                setError(null);
                setResetEmail("");
              }}
              style={{ color: "#3d5d53", cursor: "pointer" }}
            >
              {showSignUp
                ? "Sign In"
                : showForgotPassword
                ? "Sign Up"
                : "Sign Up"}
            </span>
          </p>
        </div>
      </div>
    </div>
  );
};

export default TeacherLogin;