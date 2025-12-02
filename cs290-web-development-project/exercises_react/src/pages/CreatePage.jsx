import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "../App.css";

export const CreatePage = ({}) => {
  const [name, setName] = useState('');
  const [reps, setReps] = useState('');
  const [weight, setWeight] = useState('');
  const [unit, setUnit] = useState('lbs');
  const [date, setDate] = useState('');

  const navigate = useNavigate();

  const newExercise = async () => {
 
    
    const createdExercise = {
      name,
      reps,
      weight,
      unit,
      date
    };


    const response = await fetch(`/exercises/`, {
        method: "POST",
        headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(createdExercise)

    });

    if (response.status === 201) {
      alert(
        `You have successfully logged a new exercise!\n\nHere are the stored values:\n
        Name: ${name}
        Reps: ${reps}
        Weight: ${weight}
        Unit: ${unit}
        Date: ${date}`
      );
    } else {
      alert(`Failed to create exercise - status code` + response.status);
    }
    navigate("/");
  };

  
  return (
    <>
    <div>
      <h2>Log an exercise</h2>
      <p>Use this page to log a new exercise.
        <br /><strong>NOTE: The date must be exatly in the MM-DD-YY format!</strong>
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
            // Call the actual function that will create the exercise on the POST endpoint
            newExercise();
          }}
        >
          Submit
        </button>
      </form>
    </>
  );
};

export default CreatePage;
