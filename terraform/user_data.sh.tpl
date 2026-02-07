#!/bin/bash
set -e

# ログ出力設定
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Setup Started at $(date) ==="

WORK_DIR="/home/ubuntu"
RUNNER_USER="ubuntu"


cd "$WORK_DIR"
sudo -u "$RUNNER_USER" mkdir -p actions-runner
cd actions-runner
sudo chown -R "$RUNNER_USER":"$RUNNER_USER" "$WORK_DIR/actions-runner"

sudo -u "$RUNNER_USER" curl -o actions-runner-linux-x64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz
echo "5fcc01bd546ba5c3f1291c2803658ebd3cedb3836489eda3be357d41bfcf28a7  actions-runner-linux-x64-2.331.0.tar.gz" | sudo -u "$RUNNER_USER" shasum -a 256 -c
sudo -u "$RUNNER_USER" tar xzf ./actions-runner-linux-x64-2.331.0.tar.gz
sudo chown -R "$RUNNER_USER":"$RUNNER_USER" "$WORK_DIR/actions-runner"

sudo -u "$RUNNER_USER" ./config.sh \
  --url https://github.com/iyoshi-rgb/sample-self-hosted-runner \
  --token ${REGISTRATION_TOKEN} \
  --name playwright-runner \
  --labels x64,ubuntu \
  --unattended

sudo ./svc.sh install
sudo ./svc.sh start


cd "$WORK_DIR"
sudo -u "$RUNNER_USER" mkdir -p actions-runner-2
cd actions-runner-2
sudo chown -R "$RUNNER_USER":"$RUNNER_USER" "$WORK_DIR/actions-runner-2"

sudo -u "$RUNNER_USER" curl -o actions-runner-linux-x64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz
echo "5fcc01bd546ba5c3f1291c2803658ebd3cedb3836489eda3be357d41bfcf28a7  actions-runner-linux-x64-2.331.0.tar.gz" | sudo -u "$RUNNER_USER" shasum -a 256 -c
sudo -u "$RUNNER_USER" tar xzf ./actions-runner-linux-x64-2.331.0.tar.gz
sudo chown -R "$RUNNER_USER":"$RUNNER_USER" "$WORK_DIR/actions-runner-2"

sudo -u "$RUNNER_USER" ./config.sh \
  --url https://github.com/iyoshi-rgb/npm-registry-publish-sample \
  --token ${REGISTRATION_TOKEN_2} \
  --name playwright-runner \
  --labels x64,ubuntu \
  --unattended

sudo ./svc.sh install
sudo ./svc.sh start

echo "=== Setup Completed at $(date) ==="