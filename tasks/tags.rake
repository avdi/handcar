namespace :tags do
  SOURCES = FileList['lib/**/*.rb', 'bin/*', 'spec/**/*.rb']

  desc "Generate TAGS file"
  file "TAGS" =>  SOURCES do |t|
    sh "etags #{t.prerequisites.join(' ')} -o #{t.name}"
  end
end
