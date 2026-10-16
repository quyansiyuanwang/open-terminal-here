.PHONY: install uninstall lint

install:
	./install.sh

uninstall:
	./uninstall.sh

lint:
	shellcheck install.sh uninstall.sh
