#!/usr/bin/env bash
set -euo pipefail

# インストール済みskillsと skills.txt を双方向同期するスクリプト
# 使い方: bash scripts/sync-skills.sh

SKILLS_FILE="$(cd "$(dirname "$0")/.." && pwd)/.devcontainer/skills.txt"
SKILLS_DIR="$HOME/.agents/skills"

if [ ! -f "$SKILLS_FILE" ]; then
  echo "[ERROR] skills.txt が見つかりません: $SKILLS_FILE"
  exit 1
fi

echo "=== Skills 同期 ==="
echo ""

# ---- 1. skills.txt にあるがインストールされていないもの → インストール ----
echo "--- 未インストールのskillsを確認 ---"
installed_count=0
while IFS= read -r line; do
  [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
  skill_name="${line##*@}"
  if [ ! -d "$SKILLS_DIR/$skill_name" ]; then
    echo "[INSTALL] $skill_name ..."
    npx -y skills add "$line" 2>/dev/null && echo "[OK] $skill_name" || echo "[WARN] $skill_name のインストールに失敗"
    ((installed_count++)) || true
  fi
done < "$SKILLS_FILE"

if [ "$installed_count" -eq 0 ]; then
  echo "[OK] 全てインストール済み"
fi

# ---- 2. インストール済みだが skills.txt にないもの → 追加提案 ----
echo ""
echo "--- skills.txt に未登録のskillsを確認 ---"
missing_count=0

if [ -d "$SKILLS_DIR" ]; then
  for skill_dir in "$SKILLS_DIR"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    if ! grep -q "@${skill_name}$" "$SKILLS_FILE" 2>/dev/null; then
      echo "[未登録] $skill_name がインストール済みですが skills.txt にありません"
      ((missing_count++)) || true
    fi
  done
fi

if [ "$missing_count" -eq 0 ]; then
  echo "[OK] 全て登録済み"
else
  echo ""
  echo "未登録のskillsを skills.txt に追加するには:"
  echo "  echo 'owner/repo@skill-name' >> .devcontainer/skills.txt"
  echo ""
  echo "skill の正式名を調べるには:"
  echo "  npx skills find 'skill-name'"
fi

echo ""
echo "=== 同期完了 ==="
