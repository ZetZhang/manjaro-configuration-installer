#!/usr/bin/env sh
# sudoer
export USER=`whoami`
`! sudo echo` && [ $USER != root ] && su - -c "sed -i \"/root ALL=(ALL) ALL/a\""$USER\"" ALL=(ALL) ALL\" /etc/sudoers && exit"

if [ ! -d ~/.hci ]; then
    echo -e "configure manjaro?(y|yes)"
    read -t 7 -u 0 choice
    if [[ "{y, yes}" =~ $choice ]]; then mkdir -p ~/.hci && touch ~/.hci/.c1
    else exit 0; fi
    
    echo -e "simple installtion(s|simple) or full installtion(f|full)"
    read -t 7 -u 0 way
    if [[ "{s, simple}" =~ $way ]]; then touch ~/.hci/.simple
    elif [[ "{f, full}" =~ $way ]]; then touch ~/.hci/.full
    else exit 0; fi
fi
jmpback=`pwd`

# source server init
declare exi=`grep '\[archlinuxcn\]' /etc/pacman.conf | wc -l`
if test $exi -eq 0; then
    cd $jmpback
    #sudo pacman-mirrors --fasttrack
    su - -c "echo -E \"[archlinuxcn]
SigLevel = Optional TrustedOnly
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch\" >> /etc/pacman.conf"
    sudo sed -i "s/^# \(Color\)/\1/" /etc/pacman.conf
    sudo pacman -Syy && sudo pacman -S archlinuxcn-keyring
fi

# install
ma='sudo pacman -S --noconfirm --needed'
ya='sudo pacman -S --noconfirm --needed'
$ma base-devel yay
$ya -Syu
$ma {curl,wget}

# install tmux
$ma {tmux,xclip}
if [ -f ~/.hci/.c1 ]; then
    # Tpm
    mkdir -p ~/.tmux/plugins
    cp ./tmux_conf ~/.tmux.conf
    cd ~/.tmux/plugins && git clone https://github.com/tmux-plugins/tpm
    mv ~/.hci/.c1 ~/.hci/.c2
fi
tmux new -d -s test && tmux source ~/.tmux.conf && tmux kill-session -t test
# you should enter session and execute command: `prefix r` & `prefix I`
# tmux Resurrect
# if you don't use Tpm, you should
#cd ~/.tmux/plugins && git clone https://github.com/tmux-plugins/tmux-resurrect.git
#tmux run-shell ~/.tmux/plugins/tmux-resurrect/resurrect.tmux

$ma zsh
if [ -f ~/.hci/.c2 ]; then
    cd $jmpback && mv ~/.hci/.c2 ~/.hci/.c3
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# install zsh && ohmyzsh
if [ -f ~/.hci/.c3 ]; then
    cd $jmpback
    $ma {fzf,autojump,the_silver_searcher,thefuck}
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
    echo "eval $(thefuck --alias)" >> ~/.zshrc
    source ~/.zshrc
    #sudo chsh -s /bin/zsh
    mv ~/.hci/.c3 ~/.hci/.c4
fi

# zsh-autosuggestions
[ -f ~/.hci/.c4 ] && git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && mv ~/.hci/.c4 ~/.hci/.c5
# zsh-syntax-highlighting
[ -f ~/.hci/.c5 ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && rm -rf ~//.hci/.c5

$ma rust
cd ~/.ephemeral_folder
git clone https://github.com/ZetZhang/vim-congiration-installer.git && source ./vim-congiration-installer/install.sh

# simple
if test -f ~/.hci/.simple ; then
    $ma {\
        jdk8-openjdk,\
        jdk10-openjdk,\
        jdk13-openjdk}
    archlinux-java status
    archlinux-java set java-8-jdk

    $ma {\
        bar,\
        gdb,\
        crash,\
        strace,\
        zeromq,\
        thefuck,\
        you-get,\
        cppcheck,\
        systemtap,\
        cppman-git,\ # cppman -c
        kcachegrind}
fi

# full
if test -f ~/.hci/.full ; then
    $ma {\
        code,\
        clion,\
        pycharm-professional,\
        vmware-workstation,\
        qtcreator}

    $ma {\
        lrzsz,\
        nutstore,\
        plantuml,\
        cairo-dock,\
        electronic-wechat,\
        shadowsocks-qt5,\
        wps-office,\
        ttf-wps-fonts,\
        netease-cloud-music,\
        typora,\
        timeshift,\
        nemiver,\
        google-chrome,\
        mpv}

    $ya {\
        debtap,\
        xmind}
fi

[ $? -eq 0 ] && rm -rf ~/.hci
