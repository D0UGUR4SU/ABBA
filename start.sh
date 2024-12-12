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

mkdir -p subdomains takeover hosts api files secrets urls urls/xss urls/sqli urls/redirect 

# ENUMERATING SUBDOMAINS
echo -e "\n${YELLOW}[+] Enumerating Subdomains${RESET}"
echo -e "\n${GREEN}[+] Running Subfinder...${RESET}"
subfinder -d $1 -all -recursive -silent > subdomains/$1.txt 

echo -e "\n${GREEN}[+] Running Chaos...${RESET}"
chaos -d $1 -key $CHAOS_API_KEY -silent >> subdomains/$1.txt

echo -e "\n${GREEN}[+] Running Findomain...${RESET}"
findomain -t $1 -q >> subdomains/$1.txt

#curl -s "https://crt.sh/?q=.$1&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | anew cert-$1.txt

#amass enum -passive -norecursive -d $1 -brute | anew amass.txt


echo -e "\n${YELLOW}[+] Filtering and saving domains list...${RESET}"
cat subdomains/$1.txt | anew subdomains/uniq-$1.txt
rm -rf subdomains/$1.txt
mv subdomains/uniq-$1.txt subdomains/$1.txt


# VALIDATING SUBDOMAIN TAKEOVER
echo -e "\n${YELLOW}[+] Searching for Subdomain Takeover${RESET}"
echo -e "\n${GREEN}[+] Running Subzy...${RESET}"
subzy run --targets subdomains/$1.txt --hide_fails --output takeover/subzy-$1.txt

#echo -e "\n${GREEN}[+] Running Subjack...${RESET}"
#subjack -w subdomains/$1.txt -t 10 -timeout 30 -o takeover/subjack-$1.txt

echo -e "\n${GREEN}[+] Running SubOver...${RESET}"
subover -l subdomains/$1.txt -t 10 -v -o takeover/subover-$1.txt


# ENUMERATING HTTP/HTTPS
echo -e "\n${YELLOW}[+] Enumerating HTTP/HTTPS${RESET}"
echo -e "\n${GREEN}[+] Running HTTPX for 2xx,3xx,4xx,5xx codes...${RESET}"
cat subdomains/$1.txt | httpx -silent -threads 10 -mc 200,201,204 | anew subdomains/2xx-$1.txt
cat subdomains/$1.txt | httpx -silent -threads 10 -mc 401,403,404,405 | anew subdomains/4xx-$1.txt
cat subdomains/$1.txt | httpx -silent -threads 10 -mc 301,302 | anew subdomains/3xx-$1.txt
cat subdomains/$1.txt | httpx -silent -threads 10 -mc 500,503 | anew subdomains/5xx-$1.txt



# ENUMERATING URLS
echo -e "\n${YELLOW}[+] Enumerating Urls${RESET}"
echo -e "\n${GREEN}[+] Runnig gospider...${RESET}"
xargs -a subdomains/2xx-$1.txt -I@ sh -c 'gospider -s "@" -o gospider -c 10 --other-source --js false --sitemap -q'

echo -e "\n${GREEN}[+] Runnig waybackurls...${RESET}"
cat subdomains/2xx-$1.txt | waybackurls > urls/urls-$1.txt

echo -e "\n${GREEN}[+] Runnig gau...${RESET}"
cat subdomains/2xx-$1.txt | gau >> urls/urls-$1.txt

echo -e "\n${GREEN}[+] Runnig hakwraler...${RESET}"
cat subdomains/2xx-$1.txt | hakrawler -d 3 -silent >> urls/urls-$1.txt

echo -e "\n${GREEN}[+] Runnig katana...${RESET}"
cat subdomains/2xx-$1.txt | katana -d 3 -silent >> urls/urls-$1.txt

cat urls/urls-$1.txt | anew uniq-urls-$1.txt
rm urls/urls-$1.txt
mv urls/uniq-urls-$1.txt urls/urls-$1.txt


# ENUMERATING FILES
echo -e "\n${GREEN}[+] Searching for js files... ${RESET}"
cat urls/urls-$1.txt | grep ".js" > files/js-$1.txt
cat subdomains/2xx-$1.txt | grep ".js" >> files/js-$1.txt
cat subdomains/2xx-$1.txt | gau | grep ".js" >> files/js-$1.txt
cat subdomains/2xx-$1.txt | katana -d 3 | grep ".js" >> files/js-$1.txt
cat subdomains/2xx-$1.txt | waybackurls | grep ".js" >> files/js-$1.txt

cat files/js-$1.txt | anew files/uniq-js-$1.txt
rm files/js-$1.txt
mv files/uniq-js-$1.txt files/js-$1.txt



# ENUMERATING API's
echo -e "\n${YELLOW}[+] Enumerating API's and Specifics Subdomains${RESET}"
echo -e "\n${GREEN}[+] Searching for api|dev|dev1|prod|infra|staging|app ${RESET}"

