#!/bin/bash
#把照片的本地url转换成绝对url
#../blogs/..转换成/blogs/....

cd
for i in *.md; do
    # 这些点是因为Mac的grep正则表达式与Linux的不太一样
    grep -o /blogs/..................................... $i > urls.txt
    while read URL; do
        UrlStatus=$(curl -I http://127.0.0.1:4000$URL 2>/dev/null | head -n 1 | cut -d$' ' -f2)
        if [ "$UrlStatus" == "404" ]; then
            echo $URL "in" $i
        fi
    done < "urls.txt"
done

rm urls.txt

