import rclpy
from rclpy.node import Node
from std_msgs.msg import Float64
from sensor_msgs.msg import Imu
from rosgraph_msgs.msg import Clock
from PySide6.QtCore import QObject, Signal, Property, QTimer
from datetime import datetime
import math


class DashboardBackend(Node, QObject):
    speedChanged = Signal()
    steerChanged = Signal()
    imuChanged = Signal()
    timeChanged = Signal()
    batteryChanged = Signal()

    def __init__(self):
        Node.__init__(self, "dashboard_backend")
        QObject.__init__(self)

        # ---------------- DATA ----------------
        self._speed = 0.0
        self._steer = 0.0
        self._ax = self._ay = self._az = 0.0
        self._yaw = 0.0

        self._battery = 78.0   # idle-only battery
        self._ros_time = "00:00:00"
        self._sys_time = datetime.now().strftime("%H:%M:%S")

        # ---------------- ROS ----------------
        self.create_subscription(Float64, "/vehicle_speed", self.speed_cb, 10)
        self.create_subscription(Float64, "/currentSteerAngle", self.steer_cb, 10)
        self.create_subscription(Imu, "/imu/data", self.imu_cb, 10)
        self.create_subscription(Clock, "/clock", self.clock_cb, 10)

        # ---------------- BATTERY TIMER ----------------
        self.battery_timer = QTimer()
        self.battery_timer.timeout.connect(self.idle_battery_drain)
        self.battery_timer.start(30000)  # every 30 sec

    # ---------------- CALLBACKS ----------------
    def speed_cb(self, msg):
        self._speed = msg.data
        self.speedChanged.emit()

    def steer_cb(self, msg):
        self._steer = msg.data
        self.steerChanged.emit()

    def imu_cb(self, msg):
        self._ax = msg.linear_acceleration.x
        self._ay = msg.linear_acceleration.y
        self._az = msg.linear_acceleration.z
        self._yaw = msg.angular_velocity.z
        self.imuChanged.emit()

    def clock_cb(self, msg):
        sec = msg.clock.sec
        h = (sec // 3600) % 24
        m = (sec % 3600) // 60
        s = sec % 60
        self._ros_time = f"{h:02d}:{m:02d}:{s:02d}"
        self.timeChanged.emit()

    # ---------------- BATTERY LOGIC ----------------
    def idle_battery_drain(self):
        if self._speed < 0.5 and self._battery > 0:
            self._battery -= 0.01
            self._battery = max(self._battery, 0)
            self.batteryChanged.emit()

    # ---------------- PROPERTIES ----------------
    @Property(float, notify=speedChanged)
    def speed(self): return self._speed

    @Property(float, notify=steerChanged)
    def steer(self): return self._steer

    @Property(float, notify=imuChanged)
    def ax(self): return self._ax

    @Property(float, notify=imuChanged)
    def ay(self): return self._ay

    @Property(float, notify=imuChanged)
    def az(self): return self._az

    @Property(float, notify=imuChanged)
    def yawRate(self): return self._yaw

    @Property(float, notify=batteryChanged)
    def battery(self): return self._battery

    @Property(str, notify=timeChanged)
    def rosTime(self): return self._ros_time

    @Property(str, notify=timeChanged)
    def systemTime(self): return self._sys_time
