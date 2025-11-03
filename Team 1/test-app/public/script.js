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
