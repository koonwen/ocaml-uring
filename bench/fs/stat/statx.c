#define _GNU_SOURCE
#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "dir_walk.h"

int f(const char *path) {
  struct statx buf;
  off_t sz;
    if (statx(AT_FDCWD, path, 0, STATX_ALL, &buf) == -1) {
        perror("statx");
	return -1;
    }

  sz = buf.stx_size;
  printf("%s: size of file is %ld\n", path, sz);
  return 1;
}

int main(int argc, char **argv) {
  char *path;
  struct statx buf;
  /* Check that file has been supplied */
  if (argc < 2) return 1;

  /* dir_walk(path, f); */
  path = argv[1];
  for (int i = 0; i < 1000000; i++) {
    if (statx(AT_FDCWD, path, 0, STATX_SIZE, &buf)) {
    perror("stat");
    return -1;
    };
  };

  return 0;
}
