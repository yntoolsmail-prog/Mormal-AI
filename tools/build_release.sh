#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
#  Mormal AI — сборка устанавливаемого архива мода для CK3.
# -----------------------------------------------------------------------------
#  На выходе: dist/Mormal-AI-v<version>.zip
#  Игрок распаковывает его в
#     <Documents>/Paradox Interactive/Crusader Kings III/mod/
#  Внутри архива:
#     Mormal-AI/        — контент мода (только то, что грузит игра)
#     Mormal-AI.mod     — внешний описатель для лаунчера (path = mod/Mormal-AI)
#  Больше игроку ничего создавать не нужно.
# =============================================================================

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

MOD_NAME="Mormal AI"
FOLDER="Mormal-AI"
VERSION="$(sed -n 's/^version="\(.*\)"/\1/p' descriptor.mod)"
[ -n "$VERSION" ] || { echo "ОШИБКА: не нашёл version=\"...\" в descriptor.mod" >&2; exit 1; }

BUILD="build"
STAGE="$BUILD/$FOLDER"
DIST="dist"
ZIP="$DIST/${FOLDER}-v${VERSION}.zip"

rm -rf "$BUILD"
rm -f "$ZIP"
mkdir -p "$STAGE" "$DIST"

# --- Описатели мода ---------------------------------------------------------
cp descriptor.mod "$STAGE/"
mkdir -p "$STAGE/.metadata"
cp .metadata/metadata.json "$STAGE/.metadata/"

# --- Контент: ТОЛЬКО реальные переопределения -------------------------------
#  Намеренно НЕ копируем:
#   - vanilla/        (справочное зеркало, игре не нужно)
#   - common/task.md  (рабочий документ)
#   - common/modifiers/README.txt (.txt в common/modifiers/ движок распарсил бы
#                                   как модификатор → ошибка в error.log)
mkdir -p "$STAGE/common/defines" "$STAGE/common/script_values"
cp common/defines/*.txt       "$STAGE/common/defines/"
cp common/script_values/*.txt "$STAGE/common/script_values/"

# --- Внешний описатель лаунчера ---------------------------------------------
cat > "$BUILD/${FOLDER}.mod" <<EOF
version="$VERSION"
tags={
	"Balance"
	"Gameplay"
	"Warfare"
	"Fixes"
}
name="$MOD_NAME"
supported_version="1.19.*"
path="mod/$FOLDER"
EOF

# --- Упаковка (zip, с фолбэком на python3) ----------------------------------
if command -v zip >/dev/null 2>&1; then
	( cd "$BUILD" && zip -r -q "$OLDPWD/$ZIP" "$FOLDER" "${FOLDER}.mod" )
else
	( cd "$BUILD" && python3 -c "import shutil,sys; shutil.make_archive(sys.argv[1], 'zip', '.')" "$OLDPWD/${ZIP%.zip}" )
fi

echo "Готово: $ZIP"
command -v unzip >/dev/null 2>&1 && unzip -l "$ZIP" || true
