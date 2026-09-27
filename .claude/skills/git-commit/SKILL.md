---
name: git-commit
description: 提交并推送本项目改动。当用户要求提交、push 时使用。
---

# Git 提交流程

构建已由 git pre-commit hook 自动处理（`.githooks/pre-commit`：提交时自动 `bundle exec jekyll build` 并 `git add docs/`，构建失败会中止提交），无需手动 build。

1. **提交**：`git add -A`，commit message 用简洁英文描述改动，结尾加：
   ```
   Co-Authored-By: Claude Code <noreply@anthropic.com>
   ```

2. **推送**：用户要求 push 时才执行 `git push`。
