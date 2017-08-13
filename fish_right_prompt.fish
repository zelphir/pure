function fish_right_prompt
  set NODE_VERSION (string trim -l -c=v (node -v 2>/dev/null))
  set ICON_NODE_JS 
  set DOCKER_ICON 
  set right_prompt ""

  # Prompt command execution duration
  if test -n "$CMD_DURATION"
    set command_duration (__format_time $CMD_DURATION $pure_command_max_exec_time)
    set right_prompt $right_prompt "$pure_color_yellow$command_duration$pure_color_normal"
  end

  # Check if it's a node project
  if test -f "package.json"
    set right_prompt $right_prompt "$pure_color_green$ICON_NODE_JS $NODE_VERSION$pure_color_normal"
  end

  if test -n "$DOCKER_MACHINE_NAME"
    set right_prompt $right_prompt " $pure_color_blue$DOCKER_ICON $DOCKER_MACHINE_NAME$pure_color_normal"
  end

  echo -e -s $right_prompt
end
