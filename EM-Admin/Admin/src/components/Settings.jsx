import React, { useState, useEffect } from "react";
import { auth, storage } from "../firebase";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import { updateProfile, deleteUser } from "firebase/auth";
import "../styles/Settings.css";
import profileImage from "../assets/haha.jpg";

const Settings = () => {
  const [user, setUser] = useState(null);
  const [displayName, setDisplayName] = useState("");
  const [photoFile, setPhotoFile] = useState(null);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [isDeleteConfirmOpen, setIsDeleteConfirmOpen] = useState(false);

  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged((currentUser) => {
      setUser(currentUser);
      setDisplayName(currentUser?.displayName || "");
    });
    return () => unsubscribe();
  }, []);

  const generateNameFromEmail = (email) => {
    if (!email) return "N/A";
    const prefix = email.split("@")[0];
    const lettersOnly = prefix.replace(/[^a-zA-Z]/g, "");
    return lettersOnly.charAt(0).toUpperCase() + lettersOnly.slice(1);
  };

  const handleNameChange = async (e) => {
    e.preventDefault();
    setError("");
    setSuccess("");
    if (!displayName.trim()) {
      setError("Name cannot be empty");
      return;
    }
    try {
      await updateProfile(auth.currentUser, { displayName });
      setSuccess("Name updated successfully");
    } catch (error) {
      setError("Error updating name: " + error.message);
    }
  };

  const handlePhotoChange = async (e) => {
    e.preventDefault();
    setError("");
    setSuccess("");
    if (!photoFile) {
      setError("Please select a photo");
      return;
    }
    try {
      const storageRef = ref(storage, `profile_photos/${auth.currentUser.uid}`);
      await uploadBytes(storageRef, photoFile);
      const photoURL = await getDownloadURL(storageRef);
      await updateProfile(auth.currentUser, { photoURL });
      setSuccess("Profile photo updated successfully");
      setPhotoFile(null);
    } catch (error) {
      setError("Error updating photo: " + error.message);
    }
  };

  const handleDeleteAccount = async () => {
    setError("");
    setSuccess("");
    try {
      await deleteUser(auth.currentUser);
      setSuccess("Account deleted successfully");
      // Note: User will be signed out automatically
    } catch (error) {
      setError("Error deleting account: " + error.message);
    }
  };

  return (
    <div className="settings-container">
      <h1 className="settings-section-title">Settings</h1>

      {/* Admin Profile Section */}
      <div className="settings-section">
        <h2 className="settings-section-title">Admin Profile</h2>
        <div className="profile-section">
          <img
            src={user?.photoURL || profileImage}
            alt="Admin"
            className="modal-profile-image"
          />
          <div className="modal-info">
            <div className="profile-info-button">
              <strong>Name:</strong>{" "}
              {user?.displayName || generateNameFromEmail(user?.email)}
            </div>
            <div className="profile-info-button">
              <strong>Email:</strong> {user?.email || "N/A"}
            </div>
          </div>
        </div>
        <form onSubmit={handleNameChange} className="settings-field">
          <label className="settings-label">Update Name</label>
          <input
            type="text"
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
            className="settings-input"
            placeholder="Enter new name"
          />
          <button type="submit" className="settings-button">
            Update Name
          </button>
        </form>
        <form onSubmit={handlePhotoChange} className="settings-field">
          <label className="settings-label">Update Profile Photo</label>
          <input
            type="file"
            accept="image/*"
            onChange={(e) => setPhotoFile(e.target.files[0])}
            className="settings-input"
          />
          <button type="submit" className="settings-button">
            Update Photo
          </button>
        </form>
        <div className="settings-field">
          <button
            className="settings-button settings-button-danger"
            onClick={() => setIsDeleteConfirmOpen(true)}
          >
            Delete Account
          </button>
          {isDeleteConfirmOpen && (
            <div className="delete-confirm">
              <p>
                Are you sure you want to delete your account? This cannot be
                undone.
              </p>
              <button
                className="settings-button settings-button-danger"
                onClick={handleDeleteAccount}
              >
                Confirm Delete
              </button>
              <button
                className="settings-button"
                onClick={() => setIsDeleteConfirmOpen(false)}
              >
                Cancel
              </button>
            </div>
          )}
        </div>
        {error && <p className="error-message">{error}</p>}
        {success && <p className="success-message">{success}</p>}
      </div>
    </div>
  );
};

export default Settings;
