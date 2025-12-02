import "../App.css";
import UpdateExercise from "./UpdateExercise";

function ExerciseRow({ exercise, onDelete, onEdit }) {
  return (
      <tr>
        <td>{exercise.name}</td>
        <td>{exercise.reps}</td>
        <td>{exercise.weight}</td>
        <td>{exercise.unit}</td>
        <td>{exercise.date}</td>
        <td><UpdateExercise exercise={exercise} onDelete={onDelete} onEdit={onEdit} /></td>
      </tr>
  );
}

export default ExerciseRow;
