OBJECTIVE_SOURCES += \
    main.mm

QT += widgets
QMAKE_OBJECTIVE_CFLAGS += -fobjc-arc
LIBS += -framework AppKit

# install
target.path = $$[QT_INSTALL_EXAMPLES]/native/macos/touchbar
INSTALLS += target
