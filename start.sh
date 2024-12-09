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
    echo -e "\n${RED}[ERROR]${WHITE}: Please specify a target domain!${RESET}"
    exit 1
fi

# ENUMERATING SUBDOMAINS
echo -e "\n${GREEN}[+] Enumerating Subdomains${RESET}"
subfinder -d $1 -all -recursive -silent | anew subfinder.txt 

chaos -d $1 -key $CHAOS_API_KEY -silent | anew chaos.txt 

response=$(curl -s "http://crt.sh/?q=%25.$1&output=json")
if echo "$response" | jq . >/dev/null 2>&1; then
  echo "$response" | jq -r '.[].name_value' | sed 's/\*\.//g' | anew $OUTPUT_DIR/cert.txt
else
  echo -e "\n${RED}[ERROR]${WHITE} Resposta inválida do crt.sh para a consulta ${RESET}"
fi

#amass enum -passive -norecursive -d $1 -brute | anew amass.txt

findomain -t $1 -q | anew findomain.txt

cat *.txt | anew domains.txt
rm -rf *.txt



# ENUMERATING HTTP/HTTPS
echo -e "\n${GREEN}[+] Enumerating HTTP${RESET}"
cat domains.txt | httpx -silent -threads 10 | anew 200httpx.txt

echo -e "\n${GREEN}[+] Wayback XSS${RESET}"
cat domains.txt | waybackurls | uro | gf xss | nilo | qsreplace '"><svg onload=confirm(1)>' | airixss -payload "confirm(1)" | egrep -v 'Not'

echo -e "\n${GREEN}[+] Recon Blocks MapCIDR's${RESET}"
mapcidr -l 200httpx.txt -silent -aggregate | anew mapcidr.txt

echo -e "\n${GREEN}[+] Naabu ports${RESET}"
cat domains.txt | naabu -silent | anew ports.txt -top-ports 100




# ENUMERATING API's
echo -e "\n${GREEN}[+] Enumerating API's and Specifics Subdomains${RESET}"
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
echo -e "\n${GREEN}[+] Enumerating Directories${RESET}"
dirsearch -l api_dev.txt -f -r -b -i 200 -e json -t 9000 -w /usr/share/wordlists/data/automated/httparchive_apiroutes_2024_05_28.txt -o dirsearchAPI.txt




# ENUMERATING LINKS
echo -e "\n${GREEN}[+] Enumerating Links${RESET}"
xargs -a 200httpx.txt -I@ sh -c 'gospider -s "@" -o gospider.txt -c 10 --other-source --js false --sitemap -q'




# ENUMERATING VULNERABILITES
echo -e "\n${GREEN}[+] Enumerating Vulnerabilities${RESET}"
cat 200httpx.txt | waybackurls | uro | anew wayback.txt