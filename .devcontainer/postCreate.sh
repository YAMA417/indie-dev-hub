#!/usr/bin/env bash
set -euo pipefail

echo "=== DevContainer postCreate: セットアップ開始 ==="

# ---- 0. 認証情報の永続化 ----
# ~/.claude.json はボリューム外なのでリビルドで消える
# ボリューム内（~/.claude/）にコピーを保持し、シンボリックリンクで参照する
CLAUDE_JSON="$HOME/.claude.json"
CLAUDE_JSON_BACKUP="$HOME/.claude/.claude.json.bak"

if [ -L "$CLAUDE_JSON" ]; then
  echo "[OK] .claude.json はシンボリックリンク済み"
elif [ -f "$CLAUDE_JSON_BACKUP" ]; then
  ln -sf "$CLAUDE_JSON_BACKUP" "$CLAUDE_JSON"
  echo "[OK] .claude.json をボリュームから復元"
elif [ -f "$CLAUDE_JSON" ]; then
  cp "$CLAUDE_JSON" "$CLAUDE_JSON_BACKUP"
  ln -sf "$CLAUDE_JSON_BACKUP" "$CLAUDE_JSON"
  echo "[OK] .claude.json をボリュームにバックアップ＆リンク"
fi

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
  mkdir -p "$SKILLS_DIR"
  while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    skill_name="${line##*@}"
    if [ -d "$SKILLS_DIR/$skill_name" ]; then
      echo "[SKIP] $skill_name（既にインストール済み）"
    else
      echo "[INSTALL] $skill_name ..."
      npx -y skills add "$line" -g --agent claude-code -y 2>/dev/null && echo "[OK] $skill_name" || echo "[WARN] $skill_name のインストールに失敗"
    fi
  done < "$SKILLS_FILE"
else
  echo "[WARN] skills.txt が見つかりません: $SKILLS_FILE"
fi

# ---- 4. Claude 設定 ----
echo ""
echo "--- Claude 設定 ---"

CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [ ! -f "$CLAUDE_SETTINGS" ]; then
  mkdir -p "$HOME/.claude"
  cat > "$CLAUDE_SETTINGS" << 'SETTINGS_EOF'
{
  "effortLevel": "medium",
  "language": "日本語",
  "statusLine": {
    "type": "command",
    "command": "bash $HOME/.claude/statusline-command.sh",
    "alwaysShow": true
  }
}
SETTINGS_EOF
  echo "[OK] Claude settings.json を作成"
else
  echo "[SKIP] Claude settings.json は既に存在"
fi

# ---- 5. Statusline スクリプト ----
STATUSLINE_SCRIPT="$HOME/.claude/statusline-command.sh"
if [ ! -f "$STATUSLINE_SCRIPT" ]; then
  cat > "$STATUSLINE_SCRIPT" << 'SL_EOF'
#!/bin/bash
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

dir_part=$(basename "$cwd")

if [ -n "$used" ] && [ -n "$remaining" ]; then
  printf "\033[32m%s\033[0m | \033[36m%s\033[0m | Context: \033[33m%d%%\033[0m used / \033[32m%d%%\033[0m remaining" \
    "$dir_part" "$model" "$used" "$remaining"
else
  printf "\033[32m%s\033[0m | \033[36m%s\033[0m | Context: \033[90mno data yet\033[0m" \
    "$dir_part" "$model"
fi
SL_EOF
  chmod +x "$STATUSLINE_SCRIPT"
  echo "[OK] statusline-command.sh をインストール"
else
  echo "[SKIP] statusline-command.sh は既に存在"
fi

# ---- 6. API キー確認 ----
echo ""
echo "--- 環境変数確認 ---"

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo ""
  echo "========================================"
  echo "[WARN] ANTHROPIC_API_KEY が設定されていません！"
  echo "  .env ファイルを作成してください:"
  echo "    cp .env.example .env"
  echo "  .env に ANTHROPIC_API_KEY を設定後、コンテナを再ビルドしてください。"
  echo "========================================"
  echo ""
else
  echo "[OK] ANTHROPIC_API_KEY が設定されています"
fi

# ---- 7. 子プロジェクト状態 ----
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

# ---- 8. ワークスペース生成 ----
WORKSPACE_SCRIPT="/workspaces/projects/scripts/generate-workspace.sh"
if [ -f "$WORKSPACE_SCRIPT" ]; then
  echo ""
  echo "--- ワークスペース生成 ---"
  bash "$WORKSPACE_SCRIPT"
fi

echo ""
echo "=== DevContainer セットアップ完了 ==="
echo "claude コマンドで Claude CLI を起動できます"
