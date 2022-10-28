#!/bin/bash
shopt -s globstar
targetDir="$1"
space="$2"

# Make all confluence links easy to find & replace
(cd "$targetDir"

echo "Moving root space pages into their directories..."
for file in **/*.md; do
    base="$(basename "$file" .md)"
    for dir in **/*/; do
        if [ "$(basename "$dir" | sed s^/$^^)" = "$base" ]; then
            mv "$file" "$dir"
        fi
    done
done
echo "Successfully moved files"


echo "Finding links to be updated..."
changes=""

# Change any confluence links to a uniform format
# Should make further find/replace easier to complete.
wmConfluence='https://workingmouse.atlassian.net/wiki/spaces/'
changes+="s^\\Q$wmConfluence\\E([\\^/]*)/pages/([\\^/]*)/[\\^)]*^%%CONFLUENCE_\$1_\$2%%^g; "

# Set confluence space within the front matter
changes+="s/%%CONFLUENCE-SPACE%%/$space/; "
changes+='s/^\\---$/---/; '

for file in **/*.md; do
	vals=$(awk '
	/^\\?---$/ { frontMatter=0 }
	frontMatter && /confluence-id:/ { print "id=" $2 }
	NR == 1 { frontMatter=1 }
	' "$file")

	[ "$vals" ] && declare $vals

	echo "$id => $file"
	changes+="s^%%CONFLUENCE_${space}_${id}%%^</$file>^g; "
done

echo "Applying link changes..."
perl -pi -e "$changes" **/*.md
echo "Link changes applied"
)
