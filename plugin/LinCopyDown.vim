"Author: linlin
"Datetime: 2025-05-03 02:01
"-------------------------------------------------------------------------------
if exists("g:loaded_lin_copy_down")
    finish
endif

let g:loaded_lin_copy_down = 1

"# 映射快捷键 
""" hasmapto 防止重复映射
"- lin#CreateImplement
"if !hasmapto('<Plug>LinCopyDown')
    "inoremap <silent> <c-j> <Esc><Plug>LinCopyDown
"endif

inoremap <silent> <c-j> <Esc>:call LinCopyDown#CopyDown()<CR>

"map <Plug>LinCopyDown <SID>SIDLinCopyDown 
"map <SID>SIDLinCopyDown :call LinCopyDown#CopyDown()<CR>

if !exists(":LinCopyDown")
    command! -nargs=0 LinCopyDown call LinCopyDown#CopyDown()
endif

"Switch Variable: 1 启用自动检测；0 手动指定；
"TODO:

"Variable: 手动设置包围类型
"TODO:

"Function: 查看手动设置的包围类型
"TODO:

"Dictionaries: 包围映射（标记类型）
"
let g:Lin_SurroundTypeMapping = {
            \")": "(",
            \"}": "{",
            \"]": "[",
            \">": "<",
            \"`": "`",
            \"'": "'",
            \"\"": "\""
            \ }

"Variable: 测试缓冲
"if !exists("g:Lin_TestResultBuffer")
    "let g:Lin_TestResultBuffer = bufnr("Lin Surround Test Result Buffer", 1)
    "execute "vnew |" . string(g:Lin_TestResultBuffer) . "buffer"
"endif
