typedef struct IPToken {
  char *pattern;
} IPToken;

IPToken * ip_token_new(char *pattern);
