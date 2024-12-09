#!/bin/bash

RED="\033[01;31m"
GREEN="\033[01;32m"
BLUE="\033[01;34m"
YELLOW="\033[01;33m"
WHITE="\033[01;37m"
RESET="\033[0m"

clear

echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${RED}                                                                          ${RESET}"
echo -e "${RED}           █████████   ███████████  ███████████    █████████              ${RESET}"
echo -e "${RED}          ███░░░░░███ ░░███░░░░░███░░███░░░░░███  ███░░░░░███             ${RESET}"
echo -e "${RED}         ░███    ░███  ░███    ░███ ░███    ░███ ░███    ░███             ${RESET}"
echo -e "${RED}         ░███████████  ░██████████  ░██████████  ░███████████             ${RESET}"
echo -e "${RED}         ░███░░░░░███  ░███░░░░░███ ░███░░░░░███ ░███░░░░░███             ${RESET}"
echo -e "${RED}         ░███    ░███  ░███    ░███ ░███    ░███ ░███    ░███             ${RESET}"
echo -e "${RED}         █████   █████ ███████████  ███████████  █████   █████            ${RESET}"
echo -e "${RED}         ░░░░░   ░░░░░ ░░░░░░░░░░░  ░░░░░░░░░░░  ░░░░░   ░░░░░            ${RESET}"
echo -e "${RED}                                                                          ${RESET}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${RESET}               ABBA - Advanced Bug Bounty Automation                    ${RESET}"
echo -e "${RESET}                       Created by ${BLUE}D0UGUR4SU                      ${RESET}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}            USAGE:${RESET} ./start_recon.sh ${RED}example.com           ${RESET}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════${RESET}\n"

if [ -z "$1" ]; then
    echo -e "${RED}[ERROR]${WHITE}: Please specify a target domain!${RESET}"
    exit 1
fi

# ENUMERATING SUBDOMAINS
echo -e "${GREEN}[+] Enumerating Subdomains${RESET}"
subfinder -d $1 -all -recursive -silent -o subfinder.txt 

chaos -d $1 -key $CHAOS_API_KEY -silent -o chaos.txt 

curl -s "http://crt.sh/?q=%25.$1&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | anew cert.txt

amass enum -passive -norecursive -d $1 -brute -o amass.txt

findomain -t $1 -q | anew findomain.txt

cat *.txt | anew domains
rm -rf *.txt

# ENUMERATING HTTP/HTTPS
echo -e "${GREEN}[+] Enumerating HTTP${RESET}"
cat domains | httpx -silent -threads 10 -o 200httpx.txt

#echo "[+] Wayback XSS"
#cat domains | waybackurls | uro | gf xss | nilo | qsreplace '"><svg onload=confirm(1)>' | airixss -payload "confirm(1)" | egrep -v 'Not'

#echo "[+] Recon Blocks MapCIDR"s
#mapcidr -l 200httpx.txt -silent -aggregate -o mapcidr.txt

#echo "[+] Naabu ports"
#cat domains | naabu -silent -o ports.txt -top-ports 100

# ENUMERATING API's
echo -e "${GREEN}[+] Enumerating API's and Specifics Subdomains${RESET}"
cat 200httpx.txt | grep api | anew api.txt
cat 200httpx.txt | grep dev | anew dev.txt
cat 200httpx.txt | grep dev1 | anew dev1.txt
cat 200httpx.txt | grep prod | anew prod.txt
cat 200httpx.txt | grep infra | anew infra.txt
cat 200httpx.txt | grep staging | anew staging.txt
cat 200httpx.txt | grep app | anew app.txt

cat api.txt dev.txt dev1.txt infra.txt prod.txt staging.txt app.txt | anew api_dev.txt
rm -rf api.txt dev.txt dev1.txt infra.txt prod.txt staging.txt app.txt

#ENUMERATING DIRECTORIES
echo "${GREEN}[+] Enumerating Directories${RESET}"
dirsearch -l api_dev.txt -f -r -b -i 200 -e json -t 9000 -w /usr/share/wordlists/data/automated/httparchive_apiroutes_2024_05_28.txt -o dirsearchAPI.txt


# ENUMERATING LINKS
echo "${GREEN}[+] Enumerating Links${RESET}"
xargs -a 200httpx.txt -I@ sh -c 'gospider -s "@" -o gospider.txt -c 10 --other-source --js false --sitemap -q'


# ENUMERATING VULNERABILITES
echo "${GREEN}[+] Enumerating Vulnerabilities${RESET}"
cat 200httpx.txt | waybackurls | uro | anew wayback.txt