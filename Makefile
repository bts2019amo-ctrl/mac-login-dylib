TARGET := build/libMacLogin.dylib

.PHONY: all clean

all: $(TARGET)

$(TARGET): src/MacLogin.m
	mkdir -p build
	clang -dynamiclib -framework Cocoa -fobjc-arc -fvisibility=hidden -mmacosx-version-min=12.0 -o $@ $<

clean:
	rm -rf build MacLogin-dylib-macos.zip
