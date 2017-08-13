# Whether or not is a fresh session
set -g __pure_fresh_session 1

# Deactivate the default virtualenv prompt so that we can add our own
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
set -gx LANG en_GB.utf-8

# Symbols

__pure_set_default pure_symbol_prompt ""

# Colors

__pure_set_default pure_color_red (set_color red)
__pure_set_default pure_color_green (set_color green)
__pure_set_default pure_color_blue (set_color blue)
__pure_set_default pure_color_yellow (set_color yellow)
__pure_set_default pure_color_cyan (set_color cyan)
__pure_set_default pure_color_gray (set_color 93A1A1)
__pure_set_default pure_color_purple (set_color purple)
__pure_set_default pure_color_normal (set_color normal)

__pure_set_default pure_username_color $pure_color_gray
__pure_set_default pure_host_color $pure_color_gray
__pure_set_default pure_root_color $pure_color_normal

# Determines whether the username and host are shown at the begining or end
# 0 - end of prompt, default
# 1 - start of prompt
# Any other value defaults to the default behaviour
__pure_set_default pure_user_host_location 0

# Max execution time of a process before its run time is shown when it exits
__pure_set_default pure_command_max_exec_time 5

function fish_mode_prompt
end

function fish_prompt
  # Save previous exit code
  set -l exit_code $status

  # Set default color symbol to green meaning it's all good!
  set -l color_symbol $pure_color_green

  # Template

  set -l user_and_host ""
  set -l current_folder (__parse_current_folder)
  set -l git_branch_name ""
  set -l git_arrows ""
  set -l prompt ""

  # Do not add a line break to a brand new session
  # if test $__pure_fresh_session -eq 0
  #   set prompt $prompt "\n"
  # end

  # Check if user is in an SSH session
  if [ "$SSH_CONNECTION" != "" ]
    set -l host (hostname -s)
    set -l user (whoami)

    if [ "$user" = "root" ]
      set user "$pure_root_color$user"
    else
      set user "$pure_username_color$user"
    end

    # Format user and host part of prompt
    set user_and_host "$user$pure_color_gray@$pure_host_color$host$pure_color_normal "
  end

  if test $pure_user_host_location -eq 1
    set prompt $prompt $user_and_host
  end

  if test "$fish_key_bindings" = "fish_vi_key_bindings"
    switch $fish_bind_mode
      case "default"
        set VIM_MODE (set_color white -b red)"N"
      # case "insert"
      #   set VIM_MODE (set_color black -b green)"I"
      case "replace_one"
        set VIM_MODE (set_color black -b cyan)"R"
      case "visual"
        set VIM_MODE (set_color black -b yellow)"V"
    end
    set VIM_MODE $VIM_MODE(set_color -b normal)" "
  end

  if [ (id -u) -eq 0 ]
    set superuser (set_color -b red) "root" (set_color -b normal)" "
  end


  # Format current folder on prompt output
  set prompt $prompt "$superuser$VIM_MODE$pure_color_blue$current_folder$pure_color_normal"

  # Handle previous failed command
  if test $exit_code -ne 0
    # Symbol color is red when previous command fails
    set color_symbol $pure_color_red
  end

  # Exit with code 1 if git is not available
  if not which git >/dev/null
    return 1
  end

  # Check if is on a Git repository
  set -l is_git_repository (command git rev-parse --is-inside-work-tree ^/dev/null)

  if test -n "$is_git_repository"
    set GIT_ICON                   " "
    set GIT_ICON_UNTRACKED         
    set GIT_ICON_UNMERGED          
    set GIT_ICON_DIRTY             
    set GIT_ICON_STAGED            
    set GIT_ICON_DELETED           
    set GIT_ICON_RENAME            
    set GIT_ICON_STASH             
    set GIT_ICON_INCOMING_CHANGES  ⇣
    set GIT_ICON_OUTGOING_CHANGES  ⇡

    set git_branch_name "["(__parse_git_branch)"] "

    # Check if there are files to commit
    set -l check_git_status (command git status --porcelain ^/dev/null | cut -c 1-2)

    if [ (echo -sn $check_git_status\n | egrep -c "[ACDMT][ MT]|[ACMT]D") -gt 0 ]      #added
      set git_status $git_status $pure_color_green$GIT_ICON_STAGED$pure_color_normal
    end

    if [ (echo -sn $check_git_status\n | egrep -c "[ ACMRT]D") -gt 0 ]                  #deleted
      set git_status $git_status $pure_color_red$GIT_ICON_DELETED$pure_color_normal
    end

    if [ (echo -sn $check_git_status\n | egrep -c ".[MT]") -gt 0 ]                      #modified
      set git_status $git_status $pure_color_yellow$GIT_ICON_DIRTY$pure_color_normal
    end

    if [ (echo -sn $check_git_status\n | egrep -c "R.") -gt 0 ]                         #renamed
      set git_status $git_status $pure_color_purple$GIT_ICON_RENAME$pure_color_normal
    end

    if [ (echo -sn $check_git_status\n | egrep -c "AA|DD|U.|.U") -gt 0 ]                #unmerged
      set git_status $git_status $pure_color_red$GIT_ICON_UNMERGED$pure_color_normal
    end

    if [ (echo -sn $check_git_status\n | egrep -c "\?\?") -gt 0 ]                       #untracked (new) files
      set git_status $git_status $pure_color_cyan$GIT_ICON_UNTRACKED$pure_color_normal
    end

    if test (command git rev-parse --verify --quiet refs/stash)        #stashed (was '$')
      set git_status $git_status $pure_color_red$GIT_ICON_STASH$pure_color_normal
    end

    # Check if there is an upstream configured
    command git rev-parse --abbrev-ref '@{upstream}' >/dev/null ^&1; and set -l has_upstream
    if set -q has_upstream
      set -l git_status (command git rev-list --left-right --count 'HEAD...@{upstream}' | sed "s/[[:blank:]]/ /" ^/dev/null)

      # Resolve Git arrows by treating `git_status` as an array
      set -l git_arrow_left (command echo $git_status | cut -c 1 ^/dev/null)
      set -l git_arrow_right (command echo $git_status | cut -c 3 ^/dev/null)

    # If arrow is not "0", it means it's dirty
      if test $git_arrow_left != 0
        set git_arrows "$pure_color_blue$GIT_ICON_OUTGOING_CHANGES$pure_color_normal"
      end

      if test $git_arrow_right != 0
        set git_arrows "$git_arrows$pure_color_red$GIT_ICON_INCOMING_CHANGES$pure_color_normal"
      end
    end

    if [ "$git_status" != "" ]
      and [ "$git_arrows" != "" ]
      set git_arrows " "$git_arrows" "
    else if [ "$git_status" = "" ]
      and [ "$git_arrows" != "" ]
      set git_arrows $git_arrows" "
    end


    # Format Git prompt output
    set git_prompt "$pure_color_purple$GIT_ICON$pure_color_gray$git_branch_name$pure_color_normal$git_status$git_arrows"

    if [ "$git_status" != "" ]
      set git_prompt $git_prompt" "
    end

    set prompt $prompt $git_prompt
  end

  if test $pure_user_host_location -ne 1
    set prompt $prompt $user_and_host
  end

  # Show python virtualenv name (if activated)
  if test -n "$VIRTUAL_ENV"
    set prompt $prompt $pure_color_gray(basename "$VIRTUAL_ENV")"$pure_color_normal "
  end

  set prompt $prompt "$color_symbol$pure_symbol_prompt$pure_color_normal "

  echo -e -s $prompt

  set __pure_fresh_session 0
end
