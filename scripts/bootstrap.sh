#!/usr/bin/env bash

set -euf -o pipefail

# Usage: ./bootstrap [directory name] [port]

# This is a quick and dirty script to bootstrap a new Genesis install. It:
# 1. Creates a directory with the supplied name. If no arguments are given, it defaults to cold.
# 2. Downloads the Genesis source and the ColdCore database into ./$name
# 3. Sets some opinionated configuration options regarding using big floats and numbers.
# 4. Compiles the Genesis server.
# 5. Sets up the ColdCore database structure.
# 7. Copies the Genesis binary files to the ColdCore database bin directory.
#    (This doesn't use symbolic links due to the dangerous nature of updating and rendering binary databases useless)
# 7. Replaces the default backup script with a slightly nicer one. (TODO: Better comparison of the scripts.)
# 8. Joins the ColdCore database src files into a single textdump.
# 9. Compiles the newly joined textdump into a binary database.
# 10. Starts Genesis.

# The options.h equivalent is here: src/include/defs.h

port="1138"

if [ $# -eq 0 ]; then
    name="cold"
else
    name="$1"
    if [ $# -ge 2 ]; then
        port="${2}"
    fi
fi

if nc -z 127.0.0.1 "${port}" ; then
    echo "Port ${port} is already open."
    exit 1;
fi

mkdir "${name}" || { echo "Failed to create directory ${name}" >&2; exit 1; }
cd "${name}"

git clone https://github.com/the-cold-dark/genesis.git            || { echo "Failed to clone Genesis repository."  >&2; exit 1; }
git clone https://github.com/the-cold-dark/ColdCore.git "${name}" || { echo "Failed to clone ColdCore repository." >&2; exit 1; }
cd genesis

# Enable USE_BIG_FLOATS
sed -n '/\#  define USE_BIG_FLOATS/{x;s/DISABLED/1/;x};x;1!p;${x;p}' ./src/include/defs.h > ./src/include/new_defs.h
# Enable USE_BIG_NUMBERS (temporarily disabled until the resolution of https://github.com/the-cold-dark/genesis/issues/15 )
#sed -n '/\#  define USE_BIG_NUMBERS/{x;s/DISABLED/1/;x};x;1!p;${x;p}' ./src/include/defs.h > ./src/include/new_defs.h
(rm ./src/include/defs.h && mv ./src/include/new_defs.h ./src/include/defs.h) || { echo "Failed to write new defs.h file." >&2; exit 1; }

mkdir build || { echo "Failed to create build directory." >&2; exit 1; }
cd build
# Use Berkeley DB backend instead of ndbm. This works better in Gentoo, at least.
cmake -DCOLD_LOOKUP_BACKEND=bdb .. || { echo "CMake failed." >&2; exit 1; }
make || { echo "Failed to build Genesis." >&2; exit 1; }

cd "../../${name}"
mkdir -p logs backups/textdumps root || { echo "Failed to create ColdCore directories." >&2; exit 1; }
cp ../genesis/build/coldcc ./bin || { echo "Failed to copy coldcc." >&2; exit 1; }
cp ../genesis/build/genesis ./bin || { echo "Failed to copy Genesis." >&2; exit 1; }
cd dbbin && rm ./backup && curl https://lisdude.com/cold/code/backup2.txt -o backup && chmod 700 ./backup

cd ../
./bin/tdjoin || { echo "Failed to join source files." >&2; exit 1; }
./bin/coldcc || { echo "Failed to compile textdump to binary database." >&2; exit 1; }
./bin/genesis -p :"${port}" || { echo "Failed to start the Genesis server." >&2; exit 1; }

echo "Server started on port ${port}."
echo "Be sure to edit the path / settings in dbbin/backup appropriately."
