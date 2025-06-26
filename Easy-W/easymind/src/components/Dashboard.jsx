import { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import Chart from 'chart.js/auto';
import '../styles/Dashboard.css';
import jenImage from '../assets/jen.png';
import { collection, query, where, getDocs, orderBy, limit } from 'firebase/firestore';
import { db } from '../firebase'; // Adjust path to your Firebase config
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import "bootstrap/dist/css/bootstrap.min.css";

// StatCard Component
const StatCard = ({ value, label, className, to }) => {
  const [isHovered, setIsHovered] = useState(false);

  return (
    <Link
      to={to}
      style={{ textDecoration: 'none' }}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      <div
        className={`db-stat-card ${className}`}
        style={{
          backgroundColor: isHovered ? '#E0E0E0' : undefined,
          cursor: 'pointer',
          transition: 'background-color 0.2s',
        }}
      >
        <div>
          <h3>{value}</h3>
          <p>{label}</p>
        </div>
      </div>
    </Link>
  );
};

// ChartCard Component
const ChartCard = ({ title, chartId, chartType, chartData, chartOptions, className, to }) => {
  const chartRef = useRef(null);
  const [isHovered, setIsHovered] = useState(false);

  useEffect(() => {
    const canvas = document.getElementById(chartId);
    if (!canvas) {
      console.error(`Canvas element with ID ${chartId} not found.`);
      return;
    }
    const ctx = canvas.getContext('2d');
    if (!ctx) {
      console.error(`Failed to get 2D context for canvas with ID ${chartId}.`);
      return;
    }
    const chart = new Chart(ctx, {
      type: chartType,
      data: chartData,
      options: chartOptions
    });

    return () => chart.destroy();
  }, [chartData, chartOptions, chartType, chartId]);

  return (
    <Link
      to={to}
      style={{ textDecoration: 'none' }}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      <div
        className={`db-chart-card ${className || ''}`}
        style={{
          backgroundColor: isHovered ? '#E0E0E0' : '#FFFFFF',
          cursor: 'pointer',
          transition: 'background-color 0.2s',
        }}
      >
        <h3 style={{ color: '#000000' }}>{title}</h3>
        <canvas id={chartId}></canvas>
      </div>
    </Link>
  );
};

// TopStudentsCard Component
const TopStudentsCard = ({ students }) => {
  const [isHovered, setIsHovered] = useState(false);

  return (
    <Link
      to="/students"
      style={{ textDecoration: 'none' }}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      <div
        className="db-top-students-card"
        style={{
          backgroundColor: isHovered ? '#E0E0E0' : '#FFFFFF',
          cursor: 'pointer',
          transition: 'background-color 0.2s',
        }}
      >
        <div className="d-flex justify-content-between align-items-center">
          <h3 style={{ color: '#000000' }}>Top Students</h3>
          <select className="dropdown form-select form-select-sm w-auto">
            <option>Category</option>
            <option>Math</option>
            <option>Science</option>
            <option>English</option>
          </select>
        </div>
        <ul>
          {students.length > 0 ? (
            students.map((student, index) => (
              <li key={index}>
                <img src={jenImage} alt="Student" className="db-top-student-img" />
                <span className="db-student-name">{student.name}</span>
                <span className="db-student-score">{student.score}%</span>
              </li>
            ))
          ) : (
            <li style={{ color: '#757575' }}>No students found</li>
          )}
        </ul>
      </div>
    </Link>
  );
};

// Dashboard Component
const Dashboard = () => {
  const [stats, setStats] = useState({
    totalStudents: 0,
    improvedStudents: 0,
    needsImprovement: 0,
    readingMaterials: 0,
  });
  const [weeklyProgressData, setWeeklyProgressData] = useState({
    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    datasets: [{
      label: 'Progress',
      data: [0, 0, 0, 0, 0, 0, 0],
      borderColor: '#3B82F6',
      backgroundColor: 'rgba(59, 130, 246, 0.2)',
      fill: true,
      tension: 0.4
    }]
  });
  const [assessmentResultsData, setAssessmentResultsData] = useState({
    labels: ['Passed', 'Failed'],
    datasets: [{
      data: [1, 1], // Minimal default to ensure rendering
      backgroundColor: ['#A7F3D0', '#E5E7EB']
    }]
  });
  const [dailyLoginsData, setDailyLoginsData] = useState({
    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    datasets: [{
      label: 'Logins',
      data: [0, 0, 0, 0, 0, 0, 0],
      backgroundColor: '#93C5FD'
    }]
  });
  const [overallPerformanceData, setOverallPerformanceData] = useState({
    labels: ['Assessments', 'Comprehension', 'Pronunciation'],
    datasets: [{
      data: [1, 1, 1], // Minimal default to ensure rendering
      backgroundColor: ['#A5B4FC', '#FECACA', '#A7F0D0']
    }]
  });
  const [topStudents, setTopStudents] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Fetch stats
        const studentsQuery = query(collection(db, 'students'));
        const studentsSnapshot = await getDocs(studentsQuery);
        const totalStudents = studentsSnapshot.size;

        const improvedQuery = query(collection(db, 'students'), where('progress', '>', 0));
        const improvedSnapshot = await getDocs(improvedQuery);
        const improvedStudents = improvedSnapshot.size;

        const needsImprovementQuery = query(collection(db, 'students'), where('progress', '<', 0));
        const needsImprovementSnapshot = await getDocs(needsImprovementQuery);
        const needsImprovement = needsImprovementSnapshot.size;

        const materialsQuery = query(collection(db, 'contents'), where('type', '==', 'uploaded-material'));
        const materialsSnapshot = await getDocs(materialsQuery);
        const readingMaterials = materialsSnapshot.size;

        setStats({
          totalStudents,
          improvedStudents,
          needsImprovement,
          readingMaterials,
        });

        // Fetch weekly progress
        const progressQuery = query(collection(db, 'progress'), orderBy('date', 'desc'), limit(7));
        const progressSnapshot = await getDocs(progressQuery);
        const progressData = Array(7).fill(0);
        const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        progressSnapshot.forEach(doc => {
          const data = doc.data();
          const dayIndex = labels.indexOf(data.day);
          if (dayIndex !== -1) {
            progressData[dayIndex] = data.value || 0;
          }
        });
        setWeeklyProgressData({
          labels,
          datasets: [{
            label: 'Progress',
            data: progressData,
            borderColor: '#3B82F6',
            backgroundColor: 'rgba(59, 130, 246, 0.2)',
            fill: true,
            tension: 0.4
          }]
        });

        // Fetch assessment results
        const assessmentsQuery = query(collection(db, 'contents'), where('type', '==', 'assessment'));
        const assessmentsSnapshot = await getDocs(assessmentsQuery);
        let passed = 0, failed = 0;
        assessmentsSnapshot.forEach(doc => {
          const data = doc.data();
          if (data.result === 'passed') passed++;
          else if (data.result === 'failed') failed++;
        });
        setAssessmentResultsData({
          labels: ['Passed', 'Failed'],
          datasets: [{
            data: [passed > 0 || failed > 0 ? passed : 1, passed > 0 || failed > 0 ? failed : 1],
            backgroundColor: ['#A7F3D0', '#E5E7EB']
          }]
        });

        // Fetch daily logins
        const loginsQuery = query(collection(db, 'logins'), orderBy('date', 'desc'), limit(7));
        const loginsSnapshot = await getDocs(loginsQuery);
        const loginsData = Array(7).fill(0);
        loginsSnapshot.forEach(doc => {
          const data = doc.data();
          const dayIndex = labels.indexOf(data.day);
          if (dayIndex !== -1) {
            loginsData[dayIndex] = data.count || 0;
          }
        });
        setDailyLoginsData({
          labels,
          datasets: [{
            label: 'Logins',
            data: loginsData,
            backgroundColor: '#93C5FD'
          }]
        });

        // Fetch overall class performance
        const performanceQuery = query(collection(db, 'students'));
        const performanceSnapshot = await getDocs(performanceQuery);
        let assessments = 0, comprehension = 0, pronunciation = 0;
        performanceSnapshot.forEach(doc => {
          const data = doc.data();
          assessments += data.assessmentScore || 0;
          comprehension += data.comprehensionScore || 0;
          pronunciation += data.pronunciationScore || 0;
        });
        setOverallPerformanceData({
          labels: ['Assessments', 'Comprehension', 'Pronunciation'],
          datasets: [{
            data: [assessments > 0 || comprehension > 0 || pronunciation > 0 ? assessments : 1, 
                   comprehension > 0 || assessments > 0 || pronunciation > 0 ? comprehension : 1, 
                   pronunciation > 0 || assessments > 0 || comprehension > 0 ? pronunciation : 1],
            backgroundColor: ['#A5B4FC', '#FECACA', '#A7F0D0']
          }]
        });

        // Fetch top students
        const topStudentsQuery = query(collection(db, 'students'), orderBy('score', 'desc'), limit(12));
        const topStudentsSnapshot = await getDocs(topStudentsQuery);
        const topStudentsData = topStudentsSnapshot.docs.map(doc => ({
          name: doc.data().name || 'Unknown',
          score: doc.data().score ? `${doc.data().score}%` : '0%'
        }));
        setTopStudents(topStudentsData.length > 0 ? topStudentsData : []);
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };

    fetchData();
  }, []);

  const weeklyProgressOptions = {
    scales: {
      y: {
        beginAtZero: true,
        max: 10
      }
    },
    plugins: {
      legend: {
        display: false
      }
    }
  };

  const assessmentResultsOptions = {
    plugins: {
      legend: {
        position: 'bottom',
        labels: {
          boxWidth: 20,
          padding: 15
        }
      }
    }
  };

  const dailyLoginsOptions = {
    scales: {
      y: {
        beginAtZero: true
      }
    },
    plugins: {
      legend: {
        display: false
      }
    }
  };

  const overallPerformanceOptions = {
    plugins: {
      legend: {
        position: 'right',
        labels: {
          boxWidth: 20,
          padding: 15
        }
      }
    }
  };

  return (
    <div className="container py-4">
      <h2 className="mb-4 fw-bold">DASHBOARD</h2>

      {/* Stats Cards */}
      <div className="row mb-4">
        <div className="col-md-3 mb-3">
          <StatCard
            value={stats.totalStudents}
            label="Total Number of Students"
            className="db-total-students"
            to="/students"
          />
        </div>
        <div className="col-md-3 mb-3">
          <StatCard
            value={stats.improvedStudents}
            label="Improved Students"
            className="db-improved-students"
            to="/reports"
          />
        </div>
        <div className="col-md-3 mb-3">
          <StatCard
            value={stats.needsImprovement}
            label="Needs Improvement"
            className="db-needs-improvement"
            to="/reports"
          />
        </div>
        <div className="col-md-3 mb-3">
          <StatCard
            value={stats.readingMaterials}
            label="Reading Materials"
            className="db-reading-materials"
            to="/contents"
          />
        </div>
      </div>

      {/* Charts and Top Students */}
      <div className="row">
        {/* Left Column: Weekly Progress and Daily Logins */}
        <div className="col-md-6">
          {/* Weekly Progress */}
          <div className="mb-4">
            <ChartCard
              title="Weekly Progress"
              chartId="weeklyProgressChart"
              chartType="line"
              chartData={weeklyProgressData}
              chartOptions={weeklyProgressOptions}
              to="/progress"
            />
          </div>

          {/* Daily Logins */}
          <div className="mb-4">
            <ChartCard
              title="Daily Logins"
              chartId="dailyLoginsChart"
              chartType="bar"
              chartData={dailyLoginsData}
              chartOptions={dailyLoginsOptions}
              to="/logins"
            />
          </div>
        </div>

        {/* Right Column: Assessment Results, Overall Class Performance, and Top Students */}
        <div className="col-md-6">
          <div className="row">
            {/* Assessment Results and Overall Class Performance */}
            <div className="col-md-6">
              {/* Assessment Results */}
              <div className="mb-4">
                <ChartCard
                  title="Assessment Results"
                  chartId="assessmentResultsChart"
                  chartType="pie"
                  chartData={assessmentResultsData}
                  chartOptions={assessmentResultsOptions}
                  to="/assessments"
                />
              </div>

              {/* Overall Class Performance */}
              <div className="mb-4">
                <ChartCard
                  title="Overall Class Performance"
                  chartId="overallPerformanceChart"
                  chartType="pie"
                  chartData={overallPerformanceData}
                  chartOptions={overallPerformanceOptions}
                  className="db-overall-performance-card"
                  to="/performance"
                />
              </div>
            </div>

            {/* Top Students */}
            <div className="col-md-6 mb-4">
              <TopStudentsCard students={topStudents} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;