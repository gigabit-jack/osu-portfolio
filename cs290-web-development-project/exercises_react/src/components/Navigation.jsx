import { Link } from "react-router-dom";
import "../App.css";

function Navigation() {
  return (
    <nav className="app-nav">
      <Link to="/">Home</Link>
      <Link to="/create-exercise">Create a New Exercise</Link>
      {/* <Link to="/edit-exercise">Edit an Existing Exercise</Link> */}
    </nav>
  );
}

export default Navigation;
