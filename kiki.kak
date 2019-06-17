# Kiki
#   Alexander Maricich 2019

declare-user-mode kiki

#  xsxiki.+$<ret>s(?<=xiki ).+$<ret>yA<esc>

##
# Variables
# ---------
declare-option str kiki_prefix "kiki "

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
        execute-keys "<esc>xskiki .+<ret>"
        execute-keys "s(?<=kiki ).+"
        execute-keys '<ret>H'
}

# Done
map global kiki c '<esc>okiki <esc>:comment-line<ret><esc>k<a-j>A' -docstring 'Create a new command on the current line.'
map global kiki p '<esc>Ikiki <esc>' -docstring 'Prefix the current line with kiki_prefix'
map global kiki y ':kiki-select<ret>y' -docstring 'Select and yank after tab.'
map global kiki i ':kiki-select<ret>yo<esc>!<c-r>"<ret>' -docstring 'Execute and return inline.'
map global kiki s ':kiki-select<ret>yA<esc>:e -scratch *kiki-scratch*<ret>!<c-r>"<ret>xH!<c-r>.<ret>' -docstring 'Execute and return in scratch buffer.'
map global kiki f ':kiki-select<ret>yA<esc>:kiki-fifo <c-r>"<ret>' -docstring 'Execute and pipe output to fifo.'

# In progress:
map global kiki l ':kiki-select<ret>yA<ret><esc>!ls -alh <c-r>"<ret>' -docstring 'Lists the contents of a directory.'
# TODO:
#   1. Implement usage of kiki_prefix.
#   2. Implement syntax hilighting for kiki files.
