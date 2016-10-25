UPSTREAM=https://github.com/larsbrinkhoff/awesome-cpus
MAX_DIR_SIZE=27000

error() {
    echo
    echo "ERROR: $1"
    exit 1
}

test_directory_size() {
    echo -n "Checking that no directory is too large... "

    git submodule deinit . > /dev/null
    du -s * | while read i; do
	set $i
	if test "$1" -gt $MAX_DIR_SIZE; then
	    error "The $2 directory is too large"
	fi
    done

    echo OK
}

directories_in_commit() {
    git show --name-only --format=format: "$1" | grep / | wc -l
}

test_commits() {
    echo -n "Checking that each commit touches only one directory... "

    git remote add github-upstream $UPSTREAM
    git log --format="format:%H%n" origin/master..HEAD | while read i; do
	if test `directories_in_commit "$i"` -gt 1; then
	    h=`echo "$i" | cut -c1-7`
	    error "Commit $h touches more than one directory."
	fi
    done
    git remote remove github-upstream

    echo OK
}

test_readme() {
    echo -n "Checking that every directory has a README.md... "

    for i in *; do
	if test -d "$i"; then
	    test -f "$i/README.md" || error "The $i directory has no README.md."
	fi
    done
}

test_directory_size
test_commits

