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

window="-start 16,64,52 -count 98,98,98"
window="-start 40,90,52 -count 50,50,98"
mincreshape $tmp/isostep_lbl.mnc $tmp/cropped_lbl.mnc $window
mincreshape $tmp/isostep_cmp.mnc $tmp/cropped_cmp.mnc $window
mincreshape $tmp/isostep_ana.mnc $tmp/cropped_ana.mnc $window

mincpik -sagittal -auto_range -slice ${slice} $tmp/cropped_ana.mnc $tmp/ana_${slice}_sagittal.png 
mincpik -sagittal -lookup -spectral -image_range 0 2 -slice ${slice} $tmp/cropped_lbl.mnc $tmp/lbl_${slice}_sagittal.png 
mincpik -sagittal -lookup -spectral -image_range 0 4 -slice ${slice} $tmp/cropped_cmp.mnc $tmp/cmp_${slice}_sagittal.png 

composite -dissolve 55 -tile -gravity south $tmp/ana_${slice}_sagittal.png $tmp/lbl_${slice}_sagittal.png $tmp/lbl_overlay_${slice}_sagittal.png 
composite -dissolve 55 -tile -gravity south $tmp/ana_${slice}_sagittal.png $tmp/cmp_${slice}_sagittal.png $tmp/cmp_overlay_${slice}_sagittal.png 

montage -tile x1 -geometry +0+0 -background black $tmp/ana_${slice}_sagittal.png \
                                   $tmp/lbl_overlay_${slice}_sagittal.png \
                                   $tmp/cmp_overlay_${slice}_sagittal.png  $out
rm -rf $tmp
