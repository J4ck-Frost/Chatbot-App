import os
import requests
import gradio as gr

AI_URL = os.environ.get("AI_API_URL", "http://qwen-unified-service:8000/chat")

def chat_fn(message, history):
    formatted_history = []
    
    for turn in history:
        role = "user"
        content = ""

        # 1. Xử lý nếu turn là Dict (Gradio mới)
        if isinstance(turn, dict):
            role = turn.get("role")
            raw_content = turn.get("content")
            
            # [QUAN TRỌNG] Bóc tách text từ list multimodal
            if isinstance(raw_content, list):
                # Duyệt qua các phần tử trong list (vd: [{'text': 'hi', 'type': 'text'}])
                for item in raw_content:
                    if isinstance(item, dict) and item.get("type") == "text":
                        content += item.get("text", "")
            elif isinstance(raw_content, str):
                content = raw_content

        # 2. Xử lý nếu turn là List/Tuple (Gradio cũ - Dự phòng)
        elif isinstance(turn, (list, tuple)):
            content = turn[0] # Chỉ lấy user message, phần assistant xử lý riêng nếu cần logic cũ
            role = "user" # Mặc định tạm
            
        # 3. Chỉ thêm vào nếu có nội dung
        if content:
            formatted_history.append({"role": role, "content": content})

    # Chuẩn bị payload
    payload = {
        "message": message, 
        "history": formatted_history
    }

    try:
        resp = requests.post(AI_URL, json=payload, timeout=60)
        if resp.status_code == 200:
            answer = resp.json().get("response", "(No response content)")
        else:
            answer = f"⚠️ AI Error: {resp.status_code} - {resp.text}"
    except Exception as e:
        answer = f"❌ Connection error: {str(e)}"

    return answer

# Init ChatInterface
iface = gr.ChatInterface(
    fn=chat_fn, 
    title="Gwen Chatbot"
)

if __name__ == "__main__":
    iface.launch(server_name="0.0.0.0", server_port=80)