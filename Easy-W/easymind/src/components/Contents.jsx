import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { db } from "../firebase";
import {
  collection,
  getDocs,
  addDoc,
  deleteDoc,
  doc,
  serverTimestamp,
  query,
  orderBy,
  where,
  getDoc,
} from "firebase/firestore";
import { getAuth, onAuthStateChanged } from "firebase/auth";
import "../styles/Contents.css";
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import "bootstrap/dist/css/bootstrap.min.css";

const categories = [
  "NUMBER_SKILLS",
  "SELF_HELP",
  "PRE-VOCATIONAL_SKILLS",
  "SOCIAL_SKILLS",
  "FUNCTIONAL_ACADEMICS",
  "COMMUNICATION_SKILLS",
];

const months = [
  { value: "all", label: "All Months" },
  { value: "1", label: "January" },
  { value: "2", label: "February" },
  { value: "3", label: "March" },
  { value: "4", label: "April" },
  { value: "5", label: "May" },
  { value: "6", label: "June" },
  { value: "7", label: "July" },
  { value: "8", label: "August" },
  { value: "9", label: "September" },
  { value: "10", label: "October" },
  { value: "11", label: "November" },
  { value: "12", label: "December" },
];

const displayCategory = (category) =>
  category && categories.includes(category)
    ? category.toLowerCase().replace(/_/g, " ")
    : "unknown";

