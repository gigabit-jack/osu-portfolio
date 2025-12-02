/**
 * Josh Goben
 */
import 'dotenv/config';
import mongoose from 'mongoose';

const EXERCISE_DB_NAME = 'exercise_db';
const EXERCISE_CLASS = 'Exercise';

let connection = undefined;

/**
 * This function connects to the MongoDB server and to the database
 *  'exercise_db' in that server.
 */
async function connect(){
    try{
        connection = await mongoose.connect(process.env.MONGODB_CONNECT_STRING, 
                {dbName: EXERCISE_DB_NAME});
        console.log("Successfully connected to MongoDB using Mongoose!");
    } catch(err){
        console.log(err);
        throw Error(`Could not connect to MongoDB ${err.message}`)
    }
}


/**
 * Define the schema
 */
const exerciseSchema = mongoose.Schema({
    name: { type: String, required: true },
    reps: { 
        type: Number, 
        required: true,
        validate: {
            validator: function(v) {
                return Number.isInteger(v) && v > 0;
            }
        }
    }, 
    weight: { 
        type: Number, 
        required: true,
        validate: {
            validator: function(v) {
                return Number.isInteger(v) && v > 0;
            }
         }
    },
    unit: { type: String, required: true },
    date: { type: String, required: true }
});


/**
 * Compile the model from the schema. This must be done after defining the schema.
 */
const Exercise = mongoose.model(EXERCISE_CLASS, exerciseSchema);


/**
* Create an exercise
* @param {string} name      Must be at least one character
* @param {number} reps      Must be an integer > 0
* @param {number} weight    Must be an integer > 0
* @param {string} unit      Must be 'kgs' or 'lbs'
* @param {string} date      Must be in MM-DD-YY format
* @returns 
*/
const createExercise = async (name, reps, weight, unit, date) => {
    const exercise = new Exercise({name: name, reps: reps, weight: weight, unit: unit, date: date});
    return exercise.save();
};


/**
 * Get an array of exercises or just a single exercise if an id is provided
 * @param {String} id
 * @returns A promise. Array of JSON objects of the Exercise class
 */
const getExercises = async ({id}) => {
    // if an id is provided, we will return the exercise with that id
    if (id !== undefined) {
        return await Exercise.findById(id);
    }
    else {
        // returns an array of all exercises
        return await Exercise.find({});
    }
};


/**
 * Update a single exercise by _id with any parameters provided
 * @param {String} name
 * @param {Number} reps 
 * @param {Number} weight
 * @param {String} unit
 * @param {String} date
 * @param {String} id
 * @returns Updated exercise object
 */
const updateExercise = async ({name, reps, weight, unit, date, id}) => {
    // if an id is provided, we will update and return the user with that id
    if (id !== undefined) {
        // Build an update object
        const exerciseUpdates = {};
        if (name !== undefined) exerciseUpdates.name = name;
        if (reps !== undefined) exerciseUpdates.reps = reps;
        if (weight !== undefined) exerciseUpdates.weight = weight;
        if (unit !== undefined) exerciseUpdates.unit = unit;
        if (date !== undefined) exerciseUpdates.date = date;
       
        // Use findByIdAndUpdate to update and return the updated user object
        const updatedExercise = await Exercise.findByIdAndUpdate(
            id,
            {$set: exerciseUpdates},
            {new: true} 
        );
        return updatedExercise;
    }
    // otherwise we just return false
    else {
        return false;
    }
};


/**
 * Deletes an exercise matching the provided _id
 * @param {String} id
 * @returns True or False based on deletion status
 */
const deleteExercise = async ({id}) => {
    if (id !== undefined) {
        // Deletes a specific exercise with the deleteOne() method
        const result = await Exercise.deleteOne({ _id: id });
        if (result.deletedCount === 0) {
            return false;
        }
        else {
            return true;
        }
    } else {
        return false;
    };
};

export { connect, createExercise, deleteExercise, getExercises, updateExercise };

