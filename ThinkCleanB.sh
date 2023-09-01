#!/bin/bash

# Verifică dacă utilizatorul este root
if [ "$(id -u)" -ne 0 ]; then
    echo "Acest script necesită drepturi de super-utilizator. Te rog să rulezi cu sudo."
    exit 1
fi

# Culori pentru formatare
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Începe curățenia sistemului...${NC}"

# Curățarea cache-urilor
echo -e "${GREEN}Curățarea cache-urilor...${NC}"
sudo apt-get clean
sudo apt-get autoclean

# Eliminarea pachetelor nefolosite
echo -e "${GREEN}Eliminarea pachetelor nefolosite...${NC}"
sudo apt-get autoremove -y

# Eliminarea pachetelor orfane
echo -e "${GREEN}Eliminarea pachetelor orfane...${NC}"
sudo deborphan | xargs sudo apt-get -y remove --purge

# Eliminarea nucleului vechi (linux-headers și linux-image)
echo -e "${GREEN}Eliminarea nucleului vechi...${NC}"
sudo apt-get purge $(dpkg -l 'linux-*' | awk '/^ii/{print $2}' | grep -P -v "$(uname -r)") -y

# Curățarea fonturilor arabe și asiatice (opțional)
# (Adaugă aici comanda de eliminare a fonturilor dacă dorești să continui să le elimini)

# Curățarea fișierelor de log mai vechi de 2 săptămâni
echo -e "${GREEN}Curățarea fișierelor de log mai vechi de 2 săptămâni...${NC}"
sudo find /var/log -type f -mtime +14 -exec rm {} \;

# Eliminarea pachetelor de limbă inutile
echo -e "${GREEN}Eliminarea pachetelor de limbă inutile...${NC}"
sudo apt-get remove $(dpkg-query -f '${binary:Package}\n' -W | grep language-pack- | grep -v $(locale -a | grep -v -e '^en' -e '^C' | awk -F_ '{print $1}') | sort -u) -y

# Curățarea thumbnails-urilor
echo -e "${GREEN}Curățarea thumbnails-urilor...${NC}"
find ~/.thumbnails -type f -atime +14 -exec rm -f {} \;

# Curățarea fișierelor de configurare vechi (exemplu: mai vechi de 90 de zile)
echo -e "${GREEN}Curățarea fișierelor de configurare vechi...${NC}"
find ~/ -type f -name ".*" -mtime +90 -exec rm -f {} \;

# Curățarea fișierelor temporare
echo -e "${GREEN}Curățarea fișierelor temporare...${NC}"
sudo rm -rf /tmp/*
sudo rm -rf ~/.cache/*

# Golirea coșului de gunoi
echo -e "${GREEN}Golirea coșului de gunoi...${NC}"
rm -rf ~/.local/share/Trash/*

# Curățarea snap-urilor neutilizate
echo -e "${GREEN}Curățarea snap-urilor neutilizate...${NC}"
sudo snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done

# Curățarea istoricului comenzilor în Terminal (opțional)
echo -e "${GREEN}Curățarea istoricului comenzilor în Terminal...${NC}"
history -c
history -w

echo -e "${YELLOW}Curățarea sistemului s-a încheiat.${NC}"
