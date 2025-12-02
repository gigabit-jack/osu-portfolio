import { useState } from "react";
import { Route, BrowserRouter as Router, Routes } from "react-router-dom";
import "./App.css";
import Navigation from "./components/Navigation";
import CreatePage from "./pages/CreatePage";
import EditPage from "./pages/EditPage";
import HomePage from "./pages/HomePage";


function App() {
  const [exerciseToEdit, setExerciseToEdit] = useState([]);

  return (
    <>
    <div className="app-header">
      <Router>
        <Navigation />
        <header>
        <h1>Exercise Journal</h1>
        <p>
          This app will help you keep track of your completed exercises.<br />View your completed exercises below where you can update or delete them.
        </p>
        </header>
        <Routes>
          <Route
            path="/"
            element={<HomePage setExerciseToEdit={setExerciseToEdit} />}
          ></Route>
          <Route path="/create-exercise" element={<CreatePage />}></Route>
          <Route
            path="/edit-exercise"
            element={<EditPage exerciseToEdit={exerciseToEdit} />}
          ></Route>
        </Routes>
      </Router>
    </div>
    <div>
    <footer>
    &copy; 2025 Josh Goben 
    </footer>
    </div>
    </>
  );
}

export default App;
