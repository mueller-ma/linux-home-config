# This file was generated by ~/.linux_home_config/install.sh and will be overridden by ~/.linux_home_config/update.sh
# To make permanent changes (e. g. in .bashrc), create the file "A.bashrc" in ~/.linux_home_config/persistent/ and run ~/.linux_home_config/update.sh

# This file is sourced by .bashrc

# some cd commands
function -() { cd -; }
function --() { cd --; }

function ..() { cd ..; }
function ...() { cd ../..; }
function ....() { cd ../../..; }
function .....() { cd ../../../..; }
function ......() { cd ../../../../..; }
function .......() { cd ../../../../../..; }

# show line numbers except in pipelines
function grep() { 
    if [ -t 1 ] && [ -t 0 ]; then 
        command grep -n "$@"
    else 
        command grep "$@"
    fi
}
