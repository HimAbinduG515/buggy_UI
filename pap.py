from flask import Flask, send_file, jsonify
import paho.mqtt.client as mqtt
import json
import ssl
import certifi

app = Flask(__name__)

data_store = {
    "speed": 0,
    "battery": 0,
    "steer": 0
}

# ---------- MQTT CALLBACKS ----------
def on_connect(client, userdata, flags, rc):
    print("MQTT CONNECTED:", rc)
    client.subscribe("amr/telemetry")

def on_message(client, userdata, msg):
    global data_store
    print("MQTT RECEIVED:", msg.payload)   # ✅ DEBUG
    try:
        data_store.update(json.loads(msg.payload.decode()))
    except Exception as e:
        print("JSON ERROR:", e)

# ---------- MQTT SETUP ----------
client = mqtt.Client(protocol=mqtt.MQTTv311)
client.username_pw_set("amr_buggy", "Radha@1111")

client.tls_set(
    ca_certs=certifi.where(),
    tls_version=ssl.PROTOCOL_TLS
)

client.on_connect = on_connect
client.on_message = on_message

client.connect(
    "8f0a0131320b437a91798a5a9f77e4ae.s1.eu.hivemq.cloud",
    8883,
    60
)

client.loop_start()

# ---------- ROUTES ----------
@app.route("/")
def index():
    return send_file("index.html")

@app.route("/data")
def data():
    return jsonify(data_store)

# ---------- RUN ----------
app.run(host="0.0.0.0", port=5002)
