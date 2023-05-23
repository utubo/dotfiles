vim9script
if did_filetype() && &ft !=# 'text'
finish
endif
var k = 0
var l = 0
for m in getline(1, 15)
if m[1] ==# '#'
continue
endif
if m =~# '^\S\+\t\S'
k += 1
if k ==# 3
setfiletype tsv
finish
endif
elseif m =~# '^\S\+\(,\s*\S\+\)\+$'
l += 1
if l ==# 3
setfiletype csv
endif
endif
endfor
