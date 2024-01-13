
roc format ./src/main.roc

roc build ./src/main.roc --target system --optimize --output ./roc-out/release/rng-macos_apple_silicon-latest

roc build ./src/main.roc --target linux-x64 --optimize --output ./roc-out/release/rng-linux_x86_64-latest

roc build ./src/main.roc --target linux-arm64 --optimize --output ./roc-out/release/rng-linux_arm64-latest
