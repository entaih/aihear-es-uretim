#!/usr/bin/env bash
# GitHub Actions işi: verilen dersleri üretir (ses -> dil kontrolü -> kapak + youtube.txt + video).
# Sonuçlar cikti/<ders>/ altına; durum satırları cikti/durum.txt'ye. yayin.py yerelde, indirildikten sonra çalışır.
# Kullanım: bash uret.sh <ders_klasoru> [<ders_klasoru> ...]   (klasörler Videolar/$AKADEMI_DIL/ altında; varsayılan EN)
cd "$(dirname "$0")"
export PYTHONUNBUFFERED=1
DIL="${AKADEMI_DIL:-EN}"
mkdir -p cikti
for ders in "$@"; do
  k="Videolar/$DIL/$ders"; c="cikti/$ders"; mkdir -p "$c"
  bas=$(date +%s)
  echo "::group::$ders"
  durum=TAMAM
  if ! python -X utf8 _Kaynak/motor/ses.py "$k" > "$k/_ses_log.txt" 2>&1; then
    durum="SES HATASI"
  else
    python -X utf8 _Kaynak/motor/dil_kontrol.py "$k" > "$k/_dil_kontrol.txt" 2>&1
    if ! grep -q "^0 şüpheli" "$k/_dil_kontrol.txt"; then
      durum="DIL SORUNU"
    elif ! python -X utf8 _Kaynak/motor/uret.py "$k" > "$k/_uret_log.txt" 2>&1; then
      durum="URETIM HATASI"
    elif [ "$DIL" != EN ]; then
      # çevirisi olmayan sahne etiketleri ("ES ETİKET EKSİK") için sahne kareleri; durumu etkilemez
      python -X utf8 _Kaynak/motor/uret.py "$k" --kontrol > "$k/_kontrol_log.txt" 2>&1 || true
    fi
  fi
  # üretilen metnin özeti (gh_ortak.metin_ozeti ile aynı): metin sonradan değişirse yerelde yeniden listeye girer
  python -c "import hashlib,json,sys;v=json.load(open(sys.argv[1],encoding='utf-8'));print(hashlib.sha256(json.dumps(v,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode('utf-8')).hexdigest()[:16])" "$k/metin.json" > "$c/_metin.ozet"
  for f in "$k"/*.mp4 "$k/kapak.png" "$k/youtube.txt" "$k/zamanlama.json" "$k/_ses_log.txt" "$k/_dil_kontrol.txt" "$k/_uret_log.txt" "$k/_kontrol_log.txt"; do
    [ -f "$f" ] && cp "$f" "$c/"
  done
  echo "$durum $ders $(( ($(date +%s) - bas) / 60 )) dk" | tee -a cikti/durum.txt
  echo "::endgroup::"
done
