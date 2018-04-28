# Vim MagicKey plugin - Perform various actions depending on line content
#
# Copyright (c) 2014 Benjamin Althues <benjamin@babab.nl>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


def MkRunCommand(vim):
    command = vim.current.line.split('run:')[1].lstrip().lstrip(':')
    vim.command(command)


def MkReplaceInAllBuffers(vim):
    string = vim.current.line.split('replace:')[1].lstrip()
    if string.count('/') > 1:
        print('Please specify a single "/" as separator, >1 is not supported')
        return
    command = 'bufdo %s/{}/gce | update'.format(string)
    vim.command(command)
