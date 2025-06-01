const express = require("express");
const router = express.Router();
const { createUser, getUser } = require("../controllers/userController");

router.post("/", createUser);
router.get("/:firebase_uid", getUser);

module.exports = router;
