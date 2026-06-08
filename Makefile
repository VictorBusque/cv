.PHONY: build clean check hooks convert md html

build:
	@./build.sh

clean:
	@./build.sh clean

check: build
	@echo "✅ Build check passed"

convert:
	@./convert.sh all

md:
	@./convert.sh md

html:
	@./convert.sh html

hooks:
	@git config core.hooksPath .githooks
	@echo "✅ Git hooks activated (.githooks)"
