# Hand-picked set of languages.
langs=("C" "C#" "C++" "Go" "Java" "JavaScript" "PHP" "Python" "Ruby" "Rust" "Scala" "TypeScript")

if [ ! -d TopLists ]; then
  mkdir TopLists;
fi

# Install required Python packages.
pip install -r requirements.txt

# Collect 25K repos with at least 50 stars.
# NOTE: the GH API neither guarantees nor (remotely) achieves completeness or consistency, so the resulting set of repositories will be different on each run.
# NOTE: make sure to insert your GH API key into the gh_crawler.py file.
for lang in ${langs[@]}; do
  python3 gh_crawler.py $lang;
done

# To fix: error: RPC failed; curl 92 HTTP/2 stream 5 was not closed cleanly before end of the underlying stream 
git config --global http.postBuffer 500M
git config --global https.postBuffer 500M
git config --global http.maxRequestBuffer 100M
git config --global core.compression 0
# git config --global http.version HTTP/1.1

# Clone repositories in parallel and extract all language-specific files.
for lang in ${langs[@]}; do
  cat 'TopLists/'$lang'-top-repos.txt' | xargs -P16 -n1 -I% bash clone_repo.sh % $lang
done

# Deduplicate code files.
python3 deduplicate.py
