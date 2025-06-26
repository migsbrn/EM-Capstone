import React, { useEffect, useState } from "react";
import {
  collection,
  query,
  where,
  onSnapshot,
  updateDoc,
  doc,
  serverTimestamp,
  addDoc,
} from "firebase/firestore";
import { auth, db } from "../firebase";
import { onAuthStateChanged } from "firebase/auth";
import "../styles/TeacherApproval.css";

const TeacherApproval = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [teachers, setTeachers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [updatingStatusIds, setUpdatingStatusIds] = useState([]);
  const [selectedTeacher, setSelectedTeacher] = useState(null);
  const [error, setError] = useState(null);
  const [showHistory, setShowHistory] = useState(false);
  const [historyTeachers, setHistoryTeachers] = useState([]);
  const [historyLoading, setHistoryLoading] = useState(false);
  const [adminEmail, setAdminEmail] = useState(""); // Store admin email

  const collectionName = "teacherRequests";

  useEffect(() => {
    const unsubscribeAuth = onAuthStateChanged(auth, (user) => {
      if (user) {
        setAdminEmail(user.email || "Admin"); // Set admin email
        user
          .getIdTokenResult(true)
          .then((idTokenResult) => {
            const role = idTokenResult.claims?.role || null;
            console.log(
              "Current user in TeacherApproval:",
              user.uid,
              "Role:",
              role
            );
            if (role !== "admin") {
              setError(
                "You do not have admin privileges to view teacher requests."
              );
              setTeachers([]);
              setLoading(false);
              return;
            }

            setLoading(true);
            setError(null);
            const q = query(
              collection(db, collectionName),
              where("status", "==", "Pending")
            );
            const unsubscribe = onSnapshot(
              q,
              (querySnapshot) => {
                const fetchedTeachers = querySnapshot.docs.map((doc) => ({
                  id: doc.id,
                  ...doc.data(),
                }));
                console.log("Fetched teachers:", fetchedTeachers);
                setTeachers(fetchedTeachers);
                setLoading(false);
              },
              (error) => {
                console.error("Error listening to teachers:", error);
                setError("Failed to load teachers. Please try again.");
                setLoading(false);
              }
            );
            return () => unsubscribe();
          })
          .catch((err) => {
            console.error("Error fetching token result:", err);
            setError("Failed to verify admin privileges.");
            setLoading(false);
          });
      } else {
        setError("Please sign in as an admin to view teacher requests.");
        setTeachers([]);
        setLoading(false);
      }
    });

    return () => unsubscribeAuth();
  }, []);

  const fetchHistoryTeachers = () => {
    setHistoryLoading(true);
    const q = query(
      collection(db, collectionName),
      where("status", "in", ["Approved", "Rejected", "Active"])
    );
    const unsubscribe = onSnapshot(
      q,
      (querySnapshot) => {
        const fetchedHistoryTeachers = querySnapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }));
        console.log("Fetched history teachers:", fetchedHistoryTeachers);
        setHistoryTeachers(fetchedHistoryTeachers);
        setHistoryLoading(false);
      },
      (error) => {
        console.error("Error listening to history teachers:", error);
        alert("Failed to load history. Please try again.");
        setHistoryLoading(false);
      }
    );
    return () => unsubscribe();
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
    try {
      setUpdatingStatusIds((prev) => [...prev, id]);
      const teacherRef = doc(db, collectionName, id);
      const teacher = teachers.find((t) => t.id === id);
      const teacherName = getFullName(teacher);

      // Update with timestamp
      await updateDoc(teacherRef, {
        status: newStatus,
        updatedAt: serverTimestamp(),
      });

      // If the new status is Approved, immediately set it to Active
      if (newStatus === "Approved") {
        await updateDoc(teacherRef, {
          status: "Active",
          updatedAt: serverTimestamp(),
        });
        await logAdminAction("Approved", teacherName, "approved");
        await logAdminAction("Activated", teacherName, "active");
        alert("Teacher status updated to Approved and set to Active.");
      } else {
        await logAdminAction(
          newStatus === "Rejected" ? "Rejected" : newStatus,
          teacherName,
          newStatus.toLowerCase()
        );
        alert(`Teacher status updated to ${newStatus}`);
      }
    } catch (error) {
      console.error("Error updating teacher status:", error);
      alert("Failed to update status. Try again.");
    } finally {
      setUpdatingStatusIds((prev) => prev.filter((tid) => tid !== id));
    }
  };

  const handleMoreClick = (teacher) => {
    setSelectedTeacher(teacher);
  };

  const closeModal = () => {
    setSelectedTeacher(null);
  };

  const openHistoryModal = () => {
    setShowHistory(true);
    fetchHistoryTeachers();
  };

  const closeHistoryModal = () => {
    setShowHistory(false);
    setHistoryTeachers([]);
  };

  const filteredTeachers = teachers.filter((teacher) => {
    const fullName = getFullName(teacher).toLowerCase();
    const matchesSearch =
      fullName.includes(searchTerm.toLowerCase()) ||
      (teacher.email?.toLowerCase()?.includes(searchTerm.toLowerCase()) ??
        false) ||
      (teacher.contactNo?.includes(searchTerm) ?? false);
    return matchesSearch;
  });

  const sortedTeachers = [...filteredTeachers].sort((a, b) => {
    const aDate = a.createdAt?.toDate?.() || new Date(a.createdAt || 0);
    const bDate = b.createdAt?.toDate?.() || new Date(b.createdAt || 0);
    return bDate - aDate;
  });

  const sortedHistoryTeachers = [...historyTeachers].sort((a, b) => {
    const aDate = a.createdAt?.toDate?.() || new Date(a.createdAt || 0);
    const bDate = b.createdAt?.toDate?.() || new Date(b.createdAt || 0);
    return bDate - aDate;
  });

  return (
    <div className="teacher-approval-container">
      <div className="teacher-approval-main">
        <div className="teacher-approval-content">
          <h1 className="teacher-approval-header">Teacher Account Approval</h1>

          {error && <p className="error">{error}</p>}

          <div className="teacher-approval-controls">
            <input
              type="text"
              placeholder="Search..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="teacher-approval-search-bar"
            />
            <button className="history-button" onClick={openHistoryModal}>
              <i className="fas fa-history"></i> History
            </button>
          </div>

          <div className="teacher-approval-table-container">
            {loading ? (
              <p>Loading teachers...</p>
            ) : sortedTeachers.length > 0 ? (
              <table className="teacher-approval-table">
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Contact</th>
                    <th>Details</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  {sortedTeachers.map((teacher) => (
                    <tr key={teacher.id}>
                      <td>{getFullName(teacher)}</td>
                      <td>{teacher.email || "N/A"}</td>
                      <td>{teacher.contactNo || "N/A"}</td>
                      <td>
                        <button
                          className="more-button"
                          onClick={() => handleMoreClick(teacher)}
                        >
                          <i className="fas fa-info-circle"></i> More
                        </button>
                      </td>
                      <td>
                        <select
                          value={teacher.status}
                          disabled={updatingStatusIds.includes(teacher.id)}
                          onChange={(e) =>
                            handleStatusChange(teacher.id, e.target.value)
                          }
                          className="teacher-approval-status-select"
                        >
                          <option value="Pending">Pending</option>
                          <option value="Approved">Approved</option>
                          <option value="Rejected">Rejected</option>
                        </select>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
              <p>No teachers found.</p>
            )}
          </div>

          {selectedTeacher && (
            <div className="modal" onClick={closeModal}>
              <div
                className="modal-content"
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

          {showHistory && (
            <div className="modal" onClick={closeHistoryModal}>
              <div
                className="modal-content history-modal-content"
                onClick={(e) => e.stopPropagation()}
              >
                <div className="modal-header">
                  <h2>History</h2>
                  <span className="close-icon" onClick={closeHistoryModal}>
                    ×
                  </span>
                </div>
                <div className="modal-body">
                  {historyLoading ? (
                    <p>Loading history...</p>
                  ) : sortedHistoryTeachers.length > 0 ? (
                    <div className="history-table-wrapper">
                      <table className="teacher-approval-table">
                        <thead>
                          <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Status</th>
                          </tr>
                        </thead>
                        <tbody>
                          {sortedHistoryTeachers.map((teacher) => (
                            <tr key={teacher.id}>
                              <td>{getFullName(teacher)}</td>
                              <td>{teacher.email || "N/A"}</td>
                              <td>{teacher.status || "N/A"}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  ) : (
                    <p>No history found.</p>
                  )}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default TeacherApproval;
