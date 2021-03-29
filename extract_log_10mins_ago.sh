d1=$(date +"%a %b %d %T:%3N %Y")
d2=$(date -d "-20 minutes" +"%a %b %d %T:%3N %Y")
#d2=$(date "+%s")
#D1=$(date -d @$d1)
#D2=$(date -d @$d2)
# awk "/$d1/,/$d2/" test.log
while read line; do
    [[ $line > $d2 && $line < $d1 || $line =~ $d1 ]] && echo $line
done < test.log
#awk -v d1="$d1" -v d2="$d2" '$0 > d1 && $0 < d2 || $0 ~ d2' test.log
