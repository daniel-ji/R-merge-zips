# Required packages
libs <- c("rgdal", "maptools", "gridExtra", "rjson")
lapply(libs, require, character.only = TRUE)

ZIP_SHAPEFILE <- "sd-zip.geojson" # Change this to your file path
ZIP_CLUSTER_FILE <- "sd-zip-cluster.json" # Change this to your file path

# Setup shapefile data
zips <- readOGR(dsn = ZIP_SHAPEFILE)
zips.coords <- coordinates(zips)

# Setup cluster data
clusterData <- fromJSON(file = ZIP_CLUSTER_FILE)

# create a list of ids, one for each zipcode
print(length(zips.coords[,1]))
zips.id <- rep(NA, length(zips.coords))

# iterate through each zipcode, assigning an id
for (i in 1:length(clusterData)) {
  for (j in 1:length(clusterData[[i]])) {
	zips.id[[clusterData[[i]][j]]] <- i
  }
}

# print(zips.id)


# # Merge polygons by ID
# zips.union <- unionSpatialPolygons(zips, zips.id)

# # Plotting
# plot(zips)
# plot(zips.union, add = TRUE, border = "red", lwd = 2)