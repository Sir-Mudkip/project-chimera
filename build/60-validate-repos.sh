#!/usr/bin/bash
set -eoux pipefail
echo "::group:: ===$(basename "$0")==="

REPOS_DIR="/etc/yum.repos.d"
VALIDATION_FAILED=0
ENABLED_REPOS=()

check_repo_file() {
    local repo_file="$1"
    local basename_file
    basename_file=$(basename "$repo_file")
    [[ ! -f "$repo_file" ]] && return 0
    [[ ! -r "$repo_file" ]] && return 0
    if grep -q "^enabled=1" "$repo_file" 2>/dev/null; then
        echo "ENABLED: $basename_file"
        ENABLED_REPOS+=("$basename_file")
        VALIDATION_FAILED=1
        local section_name=""
        while IFS= read -r line; do
            if [[ "$line" =~ ^\[.*\]$ ]]; then
                section_name="$line"
            elif [[ "$line" =~ ^enabled=1 ]]; then
                echo "  - $section_name"
            fi
        done < "$repo_file"
    else
        echo "Disabled: $basename_file"
    fi
}

if [[ ! -d "$REPOS_DIR" ]]; then
    echo "Warning: $REPOS_DIR does not exist"
    exit 0
fi

echo "Checking CentOS repos..."
for repo in "$REPOS_DIR"/centos*.repo; do
    [[ -f "$repo" ]] && check_repo_file "$repo"
done

echo "Checking EPEL repos..."
for repo in "$REPOS_DIR"/epel*.repo; do
    [[ -f "$repo" ]] && check_repo_file "$repo"
done

echo "Checking third-party repos..."
for repo_name in tailscale.repo; do
    [[ -f "$REPOS_DIR/$repo_name" ]] && check_repo_file "$REPOS_DIR/$repo_name"
done

echo "Checking COPR repos..."
for repo in "$REPOS_DIR"/_copr*.repo; do
    [[ -f "$repo" ]] && check_repo_file "$repo"
done

echo "======================================"
if [[ $VALIDATION_FAILED -eq 1 ]]; then
    echo "VALIDATION FAILED - the following repos are still enabled:"
    for repo in "${ENABLED_REPOS[@]}"; do
        echo "  • $repo"
    done
    exit 1
else
    echo "All repositories correctly disabled"
fi
echo "======================================"

echo "::endgroup::"
