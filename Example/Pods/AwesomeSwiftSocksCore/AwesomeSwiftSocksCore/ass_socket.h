//
//  socket.h
//  AwesomeSwiftSocks
//
//  Created by Moray on 22/06/16.
//  Copyright © 2016 Moray Baruh. All rights reserved.
//

#pragma once

int ass_create_socket(void);
void ass_close_socket(int socket);
bool ass_connect_socket(int socket, const char* address, int port);
void ass_write_socket(int socket, const char* msg, size_t size);
size_t ass_read_socket(int socket, char* data, size_t size);