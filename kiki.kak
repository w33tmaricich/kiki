# Kiki
#   Alexander Maricich 2019

declare-user-mode kiki

##
# Options
# -------

declare-option str kiki_prefix "kiki "
declare-option str kiki_scratch "~/.config/kak/kiki/scratchpad.kiki"
declare-option str kiki_topics "~/.config/kak/kiki/"

##
# Commands
# --------

# Pipe to fifo.
define-command -params .. \
    -docstring "kiki-fifo [<arguments>]: execute bash command to fifo
Executes a bash command and prints the output in a new fifo buffer" \
    kiki-fifo %{ evaluate-commands %sh{
        output=$(mktemp -d "${TMPDIR:-/tmp}"/kak-make.XXXXXXXX)/fifo
        mkfifo ${output}
        ( eval "$@" > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
        printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' %{
            edit! -fifo ${output} -scroll *kiki-fifo*
            set-option buffer filetype bash
            hook -always -once buffer BufCloseFifo .* %{ nop %sh{ rm -r $(dirname ${output}) } }
        }"
}}

# Background execution.
define-command -params .. \
    -docstring "kiki-background [<arguments>]: execute bash command in the background" \
    kiki-background %{ evaluate-commands %sh{
        ( eval "$@" > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null
}}

# Selection after prefix.
define-command -docstring "kiki-select: select all text after kiki" \
    kiki-select %{
        execute-keys "<esc>xs%opt{kiki_prefix}.+<ret>"
        execute-keys "s(?<=%opt{kiki_prefix}).+"
        execute-keys '<ret>H'
}

# Select URI.
define-command -docstring "kiki-uri-select: select a uri on the current line" \
    kiki-uri-select %{
        execute-keys "<esc>xs(~/|\./|/)[^\s]+\b<ret>"
}

# Open topic file.
define-command -docstring "kiki-topic: open a topic file with the given name" \
    kiki-topic %{
        execute-keys ":kiki-select<ret>:e %opt{kiki_topics}<c-r>..kiki<ret>"
}

##
# Shortcuts
# ---------

# Prefix shortcuts.
map global kiki c "<esc>o%opt{kiki_prefix}<esc>:comment-line<ret><esc>k<a-j>A" -docstring 'Create a new command on the current line.'
map global kiki C "<esc>I%opt{kiki_prefix}<esc>" -docstring 'Prefix the current line with kiki_prefix'

# Command execution and manipulation.
map global kiki y ':kiki-select<ret>y' -docstring 'Select and yank after tab.'
map global kiki i ':kiki-select<ret>yo<esc>!<c-r>"<ret>' -docstring 'Execute and return inline.'
map global kiki s ':kiki-select<ret>y<esc>:e -scratch *kiki-scratch*<ret>!<c-r>"<ret>xH!<c-r>.<ret>' -docstring 'Execute and return in scratch buffer.'
map global kiki f ':kiki-select<ret>yA<esc>:kiki-fifo <c-r>"<ret>' -docstring 'Execute and pipe output to fifo.'
map global kiki b ':kiki-select<ret>yA<esc>:kiki-background <c-r>"<ret>' -docstring 'Execute in the background.'

# File system navigation.
map global kiki Y ':kiki-uri-select<ret>y' -docstring 'Select and yank URI.'
map global kiki l ':kiki-uri-select<ret>yA<ret><esc>!ls -alh <c-r>"<ret>' -docstring 'ls -al: current path.'
map global kiki e ':kiki-uri-select<ret>yA<ret><esc>:e <c-r>"<ret>' -docstring ':e on the current path.'

# Topics.
map global kiki t ':kiki-topic<ret>' -docstring ':e topic file with name.'

# Scratchpad.
map global kiki , ":e %opt{kiki_scratch}<ret>" -docstring 'Open scratchpad.'

##
# Highlighters
# ------------

add-highlighter global/ regex ^>[^\n]+ 0:green
add-highlighter global/ regex "%opt{kiki_prefix}" 0:default+rb
add-highlighter global/ regex \(?<=kiki )[^\n]+ 0:cyan
# add-highlighter global/ regex ^[\ ]+-[^\n]+ 0:red

