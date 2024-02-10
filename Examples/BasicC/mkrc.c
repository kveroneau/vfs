#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vfs6502.h"

char* rcfile;

void ShowForm(){
    puts("<h3>mkrc.eXe</h3><hr width=\"300\" align=\"left\"/>");
    puts("<form action=\"mkrc.eXe\" method=\"post\">");
    puts("RC File: <input type=\"text\" name=\"rcfile\"/><br/>");
    puts("Password: <input type=\"password\" name=\"pass\"/><br/>");
    puts("Auth Header: <input type=\"text\" name=\"hdr\"/><br/>");
    puts("Button Text: <input type=\"text\" name=\"btn\"/><br/>");
    puts("Hide Folder: <input type=\"checkbox\" name=\"hide\" value=\"true\"/><br/>");
    puts("Hook: <input type=\"text\" name=\"hook\"/><br/>");
    puts("<input type=\"submit\" name=\"addit\" value=\"Create RC File\"/><br/>");
    puts("</form>");
}

void CreateRCFile(){
    rcdata* rc;
    char* buf;
    rc = (rcdata*)malloc(0x66);
    GetPost("pass", rc->password);
    GetPost("hdr", rc->header);
    GetPost("btn", rc->btntext);
    buf = (char*)malloc(10);
    GetPost("hide", buf);
    if (strcmp(buf, "true") > -1){
        rc->hide=true;
    }else{ rc->hide=false; }
    free(buf);
    GetPost("hook", rc->hook);
    SaveFile(rcfile, rc, 0x66);
    free(rc);
    //strcpy(rc->password, "password");
    //rc.password = "password";
    puts("Created!");
}

void main(){
    SetPageTitle("mkrc.eXe");
    rcfile = (char*)malloc(0x66);
    GetPost("rcfile", rcfile);
    if (rcfile[0] == 0){ SetContentHandler(ShowForm); }
    else{ SetContentHandler(CreateRCFile); }
}
