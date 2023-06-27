libs <- c("sf", "r2r")
lapply(libs, require, character.only = TRUE)

# configuration variables (change as needed)
# Note: the input csv file should have the following format: zip,cluster
zip_clusters_input_csv_file <- "sd-zip/sd-zipcode-clusters.csv"
zip_shapefile_input <- "sd-zip/sd-zip.shp"
zip_shapefile_identifier <- "zip"
zip_merged_shapefile_output <- "sd-zip/sd-zip-merged.shp" # Note: errors if this file already exists

# read csv file with zip -> cluster mapping (multiple zips per cluster)
zip_to_cluster <- read.csv(zip_clusters_input_csv_file, header = TRUE, sep = ",")

# read shapefiles
zips <- st_read(zip_shapefile_input)

# change column names
colnames(zip_to_cluster) <- c("zip", "cluster")

# also create a hashmap frame with cluster -> empty list (but later will be a list of multipolygons)
unique_clusters <- unique(zip_to_cluster$cluster)
cluster_to_multipolygon_list <- hashmap()
for (cluster in unique_clusters) {
    cluster_to_multipolygon_list[[cluster]] <- list()
}	

# loop through all of the zips and for every zip, find the cluster it belongs to and add it to the list of multipolygons
for (i in 1:nrow(zips)) {
    zip <- zips[i, ]
    zip_code <- zip[[zip_shapefile_identifier]]
    matching_cluster <- subset(zip_to_cluster, zip == zip_code)$cluster[1]
    cluster_to_multipolygon_list[[matching_cluster]] <- append(cluster_to_multipolygon_list[[matching_cluster]], list(zip))
}

merged_multipolygons <- list()

# loop through all of the clusters and merge the zip code multipolygons into one big multipolygon
for (cluster in unique_clusters) {
    multipolygon_list <- do.call(rbind, cluster_to_multipolygon_list[[cluster]])
    union_multipolygon <- st_union(multipolygon_list)
	# add cluster id to multipolygon
	union_multipolygon <- st_sf(union_multipolygon, cluster_id = cluster)
	# prevent coordinate system error
    if (length(merged_multipolygons) == 0) {
        merged_multipolygons <- union_multipolygon
    } else {
        merged_multipolygons <- append(merged_multipolygons, union_multipolygon)
    }
}

# merge all the clusters into one multipolygon, but preserve boundaries
merged_multipolygon <- st_combine(merged_multipolygons)

st_write(merged_multipolygon, zip_merged_shapefile_output)

# for sanity check
plot(st_combine(zips))
plot(merged_multipolygon, add = TRUE, border = "red", lwd = 2)
