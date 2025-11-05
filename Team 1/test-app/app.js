require("dotenv").config();
const express = require("express");
const path = require("path");
const multer = require("multer");
const { Pool } = require("pg");
const { Storage } = require("@google-cloud/storage");
const storage = new Storage();
const bucketName = process.env.GCS_BUCKET_NAME;
const bucket = storage.bucket(bucketName);

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

// PostgreSQL pool
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl:
    process.env.DB_SSL_MODE === "disable"
      ? false
      : { rejectUnauthorized: false },
});

// Multer setup (store files in memory only, mock upload)
const upload = multer({ storage: multer.memoryStorage() });

// Ensure todo table exists
async function initDB() {
  const client = await pool.connect();
  await client.query(`
    CREATE TABLE IF NOT EXISTS todos (
      id SERIAL PRIMARY KEY,
      title TEXT NOT NULL,
      completed BOOLEAN DEFAULT false,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `);
  client.release();
  console.log("✅ Todo table ready");
}
initDB();

// --------- REST API ---------

// Get all todos
app.get("/api/todos", async (req, res) => {
  const { rows } = await pool.query("SELECT * FROM todos ORDER BY id DESC");
  res.json(rows);
});

// Create todo
app.post("/api/todos", async (req, res) => {
  const { title } = req.body;
  if (!title) return res.status(400).json({ error: "title is required" });
  const { rows } = await pool.query(
    "INSERT INTO todos (title) VALUES ($1) RETURNING *",
    [title]
  );
  res.status(201).json(rows[0]);
});

// Update todo (toggle or rename)
app.put("/api/todos/:id", async (req, res) => {
  const { id } = req.params;
  const { title, completed } = req.body;
  const { rows } = await pool.query(
    "UPDATE todos SET title = COALESCE($1, title), completed = COALESCE($2, completed) WHERE id=$3 RETURNING *",
    [title, completed, id]
  );
  if (rows.length === 0)
    return res.status(404).json({ error: "Todo not found" });
  res.json(rows[0]);
});

// Delete todo
app.delete("/api/todos/:id", async (req, res) => {
  const { id } = req.params;
  await pool.query("DELETE FROM todos WHERE id=$1", [id]);
  res.json({ success: true });
});

// Upload to bucket
app.post("/api/upload", upload.single("file"), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: "No file uploaded" });

  try {
    const filename = `${Date.now()}-${req.file.originalname}`;
    const blob = bucket.file(filename);

    const blobStream = blob.createWriteStream({
      resumable: false,
      contentType: req.file.mimetype,
    });

    blobStream.on("error", (err) => {
      console.error("Upload error:", err);
      res.status(500).json({ error: "Upload failed" });
    });

    blobStream.on("finish", async () => {
      await blob.makePublic(); // hoặc bỏ dòng này nếu không muốn public
      const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;
      console.log(`Uploaded: ${req.file.originalname} -> ${publicUrl}`);

      res.status(200).json({
        status: "uploaded",
        file: {
          name: req.file.originalname,
          size: req.file.size,
          type: req.file.mimetype,
          url: publicUrl,
        },
      });
    });

    blobStream.end(req.file.buffer);
  } catch (err) {
    console.error("Unexpected error:", err);
    res.status(500).json({ error: "Unexpected upload error" });
  }
});

// === MOCK CHAT API ===
app.post("/api/chat", async (req, res) => {
  const { message, history } = req.body;

  if (!message) {
    return res.status(400).json({ error: "Message is required" });
  }

  // Mock: sinh câu trả lời giả lập dựa theo message
  const replies = [
    `Tôi hiểu bạn nói "${message}". Rất hay!`,
    `Câu hỏi thú vị: "${message}". Khi model thật hoạt động, tôi sẽ trả lời chi tiết hơn.`,
    `Giả lập phản hồi: "${message}" (từ mock chat bot).`,
    `Xin lỗi, hiện tôi đang chạy ở chế độ mock. Bạn vừa nói "${message}".`,
  ];
  const randomReply = replies[Math.floor(Math.random() * replies.length)];

  // Trả về "phản hồi" + thêm metadata
  res.json({
    role: "assistant",
    content: randomReply,
    timestamp: new Date().toISOString(),
    mock: true,
    model: "phi3-mini (mock)",
  });
});

// Serve UI
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.listen(port, () => {
  console.log(`✅ App running at http://localhost:${port}`);
});
