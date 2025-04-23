# INSTALAÇÃO


## Parâmetros da Configuração
- Boot via UEFI diretamente pela placa mãe [Wiki](https://wiki.archlinux.org/index.php/EFISTUB#Using_UEFI_directly)

- Orientação completa para SSDs

- Somente duas partições, root e boot.

- Encriptação total do sistema, menos /boot, via LUKS [Wiki](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system)

- Layout final das partições (GPT):

>       +-----------------------+------------------------+
>       | Boot Partition        | LUKS Partition         |
>       | Filesystem: FAT32     | Filesystem: ext4       |
>       | Tamanho: 550MiB       | Tamanho: 100%          |
>       |                       |                        |
>       |                       | /dev/mapper/cryptroot  |
>       |                       |------------------------|
>       | Type: EF00            | Type: 8300             |
>       | /dev/sda1             | /dev/sda2              |
>       +-----------------------+------------------------+


## Passo-a-Passo

- Fazer boot da imagem do Arch

- Modificar layout do teclado

        # loadkeys br-abnt2

- Testar internet

- Atualizar horário

        # timedatectl set-ntp true

- Particionar o SSD

        # cgdisk /dev/sda
        -- Partição #1 (/dev/sda1): Tamanho: 550MiB, Tipo: EF00, Nome: Boot Partition
        -- Partição #2 (/dev/sda2): Tamanho: 450GiB, Tipo: 8300, Nome: LUKS Partition

- Encriptar Partição #2 [Wiki](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Preparing_non-boot_partitions)

        # ext4:
        # cryptsetup -y -v luksFormat --type luks2 /dev/sda2
        # btrfs:
        # cryptsetup -y -v luksFormat --type luks1 /dev/sda2

- Abrir Partição Encriptada (e ativar discards permanentemente)

        # ext4:
        # cryptsetup --allow-discards --persistent open --type luks2 /dev/sda2 cryptroot
        # btrfs:
        # cryptsetup --allow-discards --type luks1 /dev/sda2 cryptroot

- Formatar as partições

        # mkfs.fat -F32 /dev/sda1

        # mkfs.ext4 /dev/mapper/cryptroot
        # or:
        # mkfs.btrfs -L label /dev/mapper/cryptroot

- Montar as partições

        # mount /dev/mapper/cryptroot /mnt
        # mkdir /mnt/boot
        # mount /dev/sda1 /mnt/boot

- Selecionar mirrors do arch rápidos

        # reflector --sort score --threads 16 --age 6 --number 10 --fastest 30 --download-timeout 1 --verbose --save /etc/pacman.d/mirrorlist


- Instalar o sistema base

        # pacstrap /mnt base base-devel efibootmgr linux linux-firmware nano btrfs-progs

- Gerar o FSTAB

        # genfstab -U /mnt >> /mnt/etc/fstab

    - Editar o arquivo e arrumar as coisas

            # nano /mnt/etc/fstab
                - Trocar relatime por: 'noatime' em /boot e /dev/mapper/cryptoroot
                - Adicionar 'discard,' em /dev/mapper/cryptoroot
                - Adicionar uma entrada tmpfs para /tmp
                    tmpfs    /tmp        tmpfs   rw,nodev,nosuid,noatime,size=2G     0       0

- Chroot pro sistema

        # arch-chroot /mnt

- Setar timezone e gerar /etc/adjtime

        # ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
        # hwclock --systohc

- Setar localizações e locales

        # nano /etc/locale.gen
            - Descomentar en_US.UTF-8 UTF-8
            - Descomentar pt_BR.UTF-8 UTF-8

        # locale-gen

    - Criar locale.conf e adicionar variável LANG

            # nano /etc/locale.conf
                LANG=en_US.UTF-8

    - Criar vconsole.conf e adicionar variável KEYMAP

            # nano /etc/vconsole.conf
                KEYMAP=br-abnt2

- Criar arquivo hostname e setar o nome do computador

        # nano /etc/hostname
            emi-arch

- Editar arquivo hosts de acordo

        # nano /etc/hosts
            127.0.0.1   localhost
            ::1         localhost
            127.0.1.1   emi-arch.localdomain    emi-arch

- Instalar ferramentas para conectar à internet depois de instalado

        # pacman -S iw dialog wpa_supplicant networkmanager

- Setar fonte de consoles virtuais (ttys) e também de early space

        # nano /etc/vconsole.conf
            KEYMAP=br-abnt2
            FONT=lat2-16
            FONT_MAP=8859-2

- Configurar e regerar mkinitcpio para funcionar com o dm-crypt [Wiki](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Configuring_mkinitcpio)

    - Adicionar HOOKS 'keyboard' e 'keymap' e 'consolefont' antes de 'block' e 'encrypt' antes de 'filesystems'

            # nano /etc/mkinitcpio.conf
                HOOKS=(... keyboard keymap consolefont block encrypt ... filesystems ...)
                - Apagar instâncias repetidas

    - Regerar mkinitcpio

            # mkinitcpio -p linux

- Setar senha do root

        # passwd

- Configurar bootloader

    - Instalar microcode para intel

            # pacman -S intel-ucode

    - Pegar UUID de /dev/sda2

            # blkid

    - Pegar ID do subvolume @:

            btrfs subvolume list /dev/sda

    - Criar entrada UEFI na placa mãe:

            # efibootmgr --disk /dev/sda --part 1 --create --gpt --label "Arch Linux" --loader /vmlinuz-linux --unicode "cryptdevice=UUID=[UUID-ACIMA]:cryptroot:allow-discards root=/dev/mapper/cryptroot rootflags=subvolid=[###] rw initrd=\intel-ucode.img initrd=\initramfs-linux.img"

    - *Dica: após, apertar seta para cima, adicionar aspas simples no comando inteiro, echo na frente e redirecionar para /boot/efi-params.txt*

            # echo 'efibootmgr [...]' > /boot/efi-params.txt

- Sair do chroot, desmontar partições e reiniciar sistema!

        # exit
        # umount -R /mnt
        # reboot


# POST INSTALL

- Fazer login como root

- Colocar este repo num pendrive e fazer mount em /mnt

- Ativar e iniciar a internet

        # systemctl enable NetworkManager
        # systemctl start NetworkManager

- Instalar algumas coisas para a shell:

        # pacman -S bash-completion xorg-xinit
        # bash -c "$(curl -sSL https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/autoinstall.sh)"
        # pacman -Sy nano-syntax-highlighting
        # nano /etc/nanorc
                include "/usr/share/nano/*.nanorc"
                include "/usr/share/nano-syntax-highlighting/*.nanorc"

- Editar /etc/pacman.conf

        # diff /mnt/arch-install/etc/pacman.conf /etc/pacman.conf
        # nano /etc/pacman.conf

- Desmontar, sair e logar novamente

        # sync && umount /mnt
        # exit

- Editar /etc/sudoers

        # visudo
            %wheel ALL=(ALL) ALL
            Defaults timestamp_timeout=-1
            Defaults insults

- Confirmar se discard está funcionando:
    - Ver se o header LUKS está permitindo discards (olhar FLAGS):

            # cryptsetup luksDump /dev/sdaX

    - Ver se /dev/mapper/cryptroot está incluindo discard

            # cat /proc/mounts

    - Se tudo estiver ok, *most likely it's workin'*. No entanto, se quiser testar manualmente, seguir este passo-a-passo(https://unix.stackexchange.com/questions/85865/trim-with-lvm-and-dm-crypt/85880#85880)

        - Criar um arquivo de teste (não aleatório de propósito):

                # yes | dd iflag=fullblock bs=1M count=1 of=trim.test

        - Pegar o endereço, comprimento e blocksize:

                # filefrag -s -v trim.test
                File size of trim.test is 1048576 (256 blocks, blocksize 4096)
                 ext logical physical expected length flags
                   0       0    34048             256 eof
                trim.test: 1 extent found

        - Pegar o mountpoint:

                # df trim.test
                /dev/mapper/something  32896880 11722824  20838512   37% /mount/point

        - Ler diretamente do dispositivo e confirmar o padrão *yes*:

                # dd bs=4096 skip=34048 count=256 if=/dev/mapper/something | hexdump -C
                00000000  79 0a 79 0a 79 0a 79 0a  79 0a 79 0a 79 0a 79 0a  |y.y.y.y.y.y.y.y.|
                *
                00100000

        - Deletar o arquivo, sincronizar e dropar os caches, senão dd não vai ler do disco:

                # rm trim.test
                # sync
                # echo 1 > /proc/sys/vm/drop_caches

        - Ler diretamente do dispositivo de novo, e confirmar que o padrão agora é aleatório

                # dd bs=4096 skip=34048 count=256 if=/dev/mapper/something | hexdump -C

        - *O padrão é aleatório porque o crypto layer está lendo zeros do SSD e "decriptando" eles, retornando um padrão aleatório*

- Adicionar módulos dos drivers gráficos no Early KMS:

        # nano /etc/mkinitcpio.conf
            MODULES=(i915 amdgpu)
        # mkinicpio -p linux
  
  > **Recommended**: To reduce the large GTT memory reservation by the `amdgpu` driver, create or edit a configuration file using `sudo nano /etc/modprobe.d/amdgpu-gtt.conf` and add the following line to limit the GTT size to 16 GiB (16384 MiB): `options amdgpu gttsize=16384`. Save the file, then update your initial ramdisk using the appropriate command for your distribution (e.g., `sudo update-initramfs -u` for Debian/Ubuntu, `sudo dracut -f` for Fedora, or `sudo mkinitcpio -P` for Arch), and finally, `sudo reboot` your system; after rebooting, check `free -h` to confirm significantly more RAM is available.

- Adicionar usuário

        # useradd -m -G users,wheel esauvisky
        # passwd esauvisky

- Adicionar redirecionamento tty1 -> tty2 e auto-login do usuário em tty2

        # systemctl edit getty@tty1.service
            [Service]
            ExecStart=
            ExecStart=-/usr/bin/agetty --skip-login --login-program '/usr/bin/chvt' --login-options '2' --noclear %I $TERM
            TTYVTDisallocate=no
            Restart=no
            Type=oneshot
        # systemctl edit getty@tty2.service
            [Service]
            ExecStart=
            ExecStart=-/usr/bin/agetty --autologin esauvisky --noclear %I $TERM
            TTYVTDisallocate=no

- Install gnome, gnome-extra e xorg

- Trocar para tty2, fazer login com o novo usuário e trocar de volta para tty1

    - **Atenção: .bash_profile irá executar startx imediatamente assim que for feito login com o usuário não-root em tty2! Portanto, faça login antes de copiar o arquivo ou use outro tty**

- Clone arch-install repo.

    - Copy over all dotfiles from dotfiles/ to ~

    - Copy over your previous .bash_eternal_history or create a blank one

    - Link yours, root, and any other user (including /etc/skel), to your own files:

            # ./checkandfix.sh

- Switch to tty1 and reboot.

**If everything went well, you'll be popped out into Gnome Shell on TTY2 after typing your LUKS password.**

- Make a LUKS header backup.

        # cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file luksHeaderJessie.img


# CONFIGURAÇÕES
*aaanndd heeere ve go!*

- Install `yay`

- Configure userdirs `~/.config/user-dirs.dirs`

        XDG_DOWNLOAD_DIR="$HOME/Waste"
        XDG_TEMPLATES_DIR="$HOME/.local/share/nautilus/templates"
        XDG_PUBLICSHARE_DIR="$HOME/.Public
        XDG_DOCUMENTS_DIR="$HOME/Documents"
        XDG_MUSIC_DIR="$HOME/Media"
        XDG_PICTURES_DIR="$HOME/Media"
        XDG_VIDEOS_DIR="$HOME/Media"
        XDG_DESKTOP_DIR="$HOME/Waste"

- Gnome

    - Gnome: Region & Language:

        - Language: English

        - Formats: Brasil

        - Layout Teclado: Portuguese (Brazil)

    - Configurar opções uma-a-uma

    - Configurar atalhos um-a-um, remover todos os não-utilizados

        - Custom Shortcuts:

            - Launch Terminal: `gnome-terminal` | **Super+T**
            - Shorten URL: `shortenurl -c` | **Super+W**
            - Download URL to /tmp: `uridownload` | **Super+R**
            - Launch System Monitor: `gnome-system-monitor` | **Ctrl+Alt+Delete**
            - Take a Screenshot: `takeScreenshot` | **Print**

- Remover coisas aleatórias não utilizadas que foram instaladas anyways

        $ pacr gnome-contacts gnome-maps folks gnome-todo gnome-calendar evolution evolution-data-server gnome-photos
        $ pacr -c yelp yelp-xsl

    - Ir no .config e apagar o que tá sobrando relacionado aos acima

- Instalar Google Chrome

        $ aurget -S google-chrome-stable

    - Definir a senha do Default keyring em branco, senão você vai ter que digitar toda vez que abrir o Chrome.

- Configurar gnome-shell (gnome-tweak-tool)

    - Desativar animações

    - Ação do botão de desligar

    - Ação de fechar a tampa

    - Setar "Super-Right" como tecla de overlay (para evitar Super de abrir o Activities)

    - Integrar extensões com o Chrome

        - Instalar a extensão(https://goo.gl/89TkHr) do Chrome

        - Instalar o conector nativo:

                $ pacs chrome-gnome-shell

    - Extensões

        *São instaladas em .local/share/gnome-shell/extensions*

        - Extensões Utilizadas:
            - Freon
            - Lock keys
            - No topleft hot corner
            - Pomodoro
            - Removable drive menu
            - System Monitor
            - Topicons Plus *(restaura a barra dos ícones de notificação)*
            - User themes
            - Volume mixer
            - Workspace grid
            - Shellshape

        - Editar o `extension.js` de cada extensão para reorganizar elas no painel
            - Pesquisar por: `addToStatusArea`
            - Editar de acordo. Ex.:

                    Main.panel.addToStatusArea('shellshape-indicator', _indicator, 1, 'left');
                                                                             Ordem ^   ^ Lugar

        - *Se der problema com schemas, entrar na pasta plugin@autor/schemas/ e executar:*

                $ glib-compile-schemas .

- Instalar e configurar profile-sync-daemon(https://wiki.archlinux.org/index.php/Profile-sync-daemon)


- Instalar e configurar anything-sync-daemon(https://wiki.archlinux.org/index.php/anything-sync-daemon)
    - Diretórios para sincronizar

            .cache/google-chrome
            .cache/spotify
            .aurget

- Configurações do SMART para o HD

    - Ativa o daemon do SmartmonTools

            $ pacs smartmontools
            $ subl /etc/smartd.conf
                - Substituir DEVICESCAN por:
                    /dev/nvme0n1 -a -o on -S on -s (S/../.././02|L/../../6/03) -W 4,35,45
                - Substituir /dev/sda acima por DEVICESCAN se desejar escanear *todos* os hds presentes
            $ systemctl start smartd
            $ systemctl status smartd
            $ systemctl enable smartd

- Teclado

    - Install CopyQ
    - **TODO: ** the xkb thingamabove

- Instalar e configurar linux-ck(https://wiki.archlinux.org/index.php/Linux-ck) (*para MuQSS + BFQ baby!*)

    - Adicionar o repo do no /etc/pacman.conf:

            [repo-ck]
            Server = http://repo-ck.com/$arch

    - Lembrar de usar wget no pacman porque o servidor dele dá problema o tempo inteiro (pacman.conf):

            XferCommand  = /usr/bin/wget --passive-ftp -q --show-progress -c -O %o %u

    - Instalar linux-ck-haswell e linux-ck-haswell headers

            $ pacs linux-ck-haswell linux-ck-haswell-headers

    - Pegar UUID de /dev/sda2

            # blkid

    - Criar entrada UEFI na placa mãe:

            # efibootmgr --disk /dev/sda --part 1 --create --gpt --label "Arch Linux MuQSS+BFQ" --loader /vmlinuz-linux-ck-haswell --unicode "cryptdevice=UUID=[UUID-ACIMA]:cryptroot:allow-discards root=/dev/mapper/cryptroot rw initrd=\intel-ucode.img initrd=\initramfs-linux-ck-haswell.img fbcon=scrollback:2048k scsi_mod.use_blk_mq=1"

    - Reiniciar e verificar se MuQSS está rodando:

            # dmesg | grep -i muqss

- Configurar sensores de temperatura

        $ pacs lm_sensors
        # sensors-detect
        # systemctl enable lm_sensors

    - Instalar e configurar i8kfan (para controle manual do fan)

            $ aurget -S i8kutils
            $ sudo EDITOR=nano visudo
                # Permite usuários do grupo wheel rodarem i8kfan com sudo sem precisar de senha
                %wheel ALL=(ALL) NOPASSWD: /usr/bin/i8kfan

- Configurar e instalar drivers do Xorg para amdgpu e intel

        $ pacs xf86-video-intel xf86-video-amdgpu

    - Opcional: criar arquivo de configuração para poder utilizar opções

            # subl3 /etc/X11/xorg.conf.d/20-gpu.conf
                Section "Device"
                        Identifier  "Intel Graphics"
                        Driver      "intel"
                        Option      "DRI" "3"
                        #Option     "AccelMethod"  "sna" # default
                        #Option     "AccelMethod"  "uxa" # fallback
                EndSection

                Section "Device"
                        Identifier  "AMD Graphics"
                        Driver      "amdgpu"
                        Option      "DRI" "3"
                EndSection

- [Serviços e clientes de impressão](https://wiki.archlinux.org/index.php/CUPS)

    1. Instalar `cups`, `gutenprint` e `ghostscript`

            $ pacs cups gutenprint ghostscript

    2. Para a integração com o Gnome (erro ao adicionar a impressora):

            $ pacs system-config-printer

    3. Para a ML-2165 instalar `samsung-ml2160` da AUR

            $ aurget -S samsung-ml2160

    4. Ativar e iniciar serviços

            $ systemctl enable org.cups.cupsd.service
            $ systemctl start org.cups.cupsd.service

    5. Adicionar impressora

        - Pelo `gnome-control-center`

        - Ou pela interface web do cups em localhost:631

            - Se no chrome não funcionar, tentar pelo epiphany ou outro navegador!

# Tips-and-Tricks

### USB Flash Drives

- TODO: Geram alto IOWAIT, param de ser reconhecidos, mesmo depois de desplugar e plugar.
    - Tem a ver com udev, ele trava e fica esperando.

- Se Foram escritos com *iso9660 filesystem signatures* — como um USB bootavel escrito com `dd` — executar este comando para apagar as signaturas:

    # wipefs --all /dev/sdx

### Abrir gnome-calculator com locale en_US

_Em função dos pontos decimais invertidos_

- Criar um atalho customizado com o seguinte comando
        env LC_NUMERIC=en_US.UTF-8 gnome-calculator


### VirtualBox(https://wiki.archlinux.org/index.php/VirtualBox)

1. Instalar VirtualBox e hook DKMS (para os módulos funcionarem com qualquer kernel)

        $ pacs virtualbox virtualbox-host-dkms virtualbox-guest-iso

2. Adicionar usuário ao grupo `vboxusers`

        # gpasswd -a esauvisky vboxusers

3. Reiniciar o sistema, abrir o VirtualBox e editar o diretório padrão das VMs

- USB 3.0 Passthrough

    - Necessário instalar a extensão VirtualBox da Oracle:

            $ aurget -S virtualbox-ext-oracle

    - Depois instalar na máquina virtual o [driver USB 3.0 (xHCD) da Intel](https://forums.virtualbox.org/viewtopic.php?f=6&t=76023&start=15)

### Mimetypes, associações, arquivos .desktop e [Default Applications](https://wiki.archlinux.org/index.php/Default_applications)

- Lidando com mimetypes:

    - Descobrir o mimetype de um arquivo

            $ xdg-mime query filetype *[arquivo]*

    - As configurações de mimetype (mimeapps.list) encontram-se em:

        1. `~/.config/mimeapps.list`

        2. `~/.local/share/applications/mimeapps.list` (em fase de deprecação)

        - Seções do arquivo:

            1. [Added Associations]
                - Associações listadas em ordem de preferência, separadas por ponto-e-vírgula.
            2. [Default Applications]
                - Aplicativo padrão *(ao dar duplo-clique, por exemplo)*, somente um por linha.
            3. [Removed Applications]
                - Associações explícitamente removidas *(é preferível remover das seções acima)*.

        - Exemplo útil:

            - Abre por padrão com **eog**, mas ao clicar em *Open with another application*, o primeiro da lista será o **GIMP**.

                    [Added Associations]
                    image/png=gimp.desktop;eog.desktop;
                    [Default Applications]
                    image/png=eog.desktop

    - Depois de editar mimetypes, atualizar o banco de dados:

            # update-desktop-database

- Remover/organizar as entradas do *Open with/Abrir com* do Nautilus

    1. Copiar cada entrada de /usr/share/applications para .local/share/applications

    2. Editar a entrada local e:

        - Editar a linha `Exec=[...]` e remover `%U` do final (ainda permite iniciar o software pelo Alt+F1)

        - Ou adicionar `Hidden=true` para ocultar por completo o software (inclusive do Alt+F1)

        - Outra opção é adicionar `NoDisplay=true` em vez de `Hidden=true`, mas a segunda parece mais abrangente.

- Criar swapfile para habilitar suporte para Suspensão

    1. [Criar swapfile](https://wiki.archlinux.org/index.php/Swap#Swap_file_creation)

            # cat /proc/meminfo | grep MemTotal
            # dd if=/dev/zero of=/swapfile bs=1M count=[MemTotal/1000] status=progress
            # chmod 600 /swapfile
            # mkswap /swapfile
            # swapon -f /swapfile

    2. Adicionar entrada no fstab

            # subl3 /etc/fstab
                # Swapfile
                /swapfile  none  swap  defaults,noatime,discard  0  0

    3. Descobrir offset do arquivo e adicionar entrada UEFI

            # filefrag -v /swapfile | awk '{if($1=="0:"){print $4}}'
            # efibootmgr [...] root=/dev/mapper/cryptroot resume=/dev/mapper/cryptroot resume_offset=[OFFSET_ACIMA] rw [...]

    4. Adicionar hook `resume` do mkinicpio (depois de encrypt mas antes de filesystems) e regerar initramfs

            # subl3 /etc/mkinitcpio.conf
                HOOKS=(... encrypt resume ... filesystems ...)
            # mkinitcpio -p linux-ck-haswell

    5. Aumentar [tamanho máximo da imagem de hibernação](https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate#About_swap_partition.2Ffile_size) via [tmpfiles](https://wiki.archlinux.org/index.php/Systemd#Temporary_files)

            $ free -b
            # subl3 /etc/tmpfiles.d/hibernation_size.conf
                #Type   Path                                Mode    UID     GID     Age     Argument
                w       /sys/power/image_size               -       -       -       -       [TAMANHO-SWAP-BYTES]
## Problemas de Lag no Input com Layouts de Teclado Alternativos

Usuários do Xorg com layouts como ABNT podem enfrentar lags ao usar ferramentas que simulam pressionamentos de teclas, devido ao recarregamento do mapa de teclas pelo Xorg a cada simulação.

- Gnome: [Issue #1858 no GitLab](https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/1858)
- Mutter: [Commit relevante no GitLab](https://gitlab.gnome.org/GNOME/mutter/-/commit/b01edc22f3cf816ec2bbc4e777fb44525a8456a8)

### Solução: Instalar `mutter-performance`
1. Clone e entre no repositório do AUR:
    ```bash
    git clone https://aur.archlinux.org/mutter-performance.git
    cd mutter-performance
    ```
2. Edite o PKGBUILD conforme necessário e compile o pacote:
    ```bash
    makepkg -si
    ```

# A verificar/atualizar

        - Configurar Google Chrome
            - Extensões
                - LastPass
                    - Instalar extensão
                    - Instalar componente binário
                - Stylus (antigo Stylish)
                    - Importar backup
                - Tampermonkey
                    - Importar configurações via Google Drive ou backup
                - uBlock Origin
                    - Ativar "Enable cloud storage support"
                    - Desativar "Disable pre-fetching (to prevent any connection for blocked network requests)"
                    - Baixar configurações da nuvem nas abas:
                        - 3rd-party filters
                        - My filters
                        - My rules
                        - Whitelist
                - WOT
                    - Sincronizar perfil e configurar
                - The Great Suspender
                - Chrome Regex Search
                    - Configurar atalho para Ctrl+Shift+F
                - Tabby Cat
                    - Tentar importar gatos (pesquisar por mefhakmgclhhfbdadeojlkbllmecialg no Default Profile do backup)
                - MetaMask
                    - Importar seed
                - Myibidder Auction Bid Sniper for eBay
                - WikiWand

        - Configurar Temas (gnome-tweak-tool)
            - Instalar Temas
                - Ativar Global Dark Theme (se já não estiver ativada)
                - Ativar extensão User Themes (se já não estiver ativada)
                - GTK+: NumixSolarizedDark
                - Icons: Paper
                - Shell: SolArc-Dark
        - Pulseaudio
            - Configurações do usuário local
                $ gedit ~/.config/pulse/daemon.conf
                    ## Utiliza volumes relativos. Soluciona vários probleminhas de volume e é bem melhor para resetar os volumes dos apps.
                    flat-volumes = no
        - Banco do Brasil (warsaw):
            - Verificar configurações chrome://settings/content/flash
            - Ativar flag chrome://flags/#allow-insecure-localhost
            - Instalar warsaw da AUR:
                $ aurget -S warsaw
                $ systemctl restart warsaw.service
                - Abrir http://www.dieboldnixdorf.com.br/warsaw e selecionar o banco desejado para atualizar

        - Configuração Básica Samba (com usershares):
            # pacman -S samba gvfs-smb
            # cp /etc/samba/smb.conf.default /etc/samba/smb.conf
            # gedit /etc/samba/smb.conf
                workgroup = WORKGROUP
                server string = Emi Server
            # mkdir -p /var/lib/samba/usershare
            # groupadd sambashare
            # sudo chown root:sambashare /var/lib/samba/usershare
            # chmod 1770 /var/lib/samba/usershare
            # gedit /etc/samba/smb.conf
                [global]
                usershare path = /var/lib/samba/usershare
                usershare max shares = 100
                usershare allow guests = yes
                usershare owner only = yes
            # usermod -a -G sambashare esauvisky
            # systemctl enable smbd nmbd

        - noip
            $ aurget -S noip
            # noip2 -C
                OU Copiar no-ip2.conf para /etc/
            $ systemctl enable noip2.service

        - Configurar Bluetooth:
            - Gnome Settings -> Sharing
                - Ativar Bluetooth Sharing
                - Ativar Personal File Sharing para WiFi-Direct
            $ pacs gnome-user-share gnome-bluetooth bluez bluez-utils obexftp obexfs
            # systemctl enable bluetooth
            # systemctl start bluetooth
            - Opcional: instalar blueman para monitorar transferências e pareamentos.

        - Configurar MTP
            $ pacs libmtp mtpfs gvfs-mtp

        - Configurar iPhones e iPods via Nautilus:
            $ pacs gvfs-afc usbmuxd

        - Instalar e configurar Wine/PlayOnLinux
            $ pacs playonlinux
            $ pacs wine-mono wine_gecko samba lib32-libxslt lib32-libxml2
            $ pacs lib32-alsa-lib lib32-alsa-plugins lib32-mpg123 lib32-libpulse
            - Usar no terminal TZ=America/New_York wine arquivo.exe se houver problema de TZ


        ### Tips and Tricks
        - Enable Ctrl+TAB and Ctrl+Shift+TAB for switching tabs on gnome-terminal:
            $ gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ next-tab '<Primary>Tab'
            $ gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ prev-tab '<Primary><Shift>Tab'
        - Para montar partições do Windows *com* permissão de escrita, instalar ntfs-3g
        - Como remover o popup "application is ready", e fazer a janela roubar o foco instalar (ou copiar do backup) a extensão Steal my Focus
        - Configurar GIT para usar o gnome-keyring:
            $ git config --global credential.helper /usr/lib/git-core/git-credential-gnome-keyring
        - Desativar controle de mouse com joysticks
            $ pacr xf86-input-joystick
            - Como listar todas as bibliotecas necessárias por certo binário:
                $ ldd binário
            - Como listar o pacote que contém a biblioteca:
                $ pkgfile -s libportaudio.so.2
            - Copiar arquivos pelo rsync com verificação de crc & etc.
                $ rsync -avhn --progress SOURCE DESTINO
                - Verificar e remover -n para rodar
                - Adicionar --del se quiser "sincronizar", ou seja, deletar arquivos em DESTINO que não estejam presentes em SOURCE
                - Lembre-se que se SOURCE for um diretório com / no final, este é tratado como /\*, portanto se quiser lidar com a pasta como se fosse um arquivo, não coloque / no final.

        ### Deprecado
        - * Drivers placa de vídeo Topaz XT [Radeon R7 M260/M265]
            * O driver nativo da kernel 'amdgpu' está funcionando perfeitamente
            - Carrega o módulo radeon antes do KMS
                # gedit /etc/mkinitcpio.conf
                    MODULES="radeon"
            - Adicionar radeon.dpm=1 à inicialização da Kernel??
        - Desabilitar touchpad se existe um mouse externo conectado
            # gedit /etc/udev/rules.d/01-touchpad.rules
                SUBSYSTEM=="input", KERNEL=="mouse[0-9]", ACTION=="add", PROGRAM="/usr/bin/find /var/run/gdm -name esauvisky -print -quit", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="$result/database", RUN+="/usr/bin/synclient TouchpadOff=1"
                SUBSYSTEM=="input", KERNEL=="mouse[0-9]", ACTION=="remove", PROGRAM="/usr/bin/find /var/run/gdm -name esauvisky -print -quit", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="$result/database", RUN+="/usr/bin/synclient TouchpadOff=0"
        - Editar atalhos de softwares (accels) *on-the-fly*
            $ dconf-editor
                org.gnome.desktop.interface can-change-accels true
        - Configurações do Mouse
            - Instalar solaar-git (para Logitech Unifiying Receivers)
            $ dconf-editor
                org.gnome.settings-daemon.plugins.mouse active false
            # cp /usr/share/X11/xorg.conf.d/50-synaptics.conf /etc/X11/xorg.conf.d/50-synaptics.conf
            $ gedit /etc/X11/xorg.conf.d/50-synaptics.conf
                # Scroll horizontal com dois dedos
                Option "HorizTwoFingerScroll" "1"
                # Sensibilidade de pressão
                Option "FingerLow" "20"
                Option "FingerHigh" "25"
                # Tempo máximo de tapping
                Option "MaxTapTime" "150"
                # Detecção de palmas
                Option "PalmDetect" "1"
                Option "PalmMinWidth" "8"
                Option "PalmMinZ" "100"
                # Sensibilidade
                #Option "HorizHysteresis" "1"
                #Option "VertHysteresis" "1"
            - Autostart (EmliDaemon): syndaemon -t -k -i 2 (instalar pelo pacman)
            - Autostart (EmliDaemon): touchpad-detect (script)
            - Remover applet do Solaar da auto-inicialização:
                $ sudo gedit /etc/xdg/autostart/solaar.desktop
                    X-GNOME-Autostart-enabled=false
        - Configurar Power Options
            # gedit /etc/systemd/logind.conf
                HandlePowerKey=ignore
                HandleSuspendKey=ignore
                HandleHibernateKey=ignore
                HandleLidSwitch=ignore
                HandleLidSwitchDocked=ignore
                PowerKeyIgnoreInhibited=yes
                SuspendKeyIgnoreInhibited=yes
                HibernateKeyIgnoreInhibited=yes
                LidSwitchIgnoreInhibited=yes
            $ dconf-editor
                org.gnome.settings-daemon.plugins.power
            * Talvez valha a pena desativar org.gnome.settings-daemon.plugins.power (via active false) e utilizar somente systemd
            * Se ao fechar a tampa o monitor externo (e o interno) ficarem desativados, remover ~/.config/monitors.xml
        - Pulseaudio
            - Remover autostart do pulseaudio no GDM
                # gedit /var/lib/gdm/.pulse/daemon.conf
                    autospawn = no
                    daemon-binary = /bin/true
                # chown gdm:gdm /var/lib/gdm/.pulse -R
        - Autostart: EmliDaemon
