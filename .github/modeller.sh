#!/usr/bin/env bash
# Kokoro-82M modelini ve ses dosyasını indirir ve yerelde kullanılanla aynı olduğunu doğrular
# (model depoya konmaz: 325 MB, GitHub'ın 100 MB sınırının üstünde). İş akışı ~/.aihear_akademi'yi önbellekte tutar.
set -euo pipefail
d="$HOME/.aihear_akademi/kokoro"; mkdir -p "$d"
u="https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0"
cd "$d"
for f in kokoro-v1.0.onnx voices-v1.0.bin; do
  [ -f "$f" ] || curl -sSfL --retry 5 -o "$f" "$u/$f"
done
sha256sum -c - <<'EOF'
7d5df8ecf7d4b1878015a32686053fd0eebe2bc377234608764cc0ef3636a6c5  kokoro-v1.0.onnx
bca610b8308e8d99f32e6fe4197e7ec01679264efed0cac9140fe9c29f1fbf7d  voices-v1.0.bin
EOF
