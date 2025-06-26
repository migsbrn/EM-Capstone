import React, { useEffect, useState } from "react";
import {
  collection,
  getDocs,
  query,
  where,
  doc,
  updateDoc,
  serverTimestamp,
  addDoc,
} from "firebase/firestore";
import { db, auth } from "../firebase";
import { onAuthStateChanged } from "firebase/auth";
import "../styles/ManageTeacher.css";

const ManageTeacher = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [filter, setFilter] = useState("All");
  const [teachers, setTeachers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedTeacher, setSelectedTeacher] = useState(null);
  const [error, setError] = useState(null);
  const [showArchive, setShowArchive] = useState(false);
  const [teacherToDelete, setTeacherToDelete] = useState(null);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [adminEmail, setAdminEmail] = useState(""); // Store admin email

  const fetchTeachers = async () => {
    setLoading(true);
    try {
      let q;
      if (filter === "All") {
        q = query(
          collection(db, "teacherRequests"),
          where("status", "in", ["Active", "Inactive", "Deleted"])
        );
      } else {
        q = query(
          collection(db, "teacherRequests"),
          where("status", "==", filter)
        );
      }
      const querySnapshot = await getDocs(q);
      const fetchedTeachers = querySnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      console.log("Fetched teachers in ManageTeacher:", fetchedTeachers);
      setTeachers(fetchedTeachers);
    } catch (error) {
      console.error("Error fetching teachers:", error);
      setError("Failed to load teachers. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const unsubscribeAuth = onAuthStateChanged(auth, (user) => {
      if (user) {
        setAdminEmail(user.email || "Admin"); // Set admin email
        user
          .getIdTokenResult(true)
          .then((idTokenResult) => {
            const role = idTokenResult.claims?.role || null;
            console.log(
              "Current user in ManageTeacher:",
              user.uid,
              "Role:",
              role
            );
            if (role !== "admin") {
              setError("You do not have admin privileges to manage teachers.");
              setTeachers([]);
              setLoading(false);
              return;
            }
            fetchTeachers();
          })
          .catch((err) => {
            console.error("Error fetching token result:", err);
            setError("Failed to verify admin privileges.");
            setLoading(false);
          });
      } else {
        setError("Please sign in as an admin to manage teachers.");
        setTeachers([]);
        setLoading(false);
      }
    });

    return () => unsubscribeAuth();
  }, [filter]);

  const logAdminAction = async (action, teacherName, type) => {
    try {
      await addDoc(collection(db, "adminActions"), {
        action: `${action} teacher ${teacherName}`,
        teacherName,
        adminEmail: adminEmail || "Admin",
        timestamp: serverTimestamp(),
        type: type.toLowerCase(),
      });
    } catch (error) {
      console.error("Error logging admin action:", error);
    }
  };

  const handleStatusChange = async (id, newStatus) => {
    if (newStatus === "Deleted") {
      const teacher = teachers.find((t) => t.id === id);
      setTeacherToDelete(teacher);
      setShowDeleteModal(true);
      return;
    }

    try {
      const teacher = teachers.find((t) => t.id === id);
      const teacherName = getFullName(teacher);
      setTeachers((prev) =>
        prev.map((t) => (t.id === id ? { ...t, status: newStatus } : t))
      );
      const teacherRef = doc(db, "teacherRequests", id);
      await updateDoc(teacherRef, {
        status: newStatus,
        updatedAt: serverTimestamp(),
      });
      await logAdminAction(
        newStatus === "Active" ? "Activated" : "Deactivated",
        teacherName,
        newStatus.toLowerCase()
      );
      console.log(`Teacher ${id} status updated to ${newStatus}`);
    } catch (error) {
      console.error("Error updating status:", error);
      alert("Failed to update status. Try again.");
    }
  };

  const confirmDelete = async () => {
    if (!teacherToDelete) return;

    try {
      const teacherName = getFullName(teacherToDelete);
      setTeachers((prev) =>
        prev.map((t) =>
          t.id === teacherToDelete.id ? { ...t, status: "Deleted" } : t
        )
      );
      const teacherRef = doc(db, "teacherRequests", teacherToDelete.id);
      await updateDoc(teacherRef, {
        status: "Deleted",
        updatedAt: serverTimestamp(),
      });
      await logAdminAction("Deleted", teacherName, "deleted");
      console.log(`Teacher ${teacherToDelete.id} status updated to Deleted`);
    } catch (error) {
      console.error("Error updating status to Deleted:", error);
      alert("Failed to delete teacher. Try again.");
    } finally {
      setShowDeleteModal(false);
      setTeacherToDelete(null);
    }
  };

  const cancelDelete = () => {
    setShowDeleteModal(false);
    setTeacherToDelete(null);
  };

  const formatDate = (dateValue) => {
    if (!dateValue) return "N/A";
    try {
      const date = dateValue?.toDate?.() || new Date(dateValue);
      return date.toLocaleDateString();
    } catch (error) {
      console.error("Error formatting date:", error, "Date value:", dateValue);
      return "Invalid Date";
    }
  };

  const getFullName = (teacher) => {
    return (
      `${teacher.firstName || ""} ${teacher.lastName || ""}`.trim() || "No Name"
    );
  };

  const handleMoreClick = (teacher) => {
    setSelectedTeacher(teacher);
  };

  const closeModal = () => {
    setSelectedTeacher(null);
  };

  const filteredTeachers = teachers.filter((t) => {
    const fullName = getFullName(t).toLowerCase().trim();
    const matchSearch =
      fullName.includes(searchTerm.toLowerCase()) ||
      (t.email?.toLowerCase()?.includes(searchTerm.toLowerCase()) ?? false) ||
      (t.contactNo?.includes(searchTerm) ?? false);
    return showArchive
      ? t.status === "Deleted"
      : t.status !== "Deleted" && matchSearch;
  });

  return (
    <div className="main-teacher-management">
      <div className="main-content">
        <h1 className="teacher-management-title">Manage Teachers</h1>

        {error && <p className="error">{error}</p>}

        <div className="teacher-controls-manage">
          <input
            type="text"
            placeholder="Search..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="teacher-approval-search-bar"
          />
          <select
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            className="teacher-approval-filter-select"
          >
            <option value="All">All</option>
            <option value="Active">Active</option>
            <option value="Inactive">Inactive</option>
            {showArchive && <option value="Deleted">Deleted</option>}
          </select>
          <button
            className="archive-button"
            onClick={() => setShowArchive(!showArchive)}
          >
            {showArchive ? "Back to Main" : "View Archive"}
          </button>
        </div>

        <div
          className={`teacher-table-container ${
            showArchive ? "archive-view" : ""
          }`}
          data-filter={filter}
        >
          {loading ? (
            <p>Loading teachers...</p>
          ) : filteredTeachers.length === 0 ? (
            <p>
              {showArchive
                ? "No archived teachers found."
                : "No teachers found."}
            </p>
          ) : (
            <table className="teacher-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Details</th>
                  <th>Status</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {filteredTeachers.map((teacher) => (
                  <tr key={teacher.id}>
                    <td>{getFullName(teacher)}</td>
                    <td>{teacher.email || "N/A"}</td>
                    <td>
                      <button
                        className="more-button"
                        data-filter={showArchive ? "Deleted" : filter}
                        onClick={() => handleMoreClick(teacher)}
                      >
                        <i className="fas fa-info-circle"></i> More
                      </button>
                    </td>
                    <td>{teacher.status || "N/A"}</td>
                    <td>
                      <select
                        value={teacher.status || "Active"}
                        onChange={(e) =>
                          handleStatusChange(teacher.id, e.target.value)
                        }
                        className="teacher-approval-status-select"
                        disabled={showArchive}
                      >
                        <option value="Active">Active</option>
                        <option value="Inactive">Inactive</option>
                        <option value="Deleted">Deleted</option>
                      </select>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

        {selectedTeacher && (
          <div className="modal" onClick={closeModal}>
            <div
              className={`modal-content ${showArchive ? "archive-view" : ""}`}
              data-filter={showArchive ? "Deleted" : filter}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="modal-header">
                <h2>Teacher Details</h2>
                <span className="close-icon" onClick={closeModal}>
                  ×
                </span>
              </div>
              <div className="modal-body">
                <div className="teacher-details">
                  <div className="detail-row">
                    <i className="fas fa-user detail-icon"></i>
                    <span className="detail-label">Name:</span>
                    <span className="detail-value">
                      {getFullName(selectedTeacher)}
                    </span>
                  </div>
                  <div className="detail-row">
                    <i className="fas fa-envelope detail-icon"></i>
                    <span className="detail-label">Email:</span>
                    <span className="detail-value">
                      {selectedTeacher.email || "N/A"}
                    </span>
                  </div>
                  <div className="detail-row">
                    <i className="fas fa-phone detail-icon"></i>
                    <span className="detail-label">Contact No:</span>
                    <span className="detail-value">
                      {selectedTeacher.contactNo || "N/A"}
                    </span>
                  </div>
                  <div className="detail-row">
                    <i className="fas fa-map-marker-alt detail-icon"></i>
                    <span className="detail-label">Address:</span>
                    <span className="detail-value">
                      {selectedTeacher.school || "N/A"}
                    </span>
                  </div>
                  <div className="detail-row">
                    <i className="fas fa-book detail-icon"></i>
                    <span className="detail-label">Subject:</span>
                    <span className="detail-value">
                      {selectedTeacher.subject || "N/A"}
                    </span>
                  </div>
                  <div className="detail-row">
                    <i className="fas fa-graduation-cap detail-icon"></i>
                    <span className="detail-label">Qualification:</span>
                    <span className="detail-value">
                      {selectedTeacher.qualification || "N/A"}
                    </span>
                  </div>
                  <div className="detail-row">
                    <i className="fas fa-calendar-alt detail-icon"></i>
                    <span className="detail-label">Date of Birth:</span>
                    <span className="detail-value">
                      {formatDate(selectedTeacher.dateOfBirth)}
                    </span>
                  </div>
                  <div className="detail-row">
                    <i className="fas fa-clock detail-icon"></i>
                    <span className="detail-label">Created At:</span>
                    <span className="detail-value">
                      {formatDate(selectedTeacher.createdAt)}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {showDeleteModal && (
          <div className="modal" onClick={cancelDelete}>
            <div className="modal-content" onClick={(e) => e.stopPropagation()}>
              <div className="modal-header">
                <h2>Confirm Deletion</h2>
                {/* Removed the close icon (×) */}
              </div>
              <div className="modal-body">
                <p>
                  Are you sure you want to delete the account of{" "}
                  <strong>{getFullName(teacherToDelete)}</strong>? This action
                  will move the account to the archive.
                </p>
                <div className="modal-actions">
                  <button className="confirm-button" onClick={confirmDelete}>
                    Yes
                  </button>
                  <button className="cancel-button" onClick={cancelDelete}>
                    Cancel
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ManageTeacher;
