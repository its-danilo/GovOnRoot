#!/usr/bin/env bash
# Testa impressões (fingerprints) do Play Integrity Fork até achar uma que dê
# MEETS_DEVICE_INTEGRITY, usando o app SPIC no celular.
#
# Uso:  ./testar-impressoes.sh <pasta do PIFS> [quantidade=40]
# Requisitos: adb conectado (só um aparelho, ou defina ADB_SERIAL), root,
#             módulo Play Integrity Fork instalado, app SPIC instalado,
#             tela do celular DESBLOQUEADA e ligada durante o teste.
set -u

PIFS=${1:?uso: $0 <pasta do PIFS> [quantidade]}
MAX=${2:-40}
ADB=(adb ${ADB_SERIAL:+-s "$ADB_SERIAL"})
MOD=/data/adb/modules/playintegrityfix
SPIC=com.henrikherzig.playintegritychecker
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

sh_root() { "${ADB[@]}" shell "su -c '$1'"; }

ui_dump() {
  "${ADB[@]}" shell 'uiautomator dump /sdcard/govonroot-ui.xml >/dev/null 2>&1; cat /sdcard/govonroot-ui.xml'
}

# toca no N-ésimo elemento (1 = primeiro) cujo texto é exatamente $1
tap_text() {
  local want=$1 nth=${2:-1}
  local xy
  xy=$(ui_dump | python3 -c '
import re, sys
want, nth = sys.argv[1], int(sys.argv[2])
hits = re.findall(r"text=\"([^\"]*)\"[^>]*?bounds=\"\[(\d+),(\d+)\]\[(\d+),(\d+)\]\"", sys.stdin.read())
hits = [h for h in hits if h[0] == want]
if len(hits) >= nth:
    _, x1, y1, x2, y2 = hits[nth - 1]
    print((int(x1) + int(x2)) // 2, (int(y1) + int(y2)) // 2)
' "$want" "$nth")
  [ -n "$xy" ] && "${ADB[@]}" shell input tap $xy
}

# lista candidatas: aparelhos lançados com API 21-25, build user/release-keys
python3 - "$PIFS" "$MAX" > "$TMP/lista.txt" <<'PY'
import glob, json, random, sys
pasta, maximo = sys.argv[1], int(sys.argv[2])
boas = []
for f in glob.glob(f"{pasta}/JSON/**/*.json", recursive=True):
    if "arm64" not in f:
        continue
    try:
        j = json.load(open(f))
    except Exception:
        continue
    api = str(j.get("DEVICE_INITIAL_SDK_INT", ""))
    if api.isdigit() and 21 <= int(api) <= 25 and j.get("TYPE") == "user" \
            and j.get("TAGS") == "release-keys" and j.get("FINGERPRINT"):
        boas.append(f)
random.shuffle(boas)
print("\n".join(boas[:maximo]))
PY

echo "Testando $(wc -l < "$TMP/lista.txt") impressões..."
n=0
while IFS= read -r json; do
  n=$((n + 1))
  python3 - "$json" > "$TMP/custom.pif.prop" <<'PY'
import json, sys
for k, v in json.load(open(sys.argv[1])).items():
    print(f"{k}={v}")
print("spoofBuild=1\nspoofProps=1\nspoofProvider=1\nspoofSignature=0\n"
      "spoofVendingFinger=0\nspoofVendingSdk=0\nverboseLogs=0")
PY
  "${ADB[@]}" push -q "$TMP/custom.pif.prop" /data/local/tmp/custom.pif.prop >/dev/null
  sh_root "cp /data/local/tmp/custom.pif.prop $MOD/custom.pif.prop; sh $MOD/killpi.sh >/dev/null 2>&1; am force-stop $SPIC" >/dev/null 2>&1
  "${ADB[@]}" shell monkey -p "$SPIC" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
  sleep 4
  tap_text local 1                          # Nonce Creation: local
  tap_text local 2                          # Check Verdict: local
  tap_text "Make Play Integrity Request"

  veredito=""
  for _ in $(seq 1 15); do
    sleep 2
    veredito=$(ui_dump | grep -o 'text="[^"]*"' | grep -E 'MEETS_|NO_INTEGRITY|rror|xception' | tr '\n' ' ')
    [ -n "$veredito" ] && break
  done
  printf '[%d] %s => %s\n' "$n" "$(basename "$json")" "${veredito:-sem resposta}"

  case "$veredito" in
    *MEETS_DEVICE_INTEGRITY*)
      echo
      echo "ACHEI! Ela ficou instalada em $MOD/custom.pif.prop"
      echo "Guarde uma cópia:  su -c \"cp $MOD/custom.pif.prop /data/adb/meu-custom.pif.prop\""
      "${ADB[@]}" shell rm -f /data/local/tmp/custom.pif.prop /sdcard/govonroot-ui.xml
      exit 0 ;;
  esac
done < "$TMP/lista.txt"

"${ADB[@]}" shell rm -f /data/local/tmp/custom.pif.prop /sdcard/govonroot-ui.xml
echo "Nenhuma passou no DEVICE. Rode de novo: a lista é sorteada a cada vez."
exit 1
