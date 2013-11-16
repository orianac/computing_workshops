#!/bin/bash

files=$@

#the dollar/at combo will make the program act upon every file i denote after the program.
#in this way i can draw files into the program and tell the program to act upon them.

for file in $files; do

#this for loop acts upon every file that i denote. i selected them by inputting ./avg-by-month.bash fluxes* to the commandline

	echo "computing monthly averages in file '$file'..." 1>&2

#this script gives me a real-time view into which file is being worked on

	fileOutput=`echo "$file" | sed -e "s/^fluxes_/monthly_precipitation_/g" |cut -c 1-36`
	awk '
		{
			YMsum[$1,$2] += $4
		}

#this creates an array, kind of like a matrix of numbers, for a set of variables for every year/month combination.
#it adds every value in column 4 to the variable if column 4 matches the year/month tag.

		END {
			for (monthyear in YMsum) {
				month=substr(monthyear,5,6)

#the ending part was tricky because i had started treating the ymsum as a string.
#i had to extract just the month part of the string so as to average the monthly precipitations by month as opposed to year


				Msum[month] += YMsum[monthyear]
				Mcount[month] += 1
			}

#like in previous problems, there was no guarantee that the values would be in the correct monthly order.
#sorting them by month numerical value then only printing the second precipitation value produced the ordered data.


			for (month in Msum) {
				printf "%s %f\n", month, (Msum[month]/Mcount[month])
			}
		}
	' $file | sort -n | awk '{print($2)}' > $fileOutput

	echo "averages written to '$fileOutput'" 1>&2
done
#i really liked putting in the stage markers so, this ending piece tells us that the program is done.
#i tested the program by choosing a random file (fluxes_-14.2500_38.2500.2500) and arbitrarily the month of january.
#i then input the file into excel and checked that the output was the same via excel and the bash program (was ~210 in both).

