## A simple program to merge zip codes areas based on a user-provided csv file of zipcode to zipcode region mappings.

### Usage
1. Git clone this repo and install necessary R packages (sf, r2r).
2. Create a csv file with two columns: `zipcode` and `cluster`.
3. Run 
```
Rscript merge-zip.R <zip_shapefile_input> <zip_clusters_input_csv_file> <zip_merged_shapefile_output> [zip_shapefile_identifier]
```
For example, with the provided sd-zip/ data:  
```
Rscript merge-zip.R sd-zip/sd-zip.shp sd-zip/sd-zipcode-clusters.csv sd-zip/sd-zip-merged.shp
```
Alternatively, run without parameters to use variables in the script. 
4. The output is a shapefile with the merged zip code areas.

### Example files
- sd-zip/: San Diego zip code data (shapefile)
- sd-zip/sd-zipcode-clusters.csv: An arbitrary mapping of zip codes to regions