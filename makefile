
clean:
	swift package clean

deploy:
	swift build -c release
	# cp -f .build/release/cliOTG /usr/local/bin/cliOTG

run:
	swift run

test:
	swift test

format: 
	swift-format Sources --recursive -i
	swift-format Tests --recursive -i