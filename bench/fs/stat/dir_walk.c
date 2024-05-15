#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <string.h>

void dir_walk(const char *base_path, int (*f)(const char *)) {
    char path[PATH_MAX];
    struct dirent *dp;
    DIR *dir = opendir(base_path);

    if (!dir) {
        perror("Error opening directory");
        return;
    }

    while ((dp = readdir(dir)) != NULL) {
      /* Ignore . and .. */
        if (strcmp(dp->d_name, ".") != 0 && strcmp(dp->d_name, "..") != 0) {
            sprintf(path, "%s/%s", base_path, dp->d_name);

            if (dp->d_type == DT_DIR) {
                printf("Directory: %s\n", path);
                dir_walk(path, f);
            } else {
	      f(path);
            }
        }
    }

    closedir(dir);
}
