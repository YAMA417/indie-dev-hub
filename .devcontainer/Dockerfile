FROM node:24-bookworm

# システムパッケージ
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    sudo \
    curl \
    && rm -rf /var/lib/apt/lists/*

# nodeユーザー（UID 1000、ベースイメージ既存）にsudo権限付与
RUN echo "node ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/node \
    && chmod 0440 /etc/sudoers.d/node

USER node

# Volta（子プロジェクトごとのNode.jsバージョン切替用）
ENV VOLTA_HOME=/home/node/.volta
ENV PATH=${VOLTA_HOME}/bin:${PATH}
RUN curl https://get.volta.sh | bash
RUN volta install node@24 && volta install pnpm

# npm globalプレフィックス（非root用）
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=/home/node/.npm-global/bin:${PATH}

# ディレクトリ事前作成
RUN mkdir -p /home/node/.agents/skills /home/node/.claude

WORKDIR /workspaces/projects
