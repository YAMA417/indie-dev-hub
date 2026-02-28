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

# ---- 2. Claude Code インストール ----
echo ""
echo "--- Claude Code インストール ---"

if command -v claude &>/dev/null; then
  echo "[OK] Claude Code: $(claude --version 2>/dev/null || echo 'installed')"
else
  echo "[INSTALL] Claude Code をインストール中..."
  npm install -g @anthropic-ai/claude-code && echo "[OK] Claude Code インストール完了" || echo "[WARN] Claude Code のインストールに失敗"
fi

# ---- 3. Skills インストール ----
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
  fi
else
  echo "[WARN] skills.txt が見つかりません: $SKILLS_FILE"
fi

# ---- 4. 子プロジェクト状態 ----
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

# ---- 5. ワークスペース生成 ----
WORKSPACE_SCRIPT="/workspaces/projects/scripts/generate-workspace.sh"
if [ -f "$WORKSPACE_SCRIPT" ]; then
  echo ""
  echo "--- ワークスペース生成 ---"
  bash "$WORKSPACE_SCRIPT"
fi

echo ""
echo "=== DevContainer セットアップ完了 ==="
