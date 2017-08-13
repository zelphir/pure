function __parse_current_folder -d "Replace '$HOME' with '~'"
  path_segment $PWD
end

function pretty_parent -S -a current_dir -d 'Print a parent directory, shortened to fit the prompt'
  set -q fish_prompt_pwd_dir_length
    or set -l fish_prompt_pwd_dir_length 1

  # Replace $HOME with ~
  set -l real_home ~
  set -l parent_dir (string replace -r '^'"$real_home"'($|/)' '~$1' (dirname $current_dir))

  if [ $parent_dir = "/" ]
    echo -n /
    return
  end

  if [ $fish_prompt_pwd_dir_length -eq 0 ]
    echo -n "$parent_dir/"
    return
  end

  string replace -ar '(\.?[^/]{'"$fish_prompt_pwd_dir_length"'})[^/]*/' '$1/' "$parent_dir/"
end

function path_segment -S -a current_dir -d 'Display a shortened form of a directory'
  set -l directory
  set -l parent

  switch "$current_dir"
    case /
      set directory '/'
    case "$HOME"
      set directory '~'
    case '*'
      set parent    (pretty_parent "$current_dir")
      set directory (basename "$current_dir")
  end

  echo -n $parent
  echo -ns $directory ' '
end
