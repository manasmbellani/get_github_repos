#!/bin/bash
TMP_FILE="/tmp/out.html"
OUT_FILE="github_repos_list.txt"
ERR="\033[31m"
OK="\033[32m"
WRN="\033[33m"
VRB="\033[34m"
NRM="\033[0m"
ERRM="$ERR[-]$NRM"
OKM="$OK[+]$NRM"
WRNM="$WRN[W]$NRM"
VRBM="$VRB[V]$NRM"
GITHUB_DOMAIN="https://github.com"
GITHUB_SEARCH_PATH="search?type=Repositories&type=&q="
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36"


if [ $# -lt 1 ]; then 
    echo "$0 <keywords>"
    echo
    echo "Arguments:"
    echo "  keywords - to search for keywords"
    echo 
    echo "Requirements:"
    echo "  curl - for downloading the search page locally"
    echo
    echo "Example:"
    echo "  $0 google github"
    exit
fi

keywords="$@"
keywords_search_pattern=`echo $keywords | tr -s " " "+"`


echo -e "$VRBM Getting the first page of the github search"
curl -s -k -A "$USER_AGENT" "$GITHUB_DOMAIN/$GITHUB_SEARCH_PATH""$keywords_search_pattern" -o $TMP_FILE


echo -e "$VRBM Determining the number of github repos found"
no_github_repos=`cat $TMP_FILE \
    | grep -i "Repository Results" \
    | egrep -io "[0-9]+"`
if [ "$no_github_repos" == "" ]; then
    echo -e "$ERRM No github repos for the pattern \"$keywords_search_pattern\" found"
    exit
else
    echo -e "$OKM Number of Github repos found: $no_github_repos"
fi


echo -e "$VRBM Determining the number of github pages listing repos found"
no_of_pages=`cat $TMP_FILE \
    | egrep -io "\/search\?p=[0-9]+" \
    | cut -d "=" -f2 \
    | sort -n | tail -n1`
if [ "$no_of_pages" == "" ]; then
    no_of_pages=1
fi
echo -e "$OKM No of pages: $no_of_pages"


echo -e "$VRBM Extracting results from each page and writing to $OUT_FILE"
for p in `seq 1 $no_of_pages`; do
    echo -e "$VRBM Getting Page $p from Github"
    if [ ! $p -eq 1 ]; then
        curl -s -k -A "$USER_AGENT" "$GITHUB_DOMAIN/$GITHUB_SEARCH_PATH""$keywords_search_pattern""&p=$p" -o $TMP_FILE
    fi
    page_results=`cat $TMP_FILE | grep -i 'a class="v-align-middle"' --color | cut -d">" -f2,3,4,5,6,7 | sed -r "s/<em>//" | sed -r "s/<\/em>//" | sed -r "s/<\/a>//"`
    no_of_page_results=`echo "$page_results" | wc -l`
    echo -e "$OKM No of results found on page $p: $no_of_page_results"
    if [ ! $p -eq 1 ]; then
        echo -e "$page_results" | xargs -I {} echo -e "$GITHUB_DOMAIN/{}" >> $OUT_FILE
    else
        echo -e "$page_results" | xargs -I {} echo -e "$GITHUB_DOMAIN/{}" > $OUT_FILE
    fi
done

rm $TMP_FILE
