#ifndef __HELPERS_H__
#define __HELPERS_H__

#include "bantam_bdd.h"
#include "assert.h"

#define CHOICE ip_rule_new_choice
#define SYM    ip_rule_new_sym
#define SEQ    ip_rule_new_seq
#define TOKEN  ip_token_new

#define ID     ip_rule_id
#define LEFT   ip_rule_left
#define RIGHT  ip_rule_right

#endif
