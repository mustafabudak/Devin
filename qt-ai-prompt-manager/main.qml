import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import PromptManager 1.0
import ProjectComparator 1.0
import CompilerErrorProcessor 1.0

ApplicationWindow {
    id: window
    width: 1400
    height: 900
    visible: true
    title: "AI Prompt Manager"
    color: "#1e1e1e"

    PromptManager {
        id: promptManager
        onAiResponseReceived: {
            aiResponseArea.text = response
            tabBar.currentIndex = 3 // Switch to AI Response tab
        }
        onErrorOccurred: {
            errorDialog.text = error
            errorDialog.open()
        }
    }

    ProjectComparator {
        id: projectComparator
        onComparisonPromptGenerated: {
            promptManager.currentPrompt = prompt
            promptManager.simplifyPrompt()
            tabBar.currentIndex = 0 // Switch to Prompt tab
        }
        onErrorOccurred: {
            errorDialog.text = error
            errorDialog.open()
        }
    }

    CompilerErrorProcessor {
        id: errorProcessor
        onPromptGenerated: {
            promptManager.currentPrompt = prompt
            promptManager.simplifyPrompt()
            tabBar.currentIndex = 0 // Switch to Prompt tab
        }
        onErrorOccurred: {
            errorDialog.text = error
            errorDialog.open()
        }
    }

    header: TabBar {
        id: tabBar
        background: Rectangle {
            color: "#2d2d30"
            border.color: "#3c3c3c"
            border.width: 1
        }
        
        TabButton {
            text: "Prompt Manager"
            background: Rectangle {
                color: parent.checked ? "#094771" : "#2d2d30"
                border.color: "#3c3c3c"
                border.width: 1
            }
            contentItem: Text {
                text: parent.text
                color: "#cccccc"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        TabButton {
            text: "Compiler Errors"
            background: Rectangle {
                color: parent.checked ? "#094771" : "#2d2d30"
                border.color: "#3c3c3c"
                border.width: 1
            }
            contentItem: Text {
                text: parent.text
                color: "#cccccc"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        TabButton {
            text: "Visual Diff Viewer"
            background: Rectangle {
                color: parent.checked ? "#094771" : "#2d2d30"
                border.color: "#3c3c3c"
                border.width: 1
            }
            contentItem: Text {
                text: parent.text
                color: "#cccccc"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        TabButton {
            text: "AI Response"
            background: Rectangle {
                color: parent.checked ? "#094771" : "#2d2d30"
                border.color: "#3c3c3c"
                border.width: 1
            }
            contentItem: Text {
                text: parent.text
                color: "#cccccc"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        // Prompt Manager Tab
        Item {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20

                Label {
                    text: "Original Prompt:"
                    font.bold: true
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    TextArea {
                        id: originalPromptArea
                        wrapMode: TextArea.Wrap
                        placeholderText: "Enter your prompt here or load from file..."

                        Connections {
                            target: promptManager
                            function onCurrentPromptChanged() {
                                if (originalPromptArea.text !== promptManager.currentPrompt) {
                                    var cursorPos = originalPromptArea.cursorPosition
                                    originalPromptArea.text = promptManager.currentPrompt
                                    originalPromptArea.cursorPosition = cursorPos
                                }
                            }
                        }

                        onTextChanged: {
                            if (promptManager.currentPrompt !== text) {
                                promptManager.currentPrompt = text
                            }
                        }
                    }
                }

                RowLayout {
                    Button {
                        text: "Load from File"
                        onClicked: loadPromptDialog.open()
                    }
                    Button {
                        text: "Simplify Prompt"
                        onClicked: promptManager.simplifyPrompt()
                    }
                    Button {
                        text: "Save Simplified"
                        enabled: promptManager.simplifiedPrompt.length > 0
                        onClicked: savePromptDialog.open()
                    }
                }

                Label {
                    text: "Simplified Prompt:"
                    font.bold: true
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    TextArea {
                        id: simplifiedPromptArea
                        text: promptManager.simplifiedPrompt
                        readOnly: true
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                    }
                }

                GroupBox {
                    title: "Send to AI"
                    Layout.fillWidth: true

                    ColumnLayout {
                        anchors.fill: parent

                        RowLayout {
                            Label {
                                text: "Service:"
                            }
                            ComboBox {
                                id: aiServiceCombo
                                model: ["OpenAI", "Claude"]
                                Layout.preferredWidth: 150
                            }
                            Label {
                                text: "API Key:"
                            }
                            TextField {
                                id: apiKeyField
                                echoMode: TextInput.Password
                                Layout.fillWidth: true
                                placeholderText: "Enter your API key..."
                            }
                        }

                        Button {
                            text: "Send to AI"
                            enabled: promptManager.simplifiedPrompt.length > 0 && apiKeyField.text.length > 0
                            onClicked: {
                                promptManager.sendToAI(aiServiceCombo.currentText, apiKeyField.text)
                            }
                        }
                    }
                }
            }
        }

        // Compiler Errors Tab
        Item {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20

                Label {
                    text: "Compiler Error Output:"
                    font.bold: true
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    TextArea {
                        id: errorTextArea
                        wrapMode: TextArea.Wrap
                        placeholderText: "Paste compiler error output here or load from file..."
                        font.family: "Consolas, Monaco, monospace"

                        Connections {
                            target: errorProcessor
                            function onErrorTextChanged() {
                                if (errorTextArea.text !== errorProcessor.errorText) {
                                    var cursorPos = errorTextArea.cursorPosition
                                    errorTextArea.text = errorProcessor.errorText
                                    errorTextArea.cursorPosition = cursorPos
                                }
                            }
                        }

                        onTextChanged: {
                            if (errorProcessor.errorText !== text) {
                                errorProcessor.errorText = text
                            }
                        }
                    }
                }

                RowLayout {
                    Button {
                        text: "Load Error File"
                        onClicked: loadErrorDialog.open()
                    }
                    Button {
                        text: "Process Errors"
                        onClicked: errorProcessor.processErrors()
                    }
                    Button {
                        text: "Generate Fix Prompt"
                        onClicked: errorProcessor.generateFixPrompt()
                    }
                }

                Label {
                    text: "Generated Prompt:"
                    font.bold: true
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    TextArea {
                        text: errorProcessor.processedPrompt
                        readOnly: true
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                    }
                }
            }
        }

        // Project Compare Tab
        Rectangle {
            color: "#1e1e1e"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#2d2d30"
                    border.color: "#3c3c3c"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Label {
                            text: "Project 1:"
                            color: "#cccccc"
                            font.pixelSize: 12
                        }
                        TextField {
                            id: project1Field
                            Layout.preferredWidth: 200
                            placeholderText: "Path to first project..."
                            color: "#cccccc"
                            background: Rectangle {
                                color: "#3c3c3c"
                                border.color: "#6c6c6c"
                                border.width: 1
                            }
                        }
                        Button {
                            text: "Browse"
                            background: Rectangle {
                                color: "#0e639c"
                                border.color: "#1177bb"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                project1Dialog.folder = "file://" + project1Field.text
                                project1Dialog.open()
                            }
                        }

                        Label {
                            text: "Project 2:"
                            color: "#cccccc"
                            font.pixelSize: 12
                        }
                        TextField {
                            id: project2Field
                            Layout.preferredWidth: 200
                            placeholderText: "Path to second project..."
                            color: "#cccccc"
                            background: Rectangle {
                                color: "#3c3c3c"
                                border.color: "#6c6c6c"
                                border.width: 1
                            }
                        }
                        Button {
                            text: "Browse"
                            background: Rectangle {
                                color: "#0e639c"
                                border.color: "#1177bb"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                project2Dialog.folder = "file://" + project2Field.text
                                project2Dialog.open()
                            }
                        }

                        Button {
                            text: "Compare Projects"
                            enabled: project1Field.text.length > 0 && project2Field.text.length > 0
                            background: Rectangle {
                                color: parent.enabled ? "#0e639c" : "#404040"
                                border.color: parent.enabled ? "#1177bb" : "#606060"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "#ffffff" : "#808080"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                projectComparator.compareProjects(project1Field.text, project2Field.text)
                            }
                        }

                        Button {
                            text: "Generate Analysis Prompt"
                            enabled: projectComparator.comparisonResult.length > 0
                            background: Rectangle {
                                color: parent.enabled ? "#0e639c" : "#404040"
                                border.color: parent.enabled ? "#1177bb" : "#606060"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "#ffffff" : "#808080"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: projectComparator.generateComparisonPrompt()
                        }
                    }
                }

                DiffViewer {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    fileTree1Model: projectComparator.fileTree1
                    fileTree2Model: projectComparator.fileTree2
                    currentFile1Content: projectComparator.currentFile1Content
                    currentFile2Content: projectComparator.currentFile2Content
                    diffLines: projectComparator.diffLines
                    
                    onFileSelected: {
                        projectComparator.selectFile(relativePath)
                    }
                }
            }
        }

        // AI Response Tab
        Item {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20

                Label {
                    text: "AI Response:"
                    font.bold: true
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    TextArea {
                        id: aiResponseArea
                        readOnly: true
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                        placeholderText: "AI responses will appear here..."
                    }
                }

                Button {
                    text: "Copy Response"
                    enabled: aiResponseArea.text.length > 0
                    onClicked: {
                        aiResponseArea.selectAll()
                        aiResponseArea.copy()
                        aiResponseArea.deselect()
                    }
                }
            }
        }
    }

    // File Dialogs
    FileDialog {
        id: loadPromptDialog
        title: "Load Prompt File"
        nameFilters: ["Text files (*.txt)", "All files (*)"]
        onAccepted: {
            promptManager.loadPromptFromFile(file.toString().replace("file://", ""))
        }
    }

    FileDialog {
        id: savePromptDialog
        title: "Save Simplified Prompt"
        nameFilters: ["Text files (*.txt)", "All files (*)"]
        fileMode: FileDialog.SaveFile
        onAccepted: {
            promptManager.savePromptToFile(file.toString().replace("file://", ""))
        }
    }

    FileDialog {
        id: loadErrorDialog
        title: "Load Error File"
        nameFilters: ["Text files (*.txt)", "Log files (*.log)", "All files (*)"]
        onAccepted: {
            errorProcessor.loadErrorsFromFile(file.toString().replace("file://", ""))
        }
    }

    FolderDialog {
        id: project1Dialog
        title: "Select First Project Directory"
        onAccepted: {
            project1Field.text = folder.toString().replace("file://", "")
        }
    }

    FolderDialog {
        id: project2Dialog
        title: "Select Second Project Directory"
        onAccepted: {
            project2Field.text = folder.toString().replace("file://", "")
        }
    }

    // Error Dialog
    Popup {
        id: errorDialog
        anchors.centerIn: parent
        width: 400
        height: 200
        modal: true
        property alias text: errorLabel.text
        
        Rectangle {
            anchors.fill: parent
            color: "white"
            border.color: "gray"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Label {
                    text: "Error"
                    font.bold: true
                    font.pixelSize: 16
                }
                
                Label {
                    id: errorLabel
                    wrapMode: Label.Wrap
                    width: parent.width
                }
                
                Button {
                    text: "OK"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: errorDialog.close()
                }
            }
        }
    }
}
