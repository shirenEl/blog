import express, {
  Request,
  Response
} from "express";

import cors from "cors";
import dotenv from "dotenv";

import postRoutes from "./routes/postRoutes";

dotenv.config();

const app = express();

const PORT =
  Number(process.env.PORT) || 3001;


// =====================================
// MIDDLEWARE
// =====================================

app.use(cors());

app.use(express.json());


// =====================================
// HOME
// =====================================

app.get(
  "/",
  (req: Request, res: Response) => {

    res.status(200).json({
      success: true,
      message: "API Blog berhasil berjalan 🚀"
    });

  }
);


// =====================================
// POST ROUTES
// =====================================

app.use(
  "/api/posts",
  postRoutes
);


// =====================================
// SERVER
// =====================================

app.listen(
  PORT,
  () => {

    console.log(
      `Server berjalan di http://localhost:${PORT}`
    );

  }
);