from flask import Flask
import socket

app = Flask(__name__)

@app.route('/')
def show_ip():
    # Get the private IP address of the machine
    hostname = socket.gethostname()
    private_ip = socket.gethostbyname(hostname)
    
    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>VM Private IP</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
                background-color: #f0f4f8;
            }}
            .card {{
                background: white;
                border-radius: 12px;
                padding: 40px 60px;
                box-shadow: 0 4px 16px rgba(0,0,0,0.1);
                text-align: center;
            }}
            h1 {{ color: #333; margin-bottom: 10px; }}
            .ip {{
                font-size: 2.5em;
                color: #2563eb;
                font-weight: bold;
                letter-spacing: 2px;
            }}
            .hostname {{
                color: #888;
                margin-top: 10px;
            }}
        </style>
    </head>
    <body>
        <div class="card">
            <h1>🖥️ VM Network Info</h1>
            <div class="ip">{private_ip}</div>
            <div class="hostname">Hostname: {hostname}</div>
        </div>
    </body>
    </html>
    """
    return html

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)