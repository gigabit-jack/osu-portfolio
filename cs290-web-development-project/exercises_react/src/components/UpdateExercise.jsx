import '../App.css';

import { FaPencil } from "react-icons/fa6";
import { FcCancel } from "react-icons/fc";


function UpdateExercise({exercise, onDelete, onEdit}) {
  return (
    <div>
      <FaPencil onClick={() => 
        onEdit(exercise)} title="Edit Exercise" style={{ marginRight: '20px', fontSize: 18}}/>
      
      <FcCancel onClick={() => 
        onDelete(exercise._id)} title="Delete Exercise" style={{fontSize: 18}}/>
    </div>
  );
}

export default UpdateExercise;