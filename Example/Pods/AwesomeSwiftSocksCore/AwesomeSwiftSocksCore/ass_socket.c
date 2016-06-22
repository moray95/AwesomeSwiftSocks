//
//  socket.c
//  AwesomeSwiftSocks
//
//  Created by Moray on 22/06/16.
//  Copyright © 2016 Moray Baruh. All rights reserved.
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <stdbool.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <assert.h>
#include "ass_socket.h"

int ass_create_socket()
{
  return socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
}

void ass_close_socket(int socket)
{
  int success = close(socket);
  assert(success == 0);
}

bool ass_connect_socket(int socket, const char* address, int port)
{
  struct sockaddr_in serv_addr = { 0 };
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_port = htons(port);
  if (inet_pton(AF_INET, address, &serv_addr.sin_addr) <= 0)
  {
    fprintf(stderr, "AwesomeSwiftSocks: Address %s is not valid\n", address);
    return false;
  }
  if (connect(socket, (struct sockaddr*) &serv_addr, sizeof(serv_addr)) < 0)
  {
    fprintf(stderr, "AwesomeSwiftSocks: Connect to %s on port %i failed. errno: %s\n", address, port, strerror(errno));
    return false;
  }
  return true;
}


void ass_write_socket(int socket, const char* msg, size_t size)
{
  write(socket, msg, size);
}

size_t ass_read_socket(int socket, char* data, size_t size)
{
  return read(socket, data, size);
}