GithubSSL=$(nslookup github.global.ssl.fastly.Net | grep Address | awk -F: '{print $2}' | tail -n1)
Github=$(nslookup github.com | grep Address | awk -F: '{print $2}' | tail -n1)
sed  -i '/github/d'  /etc/hosts
cat << EOF >> /etc/hosts
github.com  $Github
github.global.ssl.fastly.Net $GithubSSL
EOF
service network restart
