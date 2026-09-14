import { Router } from "express";

import {
  getPosts,
  getPostById,
  createPost,
  updatePost,
  deletePost
} from "../controllers/postController";

const router = Router();

// GET semua artikel
router.get("/", getPosts);

// GET artikel berdasarkan ID
router.get("/:id", getPostById);

// POST tambah artikel
router.post("/", createPost);

// PUT edit artikel
router.put("/:id", updatePost);

// DELETE hapus artikel
router.delete("/:id", deletePost);

export default router;