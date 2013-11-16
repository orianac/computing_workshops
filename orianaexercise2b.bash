#!/bin/bash

# This program calculates the area-weighted average of precipitation over n 0.5*0.5 degree grids corresponding to n input files. It assumes the earth is spherical.
# Run the program on files of the form "monthly_precipitation_latitude_longitude  as follows: monthly_precipitation*
# In the context of the computing workshop exercise (for which this program was created), one can calculate the average precipitation
# for the two geographic regions separately by running the program for monthly_precipitation_1* and then monthly_precipitation_-*.
# Be sure to change the file name of the finalareaweightedprecipitation file because the program will overwrite the output on subsequent runs.

# The mathematical design assumes the earth is a sphere and finds a "weighting factor" which accounts for the latitude-dependence of the degree/distance relationship.

files=$@

sumfactors=0

for file in $files; do
	echo "processing '$file' ..." 1>&2
# The echoes allow the user to watch the file being processed and see both the corresponding weighting factor and the incrementing sum of factors.
	latitude=`echo "$file" | cut -d "_" -f3`
	longitude=`echo "$file" | cut -d "_" -f4`

	factor=`echo "scale=8;s((90- $latitude)*3.14159/180)"|bc -l`
	echo weighting factor for latitude $latitude is $factor 

	sumfactors=`echo "$sumfactors + $factor"|bc`
	echo incremental sum of scaling factors ":" "$sumfactors"

	awk -v f=$factor '
				{
					printf "%f\n", $1*f
				}
	' $file >scaledprecip\_$latitude\_$longitude
done

echo "final sum of scaling factors is $sumfactors"
paste -d '\t' scaledprecip* > allprecip
finalscaling=$sumfactors
awk -v f=$finalscaling '
	{ 
	sumprecips=0
	for(i=1; i<=NF;i++) 
		{sumprecips+=$i}
		{
		print sumprecips/f
		}
	}' allprecip>finalareaweightedprecipitation
rm scaledprecip*
rm allprecip
# One could look at the scaledprecip and allprecip files to confirm that the program was running as planned. They are deleted for convenience.
# Results can be found in the file "finalareaweightedprecipitation"
# Quality control: I compared the program output from two input files to the same calculation performed in Excel. Results were consistent.
