#!/bin/bash

check_relative_links() {
  local root=$1 files failed markdown_file links wrapped target resolved
  files=$(mktemp)
  find "$root" -path '*/.git' -prune -o -type f -name '*.md' -print > "$files"
  failed=0
  while IFS= read -r markdown_file; do
    links=$(grep -oE '\]\([^)]+\)' "$markdown_file" 2>/dev/null || true)
    test -n "$links" || continue
    while IFS= read -r wrapped; do
      target=${wrapped#']('}
      target=${target%')'}
      case "$target" in ''|'#'*|http://*|https://*|mailto:*) continue ;; esac
      target=${target%%#*}
      target=${target%%\?*}
      case "$target" in
        /*) resolved="$root/${target#/}" ;;
        *) resolved="$(dirname "$markdown_file")/$target" ;;
      esac
      if test ! -e "$resolved"; then
        printf '[FAIL] code=BROKEN_RELATIVE_LINK path=%s target=%s recovery=repair_link\n' "$markdown_file" "$target" >&2
        failed=1
      fi
    done <<EOF
$links
EOF
  done < "$files"
  rm -f "$files"
  test "$failed" -eq 0
}