const Contents = () => {
  const navigate = useNavigate();
  const auth = getAuth();

  // State for content data
  const [contents, setContents] = useState([]);
  const [materialFilter, setMaterialFilter] = useState("all materials");
  const [timeRange, setTimeRange] = useState("all_time");
  const [monthFilter, setMonthFilter] = useState("all");
  const [showAssessments, setShowAssessments] = useState(false);

  // State for material form
  const [showMaterialForm, setShowMaterialForm] = useState(false);
  const [materialCategory, setMaterialCategory] = useState(categories[0]);
  const [materialFile, setMaterialFile] = useState(null);

  // State for assessment form
  const [showAssessmentForm, setShowAssessmentForm] = useState(false);
  const [assessmentTitle, setAssessmentTitle] = useState("");
  const [assessmentDescription, setAssessmentDescription] = useState("");
  const [assessmentCategory, setAssessmentCategory] = useState(categories[0]);
  const [assessmentQuestions, setAssessmentQuestions] = useState([]);
  const [currentQuestion, setCurrentQuestion] = useState({
    type: "multiple_choice",
    questionText: "",
    options: ["", "", "", ""],
    correctAnswer: "",
  });
  const [editingQuestionIndex, setEditingQuestionIndex] = useState(null);

  // State for delete confirmation
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [itemToDelete, setItemToDelete] = useState(null);

  // State for form exit confirmation
  const [showExitModal, setShowExitModal] = useState(false);
  const [pendingFormAction, setPendingFormAction] = useState(null);

  // State for notification
  const [notification, setNotification] = useState(null);

  // State for teacher name and loading
  const [teacherName, setTeacherName] = useState("Unknown");
  const [isLoadingTeacher, setIsLoadingTeacher] = useState(true);

  // Fetch teacher name from Firestore
  const fetchTeacherName = async (userId) => {
    try {
      const teacherDocRef = doc(db, "teacherRequests", userId);
      const teacherDoc = await getDoc(teacherDocRef);
      if (teacherDoc.exists()) {
        const teacherData = teacherDoc.data();
        const fullName =
          `${teacherData.firstName || ""} ${teacherData.lastName || ""}`.trim() || "Unknown";
        setTeacherName(fullName);
      } else {
        setTeacherName("Unknown");
      }
    } catch (error) {
      console.error("Error fetching teacher name:", error.message);
      setTeacherName("Unknown");
    } finally {
      setIsLoadingTeacher(false);
    }
  };

  // Listen for authentication state changes
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        await fetchTeacherName(user.uid);
      } else {
        setTeacherName("Unknown");
        setIsLoadingTeacher(false);
      }
    });

    return () => unsubscribe();
  }, [auth]);

  // Fetch content from Firestore
  useEffect(() => {
    const fetchData = async () => {
      try {
        let contentsQuery = query(collection(db, "contents"));

        // Apply type filter
        if (showAssessments) {
          contentsQuery = query(contentsQuery, where("type", "==", "assessment"));
        } else {
          contentsQuery = query(
            contentsQuery,
            where("type", "in", ["material", "uploaded-material"])
          );
          if (materialFilter !== "all materials") {
            const selectedCategory = categories.find(
              (cat) => displayCategory(cat) === materialFilter
            );
            if (selectedCategory) {
              contentsQuery = query(
                contentsQuery,
                where("category", "==", selectedCategory)
              );
            }
          }
        }

        // Apply time range filter
        if (timeRange !== "all_time") {
          const now = new Date();
          let startDate;
          switch (timeRange) {
            case "1_day":
              startDate = new Date(now.setDate(now.getDate() - 1));
              break;
            case "7_days":
              startDate = new Date(now.setDate(now.getDate() - 7));
              break;
            case "30_days":
              startDate = new Date(now.setDate(now.getDate() - 30));
              break;
            default:
              startDate = new Date(0); // Fallback
          }
          contentsQuery = query(
            contentsQuery,
            where("createdAt", ">=", startDate),
            orderBy("createdAt", "desc")
          );
        } else {
          contentsQuery = query(contentsQuery, orderBy("createdAt", "desc"));
        }

        // Fetch all content and filter by month client-side
        const contentsSnapshot = await getDocs(contentsQuery);
        let contentsData = contentsSnapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
          createdAt: doc.data().createdAt?.toDate(), // Convert Timestamp to Date
        }));

        // Apply month filter
        if (monthFilter !== "all") {
          const selectedMonth = parseInt(monthFilter);
          contentsData = contentsData.filter((item) => {
            const itemMonth = item.createdAt?.getMonth() + 1; // getMonth() is 0-based
            return itemMonth === selectedMonth;
          });
        }

        setContents(contentsData);
      } catch (error) {
        console.error("Error fetching contents:", error.message);
        setNotification("Failed to load contents. Please try again.");
      }
    };

    fetchData();
  }, [materialFilter, timeRange, monthFilter, showAssessments, categories]);

  const showNotification = (message) => {
    setNotification(message);
    setTimeout(() => setNotification(null), 2000);
  };

  const hasMaterialChanges = () => {
    return materialCategory !== categories[0] || materialFile;
  };

  const hasAssessmentChanges = () => {
    return (
      assessmentTitle ||
      assessmentDescription ||
      assessmentCategory !== categories[0] ||
      assessmentQuestions.length > 0 ||
      currentQuestion.questionText ||
      currentQuestion.options.some((opt) => opt) ||
      currentQuestion.correctAnswer
    );
  };

  const toggleMaterialForm = () => {
    if (showAssessmentForm && hasAssessmentChanges()) {
      setPendingFormAction(() => () => {
        setShowAssessmentForm(false);
        resetAssessmentForm();
        setShowMaterialForm(true);
      });
      setShowExitModal(true);
    } else {
      setShowAssessmentForm(false);
      resetAssessmentForm();
      setShowMaterialForm(true);
    }
  };

  const toggleAssessmentForm = () => {
    if (showMaterialForm && hasMaterialChanges()) {
      setPendingFormAction(() => () => {
        setShowMaterialForm(false);
        resetMaterialForm();
        setShowAssessmentForm(true);
      });
      setShowExitModal(true);
    } else {
      setShowMaterialForm(false);
      resetMaterialForm();
      setShowAssessmentForm(true);
    }
  };

  const confirmExit = () => {
    if (pendingFormAction) {
      pendingFormAction();
      setPendingFormAction(null);
    }
    setShowExitModal(false);
  };

  const cancelExit = () => {
    setPendingFormAction(null);
    setShowExitModal(false);
  };

  const resetMaterialForm = () => {
    setMaterialCategory(categories[0]);
    setMaterialFile(null);
  };

  const resetAssessmentForm = () => {
    setAssessmentTitle("");
    setAssessmentDescription("");
    setAssessmentCategory(categories[0]);
    setAssessmentQuestions([]);
    setCurrentQuestion({
      type: "multiple_choice",
      questionText: "",
      options: ["", "", "", ""],
      correctAnswer: "",
    });
    setEditingQuestionIndex(null);
  };

  const handleAddMaterial = async (e) => {
    e.preventDefault();
    if (!materialFile) {
      alert("Please upload a file.");
      return;
    }

    try {
      const maxSize = 900 * 1024;
      if (materialFile.size > maxSize) {
        alert("File is too large. Please upload a file smaller than 900KB.");
        return;
      }

      const reader = new FileReader();
      const base64Promise = new Promise((resolve) => {
        reader.onload = () => {
          const base64String = reader.result.split(",")[1];
          resolve(base64String);
        };
        reader.readAsDataURL(materialFile);
      });
      const base64String = await base64Promise;

      const materialData = {
        type: "uploaded-material",
        title: materialFile.name,
        category: materialCategory,
        file: {
          name: materialFile.name,
          type: materialFile.type,
          data: base64String,
        },
        createdAt: serverTimestamp(),
      };

      await addDoc(collection(db, "contents"), materialData);
      const user = auth.currentUser;
      if (user) {
        await fetchTeacherName(user.uid);
      }

      await addDoc(collection(db, "logs"), {
        teacherName: teacherName,
        activityDescription: `Added material: ${materialFile.name}`,
        createdAt: serverTimestamp(),
      });

      resetMaterialForm();
      setShowMaterialForm(false);

      const contentsQuery = query(
        collection(db, "contents"),
        where("type", "in", ["material", "uploaded-material"]),
        orderBy("createdAt", "desc")
      );
      const contentsSnapshot = await getDocs(contentsQuery);
      let contentsData = contentsSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate(),
      }));

      if (monthFilter !== "all") {
        const selectedMonth = parseInt(monthFilter);
        contentsData = contentsData.filter(
          (item) => item.createdAt?.getMonth() + 1 === selectedMonth
        );
      }

      setContents(contentsData);

      showNotification("Material added successfully!");
    } catch (error) {
      console.error("Error adding material:", error.message);
      alert("Failed to add material. Please try again.");
    }
  };

  const handleAddQuestion = () => {
    try {
      if (!currentQuestion.questionText.trim()) {
        alert("Please enter a question.");
        return;
      }

      if (currentQuestion.type === "multiple_choice") {
        if (
          currentQuestion.options.length < 2 ||
          currentQuestion.options.some((opt) => !opt.trim()) ||
          !currentQuestion.correctAnswer
        ) {
          alert("Please provide at least two non-empty options and select a correct answer.");
          return;
        }
        if (!currentQuestion.options.includes(currentQuestion.correctAnswer)) {
          alert("The correct answer must match one of the options.");
          return;
        }
      } else if (currentQuestion.type === "fill_in_the_blank") {
        if (!currentQuestion.correctAnswer.trim()) {
          alert("Please enter a correct answer.");
          return;
        }
      }

      if (editingQuestionIndex !== null) {
        const updatedQuestions = [...assessmentQuestions];
        updatedQuestions[editingQuestionIndex] = currentQuestion;
        setAssessmentQuestions(updatedQuestions);
        setEditingQuestionIndex(null);
        showNotification("Question updated!");
      } else {
        setAssessmentQuestions([...assessmentQuestions, currentQuestion]);
        showNotification("Question added!");
      }

      setCurrentQuestion({
        type: currentQuestion.type,
        questionText: "",
        options: ["", "", "", ""],
        correctAnswer: "",
      });
    } catch (error) {
      console.error("Error adding question:", error.message);
      alert("Failed to add question. Please try again.");
    }
  };

  const handleClearQuestion = () => {
    setCurrentQuestion({
      type: currentQuestion.type,
      questionText: "",
      options: ["", "", "", ""],
      correctAnswer: "",
    });
    setEditingQuestionIndex(null);
    showNotification("Question cleared!");
  };

  const handleDeleteQuestion = (index) => {
    try {
      const updatedQuestions = assessmentQuestions.filter((_, i) => i !== index);
      setAssessmentQuestions(updatedQuestions);
      showNotification("Question deleted!");
    } catch (error) {
      console.error("Error deleting question:", error.message);
      alert("Failed to delete question. Please try again.");
    }
  };

  const handleEditQuestion = (index) => {
    setCurrentQuestion({ ...assessmentQuestions[index] });
    setEditingQuestionIndex(index);
  };

  const handleAddAssessment = async (e) => {
    e.preventDefault();
    try {
      if (!assessmentTitle.trim() || assessmentQuestions.length === 0) {
        alert("Please enter an assessment title and add at least one question.");
        return;
      }

      await addDoc(collection(db, "contents"), {
        type: "assessment",
        title: assessmentTitle,
        description: assessmentDescription,
        category: assessmentCategory,
        questions: assessmentQuestions,
        createdAt: serverTimestamp(),
      });

      const user = auth.currentUser;
      if (user) {
        await fetchTeacherName(user.uid);
      }

      await addDoc(collection(db, "logs"), {
        teacherName: teacherName,
        activityDescription: `Added assessment: ${assessmentTitle}`,
        createdAt: serverTimestamp(),
      });

      resetAssessmentForm();
      setShowAssessmentForm(false);

      const contentsQuery = query(
        collection(db, "contents"),
        where("type", "==", "assessment"),
        orderBy("createdAt", "desc")
      );
      const contentsSnapshot = await getDocs(contentsQuery);
      let contentsData = contentsSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate(),
      }));

      if (monthFilter !== "all") {
        const selectedMonth = parseInt(monthFilter);
        contentsData = contentsData.filter(
          (item) => item.createdAt?.getMonth() + 1 === selectedMonth
        );
      }

      setContents(contentsData);

      showNotification("Assessment added successfully!");
    } catch (error) {
      console.error("Error adding assessment:", error.message);
      alert("Failed to add assessment. Please try again.");
    }
  };

  const handleDeleteContent = async () => {
    try {
      const { id, title, type } = itemToDelete;
      await deleteDoc(doc(db, "contents", id));

      const user = auth.currentUser;
      if (user) {
        await fetchTeacherName(user.uid);
      }

      const itemType = type === "assessment" ? "assessment" : "material";
      await addDoc(collection(db, "logs"), {
        teacherName: teacherName,
        activityDescription: `Deleted ${itemType}: ${title}`,
        createdAt: serverTimestamp(),
      });

      setContents(contents.filter((item) => item.id !== id));
      setShowDeleteModal(false);
      setItemToDelete(null);
      showNotification("Content deleted successfully!");
    } catch (error) {
      console.error("Error deleting content:", error.message);
      alert("Failed to delete content. Please try again.");
    }
  };

  const handleEditContent = (item) => {
    navigate(`/edit-content/${item.id}`, {
      state: { content: item, showAssessments, materialFilter, timeRange, monthFilter },
    });
  };

  return (
    <div className="container py-4">
      <div className="button-container mb-4">
        <div className="add-buttons">
          <button
            className="cl-btn cl-btn-add-material"
            onClick={toggleMaterialForm}
          >
            <span className="add-icon">+</span> Add Material
          </button>
          <button
            className="cl-btn cl-btn-add-assessment"
            onClick={toggleAssessmentForm}
          >
            <span className="add-icon">+</span> Add Assessment
          </button>
        </div>
        <div className="filter-container">
          <div className="filter-group">
            <select
              id="materialFilter"
              className="filter-select"
              value={materialFilter}
              onChange={(e) => {
                setMaterialFilter(e.target.value);
                if (showAssessments) setShowAssessments(false);
              }}
            >
              <option value="all materials">All Materials</option>
              {categories.map((category) => (
                <option key={category} value={displayCategory(category)}>
                  {displayCategory(category)}
                </option>
              ))}
            </select>
          </div>
          <div className="filter-group">
            <span
              className={`assessment-filter ${showAssessments ? "active" : ""}`}
              onClick={() => {
                setShowAssessments(!showAssessments);
                if (!showAssessments) setMaterialFilter("all materials");
              }}
            >
              Assessments
            </span>
          </div>
          <div className="filter-group">
            <select
              id="timeRange"
              className="filter-select"
              value={timeRange}
              onChange={(e) => setTimeRange(e.target.value)}
            >
              <option value="1_day">Last 1 Day</option>
              <option value="7_days">Last 7 Days</option>
              <option value="30_days">Last 30 Days</option>
              <option value="all_time">All Time</option>
            </select>
          </div>
          <div className="filter-group">
            <select
              id="monthFilter"
              className="filter-select"
              value={monthFilter}
              onChange={(e) => setMonthFilter(e.target.value)}
            >
              {months.map((month) => (
                <option key={month.value} value={month.value}>
                  {month.label}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {showMaterialForm && (
        <div className="modal-overlay">
          <div className="modal-content material-form">
            <button
              className="cl-btn close-modal"
              onClick={() => {
                if (hasMaterialChanges()) {
                  setPendingFormAction(() => () => {
                    setShowMaterialForm(false);
                    resetMaterialForm();
                  });
                  setShowExitModal(true);
                } else {
                  setShowMaterialForm(false);
                  resetMaterialForm();
                }
              }}
            >
              ×
            </button>
            <h1 className="form-heading">Add Learning Material</h1>
            <form onSubmit={handleAddMaterial}>
              <div className="form-section">
                <label htmlFor="materialCategoryInput" className="form-label">
                  Category
                </label>
                <select
                  id="materialCategoryInput"
                  className="form-select"
                  value={materialCategory}
                  onChange={(e) => setMaterialCategory(e.target.value)}
                >
                  {categories.map((category) => (
                    <option key={category} value={category}>
                      {displayCategory(category)}
                    </option>
                  ))}
                </select>
              </div>
              <div className="form-section">
                <label htmlFor="materialFileInput" className="form-label">
                  Upload File (PDF, PPTX, DOCX - Max 900KB)
                </label>
                <input
                  type="file"
                  className="form-control"
                  id="materialFileInput"
                  accept=".pdf,.pptx,.doc,.docx"
                  onChange={(e) => setMaterialFile(e.target.files[0])}
                />
              </div>
              <div className="modal-actions">
                <button type="submit" className="cl-btn submit-btn">
                  Add Material
                </button>
                <button
                  type="button"
                  className="cl-btn cancel-btn"
                  onClick={() => {
                    if (hasMaterialChanges()) {
                      setPendingFormAction(() => () => {
                        setShowMaterialForm(false);
                        resetMaterialForm();
                      });
                      setShowExitModal(true);
                    } else {
                      setShowMaterialForm(false);
                      resetMaterialForm();
                    }
                  }}
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {showAssessmentForm && (
        <div className="modal-overlay">
          <div className="modal-content assessment-form">
            <button
              className="cl-btn close-modal"
              onClick={() => {
                if (hasAssessmentChanges()) {
                  setPendingFormAction(() => () => {
                    setShowAssessmentForm(false);
                    resetAssessmentForm();
                  });
                  setShowExitModal(true);
                } else {
                  setShowAssessmentForm(false);
                  resetAssessmentForm();
                }
              }}
            >
              ×
            </button>
            <form onSubmit={handleAddAssessment}>
              <div className="form-header">
                <input
                  type="text"
                  className="assessment-title-input"
                  id="assessmentTitleInput"
                  value={assessmentTitle}
                  onChange={(e) => setAssessmentTitle(e.target.value)}
                  placeholder="Title"
                />
                <input
                  type="text"
                  className="assessment-description-input"
                  id="assessmentDescriptionInput"
                  value={assessmentDescription}
                  onChange={(e) => setAssessmentDescription(e.target.value)}
                  placeholder="Description"
                />
                <div className="form-section">
                  <label
                    htmlFor="assessmentCategoryInput"
                    className="form-label"
                  >
                    Category
                  </label>
                  <select
                    id="assessmentCategoryInput"
                    className="form-select"
                    value={assessmentCategory}
                    onChange={(e) => setAssessmentCategory(e.target.value)}
                  >
                    {categories.map((category) => (
                      <option key={category} value={category}>
                        {displayCategory(category)}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {assessmentQuestions.map((question, index) => (
                <div key={index} className="question-card">
                  <div className="question-card-content">
                    <div className="question-card-main">
                      <input
                        type="text"
                        placeholder="Question"
                        value={question.questionText}
                        onChange={(e) => {
                          const updatedQuestions = [...assessmentQuestions];
                          updatedQuestions[index] = {
                            ...question,
                            questionText: e.target.value,
                          };
                          setAssessmentQuestions(updatedQuestions);
                        }}
                        className="question-text-input"
                      />
                      {question.type === "multiple_choice" && (
                        <div className="options-list">
                          {question.options.map((option, optIndex) => (
                            <div key={optIndex} className="option-item">
                              <span className="option-indicator"></span>
                              <input
                                type="text"
                                placeholder="Add option"
                                value={option}
                                onChange={(e) => {
                                  const newOptions = [...question.options];
                                  newOptions[optIndex] = e.target.value;
                                  setAssessmentQuestions((prev) => {
                                    const updated = [...prev];
                                    updated[index] = {
                                      ...question,
                                      options: newOptions,
                                    };
                                    return updated;
                                  });
                                }}
                                className="option-input"
                              />
                              {optIndex > 0 && (
                                <button
                                  type="button"
                                  className="cl-btn option-remove-btn"
                                  onClick={() => {
                                    const newOptions = [...question.options];
                                    newOptions.splice(optIndex, 1);
                                    setAssessmentQuestions((prev) => {
                                      const updated = [...prev];
                                      updated[index] = {
                                        ...question,
                                        options: newOptions,
                                      };
                                      return updated;
                                    });
                                  }}
                                >
                                  ×
                                </button>
                              )}
                            </div>
                          ))}
                          <button
                            type="button"
                            className="add-option-btn"
                            onClick={() => {
                              setAssessmentQuestions((prev) => {
                                const updated = [...prev];
                                updated[index] = {
                                  ...question,
                                  options: [...question.options, ""],
                                };
                                return updated;
                              });
                            }}
                          >
                            Add option
                          </button>
                        </div>
                      )}
                      {question.type === "fill_in_the_blank" && (
                        <div className="fill-in-the-blank-fill">
                          <label className="form-label">Correct Answer</label>
                          <input
                            type="text"
                            placeholder="Add answer"
                            value={question.correctAnswer}
                            onChange={(e) => {
                              setAssessmentQuestions((prev) => {
                                const updated = [...prev];
                                updated[index] = {
                                  ...question,
                                  correctAnswer: e.target.value,
                                };
                                return updated;
                              });
                            }}
                            className="correct-answer-input"
                          />
                        </div>
                      )}
                      <div className="correct-answer-section">
                        {question.type === "multiple_choice" && (
                          <>
                            <label className="form-label">Correct Answer</label>
                            <select
                              value={question.correctAnswer}
                              onChange={(e) => {
                                setAssessmentQuestions((prev) => {
                                  const updated = [...prev];
                                  updated[index] = {
                                    ...question,
                                    correctAnswer: e.target.value,
                                  };
                                  return updated;
                                });
                              }}
                              className="form-select"
                            >
                              <option value="">Select correct answer</option>
                              {question.options.map((option, optIndex) => (
                                <option
                                  key={optIndex}
                                  value={option}
                                  disabled={!option}
                                >
                                  {option || `Option ${optIndex + 1}`}
                                </option>
                              ))}
                            </select>
                          </>
                        )}
                      </div>
                    </div>
                    <div className="question-card-actions">
                      <select
                        className="question-type-select"
                        value={question.type}
                        onChange={(e) => {
                          setAssessmentQuestions((prev) => {
                            const updated = [...prev];
                            updated[index] = {
                              ...question,
                              type: e.target.value,
                              options: e.target.value === "multiple_choice" ? ["", "", "", ""] : [],
                              correctAnswer: "",
                            };
                            return updated;
                          });
                        }}
                      >
                        <option value="multiple_choice">Multiple Choice</option>
                        <option value="fill_in_the_blank">Fill in the Blank</option>
                      </select>
                      <button
                        type="button"
                        className="cl-btn edit-btn"
                        onClick={() => handleEditQuestion(index)}
                      >
                        Edit
                      </button>
                      <button
                        type="button"
                        className="cl-btn delete-btn"
                        onClick={() => handleDeleteQuestion(index)}
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                </div>
              ))}

              <div className="question-card">
                <div className="question-card-content">
                  <div className="question-card-main">
                    <input
                      type="text"
                      placeholder="Question"
                      value={currentQuestion.questionText}
                      onChange={(e) =>
                        setCurrentQuestion({
                          ...currentQuestion,
                          questionText: e.target.value,
                        })
                      }
                      className="question-text-input"
                    />
                    {currentQuestion.type === "multiple_choice" && (
                      <div className="options-list">
                        {currentQuestion.options.map((option, index) => (
                          <div key={index} className="option-item">
                            <span className="option-indicator"></span>
                            <input
                              type="text"
                              placeholder="Add option"
                              value={option}
                              onChange={(e) => {
                                const newOptions = [...currentQuestion.options];
                                newOptions[index] = e.target.value;
                                setCurrentQuestion({
                                  ...currentQuestion,
                                  options: newOptions,
                                });
                              }}
                              className="option-input"
                            />
                            {index > 0 && (
                              <button
                                type="button"
                                className="cl-btn option-remove-btn"
                                onClick={() => {
                                  const newOptions = [...currentQuestion.options];
                                  newOptions.splice(index, 1);
                                  setCurrentQuestion({
                                    ...currentQuestion,
                                    options: newOptions,
                                  });
                                }}
                              >
                                ×
                              </button>
                            )}
                          </div>
                        ))}
                        <button
                          type="button"
                          className="add-option-btn"
                          onClick={() => {
                            setCurrentQuestion({
                              ...currentQuestion,
                              options: [...currentQuestion.options, ""],
                            });
                          }}
                        >
                          Add option
                        </button>
                      </div>
                    )}
                    {currentQuestion.type === "fill_in_the_blank" && (
                      <div className="fill-in-the-blank-fill">
                        <label className="form-label">Correct Answer</label>
                        <input
                          type="text"
                          placeholder="Add answer"
                          value={currentQuestion.correctAnswer}
                          onChange={(e) =>
                            setCurrentQuestion({
                              ...currentQuestion,
                              correctAnswer: e.target.value,
                            })
                          }
                          className="correct-answer-input"
                        />
                      </div>
                    )}
                    <div className="correct-answer-section">
                      {currentQuestion.type === "multiple_choice" && (
                        <>
                          <label className="form-label">Correct Answer</label>
                          <select
                            value={currentQuestion.correctAnswer}
                            onChange={(e) =>
                              setCurrentQuestion({
                                ...currentQuestion,
                                correctAnswer: e.target.value,
                              })
                            }
                            className="form-select"
                          >
                            <option value="">Select correct answer</option>
                            {currentQuestion.options.map((option, index) => (
                              <option
                                key={index}
                                value={option}
                                disabled={!option}
                              >
                                {option || `Option ${index + 1}`}
                              </option>
                            ))}
                          </select>
                        </>
                      )}
                    </div>
                  </div>
                  <div className="question-card-actions">
                    <select
                      className="question-type-select"
                      value={currentQuestion.type}
                      onChange={(e) =>
                        setCurrentQuestion({
                          ...currentQuestion,
                          type: e.target.value,
                          options: e.target.value === "multiple_choice" ? ["", "", "", ""] : [],
                          correctAnswer: "",
                        })
                      }
                    >
                      <option value="multiple_choice">Multiple Choice</option>
                      <option value="fill_in_the_blank">Fill in the Blank</option>
                    </select>
                    <button
                      type="button"
                      className="cl-btn submit-btn"
                      onClick={handleAddQuestion}
                    >
                      <span className="add-icon">+</span> Add Question
                    </button>
                  </div>
                </div>
              </div>

              <div className="modal-actions">
                <button type="submit" className="cl-btn submit-quiz-btn">
                  Add Quiz
                </button>
                <button
                  type="button"
                  className="cl-btn cancel-btn"
                  onClick={() => {
                    if (hasAssessmentChanges()) {
                      setPendingFormAction(() => () => {
                        setShowAssessmentForm(false);
                        resetAssessmentForm();
                      });
                      setShowExitModal(true);
                    } else {
                      setShowAssessmentForm(false);
                      resetAssessmentForm();
                    }
                  }}
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {!showMaterialForm && !showAssessmentForm && (
        <div className="content-grid">
          {contents.map((item) => (
            <div
              key={item.id}
              className={`cl-content-card category-${
                item.category
                  ? item.category.toLowerCase().replace(/_/g, '-')
                  : 'unknown'
              }`}
            >
              <div className="cl-content-body">
                <h5 className="cl-content-title">{item.title}</h5>
                {item.category && (
                  <p className="cl-content-info">
                    Category: {displayCategory(item.category)}
                  </p>
                )}
              </div>
              <div className="cl-content-actions">
                {item.type !== "material" && item.type !== "uploaded-material" && (
                  <button
                    className="cl-btn cl-btn-edit"
                    onClick={() => handleEditContent(item)}
                  >
                    Edit
                  </button>
                )}
                <button
                  className="cl-btn cl-btn-delete"
                  onClick={() => {
                    setItemToDelete(item);
                    setShowDeleteModal(true);
                  }}
                >
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {showDeleteModal && (
        <div className="confirmation-modal">
          <div className="modal-content">
            <h3 className="modal-title">Confirm Delete</h3>
            <p>
              Are you sure you want to delete "${itemToDelete.title}"? This action cannot be undone.
            </p>
            <div className="modal-actions">
              <button
                className="cl-btn modal-btn confirm-btn"
                onClick={handleDeleteContent}
              >
                Yes
              </button>
              <button
                className="cl-btn modal-btn"
                onClick={() => {
                  setShowDeleteModal(false);
                  setItemToDelete(null);
                }}
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      {showExitModal && (
        <div className="confirmation-modal">
          <div className="modal-content">
            <h3 className="modal-title">Unsaved Changes</h3>
            <p>You haven't saved this. Are you sure you want to exit?</p>
            <div className="modal-actions">
              <button
                className="cl-btn modal-btn confirm-btn"
                onClick={confirmExit}
              >
                Yes
              </button>
              <button
                className="cl-btn modal-btn cancel-btn"
                onClick={cancelExit}
              >
                No
              </button>
            </div>
          </div>
        </div>
      )}

      {notification && <div className="notification">{notification}</div>}
    </div>
  );
};

export default Contents;
