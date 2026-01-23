# TYPO3 directory shortcuts
# =========================

# Go up N directories (e.g. up 3)
up() {
  local count=${1:-1}

  if ! [[ "$count" =~ '^[0-9]+$' ]]; then
    echo "Usage: up <number>"
    return 1
  fi

  for (( i = 0; i < count; i++ )); do
    cd .. || return 1
  done
}

# Go to TYPO3 project root (directory containing vendor/)
t3pr() {
  local current_dir="$PWD"

  while [[ "$current_dir" != "/" && "$current_dir" != "$HOME" ]]; do
    if [[ -d "$current_dir/vendor" ]]; then
      cd "$current_dir" || return 1
      ls -lah
      return 0
    fi
    current_dir="${current_dir:h}"
  done

  echo "Not inside a TYPO3 project"
  return 1
}

# Go to packages/site-package
t3sp() {
  local current_dir="$PWD"

  while [[ "$current_dir" != "/" && "$current_dir" != "$HOME" ]]; do
    if [[ -d "$current_dir/packages/site-package" ]]; then
      cd "$current_dir/packages/site-package" || return 1
      return 0
    fi
    current_dir="${current_dir:h}"
  done

  echo "Not inside a TYPO3 project"
  return 1
}


# TYPO3 CLI shortcuts
# =========================

# Clear cache
t3cc() {
  t3pr && ./vendor/bin/typo3 cache:flush
}

# Run DB updates
t3dbu() {
  t3pr && ./vendor/bin/typo3 database:updateschema
}

# Show current TYPO3 version
t3ver() {
  t3pr && ./vendor/bin/typo3 --version
}

# Composer install
t3ci() {
  t3pr && composer install
}

# Composer update
t3cu() {
  t3pr && composer update
}


