# Required packages
libs <- c("rgdal", "maptools", "gridExtra")
lapply(libs, require, character.only = TRUE)

# Import zipcode data
zips <- readOGR(dsn = "sd-zip/sd-zip.shp")
zips.coords <- coordinates(zips)

# Generate IDs for grouping, split into quantiles by x-coordinate
zips.id <- cut(zips.coords[,1], quantile(zips.coords[,1]), include.lowest=TRUE)

# Merge polygons by ID
zips.union <- unionSpatialPolygons(zips, zips.id)

# Export merged polygons
writeOGR(as(zips.union, "SpatialPolygonsDataFrame"), dsn = "sd-zip", layer = "sd-zip-merged", driver = "ESRI Shapefile")

# Plotting, to verify
plot(zips)
plot(zips.union, add = TRUE, border = "red", lwd = 2)