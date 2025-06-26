import "bootstrap/dist/css/bootstrap.min.css";
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import "../styles/App.css";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  NavLink,
  useLocation,
} from "react-router-dom";
import { useState, useEffect } from "react";
import { getAuth, onAuthStateChanged, signOut } from "firebase/auth";
import {
  getFirestore,
  doc,
  getDoc,
  setDoc,
  serverTimestamp,
} from "firebase/firestore";
import { app } from "../firebase";
import StudentList from "./StudentList.jsx";
import Contents from "./Contents.jsx";
import EditContent from "./Editc.jsx";
import JenImage from "../assets/jen.png";
import TeacherLogin from "./TeacherLogin.jsx";
import Assessments from "./Assessments.jsx";
import Reports from "./Reports.jsx"; // Import the Reports component

// Profile Component
const Profile = () => {
  const [userData, setUserData] = useState({
    firstName: "",
    lastName: "",
    username: "",
    email: "",
    address: {
      streetAddress: "",
      barangay: "",
      cityMunicipality: "",
      province: "",
    },
    contactNo: "",
    dateOfBirth: "",
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const auth = getAuth(app);
    const db = getFirestore(app);

    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        try {
          const userDocRef = doc(db, "teachers", user.uid);
          const userDoc = await getDoc(userDocRef);

          if (userDoc.exists()) {
            const data = userDoc.data();
            console.log("Fetched user data from Firestore:", data);

            let formattedDob = "Date of Birth not set";
            if (data.dateOfBirth) {
              if (typeof data.dateOfBirth.toDate === "function") {
                try {
                  formattedDob = data.dateOfBirth
                    .toDate()
                    .toLocaleDateString(undefined, {
                      year: "numeric",
                      month: "long",
                      day: "numeric",
                    });
                } catch (e) {
                  console.error(
                    "Error formatting dateOfBirth from Timestamp:",
                    e
                  );
                  formattedDob = "Invalid Date";
                }
              } else if (typeof data.dateOfBirth === "string") {
                formattedDob = data.dateOfBirth;
              }
            }

            setUserData({
              firstName: data.firstName || "First Name not set",
              lastName: data.lastName || "Last Name not set",
              username: data.username || "Username not set",
              email: user.email || "Email not set",
              address: {
                streetAddress:
                  data.address?.streetAddress ||
                  data.streetAddress ||
                  "Street not set",
                barangay:
                  data.address?.barangay || data.barangay || "Barangay not set",
                cityMunicipality:
                  data.address?.cityMunicipality ||
                  data.cityMunicipality ||
                  "City/Municipality not set",
                province:
                  data.address?.province || data.province || "Province not set",
              },
              contactNo:
                data.contactNo !== undefined && data.contactNo !== null
                  ? String(data.contactNo)
                  : "Contact No. not set",
              dateOfBirth: formattedDob,
            });
          } else {
            console.error(
              "User document not found in Firestore for UID:",
              user.uid
            );
            setUserData({
              firstName: "Data not found",
              lastName: "Data not found",
              username: "Data not found",
              email: user.email || "Email (auth only, profile data missing)",
              address: {
                streetAddress: "Data not found",
                barangay: "Data not found",
                cityMunicipality: "Data not found",
                province: "Data not found",
              },
              contactNo: "Data not found",
              dateOfBirth: "Data not found",
            });
          }
        } catch (error) {
          console.error("Error fetching user data:", error);
          setUserData({
            firstName: "Error loading data",
            lastName: "Error loading data",
            username: "Error loading data",
            email: "Error loading data",
            address: {
              streetAddress: "Error loading data",
              barangay: "Error loading data",
              cityMunicipality: "Error loading data",
              province: "Error loading data",
            },
            contactNo: "Error loading data",
            dateOfBirth: "Error loading data",
          });
        } finally {
          setLoading(false);
        }
      } else {
        console.error("No authenticated user found");
        setUserData({
          firstName: "Not logged in",
          lastName: "Not logged in",
          username: "Not logged in",
          email: "Not logged in",
          address: {
            streetAddress: "Not logged in",
            barangay: "Not logged in",
            cityMunicipality: "Not logged in",
            province: "Not logged in",
          },
          contactNo: "Not logged in",
          dateOfBirth: "Not logged in",
        });
        setLoading(false);
      }
    });

    return () => unsubscribe();
  }, []);

  const fields = [
    { label: "Email", key: "email" },
    { label: "Address", key: "address" },
    { label: "Contact No.", key: "contactNo" },
    { label: "Date of Birth", key: "dateOfBirth" },
  ];

  if (loading) {
    return <div>Loading profile...</div>;
  }

  const formatAddress = (addressObj) => {
    if (!addressObj) return "Address not available";
    const isAllSameMessage = (message) =>
      addressObj.streetAddress === message &&
      addressObj.barangay === message &&
      addressObj.cityMunicipality === message &&
      addressObj.province === message;

    if (isAllSameMessage("Data not found")) return "Data not found";
    if (isAllSameMessage("Error loading data")) return "Error loading data";
    if (isAllSameMessage("Not logged in")) return "Not logged in";

    const parts = [
      addressObj.streetAddress,
      addressObj.barangay,
      addressObj.cityMunicipality,
      addressObj.province,
    ].filter((part) => part);
    return parts.length ? parts.join(", ") : "Address not set";
  };

  return (
    <div className="profile-container">
      <div className="profile-card">
        <img src={JenImage} alt="User" className="profile-img rounded-circle" />
        <h5 className="profile-name">
          {userData.firstName} {userData.lastName}
        </h5>
        <p className="profile-username">{userData.username}</p>
        <div className="profile-details">
          {fields.map(({ label, key }) => {
            let displayValue = "";
            if (key === "address") {
              displayValue = formatAddress(userData.address);
            } else {
              displayValue =
                userData[key] ||
                (key === "email" ? "Email not set" : `${label} not set`);
            }
            return (
              <div className="profile-detail-item annu" key={key}>
                <span className="detail-label">{label}</span>
                <div className="detail-value">
                  <span>{displayValue}</span>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

// Navbar Component with Dropdown
const Navbar = () => {
  const [showDropdown, setShowDropdown] = useState(false);
  const auth = getAuth(app);
  const db = getFirestore(app);

  const toggleDropdown = () => {
    setShowDropdown(!showDropdown);
  };

  const handleSignOut = async () => {
    try {
      const user = auth.currentUser;
      if (user) {
        // Fetch the teacher's data from the teachers collection
        const userDocRef = doc(db, "teachers", user.uid);
        const userDoc = await getDoc(userDocRef);
        let teacherName = "Unnamed Teacher";

        if (userDoc.exists()) {
          const data = userDoc.data();
          console.log("Teacher data for logout:", data);
          teacherName = `${data.firstName || ""} ${data.lastName || ""}`.trim();
          if (!teacherName) {
            // Only fall back to username if name fields are truly empty
            teacherName =
              data.username || user.email.split("@")[0] || "Unnamed Teacher";
            console.log("Name fields missing, using fallback:", teacherName);
          }
        } else {
          console.error("Teacher document not found for UID:", user.uid);
          teacherName = user.email.split("@")[0] || "Unnamed Teacher";
        }

        // Log the sign-out event to Firestore
        await setDoc(doc(db, "logs", `${user.uid}_${Date.now()}`), {
          teacherName: teacherName,
          activityDescription: "Logged out",
          createdAt: serverTimestamp(),
        });
      } else {
        console.error("No authenticated user found during sign-out");
      }
      await signOut(auth);
      setShowDropdown(false);
    } catch (error) {
      console.error("Error during sign-out or logging to Firestore:", error);
    }
  };

  return (
    <nav className="navbar navbar-expand-lg navbar-light">
      <div className="container-fluid">
        <span className="navbar-brand">EasyMind</span>
        <div className="collapse navbar-collapse d-flex justify-content-center">
          <ul className="navbar-nav mb-2 mb-lg-0">
          <li className="nav-item">
              <NavLink
                className={({ isActive }) =>
                  isActive ? "nav-link active" : "nav-link"
                }
                to="/reports"
              >
                Reports
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink
                className={({ isActive }) =>
                  isActive ? "nav-link active" : "nav-link"
                }
                to="/student-list"
              >
                Student List
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink
                className={({ isActive }) =>
                  isActive ? "nav-link active" : "nav-link"
                }
                to="/contents"
              >
                Contents
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink
                className={({ isActive }) =>
                  isActive ? "nav-link active" : "nav-link"
                }
                to="/assessments"
              >
                Assessments
              </NavLink>
            </li>
          </ul>
        </div>
        <div className="d-flex align-items-center position-relative">
          <img
            src={JenImage}
            alt="User"
            className="user-profile-img rounded-circle me-2"
            style={{ cursor: "pointer" }}
            onClick={toggleDropdown}
          />
          {showDropdown && (
            <div
              className="dropdown-menu show"
              style={{
                position: "absolute",
                top: "40px",
                right: "0",
                minWidth: "120px",
                backgroundColor: "#fff",
                boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
                borderRadius: "5px",
              }}
            >
              <NavLink
                to="/profile"
                className="dropdown-item"
                onClick={() => setShowDropdown(false)}
              >
                Profile
              </NavLink>
              <NavLink to="/" className="dropdown-item" onClick={handleSignOut}>
                Sign Out
              </NavLink>
            </div>
          )}
        </div>
      </div>
    </nav>
  );
};

// Main App Component
function App() {
  const location = useLocation();

  return (
    <div>
      {location.pathname !== "/" && <Navbar />}
      <Routes>
        <Route path="/" element={<TeacherLogin />} />
        <Route path="/reports" element={<Reports />} />
        <Route path="/student-list" element={<StudentList />} />
        <Route path="/contents" element={<Contents />} />
        <Route path="/assessments"element={<Assessments/>}/>
        <Route path="/edit-content/:id" element={<EditContent />} />
        <Route path="/profile" element={<Profile />} />
      </Routes>
    </div>
  );
}

// Wrap App with Router
export default function AppWrapper() {
  return (
    <Router>
      <App />
    </Router>
  );
}