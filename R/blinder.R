
#' Copy or rename files with cryptic names to facilitate blinded manual analysis.
#'
#' @param destination If files are to be copied, the destination folder where the files and key will be saved.
#' If this is not provided, the user will be prompted for a directory.
#' @param input A vector of directory paths specifying where the files are located.
#' @param key.name Name of the output CSV file containing the key of original and cryptic names.  Defaults to \code{key.csv}.
#' @param key.dir Directory where the CSV key will be saved.  If not provided, the key will be saved in the same directory as the blinded files.
#'
#' @export
#'
#' @importFrom uuid UUIDgenerate
#' @importFrom tools file_ext
blind <- function(destination = NULL, input = NULL, key.name = "key.csv", key.dir = NULL){

  filesep = .Platform$file.sep

  #choose.dir windows-only, but tk_choose.dir hangs
  #use console input for now, look into better options for Mac/Linux
  if(missing(destination)){
    if(exists('choose.dir', mode = 'function')){
      destination = choose.dir(default = getwd(), caption = "Select destination folder")
    }
    else{
      destination = readline(prompt = 'Enter the path to the directory where you want the renamed files to be saved: ')
    }
  }


  if(missing(input)){
    last = ""
    dirs = c()

    while(!is.na(last)){
      if(exists('choose.dir', mode = 'function')){
        last = choose.dir(default = "", caption = "Select an image folder, or press Cancel if you have finished selecting")
      }
      else{
        last = readline(prompt = 'Enter the path to a directory containing image files.  If you are finished, type \'done\': ')
        if(toupper(last) == 'DONE'){ last = NA }
      }
      if(!is.na(last)) dirs = c(dirs, last)
    }
  }
  else{
    dirs = input
  }

  if(missing(key.dir)){ key.dir = destination }



  #generating UUIDs and assembling key
  files = unlist(lapply(dirs, function(d){ list.files(d) }))

  files.df = data.frame(original = files)
  files.df$dir = unlist(lapply(dirs, function(d){ rep(d, length(list.files(d))) }))
  files.df$uuid = sapply(1:nrow(files.df), UUIDgenerate)
  files.df$new = paste(files.df$uuid, file_ext(files.df$original), sep = '.')

  files.df$old_path = paste(files.df$dir, files.df$original, sep = filesep)
  files.df$new_path = paste(destination, files.df$new, sep = filesep)

  #file handling
  sapply(1:nrow(files.df), function(i){ file.copy(from = files.df$old_path[i], to = files.df$new_path[i]) })

  write.csv(files.df, file = paste(key.dir, key.name, sep = filesep))


}



#' Restore original file names.
#'
#' @param target The directory containing blinded files to restore.  If this is not provided, the user will be prompted for a directory.
#' @param key.name Name of the CSV file containing the key of original and cryptic names.  Defaults to \code{key.csv}.
#' @param key.dir Directory where the CSV key is saved.  If not provided, the target directory is assumed.
#' @param rename.new Whether or not new files containing the uuids should be renamed.  This can be helpful if you've generated analysis files based on the blinded file names.  The uuid will be replaced with the original file name, with the rest of the new file name unchanged.  This may also be required if you've moved the files to a new directory after blinding.
#'
#' @export
#'
#' @importFrom stringr str_detect
unblind <- function(target = NULL, key.name = "key.csv", key.dir = NULL, rename.new = TRUE){

  filesep = .Platform$file.sep
  if(missing(target)){
    if(exists('choose.dir', mode = 'function')){
      target = choose.dir(default = getwd(), caption = "Select target folder")
    }
    else{
      target = readline(prompt = 'Enter the path to the target directory: ')
    }
  }

  if(missing(key.dir)){ key.dir = target }

  key = read.csv(file = paste(key.dir, key.name, sep = filesep), stringsAsFactors = F) #TODO - account for multiple

  if(rename.new == TRUE){
    files = list.files(target)
    sapply(files, function(f){
        uuid_matches = subset(key$uuid, str_detect(f, key$uuid));
        new_name = f;
        for(m in uuid_matches){
          #two passes to avoid duplicating file extensions
          new_name = sub(key[key$uuid == m, "new"], key[key$uuid == m, "original"], new_name);#first pass to check for 'new' - uuid with file extension, should be original file
          new_name = sub(m, key[key$uuid == m, "original"], new_name);#second pass to check for uuid in file name - most likely new/changed
        }
        file.rename(from = paste(target, f, sep = filesep), to = paste(target, new_name, sep = filesep));
      })
  }
  else{
    sapply(1:nrow(key),
           function(i){
             file.rename(from = key$new_path[i], to = paste(target, key$original[i], sep = filesep));
           }
    )
  }

}





#---INTERNAL METHODS---
#' Appends underscore and increasing number to the end of a filename until there is no longer a clash
#'
#' @param base Initial file name, without extension
#' @param ext File extension
#' @param dir Directory path
handleClash <- function(base, ext, dir){
  file = paste(base, ext, sep = ".")
  if(file.exists(paste(dir, file, sep = filesep))){

    clash = TRUE
    suffix = 1
    new = ""

    while(clash == TRUE){
      new = paste0(base, "_", suffix, ".", ext)
      if(file.exists(paste(dir, new, sep = filesep))){
        suffix = suffix + 1
      }
      else{
        clash = FALSE
      }
    }

    final = new
  }
  else{ final = file }

  return(final)
}
