require("dotenv").config();
const express = require("express");
const path = require("path");
const multer = require("multer");
const { Pool } = require("pg");

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

// === MOCK UPLOAD API ===
app.post("/api/upload", upload.single("file"), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: "No file uploaded" });

  // giả lập upload thành công lên GCP bucket
  const mockUrl = `https://storage.googleapis.com/mock-bucket/${Date.now()}-${
    req.file.originalname
  }`;

  console.log(`Mock upload: ${req.file.originalname} -> ${mockUrl}`);

  // trả kết quả giả định
  res.json({
    status: "mocked",
    file: {
      name: req.file.originalname,
      size: req.file.size,
      type: req.file.mimetype,
      url: mockUrl,
    },
  });
});

// === RAY PHI3-MINI CHAT API ===
app.post("/api/chat", async (req, res) => {
  const { message, history } = req.body;

  if (!message) {
    return res.status(400).json({ error: "Message is required" });
  }

  try {
    // Call Ray-powered Phi3-mini API
    const rayApiUrl = process.env.RAY_API_URL || 'http://ray-ai-model-service/chat';
    
    const chatRequest = {
      message: message,
      history: history || [],
      max_length: 512
    };

    console.log(`Sending chat request to Ray Phi3-mini: ${message}`);

    const response = await fetch(rayApiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(chatRequest)
    });

    if (!response.ok) {
      throw new Error(`Ray API error: ${response.status}`);
    }

    const chatResponse = await response.json();
    
    console.log(`Phi3-mini response received in ${chatResponse.processing_time}s`);

    // Return response in format expected by frontend
    res.json({
      role: "assistant",
      content: chatResponse.content,
      timestamp: chatResponse.timestamp,
      model: "phi3-mini-ray",
      processing_time: chatResponse.processing_time,
      worker_info: chatResponse.worker_info
    });

  } catch (error) {
    console.error(`Chat API error: ${error.message}`);
    
    // Fallback to mock response if Ray API fails
    const mockReplies = [
      `I apologize, but I'm currently unable to connect to the Ray cluster. Your message was: "${message}"`,
      `Ray Phi3-mini is temporarily unavailable. Mock response for: "${message}"`,
      `Connection to distributed AI failed. Fallback response to: "${message}"`
    ];
    
    const mockReply = mockReplies[Math.floor(Math.random() * mockReplies.length)];
    
    res.json({
      role: "assistant",
      content: mockReply,
      timestamp: new Date().toISOString(),
      mock: true,
      model: "fallback-mock",
      error: "Ray API unavailable"
    });
  }
});

// Serve UI
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.listen(port, () => {
  console.log(`✅ App running at http://localhost:${port}`);
});
