#!/bin/bash

# Обновляем индекс пакетов
sudo apt update

# Очистка кэша apt для уменьшения размера образа
sudo apt autoremove -y
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*

# Очистка временных файлов
sudo rm -rf /tmp/*
sudo rm -f /var/log/*.log
sudo rm -f /var/log/*.log.?
sudo rm -f /var/log/*.log.??

# Создаем файл motd с информацией о образе
echo "##########################################################" | sudo tee /etc/update-motd.d/99-custom-message
echo "# Packer-built Ubuntu Image"                                | sudo tee -a /etc/update-motd.d/99-custom-message
echo "# Created: $(date)"                                         | sudo tee -a /etc/update-motd.d/99-custom-message
echo "##########################################################" | sudo tee -a /etc/update-motd.d/99-custom-message
