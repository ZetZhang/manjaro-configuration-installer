#!/usr/bin/env sh
# sudoer
export USER=`whoami`
`! sudo echo` && [ $USER != root ] && su - -c "sed -i \"/root ALL=(ALL) ALL/a\""$USER\"" ALL=(ALL) ALL\" /etc/sudoers && exit"

if [ ! -d ~/.hci ]; then
    echo -e "configure manjaro?(y|yes)"
    read -t 7 -u 0 choice
    if [[ "{y, yes}" =~ $choice ]]; then mkdir -p ~/.hci && touch ~/.hci/.c1; fi
    
    echo -e "simple installtion(s|simple) or full installtion(f|full)"
    read -t 7 -u 0 way
    if [[ "{s, simple}" =~ $way ]]; then touch ~/.hci/.simple
    elif [[ "{f, full}" =~ $way ]]; then touch ~/.hci/.full
    fi
fi
jmpback=`pwd`

if test -d ~/.hci ; then

# source server init：以下基于ustc源
declare exi=`grep '\[archlinuxcn\]' /etc/pacman.conf | wc -l`
if test $exi -eq 0; then
    cd $jmpback
    #sudo pacman-mirrors --fasttrack
    sudo pacman-mirrors -i -c China -m rank
    su - -c "echo -E '[archlinuxcn]
SigLevel = Optional TrustedOnly
Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch' >> /etc/pacman.conf"
    sudo sed -i "s/^#\(Color\)/\1/" /etc/pacman.conf
    # gpg difference error
    # sudo pacman-key --refresh-keys
    # sudo pacman-key --init
    # sudo pacman-key --populate
    # sudo pacman -Scc
    # sudo pacman -Syu
    # sudo pacman -S glibc lib32-glibc 
fi

# install
ma='sudo pacman -S --noconfirm --needed'
ya='yay -S --noconfirm --needed'
sudo pacman --noconfirm --needed -Syy 
sudo pacman --noconfirm --needed -S archlinuxcn-keyring
sudo pacman --noconfirm -Syyu
$ma base-devel yay && yay --noconfirm --needed --overrite "*" -Syyu
# $ma {curl,wget,libevent}
# $ma {tlp,tlp-rdw,smartmontools}

