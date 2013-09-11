let g:syntastic_c_include_dirs = [ './core/include', './core/externals/bantam-bdd' ]
let g:syntastic_c_auto_refresh_includes = 1
let g:syntastic_c_compiler_options = '-std=gnu99 -fnested-functions -DRUBY_MISSING_H'
