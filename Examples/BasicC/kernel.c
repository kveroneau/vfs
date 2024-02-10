#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vfs6502.h"

void FolderHandler(){
    char* login;
    char* pi;
    if (frcdata.password[0] == 0){ EndRequest(); }
    login = (char*)malloc(20);
    GetSession("login", login);
    puts(login);
    puts(frcdata.password);
    if (strcmp(login, &frcdata.password[0]) > 0){ free(login); EndRequest(); }
    GetPost("pass", login);
    if (strcmp(login, &frcdata.password[0]) > 0){
        SetSession("login", login);
        EndRequest();
    }
    free(login);
    puts("<h1>");
    puts(frcdata.header);
    puts("</h1><form action=\"");
    pi = (char*)malloc(80);
    GetPathInfo(pi);
    puts(pi);
    free(pi);
    puts("\" method=\"post\">");
    puts("Password: <input type=\"password\" name=\"pass\"/>");
    puts("<input type=\"submit\" value=\"");
    puts(frcdata.btntext);
    puts("\"/></form>");
    EndRequest();
}

void main(){
    SetFolderVector(FolderHandler);
    puts("Hello World from KERNEL.SYS!\n");
}
