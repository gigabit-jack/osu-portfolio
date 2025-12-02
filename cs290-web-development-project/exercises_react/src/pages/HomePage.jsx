import { useEffect, useState } from "react";
import { FaPlus } from "react-icons/fa";
import { useNavigate } from "react-router-dom";
import "../App.css";
import ExerciseTable from "../components/ExerciseTable";

function HomePage({ setExerciseToEdit }) {
  const [exercises, setExercises] = useState([]);
  const navigate = useNavigate();

  const loadExercises = async () => {
    const response = await fetch("/exercises");
    const exercises = await response.json();
    setExercises(exercises);
  };

  useEffect(() => {
    loadExercises();
  }, []);

  const onDelete = async (_id) => {
    const response = await fetch(`/exercises/${_id}`, { method: "DELETE" });
    if (response.status === 204) {
      const response = await fetch("/exercises");
      const exercises = await response.json();
      setExercises(exercises);
    } else {
      console.error(
        `Failed to delete exercise with id = ${_id}, status code = ${response.status}`
      );
    }
  };

  const onEdit = (exerciseToEdit) => {
    setExerciseToEdit(exerciseToEdit);
    navigate("/edit-exercise");
  };

  return (
    <>
      <div>
        <h2>List of Exercises</h2>
        <h3>
          Click here to log a new exercise:
          <button
            onClick={() => {
              navigate("/create-exercise");
            }}
          >
            <FaPlus />
          </button>
        </h3>
      </div>
      <div>
        <ExerciseTable
          exercises={exercises}
          onDelete={onDelete}
          onEdit={onEdit}
        ></ExerciseTable>
      </div>
    </>
  );
}

export default HomePage;
