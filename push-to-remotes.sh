#!/bin/bash
# 将当前项目推送到 GitLab 和 GitHub（账号 branchfredric@gmail.com）
# 使用前请先在 GitLab/GitHub 创建好同名仓库 tata-ios

set -e

# ========== 配置（请根据实际情况修改）==========
GITLAB_USER="branchfredric"
GITHUB_USER="branchfredric"
REPO_NAME="tata-ios"

# 使用 HTTPS + Token 以便非交互自动推送（账号 branchfredric@gmail.com）
# Token 来源（按优先级）：环境变量 GITLAB_TOKEN/GITHUB_TOKEN，或文件 ~/.git-tata-remotes
CRED_FILE="$HOME/.git-tata-remotes"
if [[ -f "$CRED_FILE" ]]; then
  source "$CRED_FILE" 2>/dev/null || true
fi
GITLAB_URL="https://gitlab.com/sbtata89/tata-ios.git"
GITHUB_URL="https://github.com/SDTata/SBTATA.git"
[[ -n "$GITLAB_TOKEN" ]] && GITLAB_URL="https://oauth2:${GITLAB_TOKEN}@gitlab.com/sbtata89/tata-ios.git"
[[ -n "$GITHUB_TOKEN" ]] && GITHUB_URL="https://${GITHUB_TOKEN}@github.com/SDTata/SBTATA.git"

# 远程名称（与现有 origin 区分，避免覆盖）
GITLAB_REMOTE="gitlab"
GITHUB_REMOTE="github"

# ========== 脚本逻辑 ==========
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📁 项目目录: $SCRIPT_DIR"
echo ""

# 获取当前分支
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "📌 当前分支: $CURRENT_BRANCH"
echo ""

# 添加或更新 GitLab 远程
if git remote get-url "$GITLAB_REMOTE" &>/dev/null; then
    git remote set-url "$GITLAB_REMOTE" "$GITLAB_URL"
    echo "✅ 已更新 GitLab 远程: $GITLAB_REMOTE -> $GITLAB_URL"
else
    git remote add "$GITLAB_REMOTE" "$GITLAB_URL"
    echo "✅ 已添加 GitLab 远程: $GITLAB_REMOTE -> $GITLAB_URL"
fi

# 添加或更新 GitHub 远程
if git remote get-url "$GITHUB_REMOTE" &>/dev/null; then
    git remote set-url "$GITHUB_REMOTE" "$GITHUB_URL"
    echo "✅ 已更新 GitHub 远程: $GITHUB_REMOTE -> $GITHUB_URL"
else
    git remote add "$GITHUB_REMOTE" "$GITHUB_URL"
    echo "✅ 已添加 GitHub 远程: $GITHUB_REMOTE -> $GITHUB_URL"
fi

echo ""
echo "🚀 开始推送..."
echo ""

# 推送到 GitLab（无 Token 时跳过）
GITLAB_OK=0
if [[ -n "$GITLAB_TOKEN" ]]; then
    echo ">>> 推送到 GitLab ($GITLAB_REMOTE)..."
    if git push -u "$GITLAB_REMOTE" "$CURRENT_BRANCH"; then
        echo "✅ GitLab 推送成功"
        GITLAB_OK=1
    else
        echo "❌ GitLab 推送失败（请检查仓库与 Token 权限）"
    fi
    echo ""
else
    echo ">>> 跳过 GitLab（未配置 GITLAB_TOKEN）"
    echo ""
fi

# 推送到 GitHub
echo ">>> 推送到 GitHub ($GITHUB_REMOTE)..."
if git push -u "$GITHUB_REMOTE" "$CURRENT_BRANCH"; then
    echo "✅ GitHub 推送成功"
else
    echo "❌ GitHub 推送失败（请检查仓库与 Token 权限）"
    exit 1
fi

echo ""
if [[ $GITLAB_OK -eq 1 ]]; then
    echo "🎉 已成功推送到 GitLab 和 GitHub（分支: $CURRENT_BRANCH）"
else
    echo "🎉 已成功推送到 GitHub（分支: $CURRENT_BRANCH）；GitLab 未配置或推送失败"
fi
