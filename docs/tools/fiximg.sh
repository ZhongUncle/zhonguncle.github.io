#!/bin/bash
# fiximg.sh — 由 AI（Claude）编写
# 将 Markdown 文件中相对路径的图片引用（如 ./images/a.png、../img/b.jpg、images/c.gif）
# 统一改为 /assets/images/<文件名>，Markdown 语法与 HTML img 标签均处理。
# 已是 /assets/ 开头的路径和 http(s) 链接不受影响。
# 用法：fiximg.sh <file.md> [file2.md ...]

set -e

EXT='png|jpe?g|gif|svg|webp'

for f in "$@"; do
    sed -i '' -E \
        -e "s#\]\\((\\./|\\.\\./)?[^ )/:]+/([^ )/]+\\.($EXT))\\)#](/assets/images/\2)#gi" \
        -e "s#src=\"(\\./|\\.\\./)?[^ \"/:]+/([^ \"/]+\\.($EXT))\"#src=\"/assets/images/\2\"#gi" \
        "$f"
    echo "fixed: $f"
done
