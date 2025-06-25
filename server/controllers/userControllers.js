import User from "../models/user.model.js";

export async function createUser(req, res) {
  try {
    const user = await User.create(req.body);
    res.status(201).json(user);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
}

export async function getUser(req, res) {
  try {
    console.log("UID param:", req.params.uid);

    const allUsers = await User.find({});
    console.log("All users in DB:", allUsers);

    const uid = req.params.uid.trim();
    const user = await User.findOne({ uid });
    console.log("User found:", user);

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }
    res.json(user);
  } catch (err) {
    console.error("Error in getUser:", err);
    res.status(500).json({ error: err.message });
  }
}
