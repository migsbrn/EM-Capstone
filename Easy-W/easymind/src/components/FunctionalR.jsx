import React, { useState, useEffect } from "react";
import { db } from "../firebase";
import { collection, query, where, orderBy, onSnapshot } from "firebase/firestore";
import '../styles/FunctionalR.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import "bootstrap/dist/css/bootstrap.min.css";

const FunctionalR = ({ onBack }) => {
  const [selectedAssessmentType, setSelectedAssessmentType] = useState(null);
  const [fetchedAttempts, setFetchedAttempts] = useState([]);
  const [loadingAttempts, setLoadingAttempts] = useState(false);
  const [attemptsError, setAttemptsError] = useState(null);

  const functionalAcademicAssessments = [
    {
      id: "Alphabet",
      name: "LEARN THE ALPHABET",
      description: "Learn letter recognition and phonics.",
      imageUrl: "alphabet-illustration.png",
      bgColor: "#FFF8E1",
      textColor: "#333333"
    },
    {
      id: "Rhyme",
      name: "RHYME AND READ",
      description: "Develop phonological awareness and reading fluency.",
      imageUrl: "rhyme-illustration.png",
      bgColor: "#E0F8E8",
      textColor: "#333333"
    },
    {
      id: "Color",
      name: "LEARN THE COLOR",
      description: "Identify and differentiate colors.",
      imageUrl: "color-illustration.png",
      bgColor: "#FBE4EB",
      textColor: "#333333"
    },
    {
      id: "Shape",
      name: "LEARN THE SHAPES",
      description: "Match objects to their shapes.",
      imageUrl: "shape-illustration.png",
      bgColor: "#E8F0FF",
      textColor: "#333333"
    },
  ];

  useEffect(() => {
    if (!selectedAssessmentType) {
      setFetchedAttempts([]);
      setAttemptsError(null);
      return;
    }

    setLoadingAttempts(true);
    setAttemptsError(null);

    try {
      const q = query(
        collection(db, "functionalAssessments"),
        where("assessmentType", "==", selectedAssessmentType),
        orderBy("timestamp", "desc")
      );

      const unsubscribe = onSnapshot(
        q,
        (snapshot) => {
          const attemptsData = snapshot.docs.map((doc) => ({
            id: doc.id,
            ...doc.data(),
            timestamp: doc.data().timestamp?.toDate() || new Date(0),
          }));
          setFetchedAttempts(attemptsData);
          setLoadingAttempts(false);
        },
        (error) => {
          console.error("Error fetching assessment attempts:", error);
          setAttemptsError("Failed to load results. Please try again.");
          setLoadingAttempts(false);
        }
      );

      return () => unsubscribe();
    } catch (e) {
      console.error("Error setting up Firestore listener:", e);
      setAttemptsError("Failed to set up data listener.");
      setLoadingAttempts(false);
    }
  }, [selectedAssessmentType]);

  return (
    <div className="container py-4 functional-r-container">
      <button className="functional-r-btn-back" onClick={onBack}>Back</button>
      {attemptsError && <div className="alert alert-danger">{attemptsError}</div>}

      {selectedAssessmentType ? (
        <>
          {loadingAttempts ? (
            <p className="text-center">Loading results...</p>
          ) : fetchedAttempts.length > 0 ? (
            <div className="functional-r-results-table-container shadow-sm">
              <table className="functional-r-results-table">
                <thead>
                  <tr>
                    <th>Student Nickname</th>
                    <th>Score</th>
                    <th>Status</th>
                    <th>Date</th>
                  </tr>
                </thead>
                <tbody>
                  {fetchedAttempts.map((attempt) => (
                    <tr key={attempt.id}>
                      <td>{attempt.nickname}</td>
                      <td>{attempt.status === 'Skipped' ? '-' : `${attempt.score || 0}/${attempt.totalQuestions || 0}`}</td>
                      <td>{attempt.status}</td>
                      <td>
                        {attempt.timestamp instanceof Date && !isNaN(attempt.timestamp)
                          ? attempt.timestamp.toLocaleDateString()
                          : 'N/A'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <p className="no-results-message">No results found for this assessment type.</p>
          )}
        </>
      ) : (
        <div className="row justify-content-center">
          {functionalAcademicAssessments.map((assessment) => (
            <div key={assessment.id} className="col-12 col-md-6 col-lg-3">
              <div
                className="functional-r-type-card h-100 shadow-sm"
                style={{ backgroundColor: assessment.bgColor }}
                onClick={() => setSelectedAssessmentType(assessment.id)}
              >
                <div className="functional-r-type-card-header" style={{ color: assessment.textColor }}>
                  {assessment.name}
                </div>
                <div className="functional-r-type-card-body">
                  <div className="functional-r-illustration-placeholder">
                    {assessment.id === "Alphabet" && <i className="fas fa-spell-check"></i>}
                    {assessment.id === "Rhyme" && <i className="fas fa-book-reader"></i>}
                    {assessment.id === "Color" && <i className="fas fa-palette"></i>}
                    {assessment.id === "Shape" && <i className="fas fa-shapes"></i>}
                  </div>
                  <p className="functional-r-type-card-text" style={{ color: assessment.textColor }}>
                    {assessment.description}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default FunctionalR;