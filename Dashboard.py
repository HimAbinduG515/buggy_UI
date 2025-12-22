import sys
import can
import ssl
import paho.mqtt.client as mqtt

from enum import Enum
from PySide6.QtCore import QObject, Property, Signal, QTimer, QTime, QDate
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine


# ---------------- Enums ----------------
class DriveMode(Enum):
    Neutral = 0
    Forward = 1
    Reverse = 3
    ForwardMap = 5
    Manual = 9
    Auto = 10


class Status(Enum):
    Disengaged = 0
    Engaged = 1


# ---------------- Dashboard Backend ----------------
class Dashboard(QObject):
    def __init__(self):
        super().__init__()

        # Default values
        self._speed = 0.0
        self._battery = 100
        self._drive_mode = DriveMode.Neutral
        self._dbw = Status.Disengaged
        self._brake = Status.Disengaged
        self._emergency = Status.Disengaged
        self._autopark = Status.Disengaged

        self._date = QDate.currentDate().toString("yyyy-MM-dd")
        self._time = QTime.currentTime().toString("hh:mm:ss AP")

        # -------------------
        # Setup CAN
        # -------------------
        try:
            self.bus = can.interface.Bus(channel="vcan0", interface="socketcan")
            print("✅ CAN connected (vcan0)")
            self.notifier = can.Notifier(self.bus, [self])
        except Exception as e:
            print("⚠️ CAN not available, continuing without CAN")
            print(e)

        # -------------------
        # Setup MQTT
        # -------------------
        self.setup_mqtt()

        # Clock update
        self.clock_timer = QTimer()
        self.clock_timer.timeout.connect(self.update_clock)
        self.clock_timer.start(1000)

    # ------------------- MQTT -------------------
    def setup_mqtt(self):
        self.client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
        self.client.username_pw_set("amr_buggy", "Radha@1111")

        self.client.tls_set(cert_reqs=ssl.CERT_NONE)
        self.client.tls_insecure_set(True)

        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message

        print("🌐 Connecting to HiveMQ Cloud...")
        self.client.connect("8f0a0131320b437a91798a5a9f77e4ae.s1.eu.hivemq.cloud", 8883)
        self.client.loop_start()

    def on_connect(self, client, userdata, flags, rc, properties=None):
        print("🌐 MQTT Connected!")
        client.subscribe("amr/test")

    def on_message(self, client, userdata, msg):
        try:
            data = msg.payload.decode()
            print("📩 MQTT:", data)

            if data.startswith("Speed:"):
                speed = float(data.split(":")[1])
                self.set_speed(speed)

        except Exception as e:
            print("⚠️ MQTT message error:", e)

    # ---------------- Signals ----------------
    speedChanged = Signal()
    batteryChanged = Signal()
    driveModeChanged = Signal()
    dbwChanged = Signal()
    brakeChanged = Signal()
    emergencyChanged = Signal()
    autoparkChanged = Signal()
    dateChanged = Signal()
    timeChanged = Signal()

    # ---------------- Properties ----------------
    def get_speed(self): return self._speed
    def set_speed(self, value):
        if self._speed != value:
            self._speed = value
            self.speedChanged.emit()
    speed = Property(float, get_speed, set_speed, notify=speedChanged)

    def get_battery(self): return self._battery
    def set_battery(self, v):
        if self._battery != v:
            self._battery = v
            self.batteryChanged.emit()
    battery = Property(int, get_battery, set_battery, notify=batteryChanged)

    def get_drive_mode(self): return self._drive_mode.name
    def set_drive_mode(self, value):
        if self._drive_mode != value:
            self._drive_mode = value
            self.driveModeChanged.emit()
    driveMode = Property(str, get_drive_mode, set_drive_mode, notify=driveModeChanged)

    def get_dbw(self): return self._dbw.name
    def set_dbw(self, v):
        if self._dbw != v:
            self._dbw = v
            self.dbwChanged.emit()
    dbw = Property(str, get_dbw, set_dbw, notify=dbwChanged)

    def get_brake(self): return self._brake.name
    def set_brake(self, v):
        if self._brake != v:
            self._brake = v
            self.brakeChanged.emit()
    brake = Property(str, get_brake, set_brake, notify=brakeChanged)

    def get_autopark(self): return self._autopark.name
    def set_autopark(self, v):
        if self._autopark != v:
            self._autopark = v
            self.autoparkChanged.emit()
    autopark = Property(str, get_autopark, set_autopark, notify=autoparkChanged)

    def get_emergency(self): return self._emergency.name
    def set_emergency(self, v):
        if self._emergency != v:
            self._emergency = v
            self.emergencyChanged.emit()
    emergency = Property(str, get_emergency, set_emergency, notify=emergencyChanged)

    def get_date(self): return self._date
    def set_date(self, v):
        if self._date != v:
            self._date = v
            self.dateChanged.emit()
    date = Property(str, get_date, set_date, notify=dateChanged)

    def get_time(self): return self._time
    def set_time(self, v):
        if self._time != v:
            self._time = v
            self.timeChanged.emit()
    time = Property(str, get_time, set_time, notify=timeChanged)

    # ------------------- Clock -------------------
    def update_clock(self):
        self.set_time(QTime.currentTime().toString("hh:mm:ss AP"))
        self.set_date(QDate.currentDate().toString("yyyy-MM-dd"))

    # ------------------- CAN Handler -------------------
    def __call__(self, msg):
        if msg.arbitration_id != 0x12910109:
            return

        d = msg.data

        self.set_drive_mode(DriveMode(d[0]))
        self.set_dbw(Status(d[1]))
        self.set_brake(Status(d[2]))
        self.set_autopark(Status(d[3] & 0x01))
        self.set_emergency(Status(d[4]))

        raw_speed = d[6] | (d[7] << 8)
        self.set_speed(raw_speed * 0.01)

        self.set_battery(max(0, self._battery - 1))


# ---------------- Main ----------------
if __name__ == "__main__":
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    dashboard = Dashboard()
    engine.rootContext().setContextProperty("dashboard", dashboard)

    engine.load("main.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
z
