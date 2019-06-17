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
        execute-keys "<esc>xs(\./|/)[^\s]+\b<ret>"
    }

# Done
map global kiki c "<esc>o%opt{kiki_prefix}<esc>:comment-line<ret><esc>k<a-j>A" -docstring 'Create a new command on the current line.'
map global kiki p "<esc>I%opt{kiki_prefix}<esc>" -docstring 'Prefix the current line with kiki_prefix'
map global kiki y ':kiki-select<ret>y' -docstring 'Select and yank after tab.'
map global kiki Y ':kiki-uri-select<ret>y' -docstring 'Select and yank URI.'
map global kiki i ':kiki-select<ret>yo<esc>!<c-r>"<ret>' -docstring 'Execute and return inline.'
map global kiki s ':kiki-select<ret>yA<esc>:e -scratch *kiki-scratch*<ret>!<c-r>"<ret>xH!<c-r>.<ret>' -docstring 'Execute and return in scratch buffer.'
map global kiki f ':kiki-select<ret>yA<esc>:kiki-fifo <c-r>"<ret>' -docstring 'Execute and pipe output to fifo.'
map global kiki , ":e %opt{kiki_scratch}<ret>" -docstring 'Open scratchpad.'

# In progress:
map global kiki l ':kiki-uri-select<ret>yA<ret><esc>!ls -alh <c-r>"<ret>' -docstring 'Lists the contents of a directory.'

add-highlighter global/ regex ^>[^\n]+ 0:green
add-highlighter global/ regex \bkiki\b 0:yellow+rb
add-highlighter global/ regex \b(?<=kiki)[^\n]+ 0:cyan

##
# .kiki files
# -----------

# TODO:
#   1. Implement usage of kiki_prefix.
#   2. Implement syntax hilighting for kiki files.

 # kiki cat ~/.local/share/kak/rc/base/lisp.kak
 # # http://github.com/w33tmaricich/kiki
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# # Detection
# # ‾‾‾‾‾‾‾‾‾

# hook global BufCreate .*[.](kiki) %{
#     set-option buffer filetype kiki
# }

# # Highlighters
# # ‾‾‾‾‾‾‾‾‾‾‾‾

# add-highlighter shared/kiki regions
# add-highlighter shared/kiki/code default-region group
# add-highlighter shared/kiki/string  region '"' (?<!\\)(\\\\)*" fill string
# add-highlighter shared/kiki/comment region ';' '$'             fill comment

# add-highlighter shared/kiki/code/ regex \b(nil|true|false)\b 0:value
# add-highlighter shared/kiki/code/ regex (((\Q***\E)|(///)|(\Q+++\E)){1,3})|(1[+-])|(<|>|<=|=|>=) 0:operator
# add-highlighter shared/kiki/code/ regex \b(def[a-z]+|if|do|let|lambda|catch|and|assert|while|def|do|fn|finally|let|loop|new|quote|recur|set!|throw|try|var|case|if-let|if-not|when|when-first|when-let|when-not|(cond(->|->>)?))\b 0:keyword
# add-highlighter shared/kiki/code/ regex (#?(['`:]|,@?))?\b[a-zA-Z][\w!$%&*+./:<=>?@^_~-]* 0:variable
# add-highlighter shared/kiki/code/ regex \*[a-zA-Z][\w!$%&*+./:<=>?@^_~-]*\* 0:variable
# add-highlighter shared/kiki/code/ regex (\b\d+)?\.\d+([eEsSfFdDlL]\d+)?\b 0:value

# # Commands
# # ‾‾‾‾‾‾‾‾

# define-command -hidden kiki-trim-indent %{
#     # remove trailing white spaces
#     try %{ execute-keys -draft -itersel <a-x> s \h+$ <ret> d }
# }

# declare-option \
#     -docstring 'regex matching the head of forms which have options *and* indented bodies' \
#     regex kiki_special_indent_forms \
#     '(?:def.*|if(-.*|)|let.*|lambda|with-.*|when(-.*|))'

# define-command -hidden kiki-indent-on-new-line %{
#     # registers: i = best align point so far; w = start of first word of form
#     evaluate-commands -draft -save-regs '/"|^@iw' -itersel %{
#         execute-keys -draft 'gk"iZ'
#         try %{
#             execute-keys -draft '[bl"i<a-Z><gt>"wZ'

#             try %{ execute-keys -draft '"wz<a-l>s.\K.*<ret><a-;>;"i<a-Z><gt>' }

#             # If not "special" form and parameter appears on line 1, indent to parameter
#             execute-keys -draft '"wze<a-K>\A' %opt{kiki_special_indent_forms} '\z<ret>' '<a-l>s\h\K[^\s].*<ret><a-;>;"i<a-Z><gt>'
#         }
#         try %{ execute-keys -draft '[rl"i<a-Z><gt>' }
#         try %{ execute-keys -draft '[Bl"i<a-Z><gt>' }
#         execute-keys -draft ';"i<a-z>a&<space>'
#     }
# }

# # Initialization
# # ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# hook -group kiki-highlight global WinSetOption filetype=kiki %{
#     add-highlighter window/kiki ref kiki
#     hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/kiki }
# }

# hook global WinSetOption filetype=kiki %{
#     hook window ModeChange insert:.* -group kiki-trim-indent  kiki-trim-indent
#     hook window InsertChar \n -group kiki-indent kiki-indent-on-new-line

#     hook -once -always window WinSetOption filetype=.* %{ remove-hooks window kiki-.+ }
# }

