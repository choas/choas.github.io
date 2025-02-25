podman run --rm -it -p 4000:4000 -v $PWD:/site --entrypoint /bin/sh jekyll-github-pages -c "bundle install && bundle exec jekyll serve --watch --force_polling --host 0.0.0.0"

