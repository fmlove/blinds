#anonymise and combine multiple folders of images for blind analysis
#currently works on Windows only

if (!require("uuid")) install.packages("uuid")
library(uuid)
if (!require("tools")) install.packages("tools")
library(tools)


blind <- function(){
  
  filesep = .Platform$file.sep
  
  #choose.dir windows-only, but tk_choose.dir hangs
  #use console input for now, look into better options for Mac/Linux
  
  if(exists('choose.dir', mode = 'function')){
    destination = choose.dir(default = getwd(), caption = "Select destination folder")
  }
  else{
    destination = readline(prompt = 'Enter the path to the directory where you want the renamed files to be saved: ')
  }
 
  
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
  
  
  files = unlist(lapply(dirs, function(d){ list.files(d) }))
  
  files.df = data.frame(original = files)
  files.df$dir = unlist(lapply(dirs, function(d){ rep(d, length(list.files(d))) }))
  files.df$uuid = sapply(1:nrow(files.df), UUIDgenerate)
  files.df$new = paste(files.df$uuid, file_ext(files.df$original), sep = '.')
  
  files.df$old_path = paste(files.df$dir, files.df$original, sep = filesep)
  files.df$new_path = paste(destination, files.df$new, sep = filesep)
  
  
  sapply(1:nrow(files.df), function(i){ file.copy(from = files.df$old_path[i], to = files.df$new_path[i]) })
  write.csv(files.df, file = paste(destination, 'key.csv', sep = filesep)) #TODO - account fotr folder with existing key.csv - automatc increment and argument to specify
}

unblind <- function(){
  
  filesep = .Platform$file.sep
  
  target = choose.dir(default = getwd(), caption = "Select target folder")
  key = read.csv(file = paste(target, 'key.csv', sep = filesep), stringsAsFactors = F) #TODO - account for multiple
  sapply(1:nrow(key), 
         function(i){ 
           file.rename(from = key$new_path[i], to = paste(target, key$original[i], sep = filesep));
         }
  )
  
  
}