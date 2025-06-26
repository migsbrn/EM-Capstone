import { useState, useEffect } from "react";
import { db, auth } from "../firebase";
import {
  collection,
  addDoc,
  query,
  orderBy,
  onSnapshot,
  doc,
  updateDoc,
  deleteDoc,
  getDoc,
  serverTimestamp
} from "firebase/firestore";
import "../styles/StudentList.css";
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import "bootstrap/dist/css/bootstrap.min.css";

const StudentList = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [students, setStudents] = useState([]);
  const [showAddModal, setShowAddModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [showEditConfirmModal, setShowEditConfirmModal] = useState(false);
  const [surname, setSurname] = useState("");
  const [firstName, setFirstName] = useState("");
  const [middleName, setMiddleName] = useState("");
  const [nickname, setNickname] = useState("");
  const [supportNeeds, setSupportNeeds] = useState(["Autism Spectrum Disorder"]);
  const [error, setError] = useState(null);
  const [selectedStudent, setSelectedStudent] = useState(null);
  const [pendingEditData, setPendingEditData] = useState(null);

  useEffect(() => {
    const q = query(collection(db, "students"), orderBy("createdAt", "desc"));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const studentData = snapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }));
        setStudents(studentData);
      },
      (error) => {
        setError("Failed to fetch students: " + error.message);
      }
    );
    return () => unsubscribe();
  }, []);

  const generateUID = async () => {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, "0");
    const prefix = `${year}${month}`;

    const studentDocs = students.filter((student) =>
      (student.uid || "").startsWith(prefix)
    );
    if (studentDocs.length === 0) return `${prefix}001`;

    const counters = studentDocs.map((doc) =>
      parseInt((doc.uid || "").slice(-3))
    );
    const maxCounter = Math.max(...counters);
    const newCounter = String(maxCounter + 1).padStart(3, "0");
    return `${prefix}${newCounter}`;
  };

  const getTeacherName = async (teacherId) => {
    try {
      const teacherDocRef = doc(db, "teacherRequests", teacherId);
      const teacherDoc = await getDoc(teacherDocRef);
      if (teacherDoc.exists()) {
        const teacherData = teacherDoc.data();
        return (
          `${teacherData.firstName || ""} ${
            teacherData.lastName || ""
          }`.trim() || "Unknown Teacher"
        );
      }
      return "Unknown Teacher";
    } catch (error) {
      console.error("Error fetching teacher name:", error);
      return "Unknown Teacher";
    }
  };

  const handleAddStudent = async (e) => {
    e.preventDefault();
    if (!surname || !firstName || !nickname || supportNeeds.length === 0) {
      setError("Please fill all required fields");
      return;
    }

    setError(null);
    try {
      const uid = await generateUID();
      const teacherId = auth.currentUser?.uid;
      if (!teacherId) throw new Error("No authenticated teacher");
      const teacherName = await getTeacherName(teacherId);
      await addDoc(collection(db, "students"), {
        surname,
        firstName,
        middleName,
        nickname,
        supportNeeds,
        uid,
        createdBy: teacherId,
        createdAt: serverTimestamp(),
      });

      await addDoc(collection(db, "logs"), {
        teacherId,
        teacherName,
        activityDescription: `Added student: ${firstName} ${surname}`,
        createdAt: serverTimestamp(),
      });

      setSurname("");
      setFirstName("");
      setMiddleName("");
      setNickname("");
      setSupportNeeds(["Autism Spectrum Disorder"]);
      setShowAddModal(false);
    } catch (error) {
      console.error("Add student error:", error);
      setError("Failed to add student: " + error.message);
    }
  };

  const handleEditStudent = async (e) => {
    e.preventDefault();
    if (!surname || !firstName || !nickname || supportNeeds.length === 0) {
      setError("Please fill all required fields");
      return;
    }

    setError(null);

    const hasChanges =
      surname !== selectedStudent.surname ||
      firstName !== selectedStudent.firstName ||
      middleName !== selectedStudent.middleName ||
      nickname !== selectedStudent.nickname ||
      JSON.stringify(supportNeeds.sort()) !==
        JSON.stringify(selectedStudent.supportNeeds.sort());

    if (!hasChanges) {
      setSurname("");
      setFirstName("");
      setMiddleName("");
      setNickname("");
      setSupportNeeds(["Autism Spectrum Disorder"]);
      setShowEditModal(false);
      setSelectedStudent(null);
      return;
    }

    setPendingEditData({
      surname,
      firstName,
      middleName,
      nickname,
      supportNeeds,
    });
    setShowEditConfirmModal(true);
  };

  const confirmEditStudent = async () => {
    try {
      const teacherId = auth.currentUser?.uid;
      if (!teacherId) throw new Error("No authenticated teacher");
      const teacherName = await getTeacherName(teacherId);
      await updateDoc(doc(db, "students", selectedStudent.id), {
        surname: pendingEditData.surname,
        firstName: pendingEditData.firstName,
        middleName: pendingEditData.middleName,
        nickname: pendingEditData.nickname,
        supportNeeds: pendingEditData.supportNeeds,
      });

      await addDoc(collection(db, "logs"), {
        teacherId,
        teacherName,
        activityDescription: `Edited Student Information`,
        createdAt: serverTimestamp(),
      });

      setSurname("");
      setFirstName("");
      setMiddleName("");
      setNickname("");
      setSupportNeeds(["Autism Spectrum Disorder"]);
      setShowEditModal(false);
      setShowEditConfirmModal(false);
      setSelectedStudent(null);
      setPendingEditData(null);
    } catch (error) {
      console.error("Edit student error:", error);
      setError("Failed to edit student: " + error.message);
    }
  };

  const handleDeleteStudent = async () => {
    try {
      const teacherId = auth.currentUser?.uid;
      if (!teacherId) throw new Error("No authenticated teacher");
      const teacherName = await getTeacherName(teacherId);
      await deleteDoc(doc(db, "students", selectedStudent.id));

      await addDoc(collection(db, "logs"), {
        teacherId,
        teacherName,
        activityDescription: `Deleted student: ${selectedStudent.firstName} ${selectedStudent.surname}`,
        createdAt: serverTimestamp(),
      });

      setShowDeleteModal(false);
      setSelectedStudent(null);
    } catch (error) {
      console.error("Delete student error:", error);
      setError("Failed to delete student: " + error.message);
    }
  };

  const filteredStudents = students
    .filter((student) => {
      const searchLower = searchTerm.toLowerCase();
      return (
        (student.firstName || "").toLowerCase().includes(searchLower) ||
        (student.middleName || "").toLowerCase().includes(searchLower) ||
        (student.surname || "").toLowerCase().includes(searchLower) ||
        (student.uid || "").includes(searchTerm) ||
        (student.nickname || "").toLowerCase().includes(searchLower)
      );
    })
    .sort((a, b) => {
      const nameA = `${a.firstName || ""} ${a.middleName || ""} ${
        a.surname || ""
      }`.toLowerCase();
      const nameB = `${b.firstName || ""} ${b.middleName || ""} ${
        b.surname || ""
      }`.toLowerCase();
      return nameA.localeCompare(nameB);
    });

  return (
    <div className="container py-4">
      <div className="d-flex justify-content-between align-items-center mb-4">
        <button
          className="btn sl-btn-add-student mb-2"
          onClick={() => setShowAddModal(true)}
        >
          <span className="me-2">+</span>Add Student
        </button>
        <div className="d-flex align-items-center">
          <input
            type="text"
            className="form-control sl-search-input me-2"
            placeholder="Search..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      {error && (
        <div className="alert alert-danger" role="alert">
          {error}
        </div>
      )}

      <div
        className={`modal fade ${showAddModal ? "show d-block" : ""}`}
        tabIndex="-1"
        style={{
          backgroundColor: showAddModal ? "rgba(0,0,0,0.5)" : "transparent",
        }}
      >
        <div className="modal-dialog modal-dialog-centered">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title">Add New Student</h5>
              <button
                type="button"
                className="btn-close"
                onClick={() => setShowAddModal(false)}
              ></button>
            </div>
            <form onSubmit={handleAddStudent}>
              <div className="modal-body">
                <div className="mb-3">
                  <label htmlFor="addSurname" className="form-label">
                    Surname <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    type="text"
                    className="form-control"
                    id="addSurname"
                    value={surname}
                    onChange={(e) => setSurname(e.target.value)}
                    required
                  />
                </div>
                <div className="mb-3">
                  <label htmlFor="addFirstName" className="form-label">
                    First Name <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    type="text"
                    className="form-control"
                    id="addFirstName"
                    value={firstName}
                    onChange={(e) => setFirstName(e.target.value)}
                    required
                  />
                </div>
                <div className="mb-3">
                  <label htmlFor="addMiddleName" className="form-label">
                    Middle Name
                  </label>
                  <input
                    type="text"
                    className="form-control"
                    id="addMiddleName"
                    value={middleName}
                    onChange={(e) => setMiddleName(e.target.value)}
                  />
                </div>
                <div className="mb-3">
                  <label htmlFor="addNickname" className="form-label">
                    Nickname <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    type="text"
                    className="form-control"
                    id="addNickname"
                    value={nickname}
                    onChange={(e) => setNickname(e.target.value)}
                    required
                  />
                </div>
                <div className="mb-3">
                  <label htmlFor="addSupportNeeds" className="form-label">
                    Support Needs <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    type="text"
                    className="form-control"
                    id="addSupportNeeds"
                    value="Autism Spectrum Disorder"
                    readOnly
                    required
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button
                  type="button"
                  className="btn btn-secondary"
                  onClick={() => setShowAddModal(false)}
                >
                  Close
                </button>
                <button type="submit" className="btn btn-primary">
                  Add Student
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <div
        className={`modal fade ${showEditModal ? "show d-block" : ""}`}
        tabIndex="-1"
        style={{
          backgroundColor: showEditModal ? "rgba(0,0,0,0.5)" : "transparent",
        }}
      >
        <div className="modal-dialog modal-dialog-centered">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title">Edit Student</h5>
              <button
                type="button"
                className="btn-close"
                onClick={() => setShowEditModal(false)}
              ></button>
            </div>
            <form onSubmit={handleEditStudent}>
              <div className="modal-body">
                <div className="mb-3">
                  <label htmlFor="editSurname" className="form-label">
                    Surname <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    type="text"
                    className="form-control"
                    id="editSurname"
                    value={surname}
                    onChange={(e) => setSurname(e.target.value)}
                    required
                  />
                </div>
                <div className="mb-3">
                  <label htmlFor="editFirstName" className="form-label">
                    First Name <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    type="text"
                    className="form-control"
                    id="editFirstName"
                    value={firstName}
                    onChange={(e) => setFirstName(e.target.value)}
                    required
                  />
                </div>
                <div className="mb-3">
                  <label htmlFor="editMiddleName" className="form-label">
                    Middle Name
                  </label>
                  <input
                    type="text"
                    className="form-control"
                    id="editMiddleName"
                    value={middleName}
                    onChange={(e) => setMiddleName(e.target.value)}
                  />
                </div>
                <div className="mb-3">
                  <label htmlFor="editNickname" className="form-label">
                    Nickname <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    type="text"
                    className="form-control"
                    id="editNickname"
                    value={nickname}
                    onChange={(e) => setNickname(e.target.value)}
                    required
                  />
                </div>
                <div className="mb-3">
                  <label htmlFor="editSupportNeeds" className="form-label">
                    Support Needs <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    type="text"
                    className="form-control"
                    id="editSupportNeeds"
                    value="Autism Spectrum Disorder"
                    readOnly
                    required
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button
                  type="button"
                  className="btn btn-secondary"
                  onClick={() => setShowEditModal(false)}
                >
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Save Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <div
        className={`modal fade ${showEditConfirmModal ? "show d-block" : ""}`}
        tabIndex="-1"
        style={{
          backgroundColor: showEditConfirmModal
            ? "rgba(0,0,0,0.5)"
            : "transparent",
        }}
      >
        <div className="modal-dialog modal-dialog-centered">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title">Confirm Edit</h5>
              <button
                type="button"
                className="btn-close"
                onClick={() => setShowEditConfirmModal(false)}
              ></button>
            </div>
            <div className="modal-body">
              Are you sure you want to apply these changes?
            </div>
            <div className="modal-footer">
              <button
                type="button"
                className="btn btn-secondary"
                onClick={() => setShowEditConfirmModal(false)}
              >
                Cancel
              </button>
              <button
                type="button"
                className="btn btn-primary"
                onClick={confirmEditStudent}
              >
                Confirm
              </button>
            </div>
          </div>
        </div>
      </div>

      <div
        className={`modal fade ${showDeleteModal ? "show d-block" : ""}`}
        tabIndex="-1"
        style={{
          backgroundColor: showDeleteModal ? "rgba(0,0,0,0.5)" : "transparent",
        }}
      >
        <div className="modal-dialog modal-dialog-centered">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title">Confirm Delete</h5>
              <button
                type="button"
                className="btn-close"
                onClick={() => setShowDeleteModal(false)}
              ></button>
            </div>
            <div className="modal-body">
              Are you sure you want to delete{" "}
              {`${selectedStudent?.firstName || ""} ${
                selectedStudent?.middleName || ""
              } ${selectedStudent?.surname || ""}`}
              ?
            </div>
            <div className="modal-footer">
              <button
                type="button"
                className="btn btn-secondary"
                onClick={() => setShowDeleteModal(false)}
              >
                Cancel
              </button>
              <button
                type="button"
                className="btn btn-danger"
                onClick={handleDeleteStudent}
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      </div>

      <div className="row">
        {filteredStudents.map((student) => (
          <div key={student.id} className="col-12 col-md-4 mb-3">
            <div className="sl-student-card sl-student-card-top d-flex align-items-center justify-content-between p-3">
              <div className="d-flex align-items-center">
                <svg
                  className="sl-student-img me-2"
                  width="40"
                  height="40"
                  viewBox="0 0 16 16"
                  fill="currentColor"
                  style={{ marginTop: "5px" }}
                >
                  <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0z" />
                  <path
                    fillRule="evenodd"
                    d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8zm8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1z"
                  />
                </svg>
                <div className="student-details">
                  <h5 className="mb-1 sl-student-name">
                    {`${student.firstName || ""} ${student.middleName || ""} ${
                      student.surname || ""
                    }`.trim()}
                  </h5>
                  <p className="mb-0 sl-student-uid">
                    UID: {student.uid || "N/A"}
                  </p>
                </div>
              </div>
              <div className="d-flex">
                <button
                  className="btn sl-btn-edit me-1"
                  onClick={() => {
                    setSelectedStudent(student);
                    setSurname(student.surname || "");
                    setFirstName(student.firstName || "");
                    setMiddleName(student.middleName || "");
                    setNickname(student.nickname || "");
                    setSupportNeeds(student.supportNeeds || ["Autism Spectrum Disorder"]);
                    setShowEditModal(true);
                  }}
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    fill="currentColor"
                    className="bi bi-pencil-square"
                    viewBox="0 0 16 16"
                  >
                    <path d="M15.502 1.94a.5.5 0 0 1 0 .706L14.459 3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z" />
                    <path
                      fillRule="evenodd"
                      d="M1 13.5A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 1.5-1.5v-6a.5.5 0 0 0-1 0v6a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5v-11a.5.5 0 0 1 .5-.5H9a.5.5 0 0 0 0-1H2.5A1.5 1.5 0 0 0 1 2.5z"
                    />
                  </svg>
                </button>
                <button
                  className="btn sl-btn-edit"
                  onClick={() => {
                    setSelectedStudent(student);
                    setShowDeleteModal(true);
                  }}
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    fill="currentColor"
                    className="bi bi-trash3"
                    viewBox="0 0 16 16"
                  >
                    <path d="M6.5 1h3a.5.5 0 0 1 .5.5v1H6v-1a.5.5 0 0 1 .5-.5ZM11 2.5v-1A1.5 1.5 0 0 0 9.5 0h-3A1.5 1.5 0 0 0 5 1.5v1H2.506a.58.58 0 0 0-.01 0H1.5a.5.5 0 0 0 0 1h.538l.853 10.66A2 2 0 0 0 4.885 16h6.23a2 2 0 0 0 1.994-1.84l.853-10.66h.538a.5.5 0 0 0 0-1h-.995a.59.59 0 0 0-.01 0H11Zm1.958 1-.846 10.58a1 1 0 0 1-.997.92h-6.23a1 1 0 0 1-.997-.92L3.042 3.5h9.916Zm-7.487 1a.5.5 0 0 1 .528.47l.5 8.5a.5.5 0 0 1-.998.06L5 5.03a.5.5 0 0 1 .47-.53Zm5.058 0a.5.5 0 0 1 .47.53l-.5 8.5a.5.5 0 0 1-.998-.06l.5-8.5a.5.5 0 0 1 .528-.47ZM8 4.5a.5.5 0 0 1 .5.5v8.5a.5.5 0 0 1-1 0V5a.5.5 0 0 1 .5-.5Z" />
                  </svg>
                </button>
              </div>
            </div>
            <div className="sl-student-card sl-student-card-bottom p-3">
              <div className="sl-scrollable-details">
                <p className="mb-0 sl-student-nickname mt-2">
                  <span className="sl-label-bold">Nickname: </span>
                  {student.nickname || "N/A"}
                </p>
                <p className="mb-0 sl-student-support-need">
                  <span className="sl-label-bold">Support Needs: </span>
                  {(student.supportNeeds || []).join(", ") || "N/A"}
                </p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default StudentList;