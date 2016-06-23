//
//  ioctl.c
//  Pods
//
//  Created by Moray on 23/06/16.
//
//

#include <sys/ioctl.h>
#include "ioctl.h"

int socket_available_bytes(int socket)
{
  int count;
  ioctl(socket, FIONREAD, &count);
  return count;
}