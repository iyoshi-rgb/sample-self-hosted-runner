#!/bin/bash
set -e

# ログ出力設定
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Setup Started at $(date) ==="

WORK_DIR="/home/ubuntu"
RUNNER_USER="ubuntu"


cd "$WORK_DIR"

setup_runner(){
  local repo_name=$1
  local token=$2
  local runner_dir="$repo_name-actions-runner"

  echo "runner url: https://github.com/iyoshi-rgb/$repo_name"
  echo "runner token: $token"

  cd "$WORK_DIR"
  sudo -u "$RUNNER_USER" mkdir -p "$runner_dir"
  cd "$runner_dir"
  sudo chown -R "$RUNNER_USER":"$RUNNER_USER" "$WORK_DIR/$runner_dir"

  sudo -u "$RUNNER_USER" curl -o actions-runner-linux-x64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz
  echo "5fcc01bd546ba5c3f1291c2803658ebd3cedb3836489eda3be357d41bfcf28a7  actions-runner-linux-x64-2.331.0.tar.gz" | sudo -u "$RUNNER_USER" shasum -a 256 -c
  sudo -u "$RUNNER_USER" tar xzf ./actions-runner-linux-x64-2.331.0.tar.gz

  sudo -u "$RUNNER_USER" ./config.sh \
  --url https://github.com/iyoshi-rgb/$repo_name \
  --token "$token" \
  --name playwright-runner \
  --labels x64,ubuntu \
  --unattended

  sudo ./svc.sh install
  sudo ./svc.sh start
}

setup_runner "sample-self-hosted-runner" "${REGISTRATION_TOKEN}"
setup_runner "npm-registry-publish-sample" "${NPM_REGISTRY_TOKEN}"

echo "=== Setup Completed at $(date) ==="