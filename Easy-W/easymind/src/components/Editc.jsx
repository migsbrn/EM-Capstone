import { useState, useEffect } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { db } from '../firebase';
import { doc, updateDoc } from 'firebase/firestore';
import '../styles/Contents.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import "bootstrap/dist/css/bootstrap.min.css";

const categories = [
  'COMMUNICATION_SKILLS',
  'NUMBER_SKILLS',
  'SELF_HELP',
  'PRE-VOCATIONAL_SKILLS',
  'SOCIAL_SKILLS',
  'FUNCTIONAL_ACADEMICS',
];

const EditContent = () => {
  const { id } = useParams();
  const location = useLocation();
  const navigate = useNavigate();
  const content = location.state?.content;
  const { showAssessments, materialFilter, sortOrder } = location.state || { showAssessments: false, materialFilter: 'all materials', sortOrder: 'newest' };

  const [materialTitle, setMaterialTitle] = useState(content?.type?.includes('material') ? content.title : '');
  const [materialCategory, setMaterialCategory] = useState(content?.category || categories[0]);
  const [assessmentTitle, setAssessmentTitle] = useState(content?.type === 'assessment' ? content.title : '');
  const [assessmentDescription, setAssessmentDescription] = useState(content?.description || '');
  const [assessmentQuestions, setAssessmentQuestions] = useState(content?.type === 'assessment' ? content.questions : []);
  const [currentQuestion, setCurrentQuestion] = useState({
    type: 'multiple_choice',
    questionText: '',
    options: ['', '', '', ''],
    correctAnswer: '',
  });
  const [editingQuestionIndex, setEditingQuestionIndex] = useState(null); // Kept for potential future use
  const [notification, setNotification] = useState(null);
  const [errorMessage, setErrorMessage] = useState(null);

  useEffect(() => {
    if (!content) {
      console.error("No content data found for editing. ID:", id);
      navigate('/contents', { state: { showAssessments, materialFilter, sortOrder } });
    }
  }, [content, id, navigate, showAssessments, materialFilter, sortOrder]);

  const showNotification = (message) => {
    setNotification(message);
    setTimeout(() => setNotification(null), 2000);
  };

  const showError = (message) => {
    setErrorMessage(message);
    setTimeout(() => setErrorMessage(null), 3000);
  };

  const handleDeleteQuestion = (index) => {
    const updatedQuestions = assessmentQuestions.filter((_, i) => i !== index);
    setAssessmentQuestions(updatedQuestions);
  };

  const handleUpdateMaterial = async (e) => {
    e.preventDefault();
    if (!materialTitle) {
      showError('Please enter a material title.');
      return;
    }

    try {
      const materialRef = doc(db, 'contents', id);
      await updateDoc(materialRef, {
        title: materialTitle,
        category: materialCategory,
      });
      showNotification("Material updated successfully!");
      // Do not navigate; stay on the edit page
    } catch (error) {
      console.error("Error updating material:", error.message);
      showError("Failed to update material. Please try again.");
    }
  };

  const handleUpdateAssessment = async (e) => {
    e.preventDefault();

    let finalQuestions = [...assessmentQuestions];
    let newQuestionAddedThisUpdate = false;

    if (currentQuestion.questionText.trim() !== '') {
      let isNewQuestionValid = true;
      if (!currentQuestion.questionText) {
        showError('The new question text cannot be empty.');
        isNewQuestionValid = false;
      }

      if (isNewQuestionValid && currentQuestion.type === 'multiple_choice') {
        if (currentQuestion.options.some(opt => !opt.trim()) || !currentQuestion.correctAnswer.trim()) {
          showError('The new question is incomplete (options/answer). It will not be added.');
          isNewQuestionValid = false;
        } else if (!currentQuestion.options.includes(currentQuestion.correctAnswer)) {
          showError('The new question\'s correct answer must match one of its options. It will not be added.');
          isNewQuestionValid = false;
        }
      } else if (isNewQuestionValid && currentQuestion.type === 'fill_in_the_blank') {
        if (!currentQuestion.correctAnswer.trim()) {
          showError('The new question (fill in the blank) is missing a correct answer. It will not be added.');
          isNewQuestionValid = false;
        }
      }

      if (isNewQuestionValid) {
        finalQuestions.push({ ...currentQuestion });
        newQuestionAddedThisUpdate = true;
      }
    }

    if (!assessmentTitle.trim()) {
      showError('Please enter an assessment title.');
      return;
    }
    if (finalQuestions.length === 0) {
      showError('The assessment must have at least one question.');
      return;
    }

    // Validate all questions in finalQuestions
    for (const question of finalQuestions) {
      if (!question.questionText.trim()) {
        showError('One or more questions have empty text.');
        return;
      }
      if (question.type === 'multiple_choice') {
        if (question.options.some(opt => !opt.trim()) || !question.correctAnswer.trim()) {
          showError('One or more multiple-choice questions are incomplete (options/answer).');
          return;
        }
        if (!question.options.includes(question.correctAnswer)) {
          showError('One or more multiple-choice questions have a correct answer that does not match any option.');
          return;
        }
      } else if (question.type === 'fill_in_the_blank') {
        if (!question.correctAnswer.trim()) {
          showError('One or more fill-in-the-blank questions are missing a correct answer.');
          return;
        }
      }
    }

    try {
      const assessmentRef = doc(db, 'contents', id);
      await updateDoc(assessmentRef, {
        title: assessmentTitle,
        description: assessmentDescription,
        questions: finalQuestions,
      });

      if (newQuestionAddedThisUpdate) {
        setCurrentQuestion({
          type: 'multiple_choice',
          questionText: '',
          options: ['', '', '', ''],
          correctAnswer: '',
        });
      }
      showNotification("Assessment updated successfully!");
      // Do not navigate; stay on the edit page
    } catch (error) {
      console.error("Error updating assessment:", error.message);
      showError("Failed to update assessment. Please try again.");
    }
  };

  const displayCategory = (category) => category.toLowerCase().replace(/_/g, ' ');

  return (
    <div className="container py-4">
      {content?.type.includes('material') && (
        <div className="modal-overlay">
          <div className="modal-content material-form">
            <button className="cl-btn close-modal" onClick={() => navigate('/contents', { state: { showAssessments, materialFilter, sortOrder } })}>×</button>
            <h1 className="form-heading">Edit Learning Material</h1>
            <form onSubmit={handleUpdateMaterial}>
              <div className="form-section">
                <label htmlFor="materialTitleInput" className="form-label">Material Title</label>
                <input
                  type="text"
                  className="topic-input"
                  id="materialTitleInput"
                  value={materialTitle}
                  onChange={(e) => setMaterialTitle(e.target.value)}
                  placeholder="e.g., Introduction to Numbers"
                />
              </div>
              <div className="form-section">
                <label htmlFor="materialCategoryInput" className="form-label">Category</label>
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
              <div className="modal-actions">
                <button type="submit" className="cl-btn submit-btn">Update Material</button>
                <button type="button" className="cl-btn cancel-btn" onClick={() => navigate('/contents', { state: { showAssessments, materialFilter, sortOrder } })}>
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {content?.type === 'assessment' && (
        <div className="modal-overlay">
          <div className="modal-content assessment-form">
            <button className="cl-btn close-modal" onClick={() => navigate('/contents', { state: { showAssessments: true, materialFilter, sortOrder } })}>×</button>
            <form onSubmit={handleUpdateAssessment}>
              <div className="form-header">
                <input
                  type="text"
                  id="assessmentTitleInput"
                  className="assessment-title-input"
                  value={assessmentTitle}
                  onChange={(e) => setAssessmentTitle(e.target.value)}
                  placeholder="Untitled form"
                />
                <input
                  type="text"
                  id="assessmentDescriptionInput"
                  className="assessment-description-input"
                  value={assessmentDescription}
                  onChange={(e) => setAssessmentDescription(e.target.value)}
                  placeholder="Form description"
                />
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
                          updatedQuestions[index] = { ...question, questionText: e.target.value };
                          setAssessmentQuestions(updatedQuestions);
                        }}
                        className="question-text-input"
                      />
                      {question.type === 'multiple_choice' && (
                        <div className="options-list">
                          {question.options.map((option, optIndex) => (
                            <div key={optIndex} className="option-item">
                              <span className="option-indicator"></span>
                              <input
                                type="text"
                                placeholder={`Option ${optIndex + 1}`}
                                value={option}
                                onChange={(e) => {
                                  const newOptions = [...question.options];
                                  newOptions[optIndex] = e.target.value;
                                  const newCorrectAnswer = newOptions.includes(question.correctAnswer) ? question.correctAnswer : '';
                                  const updatedQuestions = [...assessmentQuestions];
                                  updatedQuestions[index] = { ...question, options: newOptions, correctAnswer: newCorrectAnswer };
                                  setAssessmentQuestions(updatedQuestions);
                                }}
                                className="option-input"
                              />
                              {question.options.length > 1 && (
                                <button
                                  type="button"
                                  className="cl-btn option-remove-btn"
                                  onClick={() => {
                                    const newOptions = question.options.filter((_, i) => i !== optIndex);
                                    const newCorrectAnswer = newOptions.includes(question.correctAnswer) ? question.correctAnswer : '';
                                    const updatedQuestions = [...assessmentQuestions];
                                    updatedQuestions[index] = { ...question, options: newOptions, correctAnswer: newCorrectAnswer };
                                    setAssessmentQuestions(updatedQuestions);
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
                              const updatedQuestions = [...assessmentQuestions];
                              updatedQuestions[index] = {
                                ...question,
                                options: [...question.options, '']
                              };
                              setAssessmentQuestions(updatedQuestions);
                            }}
                          >
                            Add option
                          </button>
                        </div>
                      )}
                      {question.type === 'fill_in_the_blank' && (
                        <div className="fill-in-the-blank-fill">
                          <label className="form-label">Correct Answer</label>
                          <input
                            type="text"
                            placeholder="Add answer"
                            value={question.correctAnswer}
                            onChange={(e) => {
                              const updatedQuestions = [...assessmentQuestions];
                              updatedQuestions[index] = { ...question, correctAnswer: e.target.value };
                              setAssessmentQuestions(updatedQuestions);
                            }}
                            className="correct-answer-input"
                          />
                        </div>
                      )}
                      <div className="correct-answer-section">
                        {question.type === 'multiple_choice' && (
                          <>
                            <label className="form-label">Correct Answer</label>
                            <select
                              value={question.correctAnswer}
                              onChange={(e) => {
                                const updatedQuestions = [...assessmentQuestions];
                                updatedQuestions[index] = { ...question, correctAnswer: e.target.value };
                                setAssessmentQuestions(updatedQuestions);
                              }}
                              className="form-select"
                            >
                              <option value="">Select correct answer</option>
                              {question.options.map((option, optIndex) => (
                                option.trim() && <option key={optIndex} value={option}>
                                  {option}
                                </option>
                              ))}
                            </select>
                            {question.correctAnswer && !question.options.includes(question.correctAnswer) && (
                              <p style={{ color: '#658ba2', fontSize: '0.85rem', marginTop: '5px' }}>
                                The selected correct answer does not match any option.
                              </p>
                            )}
                          </>
                        )}
                      </div>
                    </div>
                    <div className="question-card-actions">
                      <select
                        className="question-type-select"
                        value={question.type}
                        onChange={(e) => {
                          const updatedQuestions = [...assessmentQuestions];
                          updatedQuestions[index] = {
                            ...question,
                            type: e.target.value,
                            options: e.target.value === 'multiple_choice' ? (question.options.length ? question.options : ['', '', '', '']) : [],
                            correctAnswer: ''
                          };
                          setAssessmentQuestions(updatedQuestions);
                        }}
                      >
                        <option value="multiple_choice">Multiple Choice</option>
                        <option value="fill_in_the_blank">Fill in the Blank</option>
                      </select>
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
                <h4 className="form-label" style={{ marginTop: '20px', marginBottom: '10px', fontWeight: '500' }}>Add New Question:</h4>
                <div className="question-card-content">
                  <div className="question-card-main">
                    <input
                      type="text"
                      placeholder="New question text"
                      value={currentQuestion.questionText}
                      onChange={(e) => setCurrentQuestion({ ...currentQuestion, questionText: e.target.value })}
                      className="question-text-input"
                    />
                    {currentQuestion.type === 'multiple_choice' && (
                      <div className="options-list">
                        {currentQuestion.options.map((option, index) => (
                          <div key={index} className="option-item">
                            <span className="option-indicator"></span>
                            <input
                              type="text"
                              placeholder={`Option ${index + 1}`}
                              value={option}
                              onChange={(e) => {
                                const newOptions = [...currentQuestion.options];
                                newOptions[index] = e.target.value;
                                const newCorrectAnswer = newOptions.includes(currentQuestion.correctAnswer) ? currentQuestion.correctAnswer : '';
                                setCurrentQuestion({ ...currentQuestion, options: newOptions, correctAnswer: newCorrectAnswer });
                              }}
                              className="option-input"
                            />
                            {currentQuestion.options.length > 1 && (
                              <button
                                type="button"
                                className="cl-btn option-remove-btn"
                                onClick={() => {
                                  const newOptions = currentQuestion.options.filter((_, i) => i !== index);
                                  const newCorrectAnswer = newOptions.includes(currentQuestion.correctAnswer) ? currentQuestion.correctAnswer : '';
                                  setCurrentQuestion({ ...currentQuestion, options: newOptions, correctAnswer: newCorrectAnswer });
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
                              options: [...currentQuestion.options, '']
                            });
                          }}
                        >
                          Add option
                        </button>
                      </div>
                    )}
                    {currentQuestion.type === 'fill_in_the_blank' && (
                      <div className="fill-in-the-blank-fill">
                        <label className="form-label">Correct Answer</label>
                        <input
                          type="text"
                          placeholder="Add answer"
                          value={currentQuestion.correctAnswer}
                          onChange={(e) => setCurrentQuestion({ ...currentQuestion, correctAnswer: e.target.value })}
                          className="correct-answer-input"
                        />
                      </div>
                    )}
                    <div className="correct-answer-section">
                      {currentQuestion.type === 'multiple_choice' && (
                        <>
                          <label className="form-label">Correct Answer</label>
                          <select
                            value={currentQuestion.correctAnswer}
                            onChange={(e) => setCurrentQuestion({ ...currentQuestion, correctAnswer: e.target.value })}
                            className="form-select"
                          >
                            <option value="">Select correct answer</option>
                            {currentQuestion.options.map((option, index) => (
                              option.trim() && <option key={index} value={option}>
                                {option}
                              </option>
                            ))}
                          </select>
                          {currentQuestion.correctAnswer && !currentQuestion.options.includes(currentQuestion.correctAnswer) && (
                            <p style={{ color: '#658ba2', fontSize: '0.85rem', marginTop: '5px' }}>
                              The selected correct answer does not match any option.
                            </p>
                          )}
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
                          options: e.target.value === 'multiple_choice' ? ['', '', '', ''] : [],
                          correctAnswer: '',
                        })
                      }
                    >
                      <option value="multiple_choice">Multiple Choice</option>
                      <option value="fill_in_the_blank">Fill in the Blank</option>
                    </select>
                  </div>
                </div>
              </div>

              <div className="modal-actions" style={{ justifyContent: 'flex-end' }}>
                <button type="submit" className="cl-btn submit-btn">
                  Update Quiz
                </button>
                <button type="button" className="cl-btn cancel-btn" onClick={() => navigate('/contents', { state: { showAssessments: true, materialFilter, sortOrder } })}>
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {notification && (
        <div className="notification">
          {notification}
        </div>
      )}

      {errorMessage && (
        <div className="confirmation-modal">
          <div className="modal-content">
            <h3>Error</h3>
            <p>{errorMessage}</p>
            <div className="modal-actions">
              <button
                className="cl-btn modal-btn confirm-btn"
                onClick={() => setErrorMessage(null)}
              >
                OK
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default EditContent;