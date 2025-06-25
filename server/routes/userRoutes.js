import { Router } from "express";
const router = Router();
import { createUser, getUser } from "../controllers/userControllers.js";

router.post("/", createUser);
router.get("/:uid", getUser);

export default router;
