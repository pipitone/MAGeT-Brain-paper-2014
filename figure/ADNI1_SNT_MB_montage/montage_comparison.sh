#!/bin/bash

tmp=$(mktemp -d)
ana=$1
lbl=$2
cmp=$3
slice=$4
out=$5
step=0.9

reorder_labels.sh $lbl $tmp/_ordered_lbl.mnc
reorder_labels.sh $cmp $tmp/_ordered_cmp.mnc
autocrop+ -byte -keep_real_range -nearest_neighbour -isostep $step $tmp/_ordered_lbl.mnc $tmp/isostep_lbl.mnc 
autocrop+ -byte -keep_real_range -nearest_neighbour -isostep $step $tmp/_ordered_cmp.mnc $tmp/isostep_cmp.mnc 

autocrop -isostep $step $ana $tmp/isostep_ana.mnc 

mincreshape $tmp/isostep_lbl.mnc $tmp/cropped_lbl.mnc -start 16,64,52 -count 98,98,98 
mincreshape $tmp/isostep_cmp.mnc $tmp/cropped_cmp.mnc -start 16,64,52 -count 98,98,98 
mincreshape $tmp/isostep_ana.mnc $tmp/cropped_ana.mnc  -start 16,64,52 -count 98,98,98 

mincpik -sagittal -auto_range -slice ${slice} $tmp/cropped_ana.mnc $tmp/ana_${slice}_sagittal.png 
mincpik -sagittal -lookup -spectral -image_range 0 20 -slice ${slice} $tmp/cropped_lbl.mnc $tmp/lbl_${slice}_sagittal.png 
mincpik -sagittal -lookup -spectral -image_range 0 20 -slice ${slice} $tmp/cropped_cmp.mnc $tmp/cmp_${slice}_sagittal.png 

composite -dissolve 55 -tile -gravity south $tmp/ana_${slice}_sagittal.png $tmp/lbl_${slice}_sagittal.png $tmp/lbl_overlay_${slice}_sagittal.png 
composite -dissolve 55 -tile -gravity south $tmp/ana_${slice}_sagittal.png $tmp/cmp_${slice}_sagittal.png $tmp/cmp_overlay_${slice}_sagittal.png 

montage -geometry 200x200 -tile 3x1 -background black $tmp/ana_${slice}_sagittal.png \
                                                      $tmp/lbl_overlay_${slice}_sagittal.png \
                                                      $tmp/cmp_overlay_${slice}_sagittal.png  $out
echo $tmp
