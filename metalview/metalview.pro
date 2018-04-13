TEMPLATE = app

# hellotriangle example code
QMAKE_OBJECTIVE_CFLAGS += -fmodules -fcxx-modules
INCLUDEDIRS += hellotriangle
OBJECTIVE_SOURCES += hellotriangle/AAPLRenderer.m

# hellotriangle example shaders
hellotriangleshaders_air.target = hellotriangleshaders.air
hellotriangleshaders_air.commands = xcrun -sdk macosx metal $$PWD/hellotriangle/AAPLShaders.metal -o $$PWD/hellotriangleshaders.air
hellotriangleshaders_lib.target = hellotriangleshaders.metallib
hellotriangleshaders_lib.commands = xcrun -sdk macosx metallib $$PWD/hellotriangleshaders.air -o $$PWD/hellotriangleshaders.metallib
hellotriangleshaders_lib.depends = hellotriangleshaders_air
QMAKE_EXTRA_TARGETS += hellotriangleshaders_air hellotriangleshaders_lib
rcc.depends += $$hellotriangleshaders_lib.target
RESOURCES += hellotriangleshaders.qrc

# Qt main
SOURCES += main.mm
