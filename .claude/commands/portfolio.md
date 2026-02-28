---
description: 全プロジェクト横断の進捗確認
allowed-tools: Read, Glob, Grep, Bash(git -C:*), Bash(git log:*)
---

## タスク

全プロジェクトの現在の状態を横断的に確認し、サマリーレポートを生成してください。

### 確認項目

1. **docs/projects.md** を読み、各プロジェクトの登録情報を確認
2. 各プロジェクトディレクトリで以下を調査:
   - 最新コミット日時とメッセージ: `git -C repo/<project> log -1 --format="%ci %s"`
   - 未コミットの変更有無: `git -C repo/<project> status --short`
   - 現在のブランチ: `git -C repo/<project> branch --show-current`
3. **docs/revenue.md** から最新の収益状況を確認

### 出力形式

```
## ポートフォリオサマリー（YYYY-MM-DD）

### プロジェクト状況
| プロジェクト | ブランチ | 最終更新 | 未コミット | フェーズ |
|------------|---------|---------|-----------|---------|

### 収益状況
（revenue.mdから最新月の情報）

### 次のアクション
（優先度の高い作業を提案）
```
