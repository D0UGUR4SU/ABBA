#!/usr/bin/env bash

echo -e "\033[01;31m[+]\033[0m Starting Tools Instalations 🔧\n\n"

go env -w GO111MODULE=auto

echo -e "\033[01;31m[+]\033[0m Installing curl"
sudo apt install curl

echo -e "\033[01;31m[+]\033[0m Installing subfinder"
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

echo -e "\033[01;31m[+]\033[0m Installing findomain"
curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux.zip
unzip findomain-linux.zip
chmod +x findomain
sudo mv findomain /usr/bin/findomain

echo -e "\033[01;31m[+]\033[0m Installing assetfinder"
go install github.com/tomnomnom/assetfinder@latest

echo -e "\033[01;31m[+]\033[0m Installing chaos"
go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest

echo -e "\033[01;31m[+]\033[0m Installing katana"
CGO_ENABLED=1 go install github.com/projectdiscovery/katana/cmd/katana@latest

echo -e "\033[01;31m[+]\033[0m Installing httpx"
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

echo -e "\033[01;31m[+]\033[0m Installing naabu"
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

echo -e "\033[01;31m[+]\033[0m Installing jq"
sudo apt-get install jq

echo -e "\033[01;31m[+]\033[0m Installing anew"
go install -v github.com/tomnomnom/anew@latest

echo -e "\033[01;31m[+]\033[0m Installing dnsx"
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest

echo -e "\033[01;31m[+]\033[0m Installing mapcidr"
go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest

echo -e "\033[01;31m[+]\033[0m Installing nuclei"
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

echo -e "\033[01;31m[+]\033[0m Installing waybackurls"
go install github.com/tomnomnom/waybackurls@latest

echo -e "\033[01;31m[+]\033[0m Installing gf"
go install github.com/tomnomnom/gf

echo -e "\033[01;31m[+]\033[0m Installing gau"
go install github.com/lc/gau/v2/cmd/gau@latest

echo -e "\033[01;31m[+]\033[0m Installing jsubs"
GO111MODULE=on go get -u -v github.com/lc/subjs@latest

echo -e "\033[01;31m[+]\033[0m Installing uro"
pipx install uro

echo -e "\033[01;31m[+]\033[0m Installing nilo"
go install github.com/ferreiraklet/nilo

echo -e "\033[01;31m[+]\033[0m Installing qsreplace"
go install github.com/tomnomnom/qsreplace@latest

echo -e "\033[01;31m[+]\033[0m Installing dirsearch"
sudo apt install dirsearch

echo -e "\033[01;31m[+]\033[0m Installing gospider"
GO111MODULE=on go install github.com/jaeles-project/gospider@latest