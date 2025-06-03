import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: diffViewer
    color: "#1e1e1e"
    
    property alias project1Path: fileTree1.projectPath
    property alias project2Path: fileTree2.projectPath
    property alias fileTree1Model: fileTree1.model
    property alias fileTree2Model: fileTree2.model
    property alias currentFile1Content: codeEditor1.content
    property alias currentFile2Content: codeEditor2.content
    property alias diffLines: codeEditor1.diffLines
    
    signal fileSelected(string relativePath)
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            color: "#252526"
            border.color: "#3c3c3c"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                
                Label {
                    text: "Project Files"
                    color: "#cccccc"
                    font.bold: true
                    font.pixelSize: 14
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#1e1e1e"
                    border.color: "#3c3c3c"
                    border.width: 1
                    
                    FileTreeView {
                        id: fileTree1
                        anchors.fill: parent
                        anchors.margins: 4
                        onFileClicked: diffViewer.fileSelected(relativePath)
                    }
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#1e1e1e"
            
            RowLayout {
                anchors.fill: parent
                spacing: 1
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#1e1e1e"
                    border.color: "#3c3c3c"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: "#2d2d30"
                            border.color: "#3c3c3c"
                            border.width: 1
                            
                            Label {
                                anchors.centerIn: parent
                                text: "Project 1"
                                color: "#cccccc"
                                font.pixelSize: 12
                            }
                        }
                        
                        CodeEditor {
                            id: codeEditor1
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            showLineNumbers: true
                            readOnly: true
                            side: "left"
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#1e1e1e"
                    border.color: "#3c3c3c"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: "#2d2d30"
                            border.color: "#3c3c3c"
                            border.width: 1
                            
                            Label {
                                anchors.centerIn: parent
                                text: "Project 2"
                                color: "#cccccc"
                                font.pixelSize: 12
                            }
                        }
                        
                        CodeEditor {
                            id: codeEditor2
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            showLineNumbers: true
                            readOnly: true
                            side: "right"
                        }
                    }
                }
            }
        }
    }
}
