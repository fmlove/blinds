[![DOI](https://zenodo.org/badge/252126544.svg)](https://zenodo.org/badge/latestdoi/252126544)

# blinds
An R package to blind files for manual analysis tasks

## Why?
Automated image analysis has come a long way in recent years, but sometimes you still run into tasks that need to be handled manually.  This little package is intended to make it easy to avoid bias in your manual analysis tasks.  It works by renaming your files with universally unique identifiers (UUIDs), and then restoring your original names once you're finished.

## How?
You can install blinds with the following code:
```
if (!require("remotes")) install.packages("remotes")
remotes::install_github("fmlove/blinds")
library(blinds)
```

I'm in the process of writing some tutorials, so stay tuned!
