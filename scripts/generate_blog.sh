#!/bin/bash
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "${SCRIPT_DIR}/.." || exit 1

file_name=$(pwd)/blog.md
# 先检查文章有没有更新，节省一点时间
article_update=$(git diff --cached --name-only | grep '.*\.md')
if [ ! "$article_update" ] && [ -e "$file_name" ]; then
    echo 'Generating blog.md skipped... '
    exit 0
fi

printf "Generating blog.md... \n"
# 文件总数
((filesCount = $(find blog/*/*.md | wc -l) - $(find blog/SaveOnly/*.md | wc -l)))
echo "Article count $filesCount"
# 已处理的文件数
processedCount=0
rm -f "$file_name"
tmp=$(pwd)/tmp
blog=$(pwd)/blog
cd "$blog" || exit 1

echo '---' >"$file_name"
printf '  layout: default\n  title: Blog\n  slug: /blog\n' >>"$file_name"
echo '---' >>"$file_name"

categories=(linux cpp qt cmake ffmpeg docker golang others)
for dir in "${categories[@]}"; do
    if [ -f "$dir" ]; then
        continue
    fi
    chapter_name="${dir}"
    cd "$dir" || continue
    files=$(ls -- *.md) # 如果文件名有 - 开头，加 -- 表名不会解析成选项
    if [ -z "$files" ]; then
        continue
    fi
    printf "* %s\n\n" "$chapter_name" >>"$file_name"
    for file in $files; do
        if [ -f "$file" ]; then
            # 读取第一行
            read -r line <"$file"
            echo "$line" >"$tmp"
            # 去掉开头的'#'
            line=$(sed 's/#//g' "$tmp")
            echo "$line" >"$tmp"
            # 去掉win换行符'\r'
            line=$(sed 's/\r//g' "$tmp")
            echo "$line" >"$tmp"
            # 去掉开头的空格
            line=$(sed 's/^[ \t]*//g' "$tmp")

            printf "  * [%s](blog/%s)\n\n" "$line" "$dir/$file" >>"$file_name"

            ((processedCount++))
            ((progress = processedCount * 100 / filesCount))
            echo -en "Generating blog.md $progress%\r"
        fi
    done
    cd "$blog" || exit 1
done
# printf " \n\n*** \n\n*Do not modify this file, it was generated by ‘generate_blog.sh’ when committing.*\n\n" >>"$file_name"
rm "$tmp"
printf "Generate blog.md successful... \n\n"
git add "$file_name"
exit 0
