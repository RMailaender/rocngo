
roc format ./src/main.roc

roc build ./src/main.roc --output ./roc-out/release/rg_vanilla
roc build ./src/main.roc --output ./roc-out/release/rg --optimize
roc build ./src/main.roc --output ./roc-out/release/rg_size --opt-size