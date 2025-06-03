import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: codeEditor
    color: "#1e1e1e"
    
    property string content: ""
    property bool showLineNumbers: true
    property bool readOnly: true
    property string side: "left"
    property var diffLines: []
    
    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.margins: 4
        
        ScrollBar.horizontal: ScrollBar {
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
        
        Flickable {
            id: flickable
            contentWidth: Math.max(lineNumberColumn.width + codeColumn.width, scrollView.width)
            contentHeight: codeColumn.height
            
            Row {
                id: contentRow
                
                Rectangle {
                    id: lineNumberColumn
                    width: showLineNumbers ? 50 : 0
                    height: codeColumn.height
                    color: "#252526"
                    border.color: "#3c3c3c"
                    border.width: showLineNumbers ? 1 : 0
                    visible: showLineNumbers
                    
                    Column {
                        anchors.top: parent.top
                        anchors.topMargin: 4
                        
                        Repeater {
                            model: diffLines.length > 0 ? diffLines : (content.split('\n').length)
                            
                            Rectangle {
                                width: lineNumberColumn.width
                                height: 18
                                color: {
                                    if (diffLines.length > 0 && index < diffLines.length) {
                                        var lineData = diffLines[index]
                                        if (lineData.type === "added") return "#1e3a1e"
                                        if (lineData.type === "removed") return "#3a1e1e"
                                        if (lineData.type === "modified") return "#3a3a1e"
                                    }
                                    return "transparent"
                                }
                                
                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: index + 1
                                    color: "#858585"
                                    font.pixelSize: 11
                                    font.family: "Consolas, Monaco, monospace"
                                }
                            }
                        }
                    }
                }
                
                Rectangle {
                    id: codeColumn
                    width: Math.max(codeText.contentWidth + 16, scrollView.width - lineNumberColumn.width)
                    height: Math.max(codeText.contentHeight + 8, scrollView.height)
                    color: "#1e1e1e"
                    
                    Column {
                        id: codeText
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.topMargin: 4
                        anchors.leftMargin: 8
                        
                        property real contentWidth: 0
                        property real contentHeight: children.length * 18
                        
                        Repeater {
                            model: diffLines.length > 0 ? diffLines : content.split('\n')
                            
                            Rectangle {
                                width: Math.max(lineText.contentWidth + 16, 200)
                                height: 18
                                color: {
                                    if (diffLines.length > 0 && typeof modelData === 'object') {
                                        if (modelData.type === "added") return "#1e3a1e"
                                        if (modelData.type === "removed") return "#3a1e1e"
                                        if (modelData.type === "modified") return "#3a3a1e"
                                    }
                                    return "transparent"
                                }
                                
                                Component.onCompleted: {
                                    if (width > codeText.contentWidth) {
                                        codeText.contentWidth = width
                                    }
                                }
                                
                                Text {
                                    id: lineText
                                    anchors.left: parent.left
                                    anchors.leftMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: {
                                        if (diffLines.length > 0 && typeof modelData === 'object') {
                                            return side === "left" ? modelData.content1 : modelData.content2
                                        }
                                        return typeof modelData === 'string' ? modelData : ''
                                    }
                                    color: getSyntaxColor(text)
                                    font.pixelSize: 12
                                    font.family: "Consolas, Monaco, monospace"
                                    wrapMode: Text.NoWrap
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    function getSyntaxColor(text) {
        if (text.match(/^\s*\/\/|^\s*\/\*|^\s*\*/)) return "#6a9955"
        if (text.match(/^\s*#/)) return "#9cdcfe"
        if (text.match(/\b(class|struct|enum|namespace|public|private|protected|virtual|static|const|void|int|char|bool|float|double|string|QString|QObject)\b/)) return "#569cd6"
        if (text.match(/\b(if|else|for|while|do|switch|case|break|continue|return|try|catch|throw|new|delete)\b/)) return "#c586c0"
        if (text.match(/\b(true|false|null|nullptr)\b/)) return "#569cd6"
        if (text.match(/"[^"]*"/)) return "#ce9178"
        if (text.match(/\b\d+\b/)) return "#b5cea8"
        return "#cccccc"
    }
}
