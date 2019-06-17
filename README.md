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
4. Print the contents of a given directory.
5. Add kiki comments.
6. Add kiki prefix.

## TODO

1. Implement usage of kiki_prefix.
2. Implement syntax hilighting for kiki files.
3. have ls work on a path found anywhere on a line.
