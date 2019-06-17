# Kiki
#   Alexander Maricich 2019

declare-user-mode kiki

##
# Variables
# ---------

declare-option str kiki_prefix "kiki "
declare-option str kiki_scratch "~/.config/kak/kiki/scratchpad.kiki"

# Run a bash command in the background and pipe the output to a fifo.
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

# 
define-command -docstring "kiki-select: select all text after kiki" \
    kiki-select %{
        execute-keys "<esc>xs%opt{kiki_prefix}.+<ret>"
        execute-keys "s(?<=%opt{kiki_prefix}).+"
        execute-keys '<ret>H'
}

define-command -docstring "kiki-uri-select: select a uri on the current line" \
    kiki-uri-select %{
        execute-keys "<esc>xs(~/|\./|/)[^\s]+\b<ret>"
    }

# Done
map global kiki c "<esc>o%opt{kiki_prefix}<esc>:comment-line<ret><esc>k<a-j>A" -docstring 'Create a new command on the current line.'
map global kiki p "<esc>I%opt{kiki_prefix}<esc>" -docstring 'Prefix the current line with kiki_prefix'

map global kiki y ':kiki-select<ret>y' -docstring 'Select and yank after tab.'
map global kiki i ':kiki-select<ret>yo<esc>!<c-r>"<ret>' -docstring 'Execute and return inline.'
map global kiki s ':kiki-select<ret>yA<esc>:e -scratch *kiki-scratch*<ret>!<c-r>"<ret>xH!<c-r>.<ret>' -docstring 'Execute and return in scratch buffer.'
map global kiki f ':kiki-select<ret>yA<esc>:kiki-fifo <c-r>"<ret>' -docstring 'Execute and pipe output to fifo.'

map global kiki Y ':kiki-uri-select<ret>y' -docstring 'Select and yank URI.'
map global kiki l ':kiki-uri-select<ret>yA<ret><esc>!ls -alh <c-r>"<ret>' -docstring 'Lists the contents of a directory.'
map global kiki e ':kiki-uri-select<ret>yA<ret><esc>:e <c-r>"<ret>' -docstring 'Lists the contents of a directory.'

map global kiki , ":e %opt{kiki_scratch}<ret>" -docstring 'Open scratchpad.'

# In progress:

add-highlighter global/ regex ^>[^\n]+ 0:green
add-highlighter global/ regex kiki 0:yellow+rb
add-highlighter global/ regex \(?<=kiki )[^\n]+ 0:cyan
# add-highlighter global/ regex ^[\ ]+-[^\n]+ 0:red
