.PHONY: build clean check hooks

build:
	@./build.sh

clean:
	@./build.sh clean

check: build
	@echo "✅ Build check passed"

hooks:
	@git config core.hooksPath .githooks
	@echo "✅ Git hooks activated (.githooks)"
