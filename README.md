# kiki

An ode to xiki shell.

## Installation

```
$ ln -s /home/user/path/to/kiki.kak /home/user/.local/share/kak/rc/extra
```

To use kiki, simply type:
```
:enter-user-mode kiki
```

or, for more practical usage, bind it to a shortcut in your own personal
usermode.

```
map global yourusermode k ':enter-user-mode<space>kiki<ret>' -docstring 'Kiki.'
```

## Capabilities
This is very rough documentation right now. Once 0.1.0 is done, i will write
up more comprehensive documentation.

1. Execute the current line and print inline.
2. Execute the current line and print in scratch buffer.
3. Execute the current line and print in fifo buffer.
4. `ls -alh` for the first path on the current line
5. Create new kiki command on the currentn line.
6. Add `kiki_prefix` to the beginning of the current line.
7. Configurable scratchpad for notes and ideas.
8. Simple syntax hilighting for kiki
9. Edit files using uri on current line

## TODO

