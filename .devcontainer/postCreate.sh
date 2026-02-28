#!/usr/bin/env bash
set -euo pipefail

echo "=== DevContainer postCreate: セットアップ開始 ==="

# ---- 1. ツール確認 ----
echo ""
echo "--- ツール確認 ---"

if command -v volta &>/dev/null; then
  echo "[OK] Volta: $(volta --version)"
else
  echo "[WARN] Volta が見つかりません"
fi

if command -v node &>/dev/null; then
  echo "[OK] Node.js: $(node --version)"
fi

if command -v pnpm &>/dev/null; then
  echo "[OK] pnpm: $(pnpm --version)"
else
  echo "[WARN] pnpm が見つかりません。インストール中..."
  volta install pnpm
fi

# ---- 2. Skills インストール ----
echo ""
echo "--- Skills インストール ---"

SKILLS_FILE="/workspaces/projects/.devcontainer/skills.txt"
SKILLS_DIR="$HOME/.agents/skills"

if [ -f "$SKILLS_FILE" ]; then
  if command -v claude &>/dev/null; then
    mkdir -p "$SKILLS_DIR"
    while IFS= read -r line; do
      [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
      skill_name="${line##*@}"
      if [ -d "$SKILLS_DIR/$skill_name" ]; then
        echo "[SKIP] $skill_name（既にインストール済み）"
      else
        echo "[INSTALL] $skill_name ..."
        npx -y skills add "$line" 2>/dev/null && echo "[OK] $skill_name" || echo "[WARN] $skill_name のインストールに失敗"
      fi
    done < "$SKILLS_FILE"
  else
    echo "[INFO] Claude CLI 未インストールのためスキップ"
    echo "  公式ガイドに従って Claude Code をインストール後、bash scripts/sync-skills.sh を実行してください"
  fi
else
  echo "[WARN] skills.txt が見つかりません: $SKILLS_FILE"
fi

# ---- 3. 子プロジェクト状態 ----
echo ""
echo "--- 子プロジェクト状態 ---"

for dir in repo/*/; do
  if [ -f "$dir/package.json" ]; then
    name=$(basename "$dir")
    if [ -d "$dir/node_modules" ]; then
      echo "[OK] $name: node_modules あり"
    else
      echo "[INFO] $name: npm install または pnpm install が必要"
    fi
  fi
done

# ---- 4. ワークスペース生成 ----
WORKSPACE_SCRIPT="/workspaces/projects/scripts/generate-workspace.sh"
if [ -f "$WORKSPACE_SCRIPT" ]; then
  echo ""
  echo "--- ワークスペース生成 ---"
  bash "$WORKSPACE_SCRIPT"
fi

echo ""
echo "=== DevContainer セットアップ完了 ==="
