" Autocommands
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

autocmd TermOpen term://* startinsert

" auto spell for Markdown
autocmd BufRead,BufNewFile *.md setlocal spell

" Auto change directory to current dir (local to buffer)
autocmd BufEnter * silent! lcd %:p:h

" Autoformat on save for JS
" au BufWrite *.js :Autoformat " This should go into after/plugin/autoformat.vim or similar if more specific needed

" Typescript specific (if not part of a plugin's own autocmds)
autocmd BufRead,BufNewFile tsconfig.json set filetype=jsonc
