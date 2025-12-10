import os
import requests
import gradio as gr

AI_URL = os.environ.get("AI_API_URL", "http://qwen-unified-service:8000/chat")
BUCKET_NAME = os.environ.get("GCS_BUCKET_NAME")

def chat_fn(message, history):
    """
    Xử lý history từ Gradio để gửi sang Backend.
    Gradio mới có thể trả về list of dicts, Gradio cũ trả về list of lists.
    """
    
    formatted_history = []
    
    # 1. LOGIC CONVERT THÔNG MINH (FIX LỖI KEYERROR: 0)
    for turn in history:
        # Trường hợp A: Nếu turn là List/Tuple (Gradio cũ: ['user msg', 'bot msg'])
        if isinstance(turn, (list, tuple)):
            formatted_history.append({"role": "user", "content": turn[0]})
            if len(turn) > 1 and turn[1] is not None:
                formatted_history.append({"role": "assistant", "content": turn[1]})
        
        # Trường hợp B: Nếu turn là Dict (Gradio mới: {'role': 'user', 'content': '...'})
        # Đây chính là trường hợp bạn đang gặp phải.
        elif isinstance(turn, dict):
            formatted_history.append(turn)

    # 2. Chuẩn bị payload
    payload = {
        "message": message, 
        "history": formatted_history
    }

    # 3. Gọi backend AI
    try:
        # Timeout 60s để chờ model suy nghĩ
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
    title="Team 1 Chatbot",
    # type="messages" # Gradio 4.x tự động dùng kiểu này rồi nên ko cần khai báo, nhưng code trên đã handle cả 2.
)

if __name__ == "__main__":
    iface.launch(server_name="0.0.0.0", server_port=80)