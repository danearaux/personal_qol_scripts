import subprocess, socket, requests

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    ip = s.getsockname()[0]
    s.close()
    return ip

def getmac():
    import netifaces
    iface = netifaces.gateways()['default'][netifaces.AF_INET][1]
    mac = netifaces.ifaddresses(iface)[netifaces.AF_LINK][0]['addr']
    return mac

def get_external_ip():
    return requests.get("https://api.ipify.org").text

def get_ssid():
    result = subprocess.run(["netsh","wlan","show","interfaces"], capture_output=True, text=True)
    for line in result.stdout.splitlines():
        if "SSID" in line and "BSSID" not in line:
            return line.split(":", 1)[1].strip()
    return None

print(f"SSID:", get_ssid())
print(f"MAC:", getmac())
print(f"Local IP:", get_local_ip())
print(f"External IP:", get_external_ip())

