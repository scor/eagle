# prepare the diff directory and make sure it is empty
mkdir -p diff
rm -r diff/*

for img in `cd base; ls *.png`
do
  echo "Comparing $img"
  compare -metric ae base/$img actual/$img diff/$img
done

