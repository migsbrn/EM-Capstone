import React from "react";
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import "bootstrap/dist/css/bootstrap.min.css";
import '../styles/SocialS.css';

const SocialS = ({ onBack }) => {
  return (
    <div className="container py-4 socials-container">
      <button className="socials-btn-back" onClick={onBack}>Back</button>
      <div className="text-center">
        <h2>Social Skills Assessments</h2>
        <p>No assessments available yet for Social Skills.</p>
        <p>Please check back later!</p>
      </div>
    </div>
  );
};

export default SocialS;