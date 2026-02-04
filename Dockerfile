FROM mcr.microsoft.com/playwright:v1.58.0-jammy

RUN apt-get update && apt-get install -y \
  curl \
  git \
  jq

RUN mkdir -p /actions-runner
WORKDIR /actions-runner

# GitHub Runner ダウンロード（最新）
RUN RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name' | sed 's/^v//') \
  && curl -o actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz -L \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz \
  && tar xzf ./actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# 「Must not run with sudo」エラーへの対応
# ユーザーを作成しているらしい
RUN useradd -m -d /actions-runner -s /bin/bash runner \
  && chown -R runner:runner /actions-runner

USER runner

ENTRYPOINT ["./entrypoint.sh"]
