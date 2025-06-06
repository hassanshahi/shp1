#!/bin/bash

set -e

echo "مرحله 1: بکاپ گرفتن از فایل‌های repo"
REPO_PATH="/etc/yum.repos.d"
BACKUP_PATH="/etc/yum.repos.d/backup_$(date +%F_%T)"
sudo mkdir -p "$BACKUP_PATH"
sudo cp -r $REPO_PATH/*.repo "$BACKUP_PATH"
echo "بکاپ repo ها در مسیر $BACKUP_PATH ذخیره شد."

echo "مرحله 2: تنظیم timezone به Asia/Tehran و فعال کردن NTP"
sudo timedatectl set-timezone Asia/Tehran
sudo timedatectl set-ntp true
echo "زمان سیستم و NTP تنظیم شدند."

echo "مرحله 3: ویرایش repo ها (almalinux-appstream.repo, almalinux-extras.repo, almalinux-baseos.repo)"
for repo_file in almalinux-appstream.repo almalinux-extras.repo almalinux-baseos.repo; do
    full_path="$REPO_PATH/$repo_file"
    if [[ -f $full_path ]]; then
        echo "ویرایش $repo_file"
        sudo sed -i -e 's|^metalink=|#metalink=|g' \
                    -e 's|^#baseurl=http://mirror.almalinux.org|baseurl=http://mirror.almalinux.org|g' "$full_path"
    else
        echo "$repo_file وجود ندارد!"
    fi
done

echo "مرحله 4: نصب epel-release"
sudo dnf install -y epel-release

echo "مرحله 5: ویرایش epel.repo برای تغییر baseurl و کامنت کردن metalink"
EPEL_REPO="/etc/yum.repos.d/epel.repo"
if [[ -f $EPEL_REPO ]]; then
    sudo sed -i -e 's|^metalink=|#metalink=|g' \
                -e 's|^baseurl=.*|baseurl=https://mirrors.aliyun.com/almalinux/9/BaseOS/x86_64/os/|g' "$EPEL_REPO"
    echo "فایل epel.repo به‌روزرسانی شد."
else
    echo "فایل epel.repo وجود ندارد!"
fi

echo "مرحله 6: غیرفعال کردن epel-cisco-openh264"
sudo dnf config-manager --set-disabled epel-cisco-openh264

echo "مرحله 7: ارتقاء بسته‌ها"
sudo dnf upgrade -y

cat /etc/almalinux-release

echo "تمام مراحل با موفقیت انجام شد."
