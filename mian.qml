import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

Window {
    visible: true
    width: 1400
    height: 800
    color: "#0a0f1e"
    title: "EV Dashboard Prototype"

    // -------------------------
    // TOP BAR (Date + Time)
    // -------------------------
    Rectangle {
        id: topBar
        width: parent.width
        height: 70
        color: "#111827"
        anchors.top: parent.top
        radius: 0
        border.color: "#1e293b"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            Text {
                text: "2025-11-19"
                color: "#38bdf8"
                font.pixelSize: 24
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "17:58:30"
                color: "#22d3ee"
                font.pixelSize: 26
                font.bold: true
            }
        }
    }

    // ----------------------------------
    // LEFT PANEL — Vehicle Status
    // ----------------------------------
    Column {
        id: leftPanel
        anchors.left: parent.left
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        width: 260
        spacing: 14
        anchors.margins: 20

        // Component for glowing pills
        Component {
            id: pillItem
            Rectangle {
                width: 240
                height: 55
                radius: 25
                color: bgColor
                border.width: 1
                border.color: "#334155"
                Text {
                    anchors.centerIn: parent
                    text: pillText
                    color: "white"
                    font.pixelSize: 20
                }
            }
        }

        Loader { property string pillText: "Drive Mode: Forward"; property color bgColor: "#2563eb"; sourceComponent: pillItem }
        Loader { property string pillText: "DBW: Engaged"; property color bgColor: "#16a34a"; sourceComponent: pillItem }
        Loader { property string pillText: "Brake: Disengaged"; property color bgColor: "#475569"; sourceComponent: pillItem }
        Loader { property string pillText: "AutoPark: OFF"; property color bgColor: "#64748b"; sourceComponent: pillItem }
        Loader { property string pillText: "Emergency: OFF"; property color bgColor: "#10b981"; sourceComponent: pillItem }
        Loader { property string pillText: "Battery: 78%"; property color bgColor: "#22c55e"; sourceComponent: pillItem }

        Rectangle {
            width: 240; height: 70; radius: 20
            color: "#1e293b"
            Text { text: "GPS: 17.44°, 78.33°"; anchors.centerIn: parent; color: "#38bdf8"; font.pixelSize: 18 }
        }

        Rectangle {
            width: 240; height: 70; radius: 20
            color: "#1e293b"
            Text { text: "IMU → Roll: 1.2°, Pitch: 0.5°"; anchors.centerIn: parent; color: "#38bdf8"; font.pixelSize: 18 }
        }
    }

    // ----------------------------------
    // CENTER — SPEED GAUGE (FUTURISTIC)
    // ----------------------------------
    Item {
        id: centerGauge
        anchors.centerIn: parent
        width: 520
        height: 520

        Canvas {
            id: gauge
            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var cx = width / 2
                var cy = height / 2
                var radius = 200
                var speed = 28                     // prototype static value
                var maxSpeed = 60

                var start = Math.PI * 0.75
                var end = start + (speed / maxSpeed) * Math.PI * 1.5

                // BACK ARC
                ctx.beginPath()
                ctx.arc(cx, cy, radius, Math.PI*0.75, Math.PI*2.25)
                ctx.strokeStyle = "#1e293b"
                ctx.lineWidth = 32
                ctx.stroke()

                // GLOW ARC
                var grad = ctx.createLinearGradient(0, 0, width, 0)
                grad.addColorStop(0, "#22d3ee")
                grad.addColorStop(1, "#3b82f6")

                ctx.beginPath()
                ctx.arc(cx, cy, radius, start, end)
                ctx.lineWidth = 32
                ctx.strokeStyle = grad
                ctx.stroke()

                // NEEDLE
                ctx.beginPath()
                ctx.moveTo(cx, cy)
                var nx = cx + radius * Math.cos(end)
                var ny = cy + radius * Math.sin(end)
                ctx.lineTo(nx, ny)
                ctx.lineWidth = 6
                ctx.strokeStyle = "#f43f5e"
                ctx.stroke()
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "28"
                font.pixelSize: 72
                font.bold: true
                color: "white"
            }
            Text {
                text: "km/h"
                color: "#94a3b8"
                font.pixelSize: 24
            }
        }
    }

    // ----------------------------------
    // RIGHT PANEL — Network + System
    // ----------------------------------
    Column {
        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        width: 260
        anchors.margins: 20
        spacing: 14

        Rectangle {
            width: 240; height: 60; radius: 18
            color: "#1e3a8a"
            Text { anchors.centerIn: parent; text: "MQTT: Connected"; color: "white"; font.pixelSize: 18 }
        }

        Rectangle {
            width: 240; height: 60; radius: 18
            color: "#0f766e"
            Text { anchors.centerIn: parent; text: "CAN: Online"; color: "white"; font.pixelSize: 18 }
        }

        Rectangle {
            width: 240; height: 60; radius: 18
            color: "#334155"
            Text { anchors.centerIn: parent; text: "ROS Bag: Ready"; color: "#38bdf8"; font.pixelSize: 18 }
        }

        Rectangle {
            width: 240; height: 80; radius: 18
            color: "#1e293b"
            Column {
                anchors.centerIn: parent
                Text { text: "CPU: 34%"; color: "#38bdf8"; font.pixelSize: 18 }
                Text { text: "RAM: 48%"; color: "#22d3ee"; font.pixelSize: 18 }
            }
        }
    }

    // ----------------------------------
    // BOTTOM GRAPH PLACEHOLDER
    // ----------------------------------
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 120
        color: "#111827"
        border.color: "#1e293b"

        Text {
            text: "Speed History | Battery History | Flags"
            anchors.centerIn: parent
            color: "#475569"
            font.pixelSize: 20
        }
    }
}