cat subdomains/2xx-$1.txt | grep api >> anew api/api.txt
cat urls/urls-$1.txt | grep api >> anew api/api.txt 

cat subdomains/2xx-$1.txt | grep dev >> anew api/dev.txt
cat urls/urls-$1.txt | grep dev >> anew api/dev.txt

cat subdomains/2xx-$1.txt | grep dev1 >> anew api/dev1.txt
cat urls/urls-$1.txt | grep dev1 >> anew api/dev1.txt

cat subdomains/2xx-$1.txt | grep prod >> anew api/prod.txt
cat urls/urls-$1.txt | grep prod >> anew api/prod.txt

cat subdomains/2xx-$1.txt | grep infra >> anew api/infra.txt
cat urls/urls-$1.txt | grep infra >> anew api/infra.txt

cat subdomains/2xx-$1.txt | grep staging >> anew api/staging.txt
cat urls/urls-$1.txt | grep staging >> anew api/staging.txt

cat subdomains/2xx-$1.txt | grep app >> anew api/app.txt
cat urls/urls-$1.txt | grep app >> anew api/app.txt

echo -e "\n${GREEN}[+] Creating api_dev.txt file... ${RESET}"
cat api/api.txt api/dev.txt api/dev1.txt api/infra.txt api/prod.txt api/staging.txt api/app.txt | anew api/api_dev.txt
rm -rf api/api.txt api/dev.txt api/dev1.txt api/infra.txt api/prod.txt api/staging.txt api/app.txt


# ENUMERATING VULNERABILITES

## XSS
echo -e "\n${YELLOW}[+] Searching for XSS Vulnerabilities${RESET}"
echo -e "\n${GREEN}[+] Running nuclei -tags xss${RESET}"
cat urls/urls-$1.txt | nuclei -silent -tags xss -rl 10 -c 30

echo -e "\n${GREEN}[+] Running gf...${RESET}"
cat urls/urls-$1.txt | gf xss > anew urls/xss/xss-$1.txt

echo -e "\n${GREEN}[+] Running kxss...${RESET}"
cat urls/urls-$1.txt | kxss >> anew urls/xss/xss-$1.txt

echo -e "\n${GREEN}[+] Running kxss...${RESET}"
cat urls/urls-$1.txt | dalfox pipe >> urls/xss/xss-$1.txt

echo -e "\n${GREEN}[+] Running waybackurls | urlprobe | gf | nilo | qsreplace | airixss ${RESET}"
cat urls/urls-$1.txt | gf xss | nilo | qsreplace '"><svg onload=confirm(1)>' | airixss -payload "confirm(1)" | egrep -v 'Not'

## SENSITIVE DATA EXPOSURE
echo -e "\n${YELLOW}[+] Enumerating Vulnerabilities in JS files${RESET}"
echo -e "\n${GREEN}[+] Running nuclei-templates/http/exposures...${RESET}"
cat files/js-$1.txt | nuclei -silent -t ~/nuclei-templates/http/exposures/ -c 30 -o 

echo -e "\n${GREEN}[+] Running SecretFinder...${RESET}"
python3 ~/Desktop/Tools/SecretFinder/SecretFinder.py -i files/js-$1.txt -o secrets/secrets-$1.txt

## OPEN REDIRECT
echo -e "\n${YELLOW}[+] Searching for Open Redirect Vulnerabilities${RESET}"
cat urls/urls-$1.txt | grep "redirect=|goto=|url=|redirect_url=" > urls/redirect/redirect-$1.txt

echo -e "\n${GREEN}[+] Running gf...${RESET}"
cat urls/redirect/redirect-$1.txt | gf redirect >> urls/redirect/gf-$1.txt




# ENUMERATING IP/PORTS
#echo -e "\n${GREEN}[+] Running Naabu...${RESET}"
#cat subdomains/$1.txt | naabu -silent | anew hosts/ports-$1.txt -top-ports 100

#echo -e "\n${YELLOW}[+] Enumerating IP's and PORTS...${RESET}"
#echo -e "\n${GREEN}[+] Running Mapcidr...${RESET}"
#mapcidr -cl hosts/ports-$1.txt -silent -aggregate | anew hosts/mapcidr-$1.txt


#echo -e "\n${GREEN}[+] Searching for txt|log|cache|secret|db|backup|yml|json|gz|zip|_config${RESET}"
#cat subdomains/2xx-$1.txt | grep -E "\.txt/\.log/\.cache/\.secret/\.db/\.backup/\.yml/\.json/\.gz/\.zip/\_config" | anew api/robots.txt



#ENUMERATING DIRECTORIES
#echo -e "\n${YELLOW}[+] Enumerating Directories${RESET}"
#echo -e "\n${GREEN}[+] Runnig dirsearch...${RESET}"
#dirsearch -l api/api_dev.txt -f -r -i 200 -e json -t 9000 -w /usr/share/wordlists/data/automated/httparchive_apiroutes_2024_05_28.txt -o api/dirsearchAPI.txt