GithubSSL=$(nslookup github.global.ssl.fastly.Net | grep Address| sed -n '2p' | cut -f2 -d:)
Github=$(nslookup github.com | grep Address | sed -n '2p' | cut -f2 -d:)
sed -i '/github/d'  /etc/hosts
cat << EOF >> /etc/hosts
github.com  $Github
github.global.ssl.fastly.Net $GithubSSL
EOF
