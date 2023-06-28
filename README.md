# R-merge-zips

## A simple program to merge zip codes areas based on a user-provided csv file of zipcode to zipcode region mappings.

### Configuration & Usage
1. Git clone this repo and install necessary R packages (sf, r2r).
2. Create a csv file with two columns: `zipcode` and `cluster`.
3. Usage: 
	``` 
	Rscript merge-zip.R [options]
		-i INPUT, --input=INPUT
				Input shapefile
		-c CLUSTERS, --clusters=CLUSTERS
				Input csv file with zip -> cluster mapping
		-o OUTPUT, --output=OUTPUT
				Output shapefile
		-s SHAPEFILE-IDENTIFIER, --shapefile-identifier=SHAPEFILE-IDENTIFIER
				Shapefile identifier
		-p, --draw-plots
				Draw plots
		-r, --override-existing-output
				Override existing output
		-h, --help
				Show this help message and exit
	```
	Example: 
	```
	Rscript merge-zip.R -i sd-zip/sd-zip.shp -c sd-zip/sd-zipcode-clusters.csv -o sd-zip/sd-zip-merged.shp -s zip -p -r
	```
	__Note: If any parameters are not provided, the program will use the values hard-coded in the script.__

4. The output is a shapefile with the merged zip code areas.

### Example files
- sd-zip/: San Diego zip code data (shapefile)
- sd-zip/sd-zipcode-clusters.csv: An arbitrary mapping of zip codes to regions