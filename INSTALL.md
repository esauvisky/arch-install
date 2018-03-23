Este arquivo é versionado via git, não se esqueça de fazer commit das alterações toda vez que editar!

 
General Tips
============
- Como listar todas as bibliotecas necessárias por certo binário:
    $ ldd binário
- Como listar o pacote que contém a biblioteca:
    $ pkgfile -s libportaudio.so.2
- Copiar arquivos pelo rsync com verificação de crc & etc.
    $ rsync -avhn --progress SOURCE DESTINO
    - Verificar e remover -n para rodar
    - Adicionar --del se quiser "sincronizar", ou seja, deletar arquivos em DESTINO que não estejam presentes em SOURCE
    - Lembre-se que se SOURCE for um diretório com / no final, este é tratado como /*, portanto se quiser lidar com a pasta como se fosse um arquivo, não coloque / no final.


INSTALAÇÃO
==========

Parâmetros da Configuração
--------------------------
- Boot via UEFI diretamente pela placa mãe [https://wiki.archlinux.org/index.php/EFISTUB#Using_UEFI_directly]
- Orientação completa para SSDs
- Somente duas partições, root e boot.
- Encriptação total do sistema, menos /boot, via LUKS [https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system]
- Layout final das partições (GPT)
		+-----------------------+------------------------+
		| Boot Partition        | LUKS Partition         |
		| Filesystem: FAT32     | Filesystem: ext4       |
		| Tamanho: 550MiB       | Tamanho: 100%          |
		|                       |                        |
		|                       | /dev/mapper/cryptroot  |
		|                       |------------------------|
		| Type: EF00            | Type: 8300             |
		| /dev/sda1             | /dev/sda2              |
		+-----------------------+------------------------+

Passo-a-Passo
-------------
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
- Encriptar Partição #2 [https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Preparing_non-boot_partitions]
        # cryptsetup -y -v luksFormat --type luks2 /dev/sda2
- Abrir Partição Encriptada (e ativar discards permanentemente)
        # cryptsetup --allow-discards --persistent open --type luks2 /dev/sda2 cryptroot
- Formatar as partições
        # mkfs.ext4 /dev/mapper/cryptroot
        # mkfs.fat -F32 /dev/sda1
- Montar as partições
        # mount /dev/mapper/cryptroot /mnt
        # mkdir /mnt/boot
        # mount /dev/sda1 /mnt/boot
- Selecionar mirrors do arch rápidos
        # cd /etc/pacman.d
        # mv mirrorlist mirrorlist~
        # rankmirrors -vn 6 mirrorlist~ > mirrorlist
- Instalar o sistema base
        # pacstrap /mnt base base-devel efibootmgr
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
- Configurar e regerar mkinitcpio para funcionar com o dm-crypt [https://wiki.archlinux.org/index.php/Dm-crypt Encrypting_an_entire_system#Configuring_mkinitcpio]
    - Adicionar HOOKS 'keyboard' e 'keymap' antes de 'block' e 'encrypt' antes de 'filesystems'
        # nano /etc/mkinitcpio.conf
            HOOKS=(... keyboard keymap block encrypt ... filesystems ...)
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
    - Criar entrada UEFI na placa mãe:
        # efibootmgr --disk /dev/sda --part 1 --create --gpt --label "Arch Linux" --loader /vmlinuz-linux --unicode "cryptdevice=UUID=[UUID-ACIMA]:cryptroot:allow-discards root=/dev/mapper/cryptroot rw initrd=/intel-ucode.img initrd=/initramfs-linux.img fbcon=scrollback:2048k scsi_mod.use_blk_mq=1"
    - Dica: após, apertar seta para cima, adicionar aspas simples no comando inteiro, echo na frente e redirecionar para /boot/efi-params.txt
        # echo 'efibootmgr [...]' > /boot/efi-params.txt
- Sair do chroot, desmontar partições e reiniciar sistema!
        # exit
        # umount -R /mnt
        # reboot

Post Install
============
- Fazer login como root
- Ativar e iniciar a internet
        # systemctl enable NetworkManager
        # systemctl start NetworkManager
    - Se precisar de WiFi, usar `wifi-menu`
- Instalar algumas coisas:
        # pacman -S bash-completion xorg-xinit fortune-mod wget
- Copiar backup das configurações salvas para /root
        # mount [device] /mnt
        # cp /mnt/arch-install/bash-conf/.* /root/
    - Copiar regra udev para usar BFQ como I/O scheduler
        # cp /mnt/arch-install/etc/udev/rules.d/60-ioscheduler.rules /etc/udev/rules.d/
    - Importar /etc/pacman.conf
        # cp /mnt/arch-install/etc/pacman.conf /etc/pacman.conf
    - Importar módulo snd_hda_intel (para evitar power-saving e ruídos):
        # cp /mnt/arch-install/etc/modprobe.d/snd-hda-intel.conf /etc/modprobe.d/snd-hda-intel.conf
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
- Adicionar módulos dos drivers gráficos no Early KMS:
        # nano /etc/mkinitcpio.conf
            MODULES=(i915 amdgpu)
        # mkinicpio -p linux
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
- Instalar gnome, gnome-extra e xorg
        # pacman -S gnome gnome-extra xorg
    - Usar `^13 ^43` e assim por diante para selecionar tudo menos alguns
    - Exclusões recomendadas
        gnome:       ^13 ^43 ^45 ^50 ^51 ^52 (gnome-dictionary, rygel, totem, yelp, gnome-software, simple-scan)
        gnome-extra: ^2 ^3 ^4 ^5 ^6 ^10 ^12 ^13 ^16 ^17 ^19 ^23 ^24 ^26 ^29 ^31 ^33 ^34 ^35 ^39 ^40 ^42 ^44 ^45 ^46 ^48 ^49 ^50
- Trocar para tty2, fazer login com o novo usuário e trocar de volta para tty1
    **Atenção: .bash_profile irá executar startx imediatamente assim que for feito login com o usuário não-root em tty2!**
    **Portanto, faça login antes de copiar o arquivo ou use outro tty**
- Copiar os arquivos de configuração do bash para o usuário, apagar os em /root, criar links simbólicos e arrumar permissões
        # cd ~
        # cp .toprc .inputrc .bashrc .bash_profile /home/esauvisky
        # touch /home/esauvisky/.bash_eternal_history
        # chown esauvisky:esauvisky /home/esauvisky/.*
        # rm .toprc .inputrc .bashrc .bash_profile
        # ln -s /home/esauvisky/.bashrc /home/esauvisky/.inputrc /home/esauvisky/.toprc /home/esauvisky/.bash_profile /root/
        # chmod 664 .bashrc .inputrc .toprc .bash_profile .bash_eternal_history
- Com o usuário, copiar esqueleto do .xinitrc
        $ cp /etc/X11/xinit/xinitrc ~/.xinitrc
- Editar .xinitrc
        $ nano .xinitrc
    - Apagar de 'twm' em diante e substituir por:
        exec gnome-session
- Trocar para tty1 e reiniciar o sistema
        # reboot
**Se tudo der certo, o sistema será reiniciado e o gnome iniciará automaticamente após digitar a senha do HD!!!11UM**

+ TODO: backup header LUKS

CONFIGURAÇÕES
=============
*aaanndd theere ve go!*

- Configuração Básica Terminal e Pacotes
    # pacman -S bash-completion
    - Configurar perfil do terminal
        - Tamanho: 100x30
        - Etc...
    - Instalar aurget (usar o epiphany para baixar o pkgbuild e não precisar instalar o Firefox)
        - Importar ~/.config/aurgetrc

- Configurar userdirs ~/.config/user-dirs.dirs
   	XDG_DESKTOP_DIR="$HOME/Desktop/"
	XDG_DOWNLOAD_DIR="$HOME/Desktop/Downloads"
	XDG_TEMPLATES_DIR="$HOME/.local/share/nautilus/templates"
	XDG_PUBLICSHARE_DIR="$HOME/Files/Public"
	XDG_DOCUMENTS_DIR="$HOME/Documents"
	XDG_MUSIC_DIR="$HOME/Media"
	XDG_PICTURES_DIR="$HOME/Media"
	XDG_VIDEOS_DIR="$HOME/Media"

- Configurar Gnome
    - Gnome: Region & Language:
        - Language: English
        - Formats: Brasil
        - Layout Teclado: Portuguese (Brazil)
    - Configurar opções uma-a-uma
    - Configurar atalhos um-a-um, remover todos os não-utilizados
        - Custom Shortcuts:
            Launch Terminal: gnome-terminal | Super+T
            Shorten URL: shortenurl -c | Super+W
            Download URL to /tmp: uridownload | Super+R
            Launch System Monitor: gnome-system-monitor | Ctrl+Alt+Delete
            Take a Screenshot: emiliano-screenshot | Print

- Remover coisas aleatórias não utilizadas que foram instaladas anyways
        $ pacr gnome-contacts gnome-maps folks gnome-todo gnome-calendar evolution evolution-data-server gnome-photos
    - Ir no .config e apagar o que tá sobrando relacionado aos acima

- Instalar Google Chrome
        $ aurget -S google-chrome-stable
    - Definir a senha do Default keyring em branco

- Configurar Gnome-Shell (gnome-tweak-tool)
    - Ação do botão de desligar
    - Ação de fechar a tampa
    - Setar "Super-Right" como tecla de overlay (para evitar super de abrir o activities)
    - Integrar extensões com o Chrome
        - Instalar a extensão https://goo.gl/89TkHr
        - Instalar o conector nativo:
            $ pacs chrome-gnome-shell
    - Extensões
        * São instaladas em .local/share/gnome-shell/extensions
        * Se der problema com schemas, entrar na pasta plugin@autor/schemas/ e executar:
            $ glib-compile-schemas .
        - Extensões Utilizadas:
            - Freon
            - Lock keys
            - No topleft hot corner
            - Pomodoro
            - Removable drive menu
            - System Monitor
            - Topicons Plus (restaura a barra deprecada dos ícones de notificação)
            - User themes
            - Volume mixer
            - Workspace grid
            - Shellshape
        - Editar o extension.js de cada uma para reorganizar elas no menu
            - Pesquisar por: 'addToStatusArea'
            - Editar de acordo:
                Main.panel.addToStatusArea('shellshape-indicator', _indicator, 1, 'left');

- Adicionar tmpfs para algumas pastas em /etc/fstab
        - .cache/google-chrome
        - .cache/spotify
        - .aurget

- Instalar e configurar Profile-sync-daemon[https://wiki.archlinux.org/index.php/Profile-sync-daemon]

- Configurações do SMART para o HD
    - Ativa o daemon do SmartmonTools
        $ pacs smartmontools
        $ gedit /etc/smartd.conf
            - Substituir DEVICESCAN por:
                /dev/sda -a -o on -S on -s (S/../.././02|L/../../6/03) -W 4,35,45
            - Substituir /dev/sda acima por DEVICESCAN se desejar escanear *todos* os hds presentes
        $ systemctl start smartd
        $ systemctl status smartd
        $ systemctl enable smartd
    - Verifica o estado dos HDs
        # smartctl --all /dev/sda

- Teclado
    - Instalar e configurar clipit
        - Items in history: MAX (1000)
        - Items in menu: MIN (5)
        - Manage Hotkey: Super+Q
        - Deletar todas as outras hotkeys
        - Adicionar no auto-start do gnome-tweak tool
    - Editar layout do teclado podre US em /usr/share/X11/xkb/symbols/br (ou encontrar um user-specific)
      Já que .Xmodmap não funciona no gnome pelo visto:
        Linha 18 (Editar): key <AE12> { [        equal,           plus,           bar,     dead_ogonek ] };
        Linha 19 (Adici.): key <AD09> { [            o,              O,   Greek_OMEGA,     Greek_OMEGA ] };

- Instalar e configurar linux-ck (*para MuQSS + BFQ baby!*) [https://wiki.archlinux.org/index.php/Linux-ck]
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
        # efibootmgr --disk /dev/sda --part 1 --create --gpt --label "Arch Linux MuQSS+BFQ" --loader /vmlinuz-linux-ck-haswell --unicode "cryptdevice=UUID=[UUID-ACIMA]:cryptroot:allow-discards root=/dev/mapper/cryptroot rw initrd=/intel-ucode.img initrd=/initramfs-linux-ck-haswell.img fbcon=scrollback:2048k scsi_mod.use_blk_mq=1"
    - Reiniciar e verificar se MuQSS está rodando:
        # dmesg | grep -i muqss

- Configurar sensores de temperatura
    $ pacs lm_sensors
    # sensors-detect
    # systemctl enable lm_sensors
    TODO: i8k e controle do fan

# EU PAREI AQUI #

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

- Adicionar links para meus softwares em ~/Documentos/Programação/Projetos
    $ cdp
    $ ./Atualizar_Projetos

- Para montar partições do Windows *com* permissão de escrita, instalar ntfs-3g

- Instalar serviços e clientes de impressão:
    $ pacs cups ghotscript gsfonts gutenprint
    $ systemctl enable org.cups.cupsd.socket
    $ systemctl start org.cups.cupsd.service
        - Navegar para localhost:631
        - Configurar impressora (logar como root)

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

- Desativar controle de mouse com joysticks
    $ pacr xf86-input-joystick

- Instalar e configurar Wine/PlayOnLinux
    $ pacs playonlinux
    $ pacs wine-mono wine_gecko samba lib32-libxslt lib32-libxml2
    $ pacs lib32-alsa-lib lib32-alsa-plugins lib32-mpg123 lib32-libpulse
    - Usar no terminal TZ=America/New_York wine arquivo.exe se houver problema de TZ

- Configurar GIT para usar o gnome-keyring
    $ cd /usr/share/git/credential/gnome-keyring/
    # make
    $ git config --global credential.helper /usr/lib/git-core/git-credential-gnome-keyring

- noip
    $ aurget -S noip
    # noip2 -C
        OU Copiar no-ip2.conf para /etc/
    $ systemctl enable noip2.service

- VirtualBox
    - USB 3.0 Passthrough
        - Necessário instalar a extensão VirtualBox da Oracle
            $ aurget -S virtualbox-ext-oracle
        - Depois adicionar o usuário no grupo vboxusers
            # sudo usermod -aG vboxusers esauvisky
        - Depois instalar na máquina virtual o driver USB 3.0 (xHCD) da Intel
            https://goo.gl/NqkZ1U

##### DEPRECADO #####
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
