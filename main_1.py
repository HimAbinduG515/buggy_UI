import sys
import threading
import rclpy
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from ros_b import DashboardBackend


def main():
    rclpy.init()

    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    backend = DashboardBackend()
    engine.rootContext().setContextProperty("backend", backend)
    engine.load("main_1.qml")

    threading.Thread(target=rclpy.spin, args=(backend,), daemon=True).start()

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
