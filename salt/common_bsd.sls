/root/.profile:
    file.managed:
        - user: root
        - group: wheel
        - mode: 600
        - contents: |
            # cat .profile
            # $OpenBSD: dot.profile,v 1.9 2010/12/13 12:54:31 millert Exp $
            #
            # sh/ksh initialization
            
            PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/X11R6/bin:/usr/local/sbin:/usr/local/bin
            PATH=$PATH:/root/.virtualenvs/salt/bin
            export PATH
            : ${HOME='/root'}
            export HOME
            umask 022
            
            case "$-" in
            *i*)    # interactive shell
                    if [ -x /usr/bin/tset ]; then
                            if [ X"$XTERM_VERSION" = X"" ]; then
                                    eval `/usr/bin/tset -sQ '-munknown:?vt220' $TERM`
                            else
                                    eval `/usr/bin/tset -IsQ '-munknown:?vt220' $TERM`
                            fi
                    fi
                    ;;
            esac
            
            LSCOLORS=CxfxcxdxbxFxDxabagacad; export LSCOLORS
            EDITOR=vim VISUAL=vim HISTFILESIZE=65534; export EDITOR VISUAL
            
            if [ ! -z $BASH ]; then
                # std prompt
                _disp_exitcode() {
                    _res=$?
                    [ $_res -ne 0 ] && echo -n "[nzrc! ${_res} ]"
                }
                PS1='$(_disp_exitcode)(\h) C:$(pwd|tr \/ '\\\\\\')> '; export PS1
            fi
            
            # gen. utility
            alias ls='colorls -FG'
            alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"
            
            # git
            alias gco='git checkout'
            alias gcob='git checkout -b'
            
            alias gdom='git diff origin/master'
            alias gdum='git diff upstream/master'
            alias gmom='git merge --no-ff origin/master'
            alias gmum='git merge --no-ff upstream/master'
            
            alias gdod='git diff origin/develop'
            alias gdud='git diff upstream/develop'
            alias gmod='git merge --no-ff origin/develop'
            alias gmud='git merge --no-ff upstream/develop'
            
            alias gfap='git fetch --all --prune'
            alias gba='git branch -a'
            alias gbd='git branch -d'
            alias glg='git log --graph --decorate --pretty=oneline --abbrev-commit'
            
            # virtualenv
            alias vv='. `which virtualenvwrapper.sh`'
            alias mkv='mkvirtualenv'
            alias rmv='rmvirtualenv'
            alias wo='workon'
            alias da='deactivate'

            set -o vi


/root/.vimrc:
    file.managed:
        - user: root
        - group: wheel
        - mode: 600
        - source: salt://files/vimrc

/root/.vim:
    file.directory:
        - user: root
        - group: wheel
        - mode: 700

/root/.vim/_swap:
    file.directory:
        - user: root
        - group: wheel
        - mode: 700
        - require:
            - file: /root/.vim

/root/.vim/_backup:
    file.directory:
        - user: root
        - group: wheel
        - mode: 700
        - require:
            - file: /root/.vim

#common-packages:
#    pkg.installed:
#        pkgs:
#            - bash
#            - colorls
#            - dnsmasq
#            - git
#            - lynx
#            - nmap
#            - pv
#            - py
#            - py
#            - swig
#            - vim
#            - vpnc
