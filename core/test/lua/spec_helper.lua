pp = require("pl.pretty").dump
_ = require("underscore")

local R = require("rules")

_seq = R.Seq
_sym = R.Sym
_char = R.Char
_choice = R.Choice
_class = R.CharClass
_rep = R.Repeat
_end = R.End
