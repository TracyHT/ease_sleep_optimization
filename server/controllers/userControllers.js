const User = require("../models/User");

exports.createUser = async (req, res) => {
  try {
    const user = await User.create(req.body);
    res.status(201).json(user);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getUser = async (req, res) => {
  try {
    const user = await User.findOne({ firebase_uid: req.params.firebase_uid });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
