"Author: linlin
"Datetime: 2025-05-03 02:01
"-------------------------------------------------------------------------------

"Variable: 测试缓冲
"if !exists("g:Lin_TestResultBuffer")
    "let g:Lin_TestResultBuffer = bufnr("Lin Surround Test Result Buffer", 1)
    "execute "vnew |" . string(g:Lin_TestResultBuffer) . "buffer"
"endif

"Function: 获取右索引
"
"获取右包围标记索引
"
"[in] text line
"[out] list 第一个条目，右标记索引；第二个条目，右标记类型；
function! s:obtainRightIndex(line)
    let l:curline = a:line
    let l:right_surr = ""
    let l:right_idx = -1
    let l:len = len(l:curline)

    for i in range(0, l:len)
        let l:idx = l:len - i - 1 " 从尾部开始遍历
        let l:curchar = l:curline[l:idx]

        if l:curchar == ')'
            let l:right_surr = ")"
            let l:right_idx = l:idx
        elseif l:curchar == ']'
            let l:right_surr = "]"
            let l:right_idx = l:idx
        elseif l:curchar == '>'
            let l:right_surr = ">"
            let l:right_idx = l:idx
        elseif l:curchar == '}'
            let l:right_surr = "}"
            let l:right_idx = l:idx
        elseif l:curchar == "'"
            let l:right_surr = "'"
            let l:right_idx = l:idx
        elseif l:curchar == "\""
            let l:right_surr = "\""
            let l:right_idx = l:idx
        elseif l:curchar == "`"
            let l:right_surr = "`"
            let l:right_idx = l:idx
        endif
        if l:right_surr != ""
            "break
            "若是包围标记相同者，则不进一步扫瞄
            if l:right_surr == "\"" || l:right_surr == "'" || l:right_surr == "`"
                break
            endif
        endif
    endfor
    return [l:right_idx, l:right_surr]
endfunction

"Function: 获取左索引
"
"[in] text line 文本行
"[in] list [右索引，右标记]
"[out] 左标记索引
function! s:obtainLeftIndex(line, right_items)
    let l:curline   = a:line
    let l:right_idx = a:right_items[0]
    let l:left_surr = g:Lin_SurroundTypeMapping[a:right_items[1]]
    let l:left_idx  = -1
    let l:left_len  = l:right_idx
    for i in range(0, l:left_len)
        let l:idx = l:left_len - i - 1
        let l:curchar = l:curline[l:idx]
        if l:curchar == l:left_surr
            let l:left_idx = l:idx
            break
        endif
    endfor
    return l:left_idx
endfunction

"Function: 处理空格标记
"
"[in] text line 文本行
"[out] list [左边界索引（空格索引），右边界索引]
function! s:processSpaceMark(line)
    let l:curline     = a:line
    let l:right_space = -1
    let l:right_idx   = -1
    let l:len         = len(l:curline)
    " 若不存在包围类型
    for i in range(0, l:len)
        let l:idx = l:len - i - 1 " 从尾部开始遍历
        let l:curchar = l:curline[l:idx]
        if l:curchar == " "
            let l:right_space = l:idx
            break
        endif
        if match(l:curchar, "\\W") >= 0
            let l:right_idx = l:idx
        endif
    endfor
    return [l:right_space, l:right_idx]
endfunction

"Function: 清除包围中的内容
"
"[in] text line 文本行
"[in] 左边界索引
"[in] 右边界索引
"[out] 字符串，清除包围内容后的文本
function! s:getClearedSurroundLine(line, left_idx, right_idx)
    if a:right_idx < 0
        return a:line[0:a:left_idx] . " "
    endif
    return a:line[0:a:left_idx] . a:line[a:right_idx:]
endfunction

"Function: 执行复制向下的操作
"
"[in] 文本行
"[in] 左边界索引
"[in] 右边界索引
function! s:exeCopyDown(line, left_idx, right_idx)
    let l:newline = s:getClearedSurroundLine(a:line, a:left_idx, a:right_idx)
    let l:pos = getcurpos(".")
    call append(l:pos[1], [l:newline])
    call cursor(l:pos[1]+1, a:left_idx+1)
    call feedkeys('a')
endfunction

"Function: 复制向下
"
"复制向下接口
function! LinCopyDown#CopyDown()
    let l:curline = trim(getline("."), " ", 2)
    if len(l:curline) == 0
        return
    endif
    let l:has_mark    = 1
    let l:pos         = getcurpos(".")
    let l:right_items = s:obtainRightIndex(l:curline)
    let l:right_idx   = l:right_items[0]
    "call appendbufline(g:Lin_TestResultBuffer, "$", ["", "Invoke s:obtainRightIndex(), Right idx = " . string( l:right_idx )])
    let l:left_idx    = -1
    if l:right_idx < 0
        let l:space_idx = s:processSpaceMark(l:curline)
        if l:space_idx[0] < 0
            let l:has_mark = 0
        endif
        let l:left_idx = l:space_idx[0]
        let l:right_idx = l:space_idx[1]
        "call appendbufline(g:Lin_TestResultBuffer, "$", ["", "Invoke s:processSpaceMark(), Right idx = " . string( l:right_idx )])
    else
        let l:left_idx = s:obtainLeftIndex(l:curline, l:right_items)
        if l:left_idx < 0
            let l:has_mark = 0
        endif
        "call appendbufline(g:Lin_TestResultBuffer, "$", ["", "Invoke s:obtainLeftIndex(), Left idx = " . string( l:left_idx )])
    endif
    if l:has_mark
        call s:exeCopyDown(l:curline, left_idx, right_idx)
    else
        call append(l:pos[1], [l:curline])
        call cursor(l:pos[1]+1, l:pos[2])
        call feedkeys('a')
    endif
    "let l:result = "Left idx: " . string(l:left_idx) . ", Right idx: " . string(l:right_idx)
    "call appendbufline(g:Lin_TestResultBuffer, "$", ["", l:result])
endfunction

