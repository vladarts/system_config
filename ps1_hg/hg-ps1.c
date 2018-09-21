/*
 * Copyright 2011 Jonathan D. Page
 * 
 * This guy called Jonathan wrote this sweet code. You are hereby granted
 * permission to do whatever you feel like doing with it on the understanding
 * that he's not responsible for anything that results from your use of this
 * sweet code.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdbool.h>

#define MALLOC_CHUNK 10
#define SAFE_CHAR_MALLOC(ptr, size) if (((ptr) = (char *)malloc((size) * sizeof(char))) == NULL) panic();
#define SAFE_CHAR_REALLOC(ptr, size) if (((ptr) = (char *)realloc((ptr), (size) * sizeof(char))) == NULL) panic();

void
panic() {
	exit(EXIT_FAILURE);
}

bool
is_hg_dir(const char *pwd) {
	char *hg_path;
	size_t plen;
	int statret;
	struct stat st;

	plen = strlen(pwd);
	SAFE_CHAR_MALLOC(hg_path, plen + 5);
	sprintf(hg_path, "%s/.hg", pwd);
	statret = stat(hg_path, &st);
	free(hg_path);

	return statret == 0;
}

char *
get_branch(const char *repo) {
	FILE *f;
	char *branchfile, *branchname;
	size_t plen, read, cchar, csize;
	int k;

	plen = strlen(repo);
	SAFE_CHAR_MALLOC(branchfile, plen + 12);
	sprintf(branchfile, "%s/.hg/branch", repo);

	if ((f = fopen(branchfile, "r")) == NULL)
		return "default";

	free(branchfile);

	csize = MALLOC_CHUNK;
	SAFE_CHAR_MALLOC(branchname, csize);

	cchar = 0;
	while (true) {
		read = fread(branchname + cchar, sizeof(char), MALLOC_CHUNK, f);
		cchar += read;

		if (read < MALLOC_CHUNK) 
			break; // don't care about the difference between eof and err

		csize += MALLOC_CHUNK;
		SAFE_CHAR_REALLOC(branchname, csize);
	}

	branchname[cchar] = 0;
	for (k = 0; k < cchar; k++) {
		if (branchname[k] == '\n') {
			branchname[k] = 0;
			break;
		}
	}
	SAFE_CHAR_REALLOC(branchname, k + 1);
	
	fclose(f);
	return branchname;
}

char *
get_current_revision(const char *repo) {
	FILE *f;
	unsigned char hash[6];
	char *rev;
	char *statefile;
	size_t plen;
	int k;

	plen = strlen(repo);
	SAFE_CHAR_MALLOC(statefile, plen + 14);
	sprintf(statefile, "%s/.hg/dirstate", repo);

	if ((f = fopen(statefile, "r")) == NULL)
		return "????????????";

	free(statefile);

	fread(hash, sizeof(unsigned char), 6, f);

	SAFE_CHAR_MALLOC(rev, 13 * sizeof(char));

	for (k = 0; k < 6; k++) {
		sprintf(rev + k * 2, "%02x", hash[k]);
	}

	return rev;
}

char *
get_repo() {
	char *dir_path;
	int len, k;
	
	dir_path = getcwd(NULL, 0);

	while ((len = strlen(dir_path)) > 0) {
		if (is_hg_dir(dir_path)) {
			SAFE_CHAR_REALLOC(dir_path, strlen(dir_path) + 1);
			return dir_path;
		}

		for (k = len - 1; k >= 0; k--) {
			if (dir_path[k] == '/') {
				dir_path[k] = 0;
				break;
			}
		}
	}

	free(dir_path);
	return NULL;
}

int 
main(int argc, char **argv) {
	char *repo;
	char *format;

	repo = get_repo();

	if (repo == NULL)
		return 0;

	if (argc < 2)
		format = ":%s:%s";
	else
		format = argv[1];

	printf(" (%s)", get_branch(repo));
    // printf(format, get_branch(repo), get_current_revision(repo));

	return 0;
}
