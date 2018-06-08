QT += core gui

include($$PWD/../qtcontent/qtcontent.pri)

OBJECTIVE_SOURCES += main.mm
QMAKE_OBJECTIVE_CFLAGS += -fobjc-arc
LIBS += -framework AppKit

target.path = $$[QT_INSTALL_EXAMPLES]/native/macos/fullsizecontentview
INSTALLS += target
