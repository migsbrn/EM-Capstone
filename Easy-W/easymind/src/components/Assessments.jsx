import { useState, useEffect } from "react";
import "../styles/Assessments.css";
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import "bootstrap/dist/css/bootstrap.min.css";

// Import the specific components for each category
import FunctionalR from './FunctionalR';
import ComS from './ComS';
import SocialS from './SocialS';
import Prevoc from './Prevoc';

const Assessments = () => {
  // State to manage which component to render
  const [activeScreen, setActiveScreen] = useState("categories"); // 'categories', 'functionalR', 'communicationS', 'prevoc', 'socialS'

  useEffect(() => {
    // Load Font Awesome CDN
    const fontAwesome = document.createElement("link");
    fontAwesome.rel = "stylesheet";
    fontAwesome.href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css";
    document.head.appendChild(fontAwesome);

    // Override browser back button to always return to assessments page
    const handlePopState = () => {
      setActiveScreen("categories"); // Force back to assessments page
    };

    window.addEventListener("popstate", handlePopState);

    // Cleanup
    return () => {
      document.head.removeChild(fontAwesome);
      window.removeEventListener("popstate", handlePopState);
    };
  }, []);

  const navigateTo = (screen) => {
    setActiveScreen(screen);
  };

  const renderScreen = () => {
    switch (activeScreen) {
      case "functionalR":
        return <FunctionalR onBack={() => setActiveScreen("categories")} />;
      case "communicationS":
        return <ComS onBack={() => setActiveScreen("categories")} />;
      case "prevoc":
        return <Prevoc onBack={() => setActiveScreen("categories")} />;
      case "socialS":
        return <SocialS onBack={() => setActiveScreen("categories")} />;
      case "categories":
      default:
        return (
          <div className="row">
            {categories.map((category) => (
              <div key={category.name} className="col-12 col-md-6 col-lg-3 mb-4">
                <div
                  className="ass-card h-100 shadow-sm"
                  style={{ backgroundColor: category.color }}
                  onClick={() => navigateTo(category.screen)}
                  onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = category.hoverColor)}
                  onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = category.color)}
                >
                  <div className="ass-card-header">{category.name}</div>
                  <div className="ass-card-body">
                    <i className={`category-icon-large ${category.icon}`}></i>
                    <p className="ass-card-text">{category.description}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        );
    }
  };

  const categories = [
    {
      name: "Functional Academics",
      icon: "fas fa-book",
      description: "Assess reading, writing, and practical math skills.",
      screen: "functionalR",
      color: "var(--color-functional-academics)",
      hoverColor: "var(--color-functional-academics-hover)"
    },
    {
      name: "Communication Skills",
      icon: "fas fa-comment",
      description: "Evaluate verbal, non-verbal, and comprehension abilities.",
      screen: "communicationS",
      color: "var(--color-communication-skills)",
      hoverColor: "var(--color-communication-skills-hover)"
    },
    {
      name: "Pre-vocational Skills",
      icon: "fas fa-briefcase",
      description: "Measure foundational work readiness and job skills.",
      screen: "prevoc",
      color: "var(--color-pre-vocational-skills)",
      hoverColor: "var(--color-pre-vocational-skills-hover)"
    },
    {
      name: "Social Skills",
      icon: "fas fa-handshake",
      description: "Analyze interaction, empathy, and group participation.",
      screen: "socialS",
      color: "var(--color-social-skills)",
      hoverColor: "var(--color-social-skills-hover)"
    },
  ];

  return (
    <div className="container py-4 assessments-container">
      {renderScreen()}
    </div>
  );
};

export default Assessments;