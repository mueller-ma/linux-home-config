# This file is sourced by .bashrc

# some cd commands
function -() { cd -; }
function --() { cd --; }
function ..() { cd ..; }
function ...() { cd ../..; }
function ....() { cd ../../..; }
function .....() { cd ../../../..; }

# show line numbers except in pipelines
function grep() { 
    if [ -t 1 ] && [ -t 0 ]; then 
        command grep -n "$@"
    else 
        command grep "$@"
    fi
}