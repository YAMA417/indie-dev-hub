#!/usr/bin/env bash
set -euo pipefail

# repo/ 配下のプロジェクトを検出して .code-workspace を動的生成するスクリプト
#
# 使い方:
#   bash scripts/generate-workspace.sh                         # 全プロジェクト
#   bash scripts/generate-workspace.sh my-project         # 指定プロジェクトのみ
#   bash scripts/generate-workspace.sh --open my-project  # 生成して自動で開く

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$ROOT_DIR/repo"

# 引数解析
AUTO_OPEN=false
PROJECT_NAME=""

for arg in "$@"; do
  if [ "$arg" = "--open" ]; then
    AUTO_OPEN=true
  else
    PROJECT_NAME="$arg"
  fi
done

# プロジェクト指定時にディレクトリ存在チェック
if [ -n "$PROJECT_NAME" ] && [ ! -d "$REPO_DIR/$PROJECT_NAME" ]; then
  echo "[ERROR] プロジェクトが見つかりません: repo/$PROJECT_NAME"
  echo ""
  echo "利用可能なプロジェクト:"
  for dir in "$REPO_DIR"/*/; do
    [ -d "$dir" ] && echo "  - $(basename "$dir")"
  done
  exit 1
fi

# 出力ファイル名を決定
OUTPUT="$ROOT_DIR/projects.code-workspace"

# フォルダとscanパスを構築
folders='    {\n      "path": ".",\n      "name": "projects"\n    }'
scan_paths=()

if [ -d "$REPO_DIR" ]; then
  for dir in "$REPO_DIR"/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")

    # プロジェクト指定がある場合はそれだけ含める
    if [ -n "$PROJECT_NAME" ] && [ "$name" != "$PROJECT_NAME" ]; then
      continue
    fi

    folders="$folders,\n    {\n      \"path\": \"./repo/$name\",\n      \"name\": \"$name\"\n    }"
    scan_paths+=("./repo/$name")
  done
fi

# scan_repositories を構築
scan_json="[]"
if [ ${#scan_paths[@]} -gt 0 ]; then
  scan_json=$(printf ',\n      "%s"' "${scan_paths[@]}")
  scan_json="[${scan_json:1}\n    ]"
fi

# workspace ファイルを生成
cat > "$OUTPUT" << WORKSPACE_EOF
{
  "folders": [
$(echo -e "$folders")
  ],
  "settings": {
    "git.autoRepositoryDetection": "openEditors",
    "git.scanRepositories": $(echo -e "$scan_json")
  }
}
WORKSPACE_EOF

echo "生成完了: $OUTPUT"

# 自動で開く
if [ "$AUTO_OPEN" = true ]; then
  code "$OUTPUT"
  echo "ワークスペースを開きました"
fi
