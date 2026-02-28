# Projects 管理リポジトリ

## このリポジトリの役割

個人開発プロジェクトの横断管理リポジトリ。以下を一元管理する：
- プロジェクト状態・進捗の追跡
- テーマ別ナレッジベース
- 収益管理
- 横断的なClaude Codeコマンド

## 子プロジェクト一覧

`repo/` 配下にcloneされたプロジェクトを `docs/projects.md` で管理する。

## ルール

- 回答は日本語で行う
- 子プロジェクトのコードを直接変更しない（各プロジェクトのClaude Code設定に従う）
- ナレッジはテーマ別に `docs/knowledge/` へ整理する
- 収益情報は `docs/revenue.md` に記録する

## コマンド一覧

- `/portfolio` - 全プロジェクト横断の進捗確認
- `/switch-project` - プロジェクト切替ナビゲーション
- `/knowledge-add` - ナレッジベースに知見を追加
- `/revenue-report` - 収益状況レポート生成

## 参照ドキュメント

- `docs/projects.md` - プロジェクト詳細・ステータス
- `docs/revenue.md` - 収益管理
- `docs/knowledge/README.md` - ナレッジベース目次
