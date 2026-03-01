---
description: プロジェクト切替ナビゲーション
allowed-tools: Read, Glob, Bash, AskUserQuestion
---

## タスク

ユーザーが作業するプロジェクトを選択し、VSCodeのワークスペースを切り替えてください。

### 手順

1. `repo/` 配下のディレクトリを検出し、プロジェクト一覧を取得する
2. プロジェクト一覧を番号付きで表示し、ユーザーに選択を促す
   - 例:
     ```
     プロジェクト一覧:
     1. OshiBoard
     2. poke-dex-battle
     0. 全プロジェクト

     番号またはプロジェクト名を入力してください。
     ```
   - ユーザーが番号またはプロジェクト名で回答するのを待つ
3. ユーザーの選択に応じて以下を実行する:
   - 特定プロジェクト選択時: `bash scripts/generate-workspace.sh --open <project-name>`
   - 「全プロジェクト」選択時: `bash scripts/generate-workspace.sh --open`
4. 選択されたプロジェクトの情報を表示する:
   - 現在のブランチと最新コミット（`git -C repo/<name> log --oneline -3`）
   - CLAUDE.md があれば概要を表示
