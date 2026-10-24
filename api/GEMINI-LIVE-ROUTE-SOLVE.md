## 1 Change model gemini live
GEMINI_LIVE_MODEL: "gemini-3.1-flash-live-preview"

# Install Ubuntu
<!-- Interview memakai koneksi aman WSS/TLS dari Rails ke Gemini Live. Runtime EventMachine di Ruby Windows tidak memiliki dukungan SSL/TLS.runtime yang dipakai: EventMachine.ssl? menghasilkan false. Karena itu proses Rails berhenti saat mencoba membuka koneksi ke Gemini. jadi solusinya install Ubuntu -->

<!-- power shell aministrator -->
```shell
wsl --install -d Ubuntu
wsl -d Ubuntu
```


<!-- install ruby on Ubuntu -->
```shell
apt update
apt install -y git curl build-essential autoconf libssl-dev libyaml-dev libreadline-dev zlib1g-dev libffi-dev libgdbm-dev

git clone https://github.com/rbenv/rbenv.git /root/.rbenv
git clone https://github.com/rbenv/ruby-build.git /root/.rbenv/plugins/ruby-build

export PATH="/root/.rbenv/bin:$PATH"
eval "$(rbenv init - bash)"

rbenv install 3.3.12
rbenv global 3.3.12

ruby -v
gem install bundler
cd "/mnt/c/Users/LENOVO/Documents/Project FSW/ai-interview-platform/api"
bundle install
bundle exec ruby -e 'require "eventmachine"; puts "EventMachine SSL: #{EventMachine.ssl?}"'
```

<!-- cari alamat windows host -->
```shell
ip route | awk '/default/ {print $3}'
ganti HOST: "172.x.x.1" # contoh di application.yml
```
<!-- setting path -->
```shell
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - bash)"
rbenv global 3.3.12
hash -r
which ruby
ruby -v
which bundle

printf '\nexport PATH="$HOME/.rbenv/bin:$PATH"\neval "$(rbenv init - bash)"\n' >> ~/.bashrc
source ~/.bashrc
```
<!-- izinkan alamat wsl di config postgres -->
query tool
`SHOW hba_file;`

Buka file yang lokasinya ditampilin. Tambahkan dua aturan berikut di atas aturan penolakan umum`

```js
host    postgres             postgres    172.26.131.72/32    scram-sha-256
host    rakamin_development  postgres    172.26.131.72/32    scram-sha-256
```
query tool
`SELECT pg_reload_conf();`

<!-- running server -->
```shell
bundle exec rails server -p 3001
```