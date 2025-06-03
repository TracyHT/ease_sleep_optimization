import { Schema, model } from "mongoose";

const userSchema = new Schema({
  uid: { type: String, required: true, unique: true }, // Firebase uid
  email: String,
  displayName: String,
  createdAt: { type: Date, default: Date.now },
});

export default model("User", userSchema);
