
# Need ruby 1.9

apt-add-repository ppa:brightbox/ruby-ng
apt-get update
apt-get install ruby1.9.3

curl https://github.com/logstash/logstash/tarball/master -L -o - | tar xzf -
fetch_dir = Dir['logstash-logstash-*'][0]
cd fetch_dir
gem install bundler --no-rdoc --no-ri
apt-get install libxslt-dev libxml2-dev
bundle install

