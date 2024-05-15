#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include "dir_walk.h"

int f(const char *path) {
  struct stat buf;
  off_t sz;
  if (stat(path, &buf)) {
    perror("stat");
    return -1;
  };

  sz = buf.st_size;
  printf("%s: size of file is %ld\n", path, sz);
  return 1;
}

int main(int argc, char **argv) {
  char *path;
  struct stat buf;

  /* Check that file has been supplied */
  if (argc < 2) return 1;

  path = argv[1];
  /* dir_walk(path, f); */
  for (int i = 0; i < 1000000; i++) {
    if (stat(path, &buf)) {
    perror("stat");
    return -1;
    };
  };

  return 0;
}
