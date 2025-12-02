/**
 * Josh Goben
 */
import 'dotenv/config';
import express from 'express';
import asyncHandler from 'express-async-handler';
import * as exercises from './exercises_model.mjs';

const PORT = process.env.PORT;
const app = express();

app.use(express.json());

app.listen(PORT, async () => {
    await exercises.connect()
    console.log(`Server listening on port ${PORT}...`);
});


/**
*
* @param {string} date
* Return true if the date format is MM-DD-YY where MM, DD and YY are 2 digit integers
*/
function isDateValid(date) {
    // Test using a regular expression. 
    // To learn about regular expressions see Chapter 6 of the text book
    const format = /^\d\d-\d\d-\d\d$/;
    return format.test(date);
};


/**
 * 
 * Checks if the request body has the required properties and types
 * @param {object} req 
 * @returns 
 */
function isValid(req) {
  // first, we check if there are any additional properties other than the ones we expect
  const validProperties = ['name', 'reps', 'weight', 'unit', 'date'];

  for (const key in req.body) {
    if (!validProperties.includes(key)) {
      return false;
    } 
  }
  // then we check if we have exactly five properties
  if (Object.keys(req.body).length !== validProperties.length) {
    return false;
  }// name 
  if (typeof req.body.name !== "string" || req.body.name.length === 0) {
    return false;
  }
  // reps
  if (!Number.isInteger(req.body.reps) || req.body.reps <= 0) {
    return false;
  }
  // weight
  if (!Number.isInteger(req.body.weight) || req.body.weight <= 0) {
    return false;
  }
  // unit
  if (req.body.unit !== "kgs" && req.body.unit !== "lbs") {
    return false;
  }
  // date
  if (typeof req.body.date !== "string" || !isDateValid(req.body.date)) {
    return false;
  }
    // if we reach this point then the request is valid
  else {
    return true;
  }
};


/**
 * Creates a new exercise with the query parameters provided in the body
 */
app.post('/exercises', asyncHandler(async (req, res) => {
    if (!isValid(req)) {
      res.status(400).json({ Error: "Invalid request" });
    } else {
      const exercise = await exercises.createExercise(
        req.body.name,
        req.body.reps,
        req.body.weight,
        req.body.unit,
        req.body.date
      );
      res.status(201).json(exercise);
    }
}));


/**
 * Get all exercises based on the query parameters
 */
app.get('/exercises', asyncHandler(async (req, res) => {
    const exercisesArray = await exercises.getExercises({});
    res.json(exercisesArray);
}));


/**
 * Get exercises based on specific ID
 */
app.get('/exercises/:id', asyncHandler(async (req, res) => {
    const exercise = await exercises.getExercises({id: req.params.id})

    if (exercise) {
        res.json(exercise);
    }
    else {
        res.status(404).json({Error: "Not found"});
    }
}));


/**
 * Update a specific exercise with new values
 */
app.put('/exercises/:id', asyncHandler(async (req, res) => {
    if (!isValid(req)) {
      res.status(400).json({ Error: "Invalid request" });
    } else {
    // send any parameters provided in the body
    // missing parameters will be undefined
    const updatedExercise = await exercises.updateExercise({
        id: req.params.id,
        name: req.body.name,
        reps: req.body.reps,
        weight: req.body.weight,
        unit: req.body.unit,
        date: req.body.date
    });

    // check if we received an updated exercise
    if (updatedExercise) {
        res.json(updatedExercise);
    }
    else {
        res.status(404).json({Error: "Not found"});
    }
  }
}));


/**
 * Deletes a specific exercise by the ID provided
 * Returns 204 if successful 
 * Returns 404 if no exercise is found with that ID
 */
app.delete('/exercises/:id', asyncHandler(async (req, res) => {
    const deleteResult = await exercises.deleteExercise({id: req.params.id})

    if (deleteResult) {
        res.status(204).send();
    }
    else {
        res.status(404).json({"Error": "Not found"});
    }
}));
