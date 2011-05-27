die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "First argument required and must correspond to the base URL of the site to crawl (must end with /)"

BASE=$1
mkdir -p actual

for URL in `cat urls.txt`
do
  FILE=$URL
  if [ "$URL" = "<front>" ]; then
    URL=''
  fi
  echo "Processing $BASE$URL"
  ./CutyCapt --url=$BASE$URL --out=actual/$FILE.png
  #compare -metric ae old/$img new/$img diff/$img
done

