import React, { useState, useEffect, useRef } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { signOut } from "firebase/auth";
import { auth } from "../firebase";
import "../styles/Header.css";
import profileImage from "../assets/haha.jpg";

const Header = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const [activeLink, setActiveLink] = useState(location.pathname);
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef(null);

  useEffect(() => {
    setActiveLink(location.pathname);
  }, [location.pathname]);

  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged((currentUser) => {});
    return () => unsubscribe();
  }, []);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleLogout = async () => {
    try {
      await signOut(auth);
      navigate("/login");
    } catch (error) {
      console.error("Logout error:", error);
    }
  };

  return (
    <>
      <div className="header-container no-print">
        <div className="header-admin">Admin</div>
        <div className="header-actions">
          <Link
            to="/dashboard"
            className={activeLink === "/dashboard" ? "active" : ""}
          >
            Dashboard
          </Link>
          <Link
            to="/teacher-approval"
            className={activeLink === "/teacher-approval" ? "active" : ""}
          >
            Teacher Account Approval
          </Link>
          <Link
            to="/manage-teacher"
            className={activeLink === "/manage-teacher" ? "active" : ""}
          >
            Manage Teacher
          </Link>
          <Link
            to="/view-students"
            className={activeLink === "/view-students" ? "active" : ""}
          >
            View Students
          </Link>
          <Link
            to="/reports-logs"
            className={activeLink === "/reports-logs" ? "active" : ""}
          >
            Reports/Logs
          </Link>
          <Link
            to="/settings"
            className={activeLink === "/settings" ? "active" : ""}
          >
            Settings
          </Link>

          <div className="profile-wrapper" ref={dropdownRef}>
            <div
              className="profile-link"
              onClick={() => setDropdownOpen((prev) => !prev)}
            >
              <img
                src={profileImage}
                alt="Admin Profile"
                className="profile-image"
              />
            </div>
            {dropdownOpen && (
              <div className="profile-dropdown">
                <button
                  className="dropdown-item logout-btn"
                  onClick={handleLogout}
                >
                  Sign Out
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
};

export default Header;
