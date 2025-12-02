import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "../App.css";

export const EditPage = ({ exerciseToEdit }) => {
  const [name, setName] = useState(exerciseToEdit.name);
  const [reps, setReps] = useState(exerciseToEdit.reps);
  const [weight, setWeight] = useState(exerciseToEdit.weight);
  const [unit, setUnit] = useState(exerciseToEdit.unit);
  const [date, setDate] = useState(exerciseToEdit.date);

  const navigate = useNavigate();

  const editExercise = async () => {
    const editedExercise = {
      name,
      reps,
      weight,
      unit,
      date
    };

    const response = await fetch(`/exercises/${exerciseToEdit._id}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(editedExercise),
    });

    if (response.status === 200) {
      alert(
        `You have successfully updated this exercise!\n\nHere are the updated values:\nName: ${name}\nReps: ${reps}\nWeight: ${weight}\nUnit: ${unit}\nDate: ${date}`
      );
    } else {
      alert(`Failed to update exercise - status code` + response.status);
    }
    navigate("/");
  };

  return (
    <>
      <div>
        <h2>Edit Exercise</h2>
        <p>
          On this page you can edit the details of an exercise.
          <br />
          Simply update the values below and then press the Submit button.
          <br />
          <strong>NOTE: The date must be exatly in the MM-DD-YY format!</strong>
        </p>
      </div>
      <form>
        <fieldset>
          <legend>Edit Exercise Details</legend>
          <label>
            Name:
            <input
              type="string"
              value={name}
              onChange={(e) => setName(e.target.value)}
            />
          </label>
          <br />
          <label>
            Reps:
            <input
              type="number"
              value={reps}
              onChange={(e) => setReps(e.target.valueAsNumber)}
            />
          </label>
          <br />
          <label>
            Weight:
            <input
              type="number"
              value={weight}
              onChange={(e) => setWeight(e.target.valueAsNumber)}
            />
          </label>
          <br />
          <label>
            Unit:
            <select value={unit} onChange={(e) => setUnit(e.target.value)}>
              <option value="kgs">Kilograms</option>
              <option value="lbs">Pounds</option>
            </select>
          </label>
          <br />
          <label>
            Date:
            <input
              type="string"
              value={date}
              onChange={(e) => setDate(e.target.value)}
            />
          </label>
        </fieldset>
        <button
          onClick={(e) => {
            e.preventDefault();
            // Call the actual function that will update the exercise on the PUT endpoint
            editExercise();
          }}
        >
          Submit
        </button>
      </form>
    </>
  );
};

export default EditPage;
