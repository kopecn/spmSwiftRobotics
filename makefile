

clean:
	swift package clean

build:
	swift build
test:
	swift test

all: clean build test
run:
	swift run
