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
            alias ls='colorls -FG'

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
