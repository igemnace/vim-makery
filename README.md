# makery.vim

Do you know about Vim's own `:make` system? It's great! You can set `makeprg` to
any executable program, so you can use `:make` not just to run `make` with a
`Makefile`, but also to run linters, build scripts, task runners, etc.

Vim will then catch the results of `:make` into a quickfix list, so you can jump
to any errors, down to the correct filename, line, and column!

This plugin is designed to be a companion to `:make`.

## Introduction

I made this plugin because I was tired of having to change my `makeprg` or
`compiler` every time I wanted to run a different task. Switching between
`:compiler eslint` and `:compiler jest` gets old really fast.

Sure, you can map, but it gets harder when you start to work across different
projects: some use different linters or test runners, some use a Makefile, some
use an `npm` script, some need to generate tags, etc. Madness!

With this plugin, all I have to do is specify my make-related tasks in a
`.makery.json` file in my project root. For example, one of my React Native
projects has the following `.makery.json`:

```json
{
  "lint": {"compiler": "eslint"},
  "reload": {"makeprg": "adb shell input keyevent 82"},
  "tags": {"makeprg": "es-ctags -R src"},
  "test": {"compiler": "jest"}
}
```

Now I can just run `:Mlint` to lint, `:Mreload` to reload the JS code on my
connected Android device, `:Mtags` to generate tags, and `:Mtest` to run tests.
Nifty!

The best part is I can specify different behavior for `:Mlint` or `:Mtest`
depending on which project I'm in, by providing the necessary `.makery.json` for
each of my projects!

Even programs like ctags or adb fit well because of this, even though you don't
necessarily need the quickfix for them. Instead of fiddling with different `:!`
incantations for different projects, you can just use `:Mtags` and be done with
it!

## Installation

Copy the contents of `plugin`, `autoload`, `doc` to `~/.vim` on UNIX-like
systems, or install with your favorite plugin manager.

## Setup

Makery.vim allows you to specify different configurations of `makeprg`,
`errorformat`, and `compiler` for different projects by indicating them in a
dict in your vimrc, like so:

```vim
let g:makery_config = {
\   "~/src/my-c-project": {
\     "lint": {"compiler": "clang-format"},
\     "tags": {"makeprg": "ctags -R src"},
\     "build": {"compiler": "gcc"}
\   },
\   "~/src/my-js-project": {
\     "lint": {"compiler": "eslint"},
\     "tags": {"makeprg": "es-ctags -R src"},
\     "build": {"makeprg": "yarn"},
\     "test": {"compiler": "jest"}
\   }
\ }
```

As always in Vim, the docs are the authoritative source. Read `:help makery` for
a more detailed description.

You can also specify each project's configuration within its own `.makery.json`
file, like so:

```json
{
  "lint": {"compiler": "eslint"},
  "reload": {"makeprg": "adb shell input keyevent 82"},
  "tags": {"makeprg": "es-ctags -R src"}
}
```

Note that JSON support requires Vim 8 or higher (since these versions offer JSON
support out of the box). Read `:help makery-json` for a bit more detail.

## Usage

After setting up your Makery commands (either through `g:makery_config` or a
`.makery.json` file), you can simply call the commands through the `:M` prefix,
e.g. `:Mlint` or `:Mcompile`.

Read `:help makery-usage` for a bit more detail.

In case you already have an existing command with the same name, you can still
access the commands through the full `:Makery` form, e.g. `:Makery lint` or
`:Makery compile`.

Read `:help makery-overwrite-existing` and `:help makery-:Makery` for a bit more
detail.

## Other Usage

### Async Support

Makery.vim works well with any plugins that provide an async `:make`
implementation, such as tpope's dispatch.vim.

It does this by trying to use a `:Make` command if one exists. Read
`:makery-async` for an example, or look up your favorite async plugin's
documentation to learn how to provide such a command.

### Key Mappings

If there are commands that you use frequently across multiple projects, you
could always just map a key to trigger those commands. For example,

```vim
nnoremap <f3> :Mlint %<CR>
nnoremap <f4> :Mtags<CR>
nnoremap <f5> :Mbuild<CR>
```

## Acknowledgement

This plugin takes a lot of inspiration from tpope's projectionist.vim.

Some functions for JSON-reading logic come from projectionist, as well as the
idea of exposing commands with a `:M` prefix (projectionist uses a similar `:E`
prefix).

## Licensing

This project is free and open source software, licensed under the Vim license.
You are free to use, modify, and redistribute this software.

Take a look at `:h license` for more info.
