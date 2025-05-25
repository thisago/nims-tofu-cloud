##
# Nim's Tofu Cloud
#
# @file
# @version 0.1

HURL_VARS_FILE := tests/.hurl-variables

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  help: Show this help message"
	@echo "  test: Run all tests"

test:
	@echo "Running tests..." && \
	hurl --variables-file $(HURL_VARS_FILE) tests/*.hurl

# end
