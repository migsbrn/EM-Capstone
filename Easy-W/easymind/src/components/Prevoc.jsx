import React from "react";
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import "bootstrap/dist/css/bootstrap.min.css";
import '../styles/Prevoc.css';

const Prevoc = ({ onBack }) => {
  return (
    <div className="container py-4 prevoc-container">
      <button className="prevoc-btn-back" onClick={onBack}>Back</button>
      <div className="text-center">
        <h2>Pre-Vocational Assessments</h2>
        <p>No assessments available yet for Pre-Vocational skills.</p>
        <p>Please check back later!</p>
      </div>
    </div>
  );
};

export default Prevoc;