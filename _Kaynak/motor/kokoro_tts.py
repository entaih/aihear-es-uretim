"""Kokoro-82M (yerel, Apache-2.0) seslendirme işçisi: İspanyolca. kokoro-onnx kurulu sanal ortamda çalışır.

Kullanım: <kenv>\\Scripts\\python.exe -X utf8 kokoro_tts.py is.json
is.json: [{"metin": "...", "wav": "çıkış yolu"}, ...]
Ayarlar ortam değişkeniyle gelir (ses.py verir): AKADEMI_KOKORO_MODEL, AKADEMI_KOKORO_VOICES, AKADEMI_KOKORO_SES (ef_dora),
AKADEMI_KOKORO_HIZ (0.95), AKADEMI_KOKORO_LANG (es-419: Latin Amerika, seseo). Model bir kez yüklenir.
Kokoro kelime zamanı vermez; ses.py zamanları harf sayısına göre orantılı dağıtır (Piper gibi).
"""
import json
import os
import sys

import soundfile as sf
from kokoro_onnx import Kokoro


def main(is_dosyasi):
    isler = json.load(open(is_dosyasi, encoding='utf-8'))
    k = Kokoro(os.environ['AKADEMI_KOKORO_MODEL'], os.environ['AKADEMI_KOKORO_VOICES'])
    ses = os.environ.get('AKADEMI_KOKORO_SES', 'ef_dora')
    hiz = float(os.environ.get('AKADEMI_KOKORO_HIZ', '0.95') or 0.95)
    dil = os.environ.get('AKADEMI_KOKORO_LANG', 'es-419')
    for i, j in enumerate(isler, 1):
        x, sr = k.create(j['metin'], voice=ses, speed=hiz, lang=dil)
        sf.write(j['wav'], x, sr, subtype='PCM_16')
        if i % 20 == 0:
            print(f'{i}/{len(isler)}', flush=True)
    print(f'tamam: {len(isler)} cümle')


if __name__ == '__main__':
    main(sys.argv[1])
