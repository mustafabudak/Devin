QT += quick network

CONFIG += c++17

TARGET = qt-ai-prompt-manager

SOURCES += \
    main.cpp \
    promptmanager.cpp \
    projectcomparator.cpp \
    compilererrorprocessor.cpp

HEADERS += \
    promptmanager.h \
    projectcomparator.h \
    compilererrorprocessor.h

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Platform-specific configurations
macx {
    # macOS specific settings
    CONFIG += app_bundle
    QMAKE_INFO_PLIST = Info.plist
    QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.14
    
    # Apple Silicon (ARM64) and Intel (x86_64) support
    contains(QT_ARCH, arm64) {
        # Apple Silicon M1/M2 specific settings
        QMAKE_APPLE_DEVICE_ARCHS = arm64
        message("Building for Apple Silicon (ARM64)")
    } else:contains(QT_ARCH, x86_64) {
        # Intel Mac specific settings
        QMAKE_APPLE_DEVICE_ARCHS = x86_64
        message("Building for Intel Mac (x86_64)")
    } else {
        # Universal binary support (both architectures)
        QMAKE_APPLE_DEVICE_ARCHS = arm64 x86_64
        message("Building Universal Binary (ARM64 + x86_64)")
    }
    
    # macOS deployment path
    target.path = /Applications
    INSTALLS += target
    
    # Bundle identifier
    QMAKE_TARGET_BUNDLE_PREFIX = com.mustafabudak
    
    # Icon (if you have one)
    # ICON = qt-ai-prompt-manager.icns
    
    # Minimum macOS version for Apple Silicon compatibility
    QMAKE_MACOSX_DEPLOYMENT_TARGET = 11.0
}

# Linux specific settings
linux {
    # Linux deployment path
    target.path = /usr/local/bin
    INSTALLS += target
    
    # Desktop file installation (optional)
    desktop.files = qt-ai-prompt-manager.desktop
    desktop.path = /usr/share/applications
    # INSTALLS += desktop
}

# Windows specific settings
win32 {
    # Windows deployment path
    target.path = C:/Program Files/QtAIPromptManager
    INSTALLS += target
    
    # Windows icon (if you have one)
    # RC_ICONS = qt-ai-prompt-manager.ico
}

# Default rules for deployment (fallback)
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android:!macx: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
