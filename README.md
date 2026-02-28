# indie-dev-hub

DevContainer + Claude Code で個人開発の複数プロジェクトを一元管理するテンプレートリポジトリ。

## 何ができるか

- **統一開発環境**: `git clone` → VSCode「Reopen in Container」だけで全ツールが揃う
- **プロジェクト切替**: `/switch-project` で VSCode のワークスペースを動的切替。作業中のプロジェクトだけがエクスプローラーに表示される
- **横断管理**: `/portfolio` で全プロジェクトの進捗を一括確認
- **ナレッジ蓄積**: `/knowledge-add` でテーマ別に技術知見を蓄積・再利用
- **収益管理**: `/revenue-report` で収益状況をレポート生成

## クイックスタート

### 1. テンプレートからリポジトリを作成

GitHubの「Use this template」ボタンをクリックするか:

```bash
git clone https://github.com/<your-username>/indie-dev-hub.git my-projects
cd my-projects
```

### 2. VSCodeでDevContainerを起動

```
Ctrl+Shift+P → "Dev Containers: Reopen in Container"
```

初回ビルドには数分かかります。完了すると以下が使えます:

| ツール | 用途 |
|-------|------|
| Node.js 24（Volta管理） | ランタイム |
| pnpm | パッケージ管理 |
| GitHub CLI | GitHub操作 |

### 3. Claude Code をインストール

[公式ガイド](https://docs.anthropic.com/en/docs/claude-code/overview)に従ってインストールしてください:

```bash
npm install -g @anthropic-ai/claude-code
claude
```

### 4. プロジェクトを追加

```bash
git clone https://github.com/<user>/<repo>.git repo/<project-name>
cd repo/<project-name> && npm install
```

### 5. ワークスペースを生成して開く

```bash
bash scripts/generate-workspace.sh --open <project-name>
```

または Claude Code で `/switch-project` と入力。

## ディレクトリ構成

```
.
├── .devcontainer/          ← 開発コンテナ設定
│   ├── Dockerfile
│   ├── devcontainer.json
│   ├── postCreate.sh
│   └── skills.txt          ← Claude Code Skills リスト
├── .claude/
│   ├── CLAUDE.md            ← AI設定・ルール
│   └── commands/            ← スラッシュコマンド
├── docs/
│   ├── projects.md          ← プロジェクト一覧・ステータス
│   ├── revenue.md           ← 収益管理
│   └── knowledge/           ← テーマ別ナレッジベース
├── scripts/
│   ├── generate-workspace.sh ← ワークスペース動的生成
│   └── sync-skills.sh       ← Skills同期
└── repo/                    ← 子プロジェクト（.gitignoreで除外）
```

## Claude Code コマンド

| コマンド | 説明 |
|---------|------|
| `/switch-project` | プロジェクト選択 → ワークスペース自動切替 |
| `/portfolio` | 全プロジェクトの進捗を横断確認 |
| `/knowledge-add` | ナレッジベースに知見を追加 |
| `/revenue-report` | 収益状況レポートを生成 |

## Skills 管理

`.devcontainer/skills.txt` でスキルを管理:

```bash
# スキルを追加
npx skills add owner/repo@skill-name -g --agent claude-code -y
echo 'owner/repo@skill-name' >> .devcontainer/skills.txt

# 同期確認
bash scripts/sync-skills.sh

# スキルを検索
npx skills find 'keyword'
```

## カスタマイズ

### プロジェクト情報を設定

- `docs/projects.md` を編集してプロジェクト情報を登録
- `docs/revenue.md` を編集して収益目標を設定

### ナレッジカテゴリを追加

`docs/knowledge/` にMarkdownファイルを追加し、`README.md` の目次を更新。

### DevContainer のカスタマイズ

- **Node.jsバージョン**: `.devcontainer/Dockerfile` の `volta install node@XX` を変更
- **VSCode拡張機能**: `.devcontainer/devcontainer.json` の `extensions` に追加
- **ポートフォワード**: `forwardPorts` に追加

## 関連記事

<!-- Zenn記事のURLを追加 -->

## License

MIT
