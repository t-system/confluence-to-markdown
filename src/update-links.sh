shopt -s globstar
space="$1"

# Make all confluence links easy to find & replace
wmConfluence='https://workingmouse.atlassian.net/wiki/spaces/'
# perl -pi -e "s^\Q$wmConfluence\E\([\^/]*\)\Q/pages/\E\([\^/]*\)/[\^)]*^%%CONFLUENCE_\$1_\$2%%^g" **/*.md

declare -A articles
for file in **/*.md; do
    id="$(head -1 "$file")"
    articles[$id]=$file
    echo "$id => $file"
    # perl -pi -e "s^%%CONFLUENCE_${space}_${id}%%^$file^g" **/*.md
    perl -pi -e "s^\Qhttps://workingmouse.atlassian.net/wiki/spaces/$space/pages/$id/\E[\^)]*^</$file>^g" **/*.md
done