declare gs=`git config --global --list | grep user | wc -l`
[ $gs -gt 2 ] || (git config --global user.name "ZetZhang" && git config --global user.email "13660591402@163.com" && \ 
    [ -f /etc/pip.conf ] || ([ -z "`grep [global] /etc/pip.conf`" ] && [ -z "`grep [instsall] /etc/pip.conf`" ]) && \
        echo '[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
[install]
trusted-host=mirrors.aliyun.com' >> /etc/pip.conf)

# install tmux
$ma {tmux,xclip}
if [ -f ~/.hci/.c1 ]; then
    # Tpm
    mkdir -p ~/.tmux/plugins
    cp ./tmux.conf ~/.tmux.conf && cp ./tmux.conf.local ~/.tmux.conf.local
    cd ~/.tmux/plugins && git clone https://github.com/tmux-plugins/tpm
    [ $? -eq 0 ] && mv ~/.hci/.c1 ~/.hci/.c2
fi
tmux new -d -s test && tmux source ~/.tmux.conf && tmux kill-session -t test
# you should enter session and execute command: `prefix r` & `prefix I`
# tmux Resurrect
# if you don't use Tpm, you should
#cd ~/.tmux/plugins && git clone https://github.com/tmux-plugins/tmux-resurrect.git
#tmux run-shell ~/.tmux/plugins/tmux-resurrect/resurrect.tmux

$ma zsh
if [ -f ~/.hci/.c2 ]; then
    cd $jmpback
    su - -c "sed '/raw.githubusercontent.com/d' /etc/hosts"
    # >by links
    # $ma links
    # # FIXME：确保复制到真实IP
    # links https://githubusercontent.com.ipaddress.com/raw.githubusercontent.com
    # cpyip=`xclip -o`
    # # sduo systemctl restart NetworkManager.service
    # cpyip=`xclip -o`; su - -c "echo '$cpyip raw.githubusercontent.com' >> /etc/hosts"

    # >by curl
    export result=`curl https://githubusercontent.com.ipaddress.com/raw.githubusercontent.com | \
        sed -e 's/\(<ul[^>]*>\)/\1\n/g' -e 's/\(<\/ul[^>]*>\)/\n\1/g' | \
        grep -E '<li>([0-9]{1,3}.){3}[0-9]{1,3}</li>' | \
        sed -e 's/<li[^>]*>//g' -e 's/<\/li[^>]*>//g' | head -n 1`
    su - -c "echo '$result raw.githubusercontent.com' >> /etc/hosts"
    sudo systemctl restart NetworkManager.service && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    # Need to exit manually (Ctrl + D)
    [ $? -eq 0 ] && mv ~/.hci/.c2 ~/.hci/.c3
fi

# install zsh && ohmyzsh
if [ -f ~/.zshrc -a -f ~/.hci/.c3 ]; then
    cd $jmpback
    $ma {neovim,ruby,npm,fzf,autojump,the_silver_searcher,thefuck,bat}

    sudo python -m ensurepip
    sudo python -m pip install --upgrade pip setuptools wheel
    sudo pip3 install colorma
    
    python -m pip install --user --upgrade pynvim
    npm install express --registry=https://registry.npm.taobao.org
    npm install -g neovim
    gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/  
    gem sources --update && gem install neovim && gem list -ra neovim

    # zplug [out of data]
    # export ZPLUG_HOME=~/.zplug && git clone https://github.com/zplug/zplug $ZPLUG_HOME
    # zinit instead
    # sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
    mkdir ~/.zinit && git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
    
    declare zsc=`test -f ~/.zshrc && grep '^plugins=(' ~/.zshrc`
    if [ zsc != "" ]; then
        sed -i "/^plugins=(/a\ \t#git\n\t#zsh-syntax-highlighting\n\t#autojump\n\t#fzf\n\t#zsh-autosuggestions\n\t#web-search\n\t#extract\n\t#gitignore\n\t#cp\n\t#zsh_reload\n\t#z\n\t#per-directory-history\n\t#colored-man-pages\n\t#sudo\n\t#history-substring-search\n\t#git-open\n\t#safe-paste\n\tthemes\n\t#vi-mode\n\t#command-not-found\n\t#auto-notify $plugins # zinit instead)" ~/.zshrc
        sed -i "s/\(^plugins=(\)git)/\1/" ~/.zshrc
        sed -i "s/^# \(export LANG\)/\1/" ~/.zshrc
        echo -E "# fzf
        export FZF_DEFAULT_OPTS='--height 80%'" >> ~/.zshrc
        echo -E "export FZF_CTRL_T_OPTS=\"--preview '(highlight -O ansi -l {} 2> /dev/null || bat --style=numbers --color=always {} || tree -C {}) 2> /dev/null | head -500'\"" >> ~/.zshrc
        echo -E "export FZF_DEFAULT_COMMAND='rg --files --hidden'" >> ~/.zshrc
        echo -E "eval $(thefuck --alias)" >> ~/.zshrc
        echo -E "export EDITOR=vim" >> ~/.zshrc
        echo -E "alias tmux='tmux -2'" >> ~/.zshrc
        echo -E "alias vim='nvim'" >> ~/.zshrc
        echo -E "bindkey '^P' history-substring-search-up" >> ~/.zshrc
        echo -E "bindkey '^N' history-substring-search-down" >> ~/.zshrc
        echo -E "# history
        "HIST_STAMPS="yyyy-mm-dd" >> ~/.zshrc
        echo -E "# trash
        alias rmt='trash'" >> ~/.zshrc
        echo -E "# suggestions
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=110'" >> ~/.zshrc
        echo -E "# proxychains4
        alias pc='proxychains4'" >> ~/.zshrc
        echo -E "# asynctask
        alias task='~/.vim/plugged/asynctasks.vim/bin/asynctask -f'" >> ~/.zshrc
        echo -E "# asynctask & tmux & vim
        alias tabedit='vim'" >> ~/.zshrc
        echo -E "# polybar
        # alias polybar='/home/ichheit/ich/execute/polybar/polybar_launch.sh'
        alias polybar=~/.config/polybar/launch.sh --forest" >> ~/.zshrc
        echo -E "#mpd
        alias mpd='mpd ~/.mpdconfig'
        " >> ~/.zshrc
        echo -E "# incr
        # source ~/.oh-my-zsh/plugins/incr/incr*.zsh" >> ~/.zshrc
        # echo -E "#
        # # ruby
        # PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"
        # export GEM_HOME=$HOME/.gem
        # " >> ~/.zshrc
        echo -E "# zinit
        if [[ -f ~/.zinit/bin/zinit.zsh  ]] {
            source ~/.zinit/bin/zinit.zsh

            # OMZ lib
            zinit snippet OMZ::lib/clipboard.zsh
            zinit snippet OMZ::lib/completion.zsh
            zinit snippet OMZ::lib/history.zsh
            zinit snippet OMZ::lib/key-bindings.zsh
            zinit snippet OMZ::lib/git.zsh
            zinit snippet OMZ::lib/theme-and-appearance.zsh

            # OMZ plugins
            zinit ice svn
            zinit snippet OMZ::plugins/git
            zinit snippet OMZ::plugins/autojump
            zinit snippet OMZ::plugins/fzf
            zinit snippet OMZ::plugins/web-search
            zinit snippet OMZ::plugins/extract
            zinit snippet OMZ::plugins/gitignore
            zinit snippet OMZ::plugins/cp
            zinit snippet OMZ::plugins/zsh_reload
            zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/per-directory-history/per-directory-history.zsh
            bindkey '^P' history-substring-search-up
            bindkey '^N' history-substring-search-down
            zinit snippet OMZ::plugins/colored-man-pages
            # zinit snippet OMZ::plugins/sudo
            # zinit snippet OMZ::plugins/z
            zinit load zsh-users/zsh-history-substring-search
            zinit snippet OMZ::plugins/safe-paste
            # zinit snippet OMZ::plugins/themes
            # zinit snippet OMZ::plugins/vi-mode
            # zinit snippet OMZ::plugins/command-not-found

            # autu-ls 
            zplugin ice wait'0' lucid
            zplugin load desyncr/auto-ls
            AUTO_LS_COMMANDS=(custom_function git-status)
            auto-ls-custom_function () { ls --color }

            # auto-notify
            zinit load 'MichaelAquilina/zsh-auto-notify'
            # Set threshold to 20seconds
            export AUTO_NOTIFY_THRESHOLD=1
            export AUTO_NOTIFY_TITLE='Hey! %command has just finished'
            export AUTO_NOTIFY_BODY='It completed in %elapsed seconds with Ecode %exit_code'
            # Set notification expiry to 10 seconds
            export AUTO_NOTIFY_EXPIRE_TIME=3000
            # redefine what is ignored by auto-notify
            # export AUTO_NOTIFY_IGNORE=('docker' 'sleep' '/usr/bin/vim' '/usr/bin/nvim' 'vim' 'nvim' 'kate' 'nano' 'code')
            export AUTO_NOTIFY_WHITELIST=('apt-get' 'sleep' 'yay' 'pacman' 'curl' 'you-get' 'sh' 'shell')

            # zsh-command-time
            zinit load 'popstas/zsh-command-time'
            # If command execution time above min. time, plugins will not output time.
            ZSH_COMMAND_TIME_MIN_SECONDS=3
            # Message to display (set to "" for disable).
            ZSH_COMMAND_TIME_MSG="Exec T> %s sec"
            # Message color.
            ZSH_COMMAND_TIME_COLOR="cyan"
            # Exclude some commands
            ZSH_COMMAND_TIME_EXCLUDE=(docker vim kate nvim nano code)
            zsh_command_time() {
                if [ -n "$ZSH_COMMAND_TIME" ]; then
                    hours=$(($ZSH_COMMAND_TIME/3600))
                    min=$(($ZSH_COMMAND_TIME/60))
                    sec=$(($ZSH_COMMAND_TIME%60))
                    if [ "$ZSH_COMMAND_TIME" -le 60 ]; then
                        timer_show="$fg[green]$ZSH_COMMAND_TIME s."
                    elif [ "$ZSH_COMMAND_TIME" -gt 60 ] && [ "$ZSH_COMMAND_TIME" -le 180 ]; then
                        timer_show="$fg[yellow]$min min. $sec s."
                    else
                        if [ "$hours" -gt 0 ]; then
                            min=$(($min%60))
                            timer_show="$fg[red]$hours h. $min min. $sec s."
                        else
                            timer_show="$fg[red]$min min. $sec s."
                        fi
                    fi
                    printf "${ZSH_COMMAND_TIME_MSG}\n" "$timer_show"
                fi
            }

            # zsh_autosuggestions
            # zinit ice lucid wait='0' atload='_zsh_autosuggest_start'
            zinit light zsh-users/zsh-autosuggestions

            # zsh-syntax-highlighting
            zinit light zsh-users/zsh-syntax-highlighting

            # git-open
            zinit load paulirish/git-open

            # incr
            # There are conflicts (themes & completed)
            # zinit snippet https://github.com/makeitjoe/incr.zsh/blob/master/incr.plugin.zsh

            # 256color
            zinit load 'chrissicool/zsh-256color'

            # bd
            zinit load 'Tarrasch/zsh-bd'

            # command-not-found
            zinit load 'Tarrasch/zsh-command-not-found'

            # fast-syntax-highlighting
            zinit light 'zdharma/fast-syntax-highlighting'
            zinit wait lucid for \
                atinit'ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay' \
                zdharma/fast-syntax-highlighting \
                blockf \
                zsh-users/zsh-completions \
                atload'!_zsh_autosuggest_start' \
                zsh-users/zsh-autosuggestions

            # nohup(ctrl-h)
            zinit light 'micrenda/zsh-nohup'
        }" >> ~/.zshrc

        source ~/.zshrc
    fi
    #sudo chsh -s /bin/zsh
    mv ~/.hci/.c3 ~/.hci/.c4
fi

# zsh-autosuggestions
# [ -f ~/.hci/.c4 ] && git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && mv ~/.hci/.c4 ~/.hci/.c5
# zsh-syntax-highlighting
# [ -f ~/.hci/.c5 ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && mv ~/.hci/.c5 ~/.hci/.c6
# git-open
# [ -f ~/.hci/.c6 ] && git clone https://github.com/paulirish/git-open.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/git-open && mv ~/.hci/.c6 ~/.hci/.c7

# incr
mkdir -p ~/.oh-my-zsh/plugins/incr/ && cd ~/.oh-my-zsh/plugins/incr/ && wget https://mimosa-pudica.net/src/incr-0.2.zsh 


if [ -f ~/.hci/.c7 ]; then
$ma ttf-roboto noto-fonts ttf-dejavu
# 文泉驿
$ma wqy-bitmapfont wqy-microhei wqy-microhei-lite wqy-zenhei
# 思源字体
$ma noto-fonts-cjk adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts
cp ./fonts.conf ~/.config/fontconfig/
[ $? -eq 0 ] && rm -rf ~/.hci.c7
fi

# special
$ma {\
nethogs,\
xournalpp,\
atool,\
elinks,\
mediainfo,\
libcaca,\
catdoc,\
docx2txt,\
conky,\
graphviz}

# special 2
$ma {\
exa,\
ripgrep,\
duf,\
dust,\
broot,\
fd,\
mcfly,\
tldr,\
bottom,\
gtop,\
hyperfine,\
gping,\
procs,\
httpie,\
xh,\
dog,\
obs-studio,\
pv,\
bpftrace,\
rustup}

$ya {\
ueberzug,\
xmake,\
cajviewer,\
yuview,\
audacity,\
todesk,\
obsidian,\
logseq-desktop,\
picgo-appimage,\
nbfc}

# simple
$ma {\
jdk8-openjdk,\
jdk10-openjdk,\
jdk13-openjdk}
archlinux-java status
sudo archlinux-java set java-8-openjdk

$ma {\
nnn,\
bar,\
tig,\
gdb,\
mtr,\
mpd,\
ncdu,\
rofi,\
zstd,\
perf,\
nmon,\
mosh,\
rust,\
cloc,\
tree,\
cmake,\
aria2,\
crash,\
bspwm,\
dstat,\
ccache,\
ranger,\
strace,\
xinetd,\
zeromq,\
docker,\
glances,\
polybar,\
todotxt,\
ripgrep,\
sysstat,\
mlocate,\
thefuck,\
you-get,\
cppcheck,\
net-tools,\
systemtap,\
traceroute,\
xbacklight,\
cppman-git,\
gnu-netcat,\
ansiweather,\
google-glog,\
lksctp-tools,\
ttf-cascadia-code,\
nerd-fonts-fira-code,\
kcachegrind}

$ya {\
trash-cli,\
zplug,\
rsyslog}

which cppman && ( cppman -c -m true -p nvim -r cppreference.com )
which perf && ( sudo sysctl -w kernel.perf_event_paranoid=-1 )

cd $jmpback && git clone https://github.com/todotxt/todo.txt-cli.git
which todo.sh && cd todo.txt-cli && make && sudo make install && mkdir ~/.todo && cp todo.cfg ~/.todo/config
# config todo_cfg is neccessary

# full
if test -f ~/.hci/.full ; then
$ma {\
visual-studio-code-bin,\
clion,\
pycharm-professional,\
vmware-workstation,\
intellij-idea-ultimate-edition,\
appmenu-gtk-module,\
qtcreator}
# vmware
sysinfo="`uname -r`"
pri="`uname -r | cut -d. -f1`"
sec="`uname -r | cut -d. -f2`"
#subs=(${sysinfo//./ })
sudo pacman -Qi "linux${pri}${sec}-headers" || ($ma "linux${pri}${sec}-headers" && sudo modprobe -a vmw_vmci vmmon)
sudo pacman -Qi "linux${pri}${sec}-virtualbox-host-modules" || ($ma "linux${pri}${sec}-virtualbox-host-modules")

$ma {\
rsibreak,\
fcitx-im,\
fcitx-configtool,\
fcitx-gtk2,\
fcitx-gtk3,\
fcitx-qt4,\
fcitx-qt5,\
libidn,\
fcitx-sogoupinyin,\
fcitx-googlepinyin,\
postgresql,\
libpqxx,\
lrzsz,\
nutstore,\
plantuml,\
plank,\
crossover,\
qq-linux,\
electronic-wechat,\
shadowsocks-qt5,\
v2ray,\
qv2ray,\
proxychains-ng,\
wireshark-qt,\
deepin.com.baidu.pan,\
wps-office,\
ttf-wps-fonts,\
wps-office-mui-zh-cn\
netease-cloud-music,\
typora,\
nemiver,\
google-chrome,\
scrcpy,\
anbox-git,\
anbox-image,\
anbox-modules-dkms-git,\
mpv}

if [ ! -d ~/.config/autostart ]; then
    mkdir ~/.config/autostart
    cp /etc/xdg/autostart/fcitx-autostart.desktop ~/.cofnig/autostart
echo "GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx" > ~/.pam_environment
echo "export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx" > ~/.xprofile
fi

# use xDdroid instead of the anbox
# sudo modprobe binder_linux                                  
# sudo modprobe ashmem_linux
# sudo systemctl start anbox-container-manager.service        
# systemctl --user start anbox-session-manager.service
# sudo systemctl enable anbox-container-manager
# sudo systemctl enable anbox-session-manager --user
# nmcli con add type bridge ifname anbox0 -- connection.id anbox-net ipv4.method shared ipv4.addresses 192.168.0.40/24

$ya {\
debtap,\
xmind}
# virtualbox
sudo pacman -Qi "linux${pri}${sec}-virtualbox-host-modules" && $ya virtualbox-ext-oracle && sudo modprobe vboxdrv
# wireshark
sudo pacman -Qi wireshark-qt && sudo chgrp $USER /usr/bin/dumpcap && sudo chmod 750 /usr/bin/dumpcap && sudo setcap cap_net_raw,cap_net_admin+eip /usr/bin/dumpcap

cd $jmpback && git clone https://github.com/BDisp/unlocker.git
cd unlocker && ./lnx-install.sh 

fi

# systemctl
if which tlp; then
    sudo systemctl enable tlp.service
    sudo systemctl enable tlp-sleep.service
    sudo systemctl mask systemd-rfkill.service
    sudo systemctl mask systemd-rfkill.socket
fi
if which docker; then
    sudo groupadd docker
    sudo gpasswd -a $USER docker
    sudo systemctl start docker && sudo systemctl enable docker
    su - -c "echo 0 >/proc/sys/kernel/yama/ptrace_scope && exit:"
    [ ! -f /etc/default/docker ] && su - -c "echo \"DOCKER_OPTS=\"--registry-mirror=http://hub-mirror.c.163.com\"\" >> /etc/default/docker"
fi
which xinetd && sudo systemctl start xinetd.service && sudo systemctl enable xinetd.service
ls /usr/lib/systemd/system/rsyslog.service && sudo systemctl start rsyslog.service && sudo systemctl enable rsyslog.service
which vmware && sudo systemctl start vmware-networks.service && sudo systemctl enable vmware-networks.service

[ $? -eq 0 ] && rm -rf ~/.hci
fi

cd $jmpback
git clone https://github.com/ZetZhang/vim-congiration-installer.git cd 
./vim-congiration-installer && ./install.sh

# game
# $ {\
# nethack,\
# unnethack,\
# dwarffortress,\
# dwarffortress-tile,\
# cataclysm-dda}

# polybar config
# git clone --depth=1 https://github.com/adi1090x/polybar-themes.git
#  find the file: ~/.config/polybar/launch.sh
# check battery module
# $ sudo vim /sys/class/power_supply
# check network module (en,wl)
# $ ifconfig
# must be config mpd

# rofi config
# mkdir -p ~/.config/rofi
# rofi -dump-config > ~/.config/rofi/config.rasi

# wallfle bitmap font and then
# https://addy-dclxvi.github.io/post/bitmap-fonts/

# gdb-dashboard
wget -P ~ https://git.io/.gdbinit && pip install pygments
