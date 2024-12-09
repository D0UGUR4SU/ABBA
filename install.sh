#!/usr/bin/env bash

RED="\033[01;31m"
GREEN="\033[01;32m"
BLUE="\033[01;34m"
YELLOW="\033[01;33m"
WHITE="\033[01;37m"
RESET="\033[0m"

echo -e "${RED}[+] Starting Tools Instalations 🔧\n\n${RESET}"

go env -w GO111MODULE=auto

echo -e "${GREEN}[+] Installing curl${RESET}"
sudo apt install curl

echo -e "${GREEN}[+] Installing subfinder${RESET}"
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

echo -e "${GREEN}[+] Installing findomain${RESET}"
curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux.zip
unzip findomain-linux.zip
chmod +x findomain
sudo mv findomain /usr/bin/findomain

echo -e "${GREEN}[+] Installing assetfinder${RESET}"
go install github.com/tomnomnom/assetfinder@latest

echo -e "${GREEN}[+] Installing chaos${RESET}"
go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest

echo -e "${GREEN}[+] Installing katana${RESET}"
CGO_ENABLED=1 go install github.com/projectdiscovery/katana/cmd/katana@latest

echo -e "${GREEN}[+] Installing httpx${RESET}"
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

echo -e "${GREEN}[+] Installing naabu${RESET}"
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

echo -e "${GREEN}[+] Installing jq${RESET}"
sudo apt-get install jq

echo -e "${GREEN}[+] Installing anew${RESET}"
go install -v github.com/tomnomnom/anew@latest

echo -e "${GREEN}[+] Installing dnsx${RESET}"
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest

echo -e "${GREEN}[+] Installing mapcidr${RESET}"
go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest

echo -e "${GREEN}[+] Installing nuclei${RESET}"
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

echo -e "${GREEN}[+] Installing waybackurls${RESET}"
go install github.com/tomnomnom/waybackurls@latest

echo -e "${GREEN}[+] Installing gf${RESET}"
go install github.com/tomnomnom/gf

echo -e "${GREEN}[+] Installing gau${RESET}"
go install github.com/lc/gau/v2/cmd/gau@latest

echo -e "${GREEN}[+] Installing jsubs${RESET}"
GO111MODULE=on go get -u -v github.com/lc/subjs@latest

echo -e "${GREEN}[+] Installing uro${RESET}"
pipx install uro

echo -e "${GREEN}[+] Installing nilo${RESET}"
go install github.com/ferreiraklet/nilo

echo -e "${GREEN}[+] Installing qsreplace${RESET}"
go install github.com/tomnomnom/qsreplace@latest

echo -e "${GREEN}[+] Installing dirsearch${RESET}"
sudo apt install dirsearch

echo -e "${GREEN}[+] Installing gospider${RESET}"
GO111MODULE=on go install github.com/jaeles-project/gospider@latest

echo -e "${GREEN}Installing airixss${RESET}"
go install github.com/ferreiraklet/airixss@latest