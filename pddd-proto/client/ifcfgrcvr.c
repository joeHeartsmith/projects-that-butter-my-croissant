#include <errno.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/inotify.h>
#include <unistd.h>

/* pretty much just ripped-out of the manpage */
static void handle_events(int fd, int *wd, int argc, char *argv[]) {
  char buf[4096] __attribute__((aligned(__alignof__(struct inotify_event))));
  const struct inotify_event *event;
  int i;
  ssize_t len;
  char *ptr;

  for (;;) {
    sleep(1);
    len = read(fd, buf, sizeof buf);
    if (len == -1 && errno != EAGAIN) {
      perror("read");
      exit(EXIT_FAILURE);
    }

    if (len <= 0)
      break;

    for (ptr = buf; ptr < buf + len;
         ptr += sizeof(struct inotify_event) + event->len) {

      event = (const struct inotify_event *)ptr;

      if (event->mask & IN_MODIFY)
          system(argv[2]);

      for (i = 1; i < argc; ++i) {
        if (wd[i] == event->wd) {
          printf("");
          break;
        }
      }

      if (event->len)
        printf("");

      if (event->mask & IN_ISDIR)
        printf("\n");
      else
        printf("\n");
    }
  }
}

int main(int argc, char *argv[]) {
  char buf;
  int fd, i, poll_num;
  int *wd;
  nfds_t nfds;
  struct pollfd fds[2];

  if (argc < 2) {
    printf("Usage: %s [ADDR_SOURCE] [SCRIPT]\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  fd = inotify_init1(IN_NONBLOCK);
  if (fd == -1) {
    perror("inotify_init1");
    exit(EXIT_FAILURE);
  }

  wd = calloc(argc, sizeof(int));
  if (wd == NULL) {
    perror("calloc");
    exit(EXIT_FAILURE);
  }

    wd[1] = inotify_add_watch(fd, argv[1], IN_MODIFY);
    if (wd[1] == -1) {
      fprintf(stderr, "Cannot watch '%s': %s\n", argv[1], strerror(errno));
      exit(EXIT_FAILURE);
    }
while (1) {
handle_events(fd, wd, argc, argv);
}

  close(fd);

  free(wd);
  exit(EXIT_SUCCESS);
}
