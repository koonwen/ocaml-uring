CC := gcc
CFLAGS := -Wall -Wextra -std=c11
LDFLAGS :=  # Additional libraries to link against, if needed

# Get all C source files in the current directory
SRCS := $(wildcard *.c)

# Generate corresponding object file names for each source file
OBJS := $(SRCS:.c=.o)

SHARED_OBJS := dir_walk.o

# Final executables
TARGET_STAT := stat
TARGET_STATX := statx

.PHONY: all clean

all: $(TARGET_STAT) $(TARGET_STATX)

# Rule to compile each source file into an object file
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Rule to link all object files into the final executable 'stat'
$(TARGET_STAT): $(SHARED_OBJS) stat.o
	$(CC) $^ -o $@ $(LDFLAGS)

# Rule to link all object files into the final executable 'statx'
$(TARGET_STATX): $(SHARED_OBJS) statx.o
	$(CC) $^ -o $@ $(LDFLAGS)

clean:
	rm -f $(OBJS) $(TARGET_STAT) $(TARGET_STATX)
