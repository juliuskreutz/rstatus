build:
	cargo build --release

install:
	cp -f target/release/rstatus /usr/local/bin/

uninstall:
	rm -f /usr/local/bin/rstatus

clean:
    cargo clean
