# ssh-agent: function to start it automagically if not started.
SSH_ENV="$HOME/.ssh/environment"
function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}
# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi


# ssh_tmux function: launch tmux right-away after connecting.
function ssh_tmux() { ssh -t "$1" tmux a || ssh -t "$1" tmux; }

# ssh function wrapper so that my Tmux window name is set to the username@hostname.
ssh() {
    if [ -n "$TMUX" ]; then
        tmux rename-window "$(echo $* | cut -d @ -f 2)"
        command ssh "$@"
        tmux set-window-option automatic-rename "on" 1>/dev/null
    else
        command ssh "$@"
    fi
}
