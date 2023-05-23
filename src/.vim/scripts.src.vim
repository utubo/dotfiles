vim9script

if did_filetype() && &filetype !=# 'text'
	finish
endif

var tsv_count = 0
var csv_count = 0
for line in getline(1, 15)
	if line[1] ==# '#'
		continue
	endif
	if line =~# '^\S\+\t\S'
		tsv_count += 1
		if tsv_count ==# 3
			setfiletype tsv
			finish
		endif
	elseif line =~# '^\S\+\(,\s*\S\+\)\+$'
		csv_count += 1
		if csv_count ==# 3
			setfiletype csv
		endif
	endif
endfor

