libs <- c("sf", "r2r", "optparse")
sapply(libs, library, character.only = TRUE)

# configuration variables (change as needed)
# Note: the input csv file should have the following format: zip,cluster
zip_shapefile_input <- "sd-zip/sd-zip.shp"
zip_clusters_input_csv_file <- "sd-zip/sd-zipcode-clusters.csv"
zip_merged_shapefile_output <- "sd-zip/sd-zip-merged.shp" # Note: errors if this file already exists
zip_shapefile_identifier <- "zip"
draw_plots <- FALSE
override_existing_output <- FALSE

option_list <- list(
    make_option(c("-i", "--input"), action = "store", type = "character", default = zip_shapefile_input, help = "Input shapefile"),
    make_option(c("-c", "--clusters"), action = "store", type = "character", default = zip_clusters_input_csv_file, help = "Input csv file with zip -> cluster mapping"),
    make_option(c("-o", "--output"), action = "store", type = "character", default = zip_merged_shapefile_output, help = "Output shapefile"),
    make_option(c("-s", "--shapefile-identifier"), action = "store", type = "character", default = zip_shapefile_identifier, help = "Shapefile identifier"),
    make_option(c("-p", "--draw-plots"), action = "store_true", default = draw_plots, help = "Draw plots"),
    make_option(c("-r", "--override-existing-output"), action = "store_true", default = override_existing_output, help = "Override existing output")
)

opt_parser <- parse_args(OptionParser(option_list = option_list))

zip_shapefile_input <- opt_parser$input
zip_clusters_input_csv_file <- opt_parser$clusters
zip_merged_shapefile_output <- opt_parser$output
zip_shapefile_identifier <- opt_parser[["shapefile-identifier"]]
draw_plots <- opt_parser[["draw-plots"]]
override_existing_output <- opt_parser[["override-existing-output"]]

# read csv file with zip -> cluster mapping (multiple zips per cluster)
zip_to_cluster <- read.csv(zip_clusters_input_csv_file, header = TRUE, sep = ",", stringsAsFactors = FALSE)
# change column names
colnames(zip_to_cluster) <- c("zip", "cluster")

# read shapefiles
zips <- st_read(zip_shapefile_input)

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
    union_multipolygon <- st_sf(union_multipolygon)
    union_multipolygon$cluster <- cluster
    # add to list of multipolygons
    merged_multipolygons <- append(merged_multipolygons, list(union_multipolygon))
}

# merge all the clusters into one multipolygon, but preserve boundaries
merged_multipolygon <- do.call(rbind, merged_multipolygons)

if (draw_plots) {
    plot(st_combine(zips))
    plot(merged_multipolygon, add = TRUE, border = "red", lwd = 2)
}

if (override_existing_output) {
    st_write(merged_multipolygon, zip_merged_shapefile_output, append = FALSE)
} else {
    st_write(merged_multipolygon, zip_merged_shapefile_output)
}
