import QtQuick 2.15
import QtQuick.Controls 2.15

ListView {
    id: fileTreeView
    
    property string projectPath
    property alias model: fileTreeView.model
    
    signal fileClicked(string relativePath)
    
    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
        active: true
        
        background: Rectangle {
            color: "#2d2d30"
            border.color: "#3c3c3c"
            border.width: 1
        }
        
        contentItem: Rectangle {
            color: "#686868"
            radius: 3
        }
    }
    
    delegate: Rectangle {
        width: fileTreeView.width
        height: 24
        color: mouseArea.containsMouse ? "#094771" : "transparent"
        
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            
            Rectangle {
                width: 16
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: model.isDirectory ? "📁" : "📄"
                    font.pixelSize: 10
                }
            }
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: model.name
                color: "#cccccc"
                font.pixelSize: 12
                font.family: "Consolas, Monaco, monospace"
            }
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (!model.isDirectory) {
                    fileTreeView.fileClicked(model.path)
                }
            }
        }
    }
}
