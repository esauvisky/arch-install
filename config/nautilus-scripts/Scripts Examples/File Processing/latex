#!/bin/bash
#
# LaTeX/TeX script for nautilus
#
# Copyright GPL
#

gdialog --msgbox `echo $*` 20 30
for file in "$*"
do
    # Make sure that it is a TeX / LaTeX file
    file_type=`file "$file"`
    case "${file_type/*TeX*/TeX}" in
    	TeX)
	    output_type=`gdialog --title "(La)TeX script)" --radiolist "What form of output do you want" 200 400 3 '1' PDF on '2' PS off '3' DVI off '4' HTML off 2>&1`
	    echo .latex_$$.log
	    case $output_type in
	        1)
		    echo q | pdflatex $file >> .latex_$$.log
		    rm -f ${file/%tex/aux} ${file/%tex/log}
		    ;;
		2)
		    echo q | latex $file >> .latex_$$.log
		    dvips ${file/%tex/dvi} >> .latex_$$.log
		    rm -f ${file/%tex/aux} ${file/%tex/log} ${file/%tex/dvi}
		    ;;
		3)
		    echo q | latex $file >> .latex_$$.log
		    rm -f ${file/%tex/aux} ${file/%tex/log}
		    ;;
		4)
		    echo q | latex2html $file >> .latex_$$.log
		    ;;
		*)
		    exit 0;
	    esac
	    gdialog --title "(La)TeX script)" --textbox .latex_$$.log 25 80
	    rm -f .latex_$$.log
	    ;;
	*)
	    gdialog --title "(La)TeX script)" --msgbox "Could not process $file - Unsupported type: $file_type" 200 400
	    ;;
    esac
done
