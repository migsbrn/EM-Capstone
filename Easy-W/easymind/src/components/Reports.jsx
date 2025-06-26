import React from 'react';
// For chart visualization, we'll continue to use Recharts.
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, BarChart, Bar } from 'recharts';
// The custom CSS file will be included directly in your public/index.html instead of being imported here

function Reports() { // Renamed from App to Reports
  // Sample data for "Progress Over Time" chart
  const progressData = [
    { name: 'Week 1', 'Improved Students': 8, 'Needs Improvement': 12 },
    { name: 'Week 2', 'Improved Students': 10, 'Needs Improvement': 10 },
    { name: 'Week 3', 'Improved Students': 13, 'Needs Improvement': 9 },
    { name: 'Week 4', 'Improved Students': 16, 'Needs Improvement': 7 },
    { name: 'Week 5', 'Improved Students': 18, 'Needs Improvement': 6 },
  ];

  // Define the exact assessment options
  const assessmentOptions = [
    'All Assessments',
    'Learn the Alphabet',
    'Rhyme and Read',
    'Learn the Color',
    'Learn the Shapes',
    'Picture Reading Story'
  ];

  // Sample data for "Assessment Performance" chart - now dynamically generated from assessmentOptions
  // Ensure all relevant assessments are included in the chart data.
  const assessmentData = [
    { name: 'Learn the Alphabet', 'First Attempt': Math.floor(Math.random() * (60 - 30 + 1)) + 30, 'Latest Attempt': Math.floor(Math.random() * (95 - 70 + 1)) + 70 },
    { name: 'Rhyme and Read', 'First Attempt': Math.floor(Math.random() * (60 - 30 + 1)) + 30, 'Latest Attempt': Math.floor(Math.random() * (95 - 70 + 1)) + 70 },
    { name: 'Learn the Color', 'First Attempt': Math.floor(Math.random() * (60 - 30 + 1)) + 30, 'Latest Attempt': Math.floor(Math.random() * (95 - 70 + 1)) + 70 },
    { name: 'Learn the Shapes', 'First Attempt': Math.floor(Math.random() * (60 - 30 + 1)) + 30, 'Latest Attempt': Math.floor(Math.random() * (95 - 70 + 1)) + 70 }, // Added this entry
    { name: 'Picture Reading Story', 'First Attempt': Math.floor(Math.random() * (60 - 30 + 1)) + 30, 'Latest Attempt': Math.floor(Math.random() * (95 - 70 + 1)) + 70 },
  ];


  // Sample data for student list - updated progress structure to match table snippet
  const allStudents = [
    {
      id: 'ej',
      nickname: 'EJ', // Explicitly defined nickname
      name: 'Emma Johnson',
      specialNeeds: 'Autism Spectrum Disorder', // Kept as requested
      assessment: 'Learn the Alphabet',
      progress: { completed: 5, total: 5, target: 5 }, // Example: 5/5
      attempts: 3,
      avatar: 'EJ',
      isImproved: true,
    },
    {
      id: 'ls',
      nickname: 'LS', // Explicitly defined nickname
      name: 'Liam Smith',
      specialNeeds: 'Autism Spectrum Disorder', // Kept as requested
      assessment: 'Rhyme and Read',
      progress: { completed: 4, total: 5, target: 5 }, // Example: 4/5
      attempts: 3,
      avatar: 'LS',
      isImproved: true,
    },
    {
      id: 'od',
      nickname: 'OD', // Explicitly defined nickname
      name: 'Olivia Davis',
      specialNeeds: 'Autism Spectrum Disorder', // Kept as requested
      assessment: 'Learn the Color',
      progress: { completed: 2, total: 5, target: 5 }, // Example: 2/5
      attempts: 2,
      avatar: 'OD',
      isImproved: true,
    },
    {
      id: 'mk',
      nickname: 'MK', // Explicitly defined nickname
      name: 'Mia Kim',
      specialNeeds: 'Autism Spectrum Disorder', // Kept as requested
      assessment: 'Picture Reading Story',
      progress: { completed: 3, total: 5, target: 5 }, // Example: 3/5
      attempts: 4,
      avatar: 'MK',
      isImproved: false,
    },
    {
      id: 'jr',
      nickname: 'JR', // Explicitly defined nickname
      name: 'James Rodriguez',
      specialNeeds: 'Autism Spectrum Disorder', // Kept as requested
      assessment: 'Learn the Shapes',
      progress: { completed: 1, total: 5, target: 5 }, // Example: 1/5
      attempts: 2,
      avatar: 'JR',
      isImproved: false,
    },
    {
      id: 'sk',
      nickname: 'SK', // Explicitly defined nickname
      name: 'Sophia Kim',
      specialNeeds: 'Autism Spectrum Disorder', // Kept as requested
      assessment: 'Rhyme and Read',
      progress: { completed: 2, total: 5, target: 5 }, // Example: 2/5
      attempts: 2,
      avatar: 'SK',
      isImproved: false,
    },
    {
      id: 'al',
      nickname: 'JD', // Explicitly defined nickname for John Doe
      name: 'John Doe',
      specialNeeds: 'Autism Spectrum Disorder', // Kept as requested
      assessment: 'Learn the Color',
      progress: { completed: 3, total: 5, target: 5 }, // Example: 3/5
      attempts: 1,
      avatar: 'AL',
      isImproved: true,
    },
  ];

  const [activeTab, setActiveTab] = React.useState('improved');
  const [selectedAssessment, setSelectedAssessment] = React.useState('All Assessments');
  const [showExportMessage, setShowExportMessage] = React.useState(false);
  const [searchTerm, setSearchTerm] = React.useState(''); // New state for search term


  // Filter students based on selected assessment, tab, and search term
  const filteredStudents = allStudents.filter(student => {
    const matchesAssessment = selectedAssessment === 'All Assessments' || student.assessment === selectedAssessment;
    const matchesTab = activeTab === 'improved' ? student.isImproved : !student.isImproved;

    // Convert search term and relevant student properties to lowercase for case-insensitive search
    const lowerCaseSearchTerm = searchTerm.toLowerCase();
    const matchesSearch =
      student.name.toLowerCase().includes(lowerCaseSearchTerm) ||
      student.nickname.toLowerCase().includes(lowerCaseSearchTerm);

    return matchesAssessment && matchesTab && matchesSearch;
  });

  // Handle export report
  const handleExportReport = () => {
    let reportContent = "Student Progress Report\n\n";
    reportContent += `Assessment Filter: ${selectedAssessment}\n`;
    reportContent += `Displaying Tab: ${activeTab === 'improved' ? 'Improved Students' : 'Needs Improvement'}\n`;
    reportContent += `Search Term: "${searchTerm}"\n\n`; // Include search term in report

    reportContent += "Student List:\n";
    reportContent += "STUDENT\tASSESSMENT\tPROGRESS\tATTEMPTS\n";
    filteredStudents.forEach(student => {
      reportContent += `${student.name} (${student.specialNeeds})\t${student.assessment}\t${student.progress.completed}/${student.progress.total}/${student.progress.target}\t${student.attempts} attempts\n`;
    });

    const blob = new Blob([reportContent], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = 'student_progress_report.txt';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);

    setShowExportMessage(true);
    setTimeout(() => setShowExportMessage(false), 3000);
  };

  return (
    <div className="container-fluid bg-light-gray py-4">
      {/* Header Section */}
      <header className="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center mb-4">
        <h1 className="h3 fw-bold text-dark mb-3 mb-sm-0">Student Progress Reports</h1>
        <div className="d-flex flex-column flex-sm-row align-items-center gap-2">
          {/* Search Input Field */}
          <input
            type="text"
            className="form-control custom-search-input" // Added custom class for styling
            placeholder="Search"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <select
            className="form-select custom-select assessment-select"
            value={selectedAssessment}
            onChange={(e) => setSelectedAssessment(e.target.value)}
          >
            {assessmentOptions.map(asmnt => (
              <option key={asmnt} value={asmnt}>{asmnt}</option>
            ))}
          </select>
          <button className="btn btn-primary export-btn compact-btn" onClick={handleExportReport}>
            Export Report
          </button>
        </div>
      </header>

      {/* Export Confirmation Message */}
      {showExportMessage && (
        <div className="alert alert-success alert-dismissible fade show" role="alert">
          Report exported successfully!
          <button type="button" className="btn-close" onClick={() => setShowExportMessage(false)} aria-label="Close"></button>
        </div>
      )}

      {/* Summary Cards Section */}
      <section className="row g-4 mb-4">
        {/* Improved Students Card */}
        <div className="col-12 col-sm-6 col-lg-3">
          <div className="card shadow-sm rounded-lg h-100 p-4 d-flex flex-row align-items-center justify-content-between">
            <div>
              <div className="text-secondary mb-1">Improved Students</div>
              <div className="h2 fw-bold text-dark">
                {allStudents.filter(s => s.isImproved).length}
              </div>
              <div className="text-success small d-flex align-items-center">
                <i className="bi bi-arrow-up-short me-1"></i>
                +12% from last month
              </div>
            </div>
            <div className="icon-circle bg-success-light">
              <i className="bi bi-person-fill-up text-success icon-large"></i>
            </div>
          </div>
        </div>

        {/* Needs Improvement Card */}
        <div className="col-12 col-sm-6 col-lg-3">
          <div className="card shadow-sm rounded-lg h-100 p-4 d-flex flex-row align-items-center justify-content-between">
            <div>
              <div className="text-secondary mb-1">Needs Improvement</div>
              <div className="h2 fw-bold text-dark">
                {allStudents.filter(s => !s.isImproved).length}
              </div>
              <div className="text-danger small d-flex align-items-center">
                <i className="bi bi-arrow-down-short me-1"></i>
                -3% from last month
              </div>
            </div>
            <div className="icon-circle bg-danger-light">
              <i className="bi bi-person-fill-down text-danger icon-large"></i>
            </div>
          </div>
        </div>

        {/* Total Assessments Card */}
        <div className="col-12 col-sm-6 col-lg-3">
          <div className="card shadow-sm rounded-lg h-100 p-4 d-flex flex-row align-items-center justify-content-between">
            <div>
              <div className="text-secondary mb-1">Total Assessments</div>
              <div className="h2 fw-bold text-dark">
                {new Set(allStudents.map(s => s.assessment)).size}
              </div>
              <div className="text-info small d-flex align-items-center">
                <i className="bi bi-plus-lg me-1"></i>
                +5 new this month
              </div>
            </div>
            <div className="icon-circle bg-info-light">
              <i className="bi bi-journal-check text-info icon-large"></i>
            </div>
          </div>
        </div>

        {/* Average Score Card */}
        <div className="col-12 col-sm-6 col-lg-3">
          <div className="card shadow-sm rounded-lg h-100 p-4 d-flex flex-row align-items-center justify-content-between">
            <div>
              <div className="text-secondary mb-1">Average Score</div>
              <div className="h2 fw-bold text-dark">78%</div>
              <div className="text-purple small d-flex align-items-center">
                <i className="bi bi-bar-chart-fill me-1"></i>
                +8% from last month
              </div>
            </div>
            <div className="icon-circle bg-purple-light">
              <i className="bi bi-pie-chart-fill text-purple icon-large"></i>
            </div>
          </div>
        </div>
      </section>

      {/* Charts Section */}
      <section className="row g-4 mb-4">
        {/* Progress Over Time Chart */}
        <div className="col-12 col-lg-6">
          <div className="card shadow-sm rounded-lg p-4 h-100">
            <h2 className="h5 fw-semibold text-dark mb-4">Progress Over Time</h2>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={progressData} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line type="monotone" dataKey="Improved Students" stroke="#10B981" activeDot={{ r: 8 }} />
                <Line type="monotone" dataKey="Needs Improvement" stroke="#EF4444" />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Assessment Performance Chart */}
        <div className="col-12 col-lg-6">
          <div className="card shadow-sm rounded-lg p-4 h-100">
            <h2 className="h5 fw-semibold text-dark mb-4">Assessment Performance</h2>
            <ResponsiveContainer width="100%" height={380}>
              <BarChart data={assessmentData} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" interval={0} height={100} style={{ fontSize: '0.70rem', whiteSpace: 'normal', textOverflow: 'ellipsis' }} />
                <YAxis />
                <Tooltip />
                <Legend />
                <Bar dataKey="First Attempt" fill="#9384D1" />
                <Bar dataKey="Latest Attempt" fill="#4F46E5" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </section>

      {/* Student List Section */}
      <section className="card shadow-sm reports-student-table-bootstrap">
        <div className="card-body">
            <ul className="nav nav-tabs mb-3">
                <li className="nav-item">
                    <button
                        className={`nav-link ${activeTab === 'improved' ? 'active' : ''}`}
                        onClick={() => setActiveTab('improved')}
                    >
                        Improved Students
                    </button>
                </li>
                <li className="nav-item">
                    <button
                        className={`nav-link ${activeTab === 'needsImprovement' ? 'active' : ''}`}
                        onClick={() => setActiveTab('needsImprovement')}
                    >
                        Needs Improvement
                    </button>
                </li>
            </ul>
            <div className="table-responsive">
                <table className="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th scope="col">STUDENT</th>
                            <th scope="col">ASSESSMENT</th>
                            <th scope="col">PROGRESS</th>
                            <th scope="col">ATTEMPTS</th>
                            <th scope="col">ACTIONS</th>
                        </tr>
                    </thead>
                    <tbody>
                        {filteredStudents.length > 0 ? (
                            filteredStudents.map((student) => (
                                <tr key={student.id}>
                                    <td>
                                        <div className="d-flex align-items-center">
                                            <div className="student-avatar-bootstrap me-3">{student.avatar}</div> {/* Using avatar for display */}
                                            <div>
                                                <p className="mb-0 fw-bold">{student.name}</p>
                                                <p className="mb-0 text-muted small">{student.specialNeeds}</p> {/* Changed from student.class */}
                                            </div>
                                        </div>
                                    </td>
                                    <td>{student.assessment}</td>
                                    <td>
                                        <div className="d-flex align-items-center gap-2">
                                            <span className="text-muted small">
                                                {student.progress.completed}/{student.progress.total}
                                            </span>
                                            <div className="progress flex-grow-1" style={{ height: '6px', maxWidth: '100px' }}>
                                                <div
                                                    className="progress-bar bg-success"
                                                    role="progressbar"
                                                    style={{ width: `${(student.progress.completed / student.progress.total) * 100}%` }}
                                                    aria-valuenow={(student.progress.completed / student.progress.total) * 100}
                                                    aria-valuemin="0"
                                                    aria-valuemax="100"
                                                ></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span className="badge text-bg-success rounded-pill attempts-count-bootstrap">
                                            {student.attempts} attempts
                                        </span>
                                    </td>
                                    <td>
                                        <button className="btn btn-link p-0 text-decoration-none view-details-button-bootstrap">
                                            View Details
                                        </button>
                                    </td>
                                </tr>
                            ))
                        ) : (
                            <tr>
                                <td colSpan="5" className="text-center py-4 text-secondary">No students match the current filters.</td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
        </div>
      </section>
    </div>
  );
}

export default Reports; // Renamed from App to Reports
