import { Request, Response } from "express";
import { z } from "zod";
import db from "../config/database";

const postSchema = z.object({
  title: z
    .string()
    .min(3, "Judul minimal 3 karakter"),

  content: z
    .string()
    .min(10, "Isi artikel minimal 10 karakter"),

  country: z.enum([
    "Thailand",
    "Korea",
    "Indonesia"
  ]),

  category_id: z
    .number()
    .int()
    .positive(),

  image_url: z
    .string()
    .optional()
    .or(z.literal("")),

  source: z
    .string()
    .optional()
    .or(z.literal("")),

  author: z
    .string()
    .optional()
    .or(z.literal("")),

  published_at: z
    .string()
    .optional()
    .or(z.literal(""))
});


// ==========================================
// GET SEMUA ARTIKEL
// ==========================================

export const getPosts = async (
  req: Request,
  res: Response
) => {
  try {
    const [rows] = await db.query(`
      SELECT
        posts.id,
        posts.title,
        posts.content,
        posts.image_url,
        posts.country,
        posts.category_id,
        categories.name AS category_name,
        posts.source,
        posts.author,
        posts.published_at,
        posts.created_at,
        posts.updated_at
      FROM posts
      JOIN categories
        ON posts.category_id = categories.id
      ORDER BY posts.published_at DESC, posts.id DESC
    `);

    res.status(200).json({
      success: true,
      message: "Berhasil mengambil semua artikel",
      data: rows
    });

  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Gagal mengambil semua artikel"
    });
  }
};


// ==========================================
// GET ARTIKEL BERDASARKAN ID
// ==========================================

export const getPostById = async (
  req: Request,
  res: Response
) => {
  try {
    const id = Number(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: "ID artikel tidak valid"
      });
    }

    const [rows]: any = await db.query(
      `
      SELECT
        posts.id,
        posts.title,
        posts.content,
        posts.image_url,
        posts.country,
        posts.category_id,
        categories.name AS category_name,
        posts.source,
        posts.author,
        posts.published_at,
        posts.created_at,
        posts.updated_at
      FROM posts
      JOIN categories
        ON posts.category_id = categories.id
      WHERE posts.id = ?
      `,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Artikel tidak ditemukan"
      });
    }

    res.status(200).json({
      success: true,
      message: "Artikel ditemukan",
      data: rows[0]
    });

  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Gagal mengambil artikel"
    });
  }
};


// ==========================================
// POST TAMBAH ARTIKEL
// ==========================================

export const createPost = async (
  req: Request,
  res: Response
) => {
  try {
    const validation = postSchema.safeParse({
      title: req.body.title,
      content: req.body.content,
      country: req.body.country,
      category_id: Number(req.body.category_id),
      image_url: req.body.image_url,
      source: req.body.source,
      author: req.body.author,
      published_at: req.body.published_at
    });

    if (!validation.success) {
      return res.status(400).json({
        success: false,
        message: "Data artikel tidak valid",
        errors: validation.error.issues
      });
    }

    const {
      title,
      content,
      country,
      category_id,
      image_url,
      source,
      author,
      published_at
    } = validation.data;

    const [result]: any = await db.query(
      `
      INSERT INTO posts
      (
        title,
        content,
        image_url,
        country,
        category_id,
        source,
        author,
        published_at
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [
        title,
        content,
        image_url || null,
        country,
        category_id,
        source || null,
        author || null,
        published_at || null
      ]
    );

    res.status(201).json({
      success: true,
      message: "Artikel berhasil dibuat",
      data: {
        id: result.insertId,
        title,
        content,
        image_url,
        country,
        category_id,
        source,
        author,
        published_at
      }
    });

  } catch (error: any) {
    console.error(error);

    if (error.code === "ER_NO_REFERENCED_ROW_2") {
      return res.status(400).json({
        success: false,
        message: "Category ID tidak ditemukan"
      });
    }

    res.status(500).json({
      success: false,
      message: "Gagal membuat artikel"
    });
  }
};


// ==========================================
// PUT EDIT ARTIKEL
// ==========================================

export const updatePost = async (
  req: Request,
  res: Response
) => {
  try {
    const id = Number(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: "ID artikel tidak valid"
      });
    }

    const validation = postSchema.safeParse({
      title: req.body.title,
      content: req.body.content,
      country: req.body.country,
      category_id: Number(req.body.category_id),
      image_url: req.body.image_url,
      source: req.body.source,
      author: req.body.author,
      published_at: req.body.published_at
    });

    if (!validation.success) {
      return res.status(400).json({
        success: false,
        message: "Data artikel tidak valid",
        errors: validation.error.issues
      });
    }

    const {
      title,
      content,
      country,
      category_id,
      image_url,
      source,
      author,
      published_at
    } = validation.data;

    const [result]: any = await db.query(
      `
      UPDATE posts
      SET
        title = ?,
        content = ?,
        image_url = ?,
        country = ?,
        category_id = ?,
        source = ?,
        author = ?,
        published_at = ?
      WHERE id = ?
      `,
      [
        title,
        content,
        image_url || null,
        country,
        category_id,
        source || null,
        author || null,
        published_at || null,
        id
      ]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Artikel tidak ditemukan"
      });
    }

    res.status(200).json({
      success: true,
      message: "Artikel berhasil diperbarui"
    });

  } catch (error: any) {
    console.error(error);

    if (error.code === "ER_NO_REFERENCED_ROW_2") {
      return res.status(400).json({
        success: false,
        message: "Category ID tidak ditemukan"
      });
    }

    res.status(500).json({
      success: false,
      message: "Gagal memperbarui artikel"
    });
  }
};


// ==========================================
// DELETE HAPUS ARTIKEL
// ==========================================

export const deletePost = async (
  req: Request,
  res: Response
) => {
  try {
    const id = Number(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: "ID artikel tidak valid"
      });
    }

    const [result]: any = await db.query(
      `
      DELETE FROM posts
      WHERE id = ?
      `,
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Artikel tidak ditemukan"
      });
    }

    res.status(200).json({
      success: true,
      message: "Artikel berhasil dihapus"
    });

  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Gagal menghapus artikel"
    });
  }
};