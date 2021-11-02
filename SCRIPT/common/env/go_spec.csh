#!/bin/csh -f

if ($#argv < 1) then
	echo "Error: gospec <SPEC>"
	exit 1
endif

set spec = $argv[1]

# Cate/Func/Spec
set dirs = `find $PRJ_DESIGN -mindepth 2 -maxdepth 3 -type d -iname "*$spec*" | rev | cut -d'/' -f1-3 | rev`

if ($#dirs < 1) then
	echo "Error: Can't find $spec"
	exit 1
endif

set idx = 1
echo "================================================================"
foreach d ($dirs)
	printf ":Num %-6s: $d\n" "<$idx>"
	@ idx++
end
echo "================================================================"

if ($idx > 2) then
	echo -n "Enter number: "
	set num = $<
	
	if ( ($num < 1) || ($num >= $idx) ) then
		echo "Error: Selection number is out of range."
		exit 1
	endif
else
	set num = 1
endif

if (-d $PRJ_HOME/$dirs[$num]) then
	cd $PRJ_HOME/$dirs[$num]
else
	echo "Error: Can't find $dirs[$num]"
	exit 1
endif
