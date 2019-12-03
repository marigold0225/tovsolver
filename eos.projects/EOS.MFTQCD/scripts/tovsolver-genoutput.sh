#!/bin/bash
#
#
# tovsolver-genoutput.sh - Process the output files generated by TOV_Solver and
#							generates a file with mass, radius, pressure, etc.
#
# Author: 	Rodrigo Alvares de Souza
# 			rsouza01@gmail.com
#
#
# History:
# Version 0.4: 2014/04/04 (rsouza) - improving legibility, adding coments, etc.
# Version 0.5: 2014/04/18 (rsouza) - Added error treatment, sanity checks and some colors :-).
# Version 0.6: 2015/05/11 (rsouza) - New name, minor improvements.
#

#FUNCTIONS DEFINITIONS

print2stringslncolor () {
        echo -e "\e[0m$1\e[1;34m$2\e[0m"
}


print2stringslncolorERROR () {
        echo -e "\e[0m$1\e[1;91m$2\e[0m\n"
}

printlncolor () {
        echo -e "\e[1;34m$1\e[0m\n"
}

printlncolorERROR () {
        echo -e "\e[1;91m$1\e[0m\n"
}
#END FUNCTIONS DEFINITIONS

#Folders and files
_INPUT_DIR="./output/"
_OUTPUT_DIR="./output/"
_MASS_RADIUS_FILE=${_OUTPUT_DIR}'starStructureOutput.csv'




_USE_MESSAGE="
Usage: $(basename "$0") [OPTIONS]

OPTIONS:
  -o, --outputfile      Sets the Output file, '${_MASS_RADIUS_FILE}' by default.
  -h, --help            Show this help screen and exits.
  -V, --version         Show program version and exits.
"

_VERSION=$(grep '^# Version ' "$0" | tail -1 | cut -d : -f 1 | tr -d \#)

#Command line arguments
case $1 in

		-o | --outputfile) 
                        shift
                        _MASS_RADIUS_FILE=${_OUTPUT_DIR}$1 
                ;;

		-h | --help)
			echo "$_USE_MESSAGE"
			exit 0
		;;

		-V | --version)
			echo -n $(basename "$0")
                        echo " ${_VERSION}"
			exit 0
		;;
esac

#Patterns
rhoPattern="EPSILON_0"
pressurePattern="PRESSURE_0"
radiusPattern="Star Radius (km)"
quarkRadiusPattern="Quark Core Radius (km)"
massPattern="Star Mass (Solar Units)"
quarkCoreMassPattern="Quark Core Mass (Solar Units)"
infoEntropyPattern="Information Entropy"
diseqPattern="Disequilibrium"
complexityPattern="Complexity"


printlncolor "\n\n__________________________________________________________________________________________________________"
printlncolor "-----------------------------  TOV Solver Mass/Radius Extractor ${_VERSION} -----------------------------"
printlncolor "__________________________________________________________________________________________________________"


print2stringslncolor  "Output folder: " "'${_OUTPUT_DIR}'."
print2stringslncolor  "Output file  : " "'${_MASS_RADIUS_FILE}'."

#Replaces the INTERNAL FIELD SEPARATOR, but storing a copy first
OLD_IFS=$IFS
IFS=':'

echo "#central density,	central pressure, radius,	mass,   quarkRadiusPattern, quarkCoreMassPattern,   information entropy,	disequilibrium,	complexity" > $_MASS_RADIUS_FILE

for _FILE_NAME in ${_INPUT_DIR}*.txt; do 

	print2stringslncolor "Processing file " "'$_FILE_NAME'"; 
	while read line; do 

		#	TODO: improve these snippet of code. 
		#	The fields must be in that order, 
		#	otherwise the parser won't work.
		if [[ "$line" == *$rhoPattern* ]]
		then
			arr=($line)
			rho_0=${arr[1]// }
		elif [[ "$line" == *$pressurePattern* ]]
		then
			arr=($line)
			p_0=${arr[1]// }
		elif [[ "$line" == *$radiusPattern* ]]
		then
			arr=($line)
			radius=${arr[1]// }
		elif [[ "$line" == *$massPattern* ]]
		then
			arr=($line)
			mass=${arr[1]// }
		elif [[ "$line" == *$quarkRadiusPattern* ]]
		then
			arr=($line)
			quarkRadius=${arr[1]// }
		elif [[ "$line" == *$quarkCoreMassPattern* ]]
		then
			arr=($line)
			quarkCoreMass=${arr[1]// }
		elif [[ "$line" == *$infoEntropyPattern* ]]
		then
			arr=($line)
			infoEntropy=${arr[1]// }
		elif [[ "$line" == *$diseqPattern* ]]
		then
			arr=($line)
			disequilibrium=${arr[1]// }
		elif [[ "$line" == *$complexityPattern* ]]
		then
			arr=($line)
			complexity=${arr[1]// }
			echo -e "${rho_0}, ${p_0}, ${radius}, ${mass}, ${quarkRadius}, ${quarkCoreMass}, ${infoEntropy}, ${disequilibrium}, ${complexity}" >> $_MASS_RADIUS_FILE
		fi
	done < "$_FILE_NAME"

done

#Restoring the INTERNAL FIELD SEPARATOR
IFS=$OLD_IFS

echo "Sorting..."

LANG=en_US.UTF-8

# TODO: Find out why the sort is not working with the -g switch
# sort -gk1,1 $_MASS_RADIUS_FILE

echo "End of processing."

echo "Processing output figure with Gnuplot..."
gnuplot ./scripts/massaRaio.gnuplot
echo "Done."

#evince massaRaio.eps
