#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vfs6502.h"

void Handler(){
    char* buf;
    puts("Hello World VFS from the C runtime library!\n");
    buf = (char*)malloc(40);
    GetQuery("cquery", buf);
    puts(buf);
    free(buf);
}

void HelloHandler(){
    char* pi;
    puts("This is the Hello World endpoint!<br/>\n");
    printf("And this is being displayed via printf!<br/>\n");
    pi = (char*)malloc(80);
    GetPathInfo(pi);
    puts("The path info is: ");
    puts(pi);
    SaveFile("vfs/test.fil", pi, 80);
    free(pi);
    if (FileExists("vfs/BOOT.SYs")){ puts("<br/>It exists!"); }
}

void main(){
    char* buf;
    SetPageTitle("Hello from C");
    buf = (char*)malloc(40);
    GetQuery("cquery", buf);
    if (strcmp(buf, "hello") > -1) {
        SetContentHandler(HelloHandler);
    }else{ SetContentHandler(Handler); }
    free(buf);
}
