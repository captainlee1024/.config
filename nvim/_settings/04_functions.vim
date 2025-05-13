" ===
" === For Coc
" ===
" use <tab> to trigger completion and navigate to the next complete item
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

"function! s:check_back_space() abort
"	let col = col('.') - 1
"	return !col || getline('.')[col - 1]  =~# '\s'
"endfunction


" Use K to show documentation in preview window
"nnoremap <LEADER>k :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

"function! Show_documentation()
"	"call CocActionAsync('highlight')
"	"if (index(['vim','help'], &filetype) >= 0)
"		"execute 'h '.expand('<cword>')
"	"else
"		call CocAction('doHover')
"	endif
"endfunction
"nnoremap <LEADER>k :call Show_documentation()<CR>
"

" ===
" === For FZF BD command
" ===

function! s:list_buffers()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction

function! s:delete_buffers(lines)
  execute 'bwipeout' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction


" ===
" === For vimspector
" ===
function! s:read_template_into_buffer(template)
	" has to be a function to avoid the extra space fzf#run insers otherwise
	execute '0r ~/.config/nvim/sample_vimspector_json/'.a:template
endfunction

