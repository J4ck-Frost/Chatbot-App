const listEl = document.getElementById("todoList");
const inputEl = document.getElementById("newTodo");
const addBtn = document.getElementById("addBtn");

async function loadTodos() {
  const res = await fetch("/api/todos");
  const todos = await res.json();
  listEl.innerHTML = "";
  todos.forEach((t) => {
    const li = document.createElement("li");
    li.className = t.completed ? "done" : "";
    li.innerHTML = `
      <span>${t.title}</span>
      <div>
        <button onclick="toggleTodo(${t.id}, ${!t.completed})">${
      t.completed ? "Undo" : "Done"
    }</button>
        <button onclick="deleteTodo(${t.id})">🗑️</button>
      </div>
    `;
    listEl.appendChild(li);
  });
}

async function addTodo() {
  const title = inputEl.value.trim();
  if (!title) return;
  await fetch("/api/todos", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title }),
  });
  inputEl.value = "";
  loadTodos();
}

async function toggleTodo(id, completed) {
  await fetch(`/api/todos/${id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ completed }),
  });
  loadTodos();
}

async function deleteTodo(id) {
  await fetch(`/api/todos/${id}`, { method: "DELETE" });
  loadTodos();
}

addBtn.onclick = addTodo;
loadTodos();

// === Upload mock ===
const uploadBtn = document.getElementById("uploadBtn");
const fileInput = document.getElementById("fileInput");
const uploadResult = document.getElementById("uploadResult");

uploadBtn.onclick = async () => {
  const file = fileInput.files[0];
  if (!file) return alert("Please select a file first");

  const formData = new FormData();
  formData.append("file", file);

  const res = await fetch("/api/upload", {
    method: "POST",
    body: formData,
  });

  const data = await res.json();
  uploadResult.textContent = JSON.stringify(data, null, 2);
};

// === Chat mock ===
const chatMessages = document.getElementById("chat-messages");
const chatText = document.getElementById("chatText");
const sendBtn = document.getElementById("sendBtn");
let chatHistory = [];

function appendMessage(role, text) {
  const msg = document.createElement("div");
  msg.className = `message ${role}`;
  msg.innerHTML = `<span>${text}</span>`;
  chatMessages.appendChild(msg);
  chatMessages.scrollTop = chatMessages.scrollHeight;
}

async function sendMessage() {
  const text = chatText.value.trim();
  if (!text) return;

  appendMessage("user", text);
  chatText.value = "";

  // Mock call to backend
  const res = await fetch("/api/chat", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ message: text, history: chatHistory }),
  });

  const reply = await res.json();
  appendMessage("assistant", reply.content);

  // Update history
  chatHistory.push({ role: "user", content: text });
  chatHistory.push({ role: "assistant", content: reply.content });
}

sendBtn.onclick = sendMessage;
chatText.addEventListener("keypress", (e) => {
  if (e.key === "Enter") sendMessage();
});
