# README
DeanLiddell  
Friday, May 29, 2015  
<link rel="stylesheet" type="text/css" href="stylesheets/stylesheet.css">

## Data Source

*(message from NOAA...)*

NOAA's former three data centers have merged into the National Centers for 
Environmental Information (NCEI). The demand for high-value environmental data 
and information has dramatically increased in recent years. To improve our 
ability to meet that demand, NOAA’s former three data centers – the 
[National Climatic Data Center][01], the [National Geophysical Data Center][02], 
and the [National Oceanographic Data Center][03], which includes the 
[National Coastal Data Development Center][04] – have merged into the National Centers 
for Environmental Information (NCEI).

<center>![NOAA National Centers for Environmental Information](images/noaa-ncei.jpg)</center>

"...(NCEI) is responsible for preserving, monitoring, assessing, and providing 
public access to the Nation's treasure of climate and historical weather 
data and information." For climate information, data acess, and support refer
to the U.S. Department of Commerce, National Oceanic and Atmospheric 
Administration web site: [www.ncei.noaa.gov.][05]. For information relevant to
the Archival Data Sets listed below, refer to 
[National Weather Service Instruction 10-1605][06], Storm Data Preparation.

## Data Sets

The directive listed above (National Weather Service Instruction 10-1605), which
is part of NOAA's Operations and Services Performance Standards, dating from 
August 2007, provides a comprehensive "Storm Data Event Table" which standardizes
the "Event Name" and "Designator" that will be used to record all observed
severe weather events. *(NOAA)* "The only events permitted in Storm Data are listed 
in this table. The chosen event name should be one that describes the meterological
event leading to fatalities, injuries, damage, etc."

### Storm Events Database

The database currently contains data from January 1950 to January 2015, as entered 
by NOAA's National Weather Service (NWS). Due to changes in the data collection 
and processing procedures over time, there are unique periods of records available 
depending on the event type. 

1.  <u>Tornado</u>: From 1950 through 1954, only tornado events were recorded.  

2.  <u>Tornado, Thunderstorm Wind, and Hail</u>: From 1955 through 1992, only 
    tornado, thunderstorm wind and hail events were keyed from the paper 
    publications into digital data. From 1993 to 1995, only tornado, thunderstorm 
    wind and hail events have been extracted from the [Unformatted Text Files.][07]  
    
3.  <u>All Event Types (48 from Directive 10-1605)</u>: From 1996 to present, 48 
    event types are recorded as defined in NWS Directive 10-1605.

4.  NOTE: In addition to the above three(3) items, the Storm Events Database 
    (above link) also lists important information on "Collection Sources" and
    "Supplemental Information" necessary to understanding the data series.

The various files that comprise the Storm Events Database are available from
NOAA via HTTP or FTP. For the later, the top of the folder tree for storm
events starts [here][08]. If you are using Windows® then it would be best to
open the FTP site in your Windows Explorer rather than use your browser. If you 
happen to be using Mozilla, then an add-in like DownThemAll! is likely the most 
useful tool for pulling data to your machine since the application supports 
multiple concurrent streams, in this case only limited by NOAA server policies.

Overall, the Storm Events Database (either presented in separate per-year files
for each reporting type, or in a comprehesive Microsoft® Access database, which
is available on the site for download) still relies on the original reporting
methods during each time-span (above) as opposed to updating the entire data set
with the "Event Types" defined in Directive 10-1605. Considering the usefulness
of this later approach led to the creation of a "concordance" table.

##### StormDataEventTable

The file "StormDataEventTable.csv" is a concordance table comprised of the 883
distinct (unique) event descriptors (derived from scrubbing names to remove
leading, trailing, and embedded spaces, as well as commas and periods – which is
significantly less than the 985 you will discover by using the 'unique' function
on the original 'EVTYPE' column) that are correlated with the 48 event descriptors 
(plus an "Unknown" name) set forth in the above directive. Use of this concordance 
table in "R" is relatively straight forward. Assume the following piece of code 
could be adapted to your "Reproducible Research" project, then this is how you 
would apply the concordance.


```r
# Load the downloaded archive file directly into an R data.frame named 'df'.
df <- read.csv(bzfile("StormData.csv.bz2"), header = TRUE, stringsAsFactors = FALSE)

# Load the downloaded concordance table into an R data.frame named 'kv'.
kv <- read.csv("StormDataEventTable.csv", header = TRUE, stringsAsFactors = FALSE)

# Rename the columns in 'df' to be more informative and easier to reference.
names(df) <- c("state.fips", "b.date", "b.time", "b.tz", "county.fips", "county.name", 
    "state.usps", "event.type", "b.range", "b.azimuth", "b.location", "e.date", 
    "e.time", "e.county.fips", "e.county.name", "e.range", "e.azimuth", "e.location", 
    "length", "width", "force", "magnitude", "fatalities", "injuries", "property.damage", 
    "property.exp", "crop.damage", "crop.exp", "field.office", "state.office", 
    "zone.name", "b.latitude", "b.longitude", "e.latitude", "e.longitude", "remarks", 
    "record.id")

# Write a function that will scrub the old event type descriptors.
scrub <- function(s) {
    s <- gsub("[\\.,]", "", s, perl = TRUE)  # remove select punctuation.
    s <- gsub("\\s+", " ", s, perl = TRUE)  # truncate multiple spaces.
    s <- gsub("^\\s+|\\s+$", "", s, perl = TRUE)  # remove leading and trailing spaces.
    s <- gsub("(.*)", "\\L\\1", s, perl = TRUE)  # lowercase.
    return(s)
}

# Now 'scrub' the old event type descriptors.
df$event.type <- scrub(df$event.type)

# Now use the correspondence table to update the old event type descriptors.
df$event.type <- kv$VALUE[match(df$event.type, kv$KEY, nomatch = 1)]
```

The only time consuming operation is loading the first data set. Each subsequent
operation takes just moments. Here are some sample times:


```r
> system.time(kv <- read.csv("StormDataEventTable.csv", header = TRUE, stringsAsFactors = FALSE))
  user  system  elapsed  
  0.02    0.00     0.01  

> system.time(names(df) <- c(...))
  user  system  elapsed  
     0       0        0  

> system.time(df$event.type <- scrub(df$event.type))
  user  system  elapsed  
  1.73    0.00     1.73  

> system.time(df$event.type <- kv$VALUE[match(df$event.type, kv$KEY, nomatch = 1)])
  user  system  elapsed  
  0.03    0.00     0.06  
```

As you can see, for 902,297 records it takes less than two(2) seconds to scrub
the event type descriptors and to replace them with the concordance of 48
updated event type descriptors. This two(2) seconds of processing time will be
invaluable to performing a clear, logical, and convincing data analysis.


[01]:http://www.ncdc.noaa.gov/
[02]:http://www.ngdc.noaa.gov/
[03]:http://www.nodc.noaa.gov/
[04]:http://www.ncddc.noaa.gov/
[05]:http://www.ncei.noaa.gov/
[06]:https://www.ncdc.noaa.gov/stormevents/pd01016005curr.pdf
[07]:https://www.ncdc.noaa.gov/stormevents/details.jsp?type=collection
[08]:ftp://ftp.ncdc.noaa.gov/pub/data/swdi/stormevents/
