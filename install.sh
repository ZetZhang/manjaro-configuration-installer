#!/usr/bin/env sh
# sudoer
export USER=`whoami`
`! sudo echo` && [ $USER != root ] && su - -c "sed -i \"/root ALL=(ALL) ALL/a\""$USER\"" ALL=(ALL) ALL\" /etc/sudoers && exit"

if [ ! -d ~/.hci ]; then
    echo -e "configure manjaro?(y|yes)"
    read -t 7 -u 0 choice
    if [[ "{y, yes}" =~ $choice ]]; then mkdir -p ~/.hci && touch ~/.hci/.{c1,c2,c3,c4} && echo "mkdir"
    else exit 0
    fi
fi
mkdir ~/ephemeral_folder

# source server init
declare exi=`grep '[archlinuxcn]' /etc/pacman.con | wc -l`
if [ exi == 0 ]; then
    trap "wait..." SIGINT
    cd ~/.ephemeral_folder
    sudo pacman-mirrors --fasttrack
    sudo echo "[archlinuxcn]
    SigLevel = Optional TrustedOnly
    Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch" >> sudo /etc/pacman.conf
    sudo sed -i "s/^# \(Color\)/\1/" /etc/pacman.conf
    sudo pacman -Syy
    trap -- SIGINT
fi

# install
ma='sudo pacman -S --confirm --needed'
ya='sudo pacman -S --confirm --needed'
$ma base-devel yay
$ya -Syu
$ma curl
$ma wget
$ma google-chrome

# install tmux
$ma tmux
$ma xclip
if [ -f ~/.hci/.h1 ]; then
    trap "wait..." SIGINT
    # Tpm
    mkdir -p ~/.tmux/plugins && cd ~/.tmux/plugins && git clone https://github.com/tmux-plugins/tpm
    cp ./tmux_conf ~/.tmux.conf
    rm -rf ~/.hci/h1
    trap -- SIGINT
fi
tmux new -d -s test && tmux source ~/.tmux.conf && tmux kill-session -t test
# you should enter session and execute command: `prefix r` & `prefix I`
# tmux Resurrect
# if you don't use Tpm, you should
#cd ~/.tmux/plugins && git clone https://github.com/tmux-plugins/tmux-resurrect.git
#tmux run-shell ~/.tmux/plugins/tmux-resurrect/resurrect.tmux

# install zsh && ohmyzsh
if [ -f ~/.hci/.h2 ]; then
    cd ~/.ephemeral_folder
    $ma zsh
    chsh -s /bin/zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    $ma fzf
    $ma autojump
    $ma the_silver_searcher
    rm -rf ~/.hci/.h2
fi

# zsh-autosuggestions
if [ -f ~/.hci/.h3 ]; then
    cd ~/.ephemeral_folder
    git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    rm -rf ~/.hci/.h3
fi

# zsh-syntax-highlighting
if [ -f ~/.hci/.h4 ]; then
    cd ~/.ephemeral_folder
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    rm -rf ~/.hci/.h4
fi 

trap "wait.." SIGINT
{
    flock -w 10 123
    sed -i "/^plugins=(/a\ \tgit\n\tzsh-syntax-highlighting\n\tautojump\n\tfzf\n\tzsh-autosuggestions\n\tweb-search\n\textract\n)" ~/.zshrc
    sed -i "s/\(^plugins=(\)git)/\1/" ~/.zshrc
    sed -i "s/^# \(export LANG\)/\1/" ~/.zshrc
    echo -E "export FZF_DEFAULT_OPTS='--height 80%'" >> ~/.zshrc
    echo -E "export FZF_CTRL_T_OPTS=\"--preview '(highlight -O ansi -l {} 2> /dev/null || bat --style=numbers --color=always {} || tree -C {}) 2> /dev/null | head -500'\"" >> ~/.zshrc
    echo -E "#--preview '[[ $(file --mime {}) =~ binary ]] &&
        #echo {} is a binary file ||
            #(bat --style=numbers --color=always {} ||
            #highlight -O ansi -l {} ||
            #coderay {} ||
            #rougify {} ||
            #cat {}) 2> /dev/null | head -500'" >> ~/.zshrc
            echo -E "# fzf
            export FZF_DEFAULT_COMMAND='rg --files --hidden'" >> ~/.zshrc

            source ~/.zshrc
} 123<>.lock
trap SIGINT

$ma rust
cd ~/.ephemeral_folder
git clone https://github.com/ZetZhang/vim-congiration-installer.git && cd vim-congiration-installer && ./install.sh

$ma jdk8-openjdk
$ma jdk10-openjdk
$ma jdk13-openjdk
archlinux-java status
archlinux-java set java-8-jdk

$ma code
$ma clion
$ma pycharm-professional
$ma vmware-workstation
$ma qtcreator


$ma bat
$ma gdb
$ma crash
$ma strace
$ma zeromq
$ma thefuck
$ma you-get
$ma cppcheck
$ma systemtap
$ma cppman-git
# cppman -c
$ma kcachegrind

$ma lrzsz
$ma nutstore
$ma plantuml
$ma cairo-dock
$ma electronic-wechat
$ma shadowsocks-qt5
$ma wps-office ttf-wps-fonts
$ma netease-cloud-music
$ma typora
#$ma timeshift
$ma nemiver
$ma mpv
#echo "eval $(thefuck --alias)" >> ~/.zshrc
$ya -S debtap
$ya -S xmind
