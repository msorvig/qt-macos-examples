import QtQuick 2.0
import WindowController 1.0

Rectangle {
    id: page
    color: "lightgray"

    Text {
        id: helloText
        y : 40
        text: "Qt Quick with Metal overlay window"
        anchors.horizontalCenter: page.horizontalCenter
        font.pointSize: 24; font.bold: true
    }
    
    WindowController {
        controlledWindow: metalWindow
        y : 80
        width : 640
        height : 480
        anchors.horizontalCenter: page.horizontalCenter
    }
    
}
