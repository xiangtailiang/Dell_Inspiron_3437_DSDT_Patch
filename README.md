# Overview

The purpose of this guide is to provide a step-by-step guide to installing El Capitan on the Dell Inspiron 3437.


# Hardware Detail

The Hardware Detail of Dell Inspiron 3437:

- CPU: i5-4200U/HM87
- Graphics: HD4400, GT720M(discrete card, be disabled), 1366x768
- Ram: 8G DDR3 1600 MHz
- HDD: ST500LT012-1DG142 (500G)

In case of my computer, I add  a SSD and replace the wireless network card(WiFi), because the origin WiFi is not compatible.

- SSD: PLEXTOR PX-128M6S (128G, Mac OS Installed)
- Broadcom 4322(better OS X feature support)


# BIOS settings

To start, set BIOS to defaults.

Then ensure:

- Intel Virtualization disabled
- UEFI boot is enabled
- secure boot is disabled
- disable fast boot


# Preparing USB and initial Installation

This guide for creating USB and installing using Clover UEFI works well for this laptop: [http://www.tonymacx86.com/threads/guide-booting-the-os-x-installer-on-laptops-with-clover.148093](http://www.tonymacx86.com/threads/guide-booting-the-os-x-installer-on-laptops-with-clover.148093/)

Just follow the guide and do the initial installation.

Special notes:
When prepare the kext，you only need these kexts：

[FakeSMC.kext](https://github.com/RehabMan/OS-X-FakeSMC-kozlek)

[VoodooPS2Controller.kext](https://github.com/RehabMan/OS-X-Voodoo-PS2-Controller)

[RealtekRTL8100.kext](http://www.insanelymac.com/forum/topic/296190-driver-for-realteks-rtl810x-fast-ethernet-series/)

For convince, you can use the files in `for_install` by this repo, put the files in the right place.

# Post Installation

Install Clover UEFI as described in the guide linked by the [http://www.tonymacx86.com/threads/guide-booting-the-os-x-installer-on-laptops-with-clover.148093](http://www.tonymacx86.com/threads/guide-booting-the-os-x-installer-on-laptops-with-clover.148093/).

After installing Clover, and configuring it correctly (config.plist, kexts, etc, just as you did for USB) you should be able to boot from the HDD/SSD. The configuration at this point should be exactly the same as USB. Don't forget the `HFSPlus.efi`.

But there are still many issues and devices that won't work correctly. For that, we need to patch ACPI, provide a proper config.plist, and install the kexts that are required.

The most useful article for patching ACPI is [[Guide] Patching LAPTOP DSDT/SSDTs](http://www.tonymacx86.com/threads/guide-patching-laptop-dsdt-ssdts.152573/).

The normal extract/disassemble/patch/compile process is difficult and have to try many times to success.

So I write a batch command to do it. It can make the patching ACPI more easier.

In Terminal:

```shell

mkdir ~/Projects
cd ~/Projects
git clone https://github.com/xiangtailiang/Dell_Inspiron_3437_DSDT_Patch.git

```

## 1.Patch DSDT

With the current project, no patched DSDT/SSDTs are used. Instead, this guide uses Clover hotpatches and a set of "add-on" SSDTs. 
The advantage of hotpatching is that hardware and BIOS can be changed without re-extract/re-patch. It is also a bit easier to setup as the normal extract/disassemble/patch/compile process is not needed.

In Terminal:
```shell

chmod +x build.sh
./build.sh

```
After the build step, you should find `SSDT-HACK.aml` in the `build` dir.
Now you need to copy it to `EFI/Clover/ACPI/patched` .

In Terminal:
```shell

sudo ./mount_efi.sh /
cp -rf build/SSDT-HACK.aml /Volumes/EFI/EFI/Clover/ACPI/patched/SSDT-HACK.aml

```

## 2.Power Management

Use the ssdtPRgen.sh script by Pike R. Alpha: [https://github.com/Piker-Alpha/ssdtPRGen.sh](https://github.com/Piker-Alpha/ssdtPRGen.sh)

You only need to do the first two commands:

```shell

curl --fail -o ./ssdtPRGen.sh https://raw.githubusercontent.com/Piker-Alpha/ssdtPRGen.sh/master/ssdtPRGen.sh
chmod +x ./ssdtPRGen.sh
./ssdtPRGen.sh

```

When it asks if you want to copy to /Extra just respond 'n'. Same for opening ssdt.dsl... respond 'n'.

The results are at `~/Library/ssdtPRgen/SSDT.aml`.

Copy that file to EFI partition, /EFI/Clover/ACPI/patched/SSDT.aml

```shell

sudo ./mount_efi.sh /
cp ~/Library/ssdtPRgen/ssdt.aml /Volumes/EFI/EFI/Clover/ACPI/patched/SSDT.aml

```

## 3.Kext Installation

The `download.sh` script will automatically gather the latest version of all tools (patchmatic, iasl, MaciASL) and all the kexts (FakeSMC.kext, IntelBacklight.kext, ACPIBatteryManager.kext, etc) from bitbucket. The `install_downloads.sh` will automatically install them to the proper locations.

In Terminal:
```shell

chmod +x *.sh
./download.sh
./install_downloads.sh

```

All kext will be install as follow:

```code
VoodooPS2Trackpad.kext
VoodooPS2Mouse.kext
VoodooPS2Keyboard.kext
VoodooPS2Controller.kext
USBXHC_dell_3437.kext
RealtekRTL8100.kext
IntelBacklight.kext
FakeSMC.kext
FakePCIID_Intel_HD_Graphics.kext
FakePCIID_Broadcom_WiFi.kext
FakePCIID.kext
CodecCommander.kext
AppleHDA_ALC283.kext
ACPIBatteryManager.kext

```


## 4.Final config.plist

Copy the  project `config.plist` to `/EFI/Clover/`, replace the old one.

>DO NOT edit your config.plist with Clover Configurator. Clover Configurator will erase important settings from the config.plist, and as a result, it will not work.


That every thing is done~

In Finder, 'Enject EFI' partition(remember to to do that, or the changed files will not save), and restart the computer.

Welcome to the Mac World~

# Compatibility

## What works

I have tested the following features:

- UEFI booting via Clover
- built-in keyboard (with special function keys)
- built-in trackpad (basic gestures)
- HDMI video/audio with hotplug
- WiFi, provided you have compatible hardware
- native USB3 with AppleUSBXHCI (USB2 works also)
- native audio with AppleHDA, including headphone
- built-in mic
- built-in camera (if you are lucky)
- native power management
- battery status
- backlight controls with smooth transitions, save/restore across restart
- accelerated graphics
- wired Ethernet
- Mac App Store working

## Not tested/not working

The following features have issues, or have not been tested:

- Messages/FaceTime have not been tested
- card reader is not working (not important to me)



# Contributors

First of all, I am very grateful for [RehabMan](http://www.tonymacx86.com/members/rehabman.429483/)'s help, I have benefited from his guides.
This patch project reference to his great [ProBook repository](https://github.com/RehabMan/HP-ProBook-4x30s-DSDT-Patch).

I would also thanked [dummyone](http://www.tonymacx86.com/members/dummyone.1414358/), the first installation of Mac OS is based on his guide [[Guide] Dell Inspiron 3x37 - 5x37 -7x37 Clover, Yosemite/El Capitan](http://www.tonymacx86.com/threads/guide-dell-inspiron-3x37-5x37-7x37-clover-yosemite-el-capitan.177410/).

