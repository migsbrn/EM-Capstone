import React, { useState, useEffect } from "react";
import { db } from "../firebase";
import { collection, query, orderBy, onSnapshot } from "firebase/firestore";
import { useAuthState } from "react-firebase-hooks/auth";
import { auth } from "../firebase"; // Adjust the import path
import "../styles/ReportLogs.css";

const ReportLogs = () => {
  const [user] = useAuthState(auth);
  const [logs, setLogs] = useState([]);
  const [filteredLogs, setFilteredLogs] = useState([]);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedMonth, setSelectedMonth] = useState("");
  const [selectedDay, setSelectedDay] = useState("");

  useEffect(() => {
    if (!user) {
      setError("Please log in to view logs.");
      return;
    }
    const q = query(collection(db, "logs"), orderBy("createdAt", "desc"));

    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        console.log(
          "Snapshot data:",
          snapshot.docs.map((doc) => doc.data())
        );
        const logData = snapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }));
        setLogs(logData);
        setFilteredLogs(logData);
        setError(null);
      },
      (err) => {
        console.error("Error fetching logs:", err);
        setError("Failed to load logs: " + err.message);
      }
    );

    return () => unsubscribe();
  }, [user]);

  useEffect(() => {
    let filtered = logs;

    if (searchTerm) {
      const lowerSearchTerm = searchTerm.toLowerCase();
      filtered = filtered.filter(
        (log) =>
          (log.teacherName || "").toLowerCase().includes(lowerSearchTerm) ||
          (log.activityDescription || "")
            .toLowerCase()
            .includes(lowerSearchTerm)
      );
    }

    if (selectedMonth) {
      filtered = filtered.filter((log) => {
        if (!log.createdAt) return false;
        const date = log.createdAt.toDate();
        return date.getMonth() + 1 === parseInt(selectedMonth);
      });
    }

    if (selectedDay) {
      filtered = filtered.filter((log) => {
        if (!log.createdAt) return false;
        const date = log.createdAt.toDate();
        return date.getDate() === parseInt(selectedDay);
      });
    }

    setFilteredLogs(filtered);
  }, [searchTerm, selectedMonth, selectedDay, logs]);

  const formatTimestamp = (timestamp) => {
    if (!timestamp) return "N/A";
    try {
      const date = timestamp.toDate();
      return date.toLocaleString("en-US", {
        month: "long",
        day: "numeric",
        year: "numeric",
        hour: "numeric",
        minute: "2-digit",
        hour12: true,
      });
    } catch {
      return "Invalid Date";
    }
  };

  const handlePrint = () => {
    const printDate = new Date().toLocaleString("en-US", {
      timeZone: "Asia/Manila",
      month: "long",
      day: "numeric",
      year: "numeric",
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
      timeZoneName: "short",
    });
    const printHeader = document.querySelector(".print-only-header p");
    if (printHeader) {
      printHeader.textContent = `Generated on: ${printDate}`;
    }
    window.print();
  };

  const months = Array.from({ length: 12 }, (_, i) => ({
    value: (i + 1).toString(),
    label: new Date(0, i).toLocaleString("en-US", { month: "long" }),
  }));

  const days = Array.from({ length: 31 }, (_, i) => ({
    value: (i + 1).toString(),
    label: (i + 1).toString(),
  }));

  return (
    <div className="report-logs-container">
      <h2 className="report-logs-title no-print">Activity Logs</h2>
      {error && (
        <div className="alert alert-danger no-print" role="alert">
          {error}
        </div>
      )}
      <div className="report-controls no-print">
        <input
          type="text"
          placeholder="Search logs..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="report-controls-input"
        />
        <select
          value={selectedMonth}
          onChange={(e) => setSelectedMonth(e.target.value)}
          className="report-controls-select"
        >
          <option value="">All Months</option>
          {months.map((month) => (
            <option key={month.value} value={month.value}>
              {month.label}
            </option>
          ))}
        </select>
        <select
          value={selectedDay}
          onChange={(e) => setSelectedDay(e.target.value)}
          className="report-controls-select"
        >
          <option value="">All Days</option>
          {days.map((day) => (
            <option key={day.value} value={day.value}>
              {day.label}
            </option>
          ))}
        </select>
        <button onClick={handlePrint} className="report-controls-button">
          Print Logs
        </button>
      </div>
      <div className="report-table-container print-only-table">
        <div className="print-only-header">
          <h1>Activity Logs Report</h1>
          <p>Generated on: </p>
        </div>
        <table className="report-table">
          <thead>
            <tr>
              <th>DATE & TIME</th>
              <th>TEACHER NAME</th>
              <th>ACTIVITY</th>
            </tr>
          </thead>
          <tbody>
            {filteredLogs.length === 0 ? (
              <tr>
                <td colSpan="3" className="text-center">
                  No logs available
                </td>
              </tr>
            ) : (
              filteredLogs.map((log) => (
                <tr key={log.id}>
                  <td>{formatTimestamp(log.createdAt)}</td>
                  <td>{log.teacherName || "Unknown"}</td>
                  <td>{log.activityDescription || "No description"}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ReportLogs;
