import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import PromptManager 1.0
import ProjectComparator 1.0
import CompilerErrorProcessor 1.0

ApplicationWindow {
    id: window
    width: 1200
    height: 800
    visible: true
    title: "AI Prompt Manager"

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
        TabButton {
            text: "Prompt Manager"
        }
        TabButton {
            text: "Compiler Errors"
        }
        TabButton {
            text: "Project Compare"
        }
        TabButton {
            text: "AI Response"
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
                        text: promptManager.currentPrompt
                        onTextChanged: promptManager.currentPrompt = text
                        wrapMode: TextArea.Wrap
                        placeholderText: "Enter your prompt here or load from file..."
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
                        text: errorProcessor.errorText
                        onTextChanged: errorProcessor.errorText = text
                        wrapMode: TextArea.Wrap
                        placeholderText: "Paste compiler error output here or load from file..."
                        font.family: "Consolas, Monaco, monospace"
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
        Item {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20

                Label {
                    text: "Project Comparison:"
                    font.bold: true
                }

                RowLayout {
                    Label {
                        text: "Project 1:"
                    }
                    TextField {
                        id: project1Field
                        Layout.fillWidth: true
                        placeholderText: "Path to first project..."
                    }
                    Button {
                        text: "Browse"
                        onClicked: {
                            project1Dialog.folder = "file://" + project1Field.text
                            project1Dialog.open()
                        }
                    }
                }

                RowLayout {
                    Label {
                        text: "Project 2:"
                    }
                    TextField {
                        id: project2Field
                        Layout.fillWidth: true
                        placeholderText: "Path to second project..."
                    }
                    Button {
                        text: "Browse"
                        onClicked: {
                            project2Dialog.folder = "file://" + project2Field.text
                            project2Dialog.open()
                        }
                    }
                }

                RowLayout {
                    Button {
                        text: "Compare Projects"
                        enabled: project1Field.text.length > 0 && project2Field.text.length > 0
                        onClicked: {
                            projectComparator.compareProjects(project1Field.text, project2Field.text)
                        }
                    }
                    Button {
                        text: "Generate Analysis Prompt"
                        enabled: projectComparator.comparisonResult.length > 0
                        onClicked: projectComparator.generateComparisonPrompt()
                    }
                }

                Label {
                    text: "Comparison Results:"
                    font.bold: true
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    TextArea {
                        text: projectComparator.comparisonResult
                        readOnly: true
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                        font.family: "Consolas, Monaco, monospace"
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
