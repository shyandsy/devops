# OpenResty Makefile
# Usage: make openresty install|uninstall

OPENRESTY_VERSION = 1.27.1.2
OPENRESTY_URL = https://openresty.org/download/openresty-$(OPENRESTY_VERSION).tar.gz
OPENRESTY_ARCHIVE = openresty-$(OPENRESTY_VERSION).tar.gz
OPENRESTY_DIR = openresty-$(OPENRESTY_VERSION)
INSTALL_PREFIX = /opt/openresty

.PHONY: install uninstall clean help deps check-deps

help:
	@echo "OpenResty Management"
	@echo "Available targets:"
	@echo "  deps      - Install system dependencies for OpenResty"
	@echo "  check-deps- Check if required dependencies are installed"
	@echo "  install   - Download, compile and install OpenResty $(OPENRESTY_VERSION)"
	@echo "  uninstall - Remove OpenResty installation"
	@echo "  clean     - Clean downloaded files and build directory"
	@echo "  help      - Show this help message"

deps:
	@echo "Installing OpenResty dependencies..."
	@if command -v apt-get >/dev/null 2>&1; then \
		echo "Detected Debian/Ubuntu system, installing dependencies with apt-get..."; \
		sudo apt-get update && \
		sudo apt-get install -y libpcre3-dev libssl-dev perl make build-essential curl; \
	elif command -v yum >/dev/null 2>&1; then \
		echo "Detected RedHat/CentOS system, installing dependencies with yum..."; \
		sudo yum install -y pcre-devel openssl-devel gcc curl zlib-devel; \
	elif command -v dnf >/dev/null 2>&1; then \
		echo "Detected Fedora system, installing dependencies with dnf..."; \
		sudo dnf install -y pcre-devel openssl-devel gcc curl zlib-devel; \
	elif command -v brew >/dev/null 2>&1; then \
		echo "Detected macOS with Homebrew, installing dependencies..."; \
		brew install pcre openssl curl; \
	else \
		echo "Unsupported package manager. Please install the following dependencies manually:"; \
		echo "- libpcre development headers"; \
		echo "- libssl development headers"; \
		echo "- perl 5.6.1+"; \
		echo "- make and build tools"; \
		echo "- curl"; \
		echo ""; \
		echo "For Debian/Ubuntu: apt-get install libpcre3-dev libssl-dev perl make build-essential curl"; \
		echo "For RedHat/CentOS: yum install pcre-devel openssl-devel gcc curl zlib-devel"; \
		echo "For Fedora: dnf install pcre-devel openssl-devel gcc curl zlib-devel"; \
		exit 1; \
	fi
	@echo "Dependencies installed successfully!"

check-deps:
	@echo "Checking OpenResty dependencies..."
	@missing_deps=0; \
	if ! command -v perl >/dev/null 2>&1; then \
		echo "❌ perl is not installed"; \
		missing_deps=1; \
	else \
		echo "✅ perl is installed"; \
	fi; \
	if ! command -v make >/dev/null 2>&1; then \
		echo "❌ make is not installed"; \
		missing_deps=1; \
	else \
		echo "✅ make is installed"; \
	fi; \
	if ! command -v curl >/dev/null 2>&1; then \
		echo "❌ curl is not installed"; \
		missing_deps=1; \
	else \
		echo "✅ curl is installed"; \
	fi; \
	if ! command -v gcc >/dev/null 2>&1 && ! command -v clang >/dev/null 2>&1; then \
		echo "❌ C compiler (gcc or clang) is not installed"; \
		missing_deps=1; \
	else \
		echo "✅ C compiler is available"; \
	fi; \
	if [ "$$missing_deps" -eq 1 ]; then \
		echo ""; \
		echo "Some dependencies are missing. Run 'make openresty deps' to install them."; \
		exit 1; \
	else \
		echo ""; \
		echo "✅ All dependencies are satisfied!"; \
	fi

install: deps $(OPENRESTY_ARCHIVE)
	@echo "Installing OpenResty $(OPENRESTY_VERSION)..."
	# Extract the archive
	tar -xvf $(OPENRESTY_ARCHIVE)
	# Enter the directory and configure, build, install
	cd $(OPENRESTY_DIR) && \
	./configure --prefix=/opt/openresty \
	            --with-pcre-jit \
	            --with-ipv6 \
	            --without-http_redis2_module \
	            --with-http_iconv_module \
	            --with-http_postgres_module \
	            -j8 && \
	make -j2 && \
	sudo make install
	# Clean up source files after successful installation
	@echo "Cleaning up source files..."
	rm -rf $(OPENRESTY_DIR)
	rm -f $(OPENRESTY_ARCHIVE)
	@echo "OpenResty $(OPENRESTY_VERSION) installed successfully!"
	@echo "Installation path: $(INSTALL_PREFIX)"
	@echo ""
	@echo "To use OpenResty commands, add the following line to your ~/.bashrc or ~/.bash_profile:"
	@echo "export PATH=/opt/openresty/bin:/opt/openresty/nginx/sbin:\$$PATH"
	@echo ""
	@echo "Then run: source ~/.bashrc (or source ~/.bash_profile)"

$(OPENRESTY_ARCHIVE):
	@echo "Downloading OpenResty $(OPENRESTY_VERSION)..."
	curl -L -O $(OPENRESTY_URL)

uninstall:
	@echo "Uninstalling OpenResty..."
	@echo "This will remove:"
	@echo "  - OpenResty installation directory: $(INSTALL_PREFIX)"
	@echo "  - All OpenResty binaries and libraries"
	@echo "  - Configuration files (if not modified)"
	@echo ""
	@read -p "Are you sure you want to uninstall OpenResty? (y/N): " confirm && \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		if [ -d "$(INSTALL_PREFIX)" ]; then \
			echo "Removing OpenResty installation..."; \
			sudo rm -rf $(INSTALL_PREFIX); \
			echo "OpenResty uninstalled successfully!"; \
			echo ""; \
			echo "Don't forget to remove the PATH export from your ~/.bashrc or ~/.bash_profile:"; \
			echo "export PATH=/opt/openresty/bin:/opt/openresty/nginx/sbin:\$$PATH"; \
		else \
			echo "OpenResty installation not found at $(INSTALL_PREFIX)"; \
		fi \
	else \
		echo "Uninstall cancelled."; \
	fi

clean:
	@echo "Cleaning OpenResty build files..."
	@if [ -f "$(OPENRESTY_ARCHIVE)" ]; then \
		rm -f $(OPENRESTY_ARCHIVE); \
		echo "Removed $(OPENRESTY_ARCHIVE)"; \
	fi
	@if [ -d "$(OPENRESTY_DIR)" ]; then \
		rm -rf $(OPENRESTY_DIR); \
		echo "Removed $(OPENRESTY_DIR)/"; \
	fi
	@echo "Clean completed!"

# Default target
all: help
