---
name: import-blog
description: 导入一篇博客到本站点：中文原版放 assets/original/，英文翻译放 _blogs/ 用 MD5 命名并加标头。当用户提供中文笔记和英文翻译（或要求导入新博客）时使用。
---

# 博客导入流程

用户提供中文笔记文件和英文翻译文件（或英文标题）后，严格按以下步骤执行，不主动扩展范围。

## 重要：先确认再修改

执行任何文件修改之前，必须先向用户展示计划修改的内容（包括拟写入的标头、拟重命名的文件名等），等待用户确认后才能动手。**不能直接改。** 如果涉及多个文件，用表格形式列出所有计划的改动。

## 步骤

1. **中文原版**：移入 `assets/original/` 目录，保持 Markdown 原样，不转 HTML。

2. **英文翻译版**：文件名为英文标题（连字符形式）的 MD5 哈希值，放入 `_blogs/`：
   ```bash
   md5 -s "shannon-entropy-explained"
   # => 36baceda5216ec46eb053fbc60cbd6b6.md
   ```

3. **在英文版开头写入标头**：
   ```yaml
   ---
   layout: article
   category: Research
   date: <英文版文件的最后修改日期，YYYY-MM-DD，用 stat -f "%Sm" -t "%Y-%m-%d" 文件 获取>
   title: "<英文标题>"
   excerpt: "<正文第一段作为摘要>"
   originurl: "/assets/original/<URL编码后的中文文件名>.md"
   ---
   ```
   - 中文文件名需做百分号编码（如 `香农信息论笔记.md` → `%E9%A6%99%E5%86%9C%E4%BF%A1%E6%81%AF%E8%AE%BA%E7%AC%94%E8%AE%B0.md`），可用 `python3 -c "from urllib.parse import quote; print(quote('文件名'))"` 生成。
   - `originurl` 用 `/` 开头的相对路径，不带域名。

4. **删除英文版正文中与 title 重复的一级标题**（title 已由 layout 渲染，否则页面出现两个大标题）。标头后直接接正文。

5. **验证**：运行 `bundle exec jekyll build` 确认构建通过。

## 参考样例

`_blogs/36baceda5216ec46eb053fbc60cbd6b6.md`（Shannon Entropy, Explained）是完整符合本流程的样例。
