# vim-MagicKey

A plugin for Vim for performing various common (at least to me) editing
actions **with a single key**. The appropiate type of action to perform
after pressing the MagicKey depends on line context and filetype.

Magic actions:

- Bump copyright headers
- Create beautiful fold sections
- Create horizontal rulers
- Expand Markdown headers to reStructuredText (ft=rst *only*)
- Run a command from buffer text
- Quickly substitute text in all buffers

## Installing

Use your plugin manager of choice.

- [Pathogen](https://github.com/tpope/vim-pathogen)
  - `git clone https://github.com/babab/vim-MagicKey ~/.vim/bundle/vim-MagicKey`
- [Vundle](https://github.com/gmarik/vundle)
  - Add `Bundle 'https://github.com/babab/vim-MagicKey'` to .vimrc
  - Run `:BundleInstall`
- [NeoBundle](https://github.com/Shougo/neobundle.vim)
  - Add `NeoBundle 'https://github.com/babab/vim-MagicKey'` to .vimrc
  - Run `:NeoBundleInstall`
- [vim-plug](https://github.com/junegunn/vim-plug)
  - Add `Plug 'https://github.com/babab/vim-MagicKey'` to .vimrc
  - Run `:PlugInstall`

## What it does

Whenever the `MagicKey()` function is called by pressing `<Return>`
in normal mode (by default) it will scan the context around your
cursor and decide which action to perform, taking the type of file in
consideration.

When multiple actions are applicable, MagicKey presents an options menu
so you can choose the appropiate action.

## Global actions

These are actions that are always available. No matter what the current
filetype is.

### Bumping Copyright headers

When the word `Copyright` is found it will bump the copyright by looking
for the value of `strftime("%Y") - 1` in the context.

    Before: # Copyright (c) 2017 Author Name <user@example.com>
    After : # Copyright (c) 2017-2018 Author Name <user@example.com>

    Before: # Copyright (c) 2009-2017 Author Name <user@example.com>
    After : # Copyright (c) 2009-2018 Author Name <user@example.com>

It will not bump the copyright when the time overlaps more then a year.

    Before: # Copyright (c) 2016 Author Name <user@example.com>
    After : # Copyright (c) 2016 Author Name <user@example.com>

    Before: # Copyright (c) 2012 Author Name <user@example.com>
    After : # Copyright (c) 2012 Author Name <user@example.com>

This feature is also available through this command and function:

- Command: `BumpCopyright`
- Function: `MkBumpCopyright()`

### Horizontal Ruler

You can expand a stream of chars to a horizontal ruler by using MagicKey
on any line that contains a stream of >= 5 *rulerchars*.

    Before: -------
    After : ------------------------------------------------------------------------------

The type of chars can be altered and are defined as:

    let g:magickey_rulerchars = ['*', '=', '-', '.', '"', "'", '#', ':', '\^', '~']

The ruler char will be copied to each column in the line up to a max
width of `g:magickey_maxlinelength` columns. The default value is `78`.

This feature is also available through this command and function:

- Command: `HorizontalRuler`
- Function: `MkHorizontalRuler(...)`

The HorizontalRuler command and calling `MkHorizontalRuler` without
arguments work the same as using it via the MagicKey. It will use the
char found in the first column to expand the line.

The `MkHorizontalRuler` also accepts an optional argument which should
be a single char, which is then used to expand.

### Execute current line text as command

When the current line starts with `# mkrun: `, the remaining text will
be executed as an Ex command. Because Ex commands always start with `:`,
this is added implicitly and any leading `:` characters added by the
user will be stripped.

Example:

    # mkrun: !python %

### Replace in all buffers (alias for ":bufdo %s/{content}/gce | update"

When the current line starts with `# mkreplace: `, the remaining text will be
pasted into a command that substitutes over all open buffers.

Example:

    # mkreplace: croccet/correct

The above line will result in the command:

    :bufdo %s/croccet/correct/gce | update

## License

Copyright (c) 2014-2018  Benjamin Althues <benjamin@babab.nl>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
