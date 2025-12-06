import os
import requests
import gradio as gr

AI_URL = os.environ.get("AI_API_URL", "http://qwen-unified-service:8000/chat")
BUCKET_NAME = os.environ.get("GCS_BUCKET_NAME")

def chat_fn(message, history):
    """
    history: Mặc định của ChatInterface là list các cặp [[user_msg, bot_msg], ...]
    Chúng ta cần convert nó sang list of dicts [{"role": "user", ...}] để gửi cho Backend.
    """
    
    # 1. CONVERT history từ Tuples -> Dicts (cho Backend)
    formatted_history = []
    for turn in history:
        # turn[0] là user input, turn[1] là bot output
        formatted_history.append({"role": "user", "content": turn[0]})
        if turn[1] is not None:
            formatted_history.append({"role": "assistant", "content": turn[1]})

    # 2. Chuẩn bị payload
    payload = {
        "message": message, 
        "history": formatted_history
    }

    # 3. Gọi backend AI
    try:
        resp = requests.post(AI_URL, json=payload, timeout=20)
        
        if resp.status_code == 200:
            answer = resp.json().get("response", "(No response content)")
        else:
            answer = f"⚠️ AI Error: {resp.status_code} - {resp.text}"
            
    except Exception as e:
        answer = f"❌ Connection error: {str(e)}"

    # 4. Trả về string (ChatInterface tự động update UI)
    return answer

# KHÔNG dùng type="messages" nữa để tránh lỗi init
iface = gr.ChatInterface(
    fn=chat_fn, 
    title="Team 1 Chatbot"
)

iface.launch(server_name="0.0.0.0", server_port=80)