import '../App.css';
import ExerciseRow from "./ExerciseRow";

function ExerciseTable({ exercises, onDelete, onEdit }) {
  return (
    <>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Reps</th>
            <th>Weight</th>
            <th>Unit</th>
            <th>Date</th>
            <th>Modify</th>
          </tr>
        </thead>
        <tbody>
          {exercises.map((exercise, exerciseIndex) => (
            <ExerciseRow
              key={exerciseIndex}
              exercise={exercise}
              onDelete={onDelete}
              onEdit={onEdit}
            />
          ))}
        </tbody>
      </table>
    </>
  );
}

export default ExerciseTable;
