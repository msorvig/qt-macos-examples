TEMPLATE = app
QT += quick

# hellotriangle example code
QMAKE_OBJECTIVE_CFLAGS += -fmodules -fcxx-modules
INCLUDEDIRS += hellotriangle
OBJECTIVE_SOURCES += hellotriangle/AAPLRenderer.mm

# hellotriangle example shaders
hellotriangleshaders_air.target = hellotriangleshaders.air
hellotriangleshaders_air.commands = xcrun -sdk macosx metal hellotriangle/AAPLShaders.metal -o hellotriangleshaders.air
hellotriangleshaders_lib.target = hellotriangleshaders.metallib
hellotriangleshaders_lib.commands = xcrun -sdk macosx metallib hellotriangleshaders.air -o hellotriangleshaders.metallib
hellotriangleshaders_lib.depends = hellotriangleshaders_air
QMAKE_EXTRA_TARGETS += hellotriangleshaders_air hellotriangleshaders_lib
rcc.depends += $$hellotriangleshaders_lib.target
RESOURCES += hellotriangleshaders.qrc

# Qt Metal QWindow integration
HEADERS += metalwindow.h
SOURCES += metalwindow.mm

# Qt Quick QWindow controller
QT += quick-private
HEADERS += qquickwindowcontroller.h
SOURCES += qquickwindowcontroller.cpp

# Qt main
SOURCES += main.cpp
RESOURCES += main.qml
