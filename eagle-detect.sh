for img in `cd old; ls *.png`
do
  echo "Processing $img"
  compare -metric ae old/$img new/$img diff/$img
done

