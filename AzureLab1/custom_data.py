from flask import Flask
import socket
import requests

app = Flask(__name__)

import requests
@app.route('/')
def hello_world():
    # Get the private IP address of the machine
    hostname = socket.gethostname()
    private_ip = socket.gethostbyname(hostname)
    
    return f"""<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<head>
    <title>Taco Wagon</title>
</head>
<body>
    <h1>MOAR! MOAR!🚗🌮🌮🌮</h1>
    <div class="ip">Private IP: {private_ip}</div>
    <div class="hostname">Hostname: {hostname}</div>
</body>
</html>"""

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)