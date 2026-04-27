#!/usr/bin/env bats

setup() {
  LIB="/Users/c/dotfiles/scripts/tapi-flow-lib.sh"
  # shellcheck source=/dev/null
  source "$LIB"
}

@test "slugify lowercases and dashifies" {
  run slugify "Add Some Cool Feature 99!"
  [ "$status" -eq 0 ]
  [ "$output" = "add-some-cool-feature-99" ]
}

@test "slugify caps at 50 chars" {
  run slugify "$(printf 'abcde%.0s' {1..20})"
  [ "$status" -eq 0 ]
  [ "${#output}" -le 50 ]
}

@test "ticket_from_branch extracts uppercase key from feature/tos-9-foo" {
  run ticket_from_branch "feature/tos-9-foo"
  [ "$output" = "TOS-9" ]
}

@test "ticket_from_branch extracts from hotfix/TOSS-1003-bar" {
  run ticket_from_branch "hotfix/TOSS-1003-bar"
  [ "$output" = "TOSS-1003" ]
}

@test "ticket_from_branch returns empty for tracker-only" {
  run ticket_from_branch "toco"
  [ "$output" = "" ]
}

@test "pre-commit hook refuses commit on tracker branch" {
  local tmp
  tmp=$(mktemp -d)
  git -C "$tmp" init -q -b toco
  install -m755 /Users/c/dotfiles/scripts/tapi-hooks/pre-commit "$tmp/.git/hooks/pre-commit"
  echo file > "$tmp/f"
  git -C "$tmp" add f
  run git -C "$tmp" -c user.name=t -c user.email=t@t commit -m x
  [ "$status" -ne 0 ]
  [[ "$output" == *"refusing commit on tracker branch 'toco'"* ]]
}

@test "pre-commit hook allows commit on feature/* branch" {
  local tmp
  tmp=$(mktemp -d)
  git -C "$tmp" init -q -b feature/tos-9-x
  install -m755 /Users/c/dotfiles/scripts/tapi-hooks/pre-commit "$tmp/.git/hooks/pre-commit"
  echo file > "$tmp/f"
  git -C "$tmp" add f
  run git -C "$tmp" -c user.name=t -c user.email=t@t commit -m x
  [ "$status" -eq 0 ]
}
