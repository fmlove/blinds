% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/blinder.R
\name{unblind}
\alias{unblind}
\title{Restore original file names.}
\usage{
unblind(target = NULL, key.name = "key.csv", key.dir = NULL, rename.new = TRUE)
}
\arguments{
\item{target}{The directory containing blinded files to restore.  If this is not provided, the user will be prompted for a directory.}

\item{key.name}{Name of the CSV file containing the key of original and cryptic names.  Defaults to \code{key.csv}.}

\item{key.dir}{Directory where the CSV key is saved.  If not provided, the target directory is assumed.}

\item{rename.new}{Whether or not new files containing the uuids should be renamed.  This can be helpful if you've generated analysis files based on the blinded file names.  The uuid will be replaced with the original file name, with the rest of the new file name unchanged.  This may also be required if you've moved the files to a new directory after blinding.}
}
\description{
Restore original file names.
}
