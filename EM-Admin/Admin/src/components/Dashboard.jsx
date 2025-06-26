import React, { useEffect, useState } from "react";
import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  Legend,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  ResponsiveContainer,
} from "recharts";
import { db } from "../firebase";
import {
  collection,
  query,
  where,
  getDocs,
  onSnapshot,
  orderBy,
  limit,
} from "firebase/firestore";
import "../styles/Dashboard.css";

const Dashboard = () => {
  const [loading, setLoading] = useState(true);
  const [teacherCount, setTeacherCount] = useState(0);
  const [studentCount, setStudentCount] = useState(0);
  const [dailyActiveUsers, setDailyActiveUsers] = useState([]);
  const [recentActivities, setRecentActivities] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Fetch teacher count (only Active teachers)
        const teacherQuery = query(
          collection(db, "teacherRequests"),
          where("status", "==", "Active")
        );
        const teacherSnapshot = await getDocs(teacherQuery);
        const activeTeachers = teacherSnapshot.size;
        setTeacherCount(activeTeachers);

        // Fetch student count
        const studentSnapshot = await getDocs(collection(db, "students"));
        const totalStudents = studentSnapshot.size;
        setStudentCount(totalStudents);

        // Set up real-time listeners for logins
        const updateLoginData = () => {
          const now = new Date(); // Current date and time (e.g., June 9, 2025, 03:37 AM PST)
          const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
          const startOfWeek = new Date(now);
          startOfWeek.setDate(now.getDate() - now.getDay()); // Start of the week (Sunday)
          startOfWeek.setHours(0, 0, 0, 0); // Midnight PST
          const endOfWeek = new Date(startOfWeek);
          endOfWeek.setDate(startOfWeek.getDate() + 6); // End of the week (Saturday)
          endOfWeek.setHours(23, 59, 59, 999); // End of the day PST

          // Adjust to PST (UTC-7)
          startOfWeek.setMinutes(startOfWeek.getMinutes() - 7 * 60); // Subtract 7 hours for PST
          endOfWeek.setMinutes(endOfWeek.getMinutes() - 7 * 60);

          const loginCountsByDay = {};
          days.forEach((day) => {
            loginCountsByDay[day] = {
              students: new Set(),
              teachers: new Set(),
            };
          });

          // Real-time listener for student logins
          const studentLoginQuery = query(
            collection(db, "studentLogins"),
            where("loginTime", ">=", startOfWeek),
            where("loginTime", "<=", endOfWeek)
          );
          const unsubscribeStudents = onSnapshot(
            studentLoginQuery,
            (snapshot) => {
              const studentLoginData = snapshot.docs.map((doc) => ({
                id: doc.id,
                ...doc.data(),
              }));
              console.log("Real-time Student Logins:", studentLoginData);

              // Clear all days
              days.forEach((day) => loginCountsByDay[day].students.clear());

              studentLoginData.forEach((login) => {
                if (login.loginTime) {
                  const loginDate = login.loginTime.toDate();
                  // Convert to PST for consistency
                  const loginDay = loginDate.toLocaleDateString("en-US", {
                    weekday: "short",
                    timeZone: "America/Los_Angeles",
                  });
                  if (login.nickname && days.includes(loginDay)) {
                    loginCountsByDay[loginDay].students.add(login.nickname);
                  }
                }
              });

              const updatedUsers = days.map((day) => ({
                name: day,
                students: loginCountsByDay[day].students.size || 0,
                teachers: loginCountsByDay[day].teachers.size || 0,
              }));
              setDailyActiveUsers(updatedUsers);
            }
          );

          // Real-time listener for teacher logins
          const teacherLoginQuery = query(
            collection(db, "teacherLogins"),
            where("loginTime", ">=", startOfWeek),
            where("loginTime", "<=", endOfWeek)
          );
          const unsubscribeTeachers = onSnapshot(
            teacherLoginQuery,
            (snapshot) => {
              const teacherLoginData = snapshot.docs.map((doc) => ({
                id: doc.id,
                ...doc.data(),
              }));
              console.log("Real-time Teacher Logins:", teacherLoginData);

              // Clear all days
              days.forEach((day) => loginCountsByDay[day].teachers.clear());

              teacherLoginData.forEach((login) => {
                if (login.loginTime) {
                  const loginDate = login.loginTime.toDate();
                  // Convert to PST for consistency
                  const loginDay = loginDate.toLocaleDateString("en-US", {
                    weekday: "short",
                    timeZone: "America/Los_Angeles",
                  });
                  if (login.teacherId && days.includes(loginDay)) {
                    loginCountsByDay[loginDay].teachers.add(login.teacherId);
                  }
                }
              });

              const updatedUsers = days.map((day) => ({
                name: day,
                students: loginCountsByDay[day].students.size || 0,
                teachers: loginCountsByDay[day].teachers.size || 0,
              }));
              setDailyActiveUsers(updatedUsers);
            }
          );

          // Real-time listener for recent admin actions
          const activityQuery = query(
            collection(db, "adminActions"),
            orderBy("timestamp", "desc"),
            limit(5)
          );
          const unsubscribeActivities = onSnapshot(
            activityQuery,
            (snapshot) => {
              const activities = snapshot.docs.map((doc) => {
                const data = doc.data();
                return {
                  id: doc.id,
                  action: data.action || "Unknown action",
                  type: data.type || "",
                  admin: "Admin",
                  timestamp: data.timestamp || new Date(),
                };
              });
              console.log("Real-time Recent Activities:", activities);
              setRecentActivities(activities);
            }
          );

          return () => {
            unsubscribeStudents();
            unsubscribeTeachers();
            unsubscribeActivities();
          };
        };

        const unsubscribe = updateLoginData();
        return () => unsubscribe && unsubscribe();
      } catch (error) {
        console.error("Error fetching dashboard data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const pieData = [
    { name: "Teachers", value: teacherCount, color: "#4CAF50" },
    { name: "Students", value: studentCount, color: "#FF9800" },
  ];

  return (
    <div className="main-content">
      <h1 className="dashboard-title">Dashboard</h1>

      {loading ? (
        <p>Loading data...</p>
      ) : (
        <>
          <div className="charts-container">
            <div className="chart-container pie-chart">
              <h3>Total Teachers vs. Students</h3>
              <ResponsiveContainer width="100%" height={200}>
                <PieChart>
                  <Pie
                    data={pieData}
                    dataKey="value"
                    innerRadius={60}
                    outerRadius={80}
                    startAngle={90}
                    endAngle={-270}
                    labelLine={false}
                  >
                    {pieData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend
                    layout="vertical"
                    align="right"
                    verticalAlign="middle"
                  />
                </PieChart>
              </ResponsiveContainer>
            </div>

            <div className="chart-container bar-chart">
              <h3>Daily Logins</h3>
              <ResponsiveContainer width="100%" height={200}>
                <BarChart data={dailyActiveUsers}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Bar dataKey="students" stackId="a" fill="#FF9800" />
                  <Bar dataKey="teachers" stackId="a" fill="#4CAF50" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="recent-activity">
            <h3>Recent Activity</h3>
            <table className="recent-activity-table">
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Action</th>
                  <th>Admin</th>
                </tr>
              </thead>
              <tbody>
                {recentActivities.map((activity) => (
                  <tr
                    key={activity.id}
                    className={`activity-row activity-row-${activity.type}`}
                  >
                    <td>
                      {activity.timestamp?.toDate
                        ? new Date(
                            activity.timestamp.toDate()
                          ).toLocaleDateString()
                        : "N/A"}
                    </td>
                    <td>{activity.action}</td>
                    <td>{activity.admin}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
};

export default Dashboard;
