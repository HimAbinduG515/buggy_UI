import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: "Vehicle Analytics Dashboard"
    color: "#0b1220"

    property real speedRatio: Math.min(backend.speed / 120.0, 1.0)

    Rectangle { anchors.fill: parent; color: "#0b1220" }

    /* ================= HEADER ================= */
    Rectangle {
        height: 56
        width: parent.width
        color: "#0e1626"

        Text {
            text: "Vehicle Analytics Dashboard"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 24
            color: "white"
            font.pixelSize: 20
            font.bold: true
        }

        Column {
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text { text: "SYS: " + backend.systemTime; color: "#9fbce0"; font.pixelSize: 12 }
            Text { text: "ROS: " + backend.rosTime; color: "#4cc9ff"; font.pixelSize: 12 }
        }
    }

    /* ================= BODY ================= */
    Row {
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 32
        spacing: 32

        /* ================= LEFT ================= */
        Column {
            width: 260
            spacing: 24

            /* VEHICLE */
            Rectangle {
                width: parent.width
                height: 150
                radius: 14
                color: "#0e1626"
                border.color: "#1f3550"

                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    width: parent.width - 32

                    Text { text: "VEHICLE"; color: "#4cc9ff"; font.bold: true }
                    Text { text: "Steer Angle"; color: "#9fbce0" }

                    Rectangle {
                        width: parent.width
                        height: 8
                        radius: 4
                        color: "#1a2636"

                        Rectangle {
                            width: parent.width * Math.min(Math.abs(backend.steer)/45,1)
                            height: parent.height
                            radius: 4
                            color: "#6affb3"
                        }
                    }

                    Text {
                        text: backend.steer.toFixed(1) + " °"
                        color: "white"
                        font.pixelSize: 18
                    }
                }
            }

            /* IMU */
            Rectangle {
                width: parent.width
                height: 190
                radius: 14
                color: "#0e1626"
                border.color: "#1f3550"

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Text { text: "IMU"; color: "#4cc9ff"; font.bold: true }
                    Text { text: "Ax: " + backend.ax.toFixed(2); color: "white" }
                    Text { text: "Ay: " + backend.ay.toFixed(2); color: "white" }
                    Text { text: "Az: " + backend.az.toFixed(2); color: "white" }
                    Text { text: "Yaw: " + backend.yawRate.toFixed(2); color: "#9fbce0" }
                }
            }
        }

        /* ================= CENTER SPEED ================= */
        Rectangle {
            width: 460
            height: 460
            radius: 18
            color: "#0e1626"
            border.color: "#1f3550"

            Item {
                anchors.centerIn: parent
                width: 360
                height: 360

                /* ARC + PROGRESS */
                Canvas {
                    id: gauge
                    anchors.fill: parent

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0,0,width,height)

                        var cx = width/2
                        var cy = height/2
                        var r = 150
                        var start = Math.PI * 0.75
                        var sweep = Math.PI * 1.5

                        /* base arc */
                        ctx.lineWidth = 14
                        ctx.strokeStyle = "#22364d"
                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start + sweep)
                        ctx.stroke()

                        /* active arc (green shade increases) */
                        ctx.lineWidth = 18
                        ctx.strokeStyle =
                            "rgba(106,255,179," + (0.3 + speedRatio*0.7) + ")"
                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start + sweep*speedRatio)
                        ctx.stroke()
                    }
                }

                Connections {
                    target: backend
                    function onSpeedChanged() { gauge.requestPaint() }
                }

                /* NEEDLE – FIXED */
                Item {
                    width: 360
                    height: 360
                    anchors.centerIn: parent

                    rotation: -135 + speedRatio * 270
                    transformOrigin: Item.Center

                    Behavior on rotation {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        width: 4
                        height: 135
                        radius: 2
                        color: "#ff6b6b"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -68
                    }

                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        color: "#ff6b6b"
                        anchors.centerIn: parent
                    }
                }

                /* SPEED TEXT */
                Text {
                    anchors.centerIn: parent
                    text: Math.round(backend.speed)
                    color: "#6affb3"
                    font.pixelSize: 72
                    font.bold: true
                }

                Text {
                    anchors.top: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 42
                    text: "km/h"
                    color: "#9fbce0"
                    font.pixelSize: 16
                }
            }
        }

        /* ================= RIGHT ================= */
        Column {
            width: 260
            spacing: 24

            Rectangle {
                width: parent.width
                height: 130
                radius: 14
                color: "#0e1626"
                border.color: "#1f3550"

                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    width: parent.width - 32

                    Text { text: "BATTERY"; color: "#4cc9ff"; font.bold: true }

                    Rectangle {
                        width: parent.width
                        height: 8
                        radius: 4
                        color: "#1a2636"

                        Rectangle {
                            width: parent.width * backend.battery / 100
                            height: parent.height
                            radius: 4
                            color: "#6affb3"
                        }
                    }

                    Text {
                        text: backend.battery.toFixed(1) + " %"
                        color: "#6affb3"
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 100
                radius: 14
                color: "#0e1626"
                border.color: "#1f3550"

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Text { text: "STATE"; color: "#4cc9ff"; font.bold: true }
                    Text {
                        text: backend.speed < 1 ? "Idle" : "Moving"
                        color: "#9fbce0"
                        font.pixelSize: 16
                    }
                }
            }
        }
    }
}
