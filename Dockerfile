FROM mcr.microsoft.com/playwright:v1.58.0-jammy

RUN apt-get update && apt-get install -y \
  curl \
  git \
  jq

RUN mkdir -p /actions-runner
WORKDIR /actions-runner

# GitHub Runner ダウンロード
RUN curl -o actions-runner-linux-arm64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-arm64-2.331.0.tar.gz
RUN echo "f5863a211241436186723159a111f352f25d5d22711639761ea24c98caef1a9a  actions-runner-linux-arm64-2.331.0.tar.gz" | shasum -a 256 -c
RUN tar xzf ./actions-runner-linux-arm64-2.331.0.tar.gz

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# 「Must not run with sudo」エラーへの対応
# ユーザーを作成しているらしい
RUN useradd -m -d /actions-runner -s /bin/bash runner \
  && chown -R runner:runner /actions-runner

USER runner

ENTRYPOINT ["./entrypoint.sh"]
