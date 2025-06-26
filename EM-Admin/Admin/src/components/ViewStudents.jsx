import React, { useEffect, useState } from "react";
import { db } from "../firebase";
import {
  collection,
  query,
  getDocs,
  orderBy,
  onSnapshot,
  doc,
  getDoc,
} from "firebase/firestore";
import "../styles/ViewStudents.css";

const ViewStudents = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [progressFilter, setProgressFilter] = useState("");
  const [students, setStudents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedStudent, setSelectedStudent] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    const fetchStudents = async () => {
      try {
        console.log("Starting to fetch students...");
        const q = query(
          collection(db, "students"),
          orderBy("createdAt", "desc")
        );
        const unsubscribe = onSnapshot(
          q,
          async (snapshot) => {
            console.log("Snapshot received, docs count:", snapshot.docs.length);
            const studentData = await Promise.all(
              snapshot.docs.map(async (docSnapshot) => {
                const data = docSnapshot.data();
                console.log("Processing document:", docSnapshot.id, data);
                let teacherName = "Unknown";
                if (data.createdBy) {
                  try {
                    const teacherDoc = await getDoc(
                      doc(db, "teacherRequests", data.createdBy)
                    );
                    console.log("Teacher doc exists:", teacherDoc.exists());
                    if (teacherDoc.exists()) {
                      const teacherData = teacherDoc.data();
                      teacherName =
                        `${teacherData.firstName || ""} ${
                          teacherData.lastName || ""
                        }`.trim() || "Unknown";
                      console.log("Teacher name fetched:", teacherName);
                    } else {
                      console.log(
                        "No teacher document found for ID:",
                        data.createdBy
                      );
                    }
                  } catch (teacherError) {
                    console.error("Error fetching teacher:", teacherError);
                  }
                }
                return {
                  id: docSnapshot.id,
                  nickname: data.nickname || "N/A",
                  assignedTeacher: teacherName,
                  progress: calculateProgress(data),
                  details: {
                    surname: data.surname || "N/A",
                    firstName: data.firstName || "N/A",
                    middleName: data.middleName || "N/A",
                    supportNeeds: data.supportNeeds || [],
                    lastLogin: data.lastLogin
                      ? data.lastLogin.toDate().toLocaleString()
                      : "Never",
                  },
                  lastLogin: data.lastLogin || null,
                };
              })
            );
            console.log("Processed student data:", studentData);
            setStudents(studentData);
            setLoading(false);
          },
          (error) => {
            console.error("Error in snapshot listener:", error);
            setLoading(false);
          }
        );
        return () => unsubscribe();
      } catch (error) {
        console.error("Error in useEffect:", error);
        setLoading(false);
      }
    };

    fetchStudents();
  }, []);

  const calculateProgress = (studentData) => {
    return `${Math.floor(Math.random() * 100) + 1}%`; // Ensure 1-100%
  };

  const filteredStudents = students.filter((student) => {
    const matchesSearch = student.nickname
      .toLowerCase()
      .includes(searchTerm.toLowerCase());
    const matchesProgress = progressFilter
      ? student.progress === progressFilter
      : true;
    return matchesSearch && matchesProgress;
  });

  const openModal = (student) => {
    setSelectedStudent(student);
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setSelectedStudent(null);
  };

  return (
    <div className="vs-container">
      <h1 className="vs-title">Student List</h1>

      <div className="vs-controls">
        <input
          className="vs-search"
          type="text"
          placeholder="Search..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />

        <select
          className="vs-select"
          value={progressFilter}
          onChange={(e) => setProgressFilter(e.target.value)}
        >
          <option value="">All</option>
          {[...Array(100)].map((_, index) => {
            const val = index + 1;
            return (
              <option key={val} value={`${val}%`}>
                {val}%
              </option>
            );
          })}
        </select>
      </div>

      <div className="vs-table-container" data-filter={progressFilter || "All"}>
        {loading ? (
          <p>Loading students...</p>
        ) : (
          <>
            <table className="vs-table">
              <thead>
                <tr>
                  <th>NICKNAME</th>
                  <th>ASSIGNED TEACHER</th>
                  <th>PROGRESS</th>
                  <th>DETAILS</th>
                </tr>
              </thead>
              <tbody>
                {filteredStudents.map((student) => (
                  <tr key={student.id}>
                    <td>{student.nickname}</td>
                    <td>{student.assignedTeacher}</td>
                    <td>{student.progress}</td>
                    <td>
                      <button
                        className="vs-more-btn"
                        data-filter={progressFilter || "All"}
                        onClick={() => openModal(student)}
                      >
                        More
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {filteredStudents.length === 0 && <p>No students found.</p>}
          </>
        )}
      </div>

      {isModalOpen && selectedStudent && (
        <div className="vs-modal">
          <div
            className="vs-modal-content"
            data-filter={progressFilter || "All"}
          >
            <h2>Student Details</h2>
            <div className="vs-modal-detail">
              <p>
                <strong>Full Name:</strong>{" "}
                {`${selectedStudent.details.firstName} ${
                  selectedStudent.details.middleName !== "N/A"
                    ? selectedStudent.details.middleName + " "
                    : ""
                }${selectedStudent.details.surname}`}
              </p>
              <p>
                <strong>Nickname:</strong> {selectedStudent.nickname}
              </p>
              <p>
                <strong>Support Needs:</strong>{" "}
                {selectedStudent.details.supportNeeds.length > 0
                  ? selectedStudent.details.supportNeeds.join(", ")
                  : "None"}
              </p>
              <p>
                <strong>Last Login:</strong>{" "}
                {selectedStudent.details.lastLogin || "Never"}
              </p>
            </div>
            <button className="vs-close-btn" onClick={closeModal}>
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default ViewStudents;
