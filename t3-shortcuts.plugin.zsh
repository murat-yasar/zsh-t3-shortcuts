
# Directory Shortcuts for TYPO3 projects
# ======================================

# takes an integer and takes you up that amount in parent directories
function up () {
  local count=$1;
  for ((i=0;i<$count;i++)) do cd ..; done
}

# change directory to the project root of the current project
function _pr() {
    local current_dir=$(pwd)
    while [[ "$current_dir" != "/" && "$current_dir" != "$HOME" ]]; do
        if [[ -d "$current_dir/vendor" ]]; then
            cd "$current_dir"
            ls -l
            return
        fi
        current_dir=$(dirname "$current_dir")
    done
    echo "Not in a project directory"
}

# change directory to the packages/site-package directory of the current project
function _sp() {
    local current_dir=$(pwd)
    while [[ "$current_dir" != "/" && "$current_dir" != "$HOME" ]]; do
        if [[ -d "$current_dir/packages/site-package" ]]; then
            cd "$current_dir/packages/site-package"
            return
        fi
        current_dir=$(dirname "$current_dir")
    done
    echo "Not in a project directory"
}