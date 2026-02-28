---
description: プロジェクト切替ナビゲーション
allowed-tools: Read, Glob, Bash, AskUserQuestion
---

## タスク

ユーザーが作業するプロジェクトを選択し、VSCodeのワークスペースを切り替えてください。

### 手順

1. `repo/` 配下のディレクトリを検出し、プロジェクト一覧を取得する
2. AskUserQuestion ツールで「どのプロジェクトを開発しますか？」と選択肢を提示する
   - repo/ 配下の全プロジェクトを選択肢にする
   - 「全プロジェクト」も選択肢に含める
3. ユーザーの選択に応じて以下を実行する:
   - 特定プロジェクト選択時: `bash scripts/generate-workspace.sh --open <project-name>`
   - 「全プロジェクト」選択時: `bash scripts/generate-workspace.sh --open`
4. 選択されたプロジェクトの情報を表示する:
   - 現在のブランチと最新コミット（`git -C repo/<name> log --oneline -3`）
   - CLAUDE.md があれば概要を表示
