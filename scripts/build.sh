#!/bin/bash
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "${SCRIPT_DIR}/.." || exit 1

cp -ar blog blog.bak
cp blog.md blog.md.bak

cat <<EOF >tmp_header
---
layout: default
---

EOF

while IFS= read -r line; do
    if [[ $line =~ .*\(blog/.*md\) ]]; then
        file=$(echo "$line" | grep -o 'blog/.*md')
        cat tmp_header "$file" >>tmp_md
        sed -e 's#md)#html)#g' -i tmp_md
        mv tmp_md "$file"
    fi
done <blog.md

sed -e 's#(blog#(/blog#g' -e 's#md)#html)#g' -i blog.md

rm tmp_header

export LC_ALL=en_US.UTF-8

if [ "$1" = "-s" ]; then
    bundle exec jekyll server --future
else
    bundle exec jekyll build --future
fi

rm -rf _site/scripts
rm -rf _site/blog/SaveOnly
rm -rf _site/blog.bak
rm -rf _site/blog.md.bak
rm -rf _site/README.md
rm -rf blog
mv blog.bak blog
mv blog.md.bak blog.md