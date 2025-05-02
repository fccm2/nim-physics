all: demo.js
%.js: %.nim
	nim js -d:release --path:../src/ $<
