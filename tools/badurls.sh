#!/bin/bash
#

for i in *.html; do
    # 这些点是因为Mac的grep正则表达式与Linux的不太一样，应该是版本太老了？
    grep -o /blogs/..................................... $i > urls.txt
    while read URL; do
        UrlStatus=$(curl -I http://127.0.0.1:4000$URL 2>/dev/null | head -n 1 | cut -d$' ' -f2)
        if [ "$UrlStatus" == "404" ]; then
            echo $URL "in" $i
        fi
    done < "urls.txt"
done

rm urls.txt

