module FolderExplorer
  def retrieve_filenames_without_ext(path, process_filename)
    filenames = Dir["#{path}/*.rb"]
    return filenames.map{|filename| process_filename.call filename}
  end
end
