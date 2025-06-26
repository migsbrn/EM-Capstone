import React, { useState, useEffect } from "react";
import { db } from "../firebase";
import { collection, query, where, orderBy, onSnapshot } from "firebase/firestore";
import '../styles/ComS.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import "bootstrap/dist/css/bootstrap.min.css";

const ComS = ({ onBack }) => {
  const [selectedAssessmentType, setSelectedAssessmentType] = useState(null);
  const [fetchedAttempts, setFetchedAttempts] = useState([]);
  const [loadingAttempts, setLoadingAttempts] = useState(false);
  const [attemptsError, setAttemptsError] = useState(null);

  const communicationSocialAssessments = [
    {
      id: "PictureStory",
      name: "PICTURE STORY ASSESSMENT",
      description: "Assess comprehension and narrative skills through picture stories.",
      imageUrl: "picture-story-illustration.png",
      bgColor: "#E0F7FA",
      textColor: "#006064"
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
        collection(db, "communicationAssessments"),
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
    <div className="container py-4 coms-container">
      <button className="coms-btn-back" onClick={onBack}>Back</button>
      {attemptsError && <div className="alert alert-danger">{attemptsError}</div>}

      {selectedAssessmentType ? (
        <>
          {loadingAttempts ? (
            <p className="text-center">Loading results...</p>
          ) : fetchedAttempts.length > 0 ? (
            <div className="coms-results-table-container shadow-sm">
              <table className="coms-results-table">
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
          {communicationSocialAssessments.map((assessment) => (
            <div key={assessment.id} className="col-12 col-md-6 col-lg-3">
              <div
                className="coms-type-card h-100 shadow-sm"
                style={{ backgroundColor: assessment.bgColor }}
                onClick={() => setSelectedAssessmentType(assessment.id)}
              >
                <div className="coms-type-card-header" style={{ color: assessment.textColor }}>
                  {assessment.name}
                </div>
                <div className="coms-type-card-body">
                  <div className="coms-illustration-placeholder">
                    {assessment.id === "PictureStory" && <i className="fas fa-image"></i>}
                  </div>
                  <p className="coms-type-card-text" style={{ color: assessment.textColor }}>
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

export default ComS;