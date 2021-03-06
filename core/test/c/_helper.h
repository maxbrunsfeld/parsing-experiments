#ifndef __HELPERS_H__
#define __HELPERS_H__

#include "compiler.h"
#include "bantam_bdd.h"
#include "assert.h"

#define CHOICE ts_rule_new_choice
#define SYM    ts_rule_new_sym
#define SEQ    ts_rule_new_seq

#define STR    ts_rule_new_string
#define PAT    ts_rule_new_pattern

#endif
