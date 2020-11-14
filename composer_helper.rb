def ask_for_config(question, default_config)
  result = $USE_CUSTOM_CONFIG ? ask("#{question}  [#{default_config}]") : default_config
  result.presence || default_config
end

def remove_comments(file)
  gsub_file(file, /^\s*#.*$\n/, '')
end

def remove_gem(*names)
  names.each do |name|
    gsub_file 'Gemfile', /gem '#{name}'.*\n/, ''
  end
end

def replace_myapp(file)
  gsub_file file, /myapp/, app_name, verbose: false
end

def replace_app_root_path(file)
  gsub_file file, /\/data\/www/, $DEST_APP_ROOT_PATH, verbose: false
end

def get_remote(src, dest = src)
  if ENV['RAILS_TEMPLATE_DEBUG'].present?
    repo = File.join(File.dirname(__FILE__), 'files/')
  else
    repo = 'https://raw.githubusercontent.com/jiz4oh/rails-template/master/files/'
  end
  remote_file = repo + src
  get(remote_file, dest, force: true)
  replace_myapp(dest)
  replace_app_root_path(dest)
end

def get_remote_dir(names, dir)
  names.each do |name|
    src = File.join(dir, name)
    get_remote(src)
  end
end

def remove_dir(dir)
  run("rm -rf #{dir}")
end
