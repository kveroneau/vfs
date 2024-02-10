#include <stdbool.h>

void __fastcall__ SetSiteTitle(char* title);
void __fastcall__ SetPageTitle(char* title);
void __fastcall__ SetTemplate(char* tmpl);
void __fastcall__ SetSiteHeader(char* header);
void __fastcall__ SetAdminPass(char* pass);

typedef void (*content_handler) (void);

void __fastcall__ SetContentHandler(content_handler f);
void __fastcall__ SetFolderVector(content_handler f);
void __fastcall__ SetRedirect(char* url);
void __fastcall__ SetInfoVector(content_handler f);
void __fastcall__ SetAdminVector(content_handler f);
void __fastcall__ SetShellVector(content_handler f);
void __fastcall__ SetContentType(char* mimetype);
void __fastcall__ SetTagVector(content_handler f);
void __fastcall__ pcallkey(char* mimetype);
void EndRequest();

void __fastcall__ GetQuery(char* param, char* buf);
char __fastcall__ IsQuery(char* param, char* s);
void __fastcall__ GetPost(char* param, char* buf);
char __fastcall__ IsPost(char* param, char* s);
void __fastcall__ SetSession(char* skey, char* svalue);
void __fastcall__ GetSession(char* skey, char* buf);
char __fastcall__ IsSession(char* param, char* s);

void __fastcall__ GetPRGName(char* buf);
void __fastcall__ GetPathInfo(char* buf);
void __fastcall__ GetPrefix(char* buf);

bool __fastcall__ FileExists(char* fname);
unsigned __fastcall__ LoadPRGFile(char* fname);
void __fastcall__ WriteFile(char* fname, char* pv);
void __fastcall__ SaveFile(char* fname, void* buf, unsigned size);
unsigned __fastcall__ LoadFile(char* fname, void* buf);
void __fastcall__ ESaveFile(char* fname, void* buf, unsigned size);
unsigned __fastcall__ ELoadFile(char* fname, void* buf);

void __fastcall__ PostbackWidget(content_handler f, char* btntext);

void __fastcall__ LogHTML(char* msg);
void __fastcall__ LogVersion(unsigned ver);

void __fastcall__ AddRunHook(char* hook);
void __fastcall__ AddIndex(char* idx);
void __fastcall__ AddTag(char* tag, content_handler f);

unsigned __fastcall__ WebGet(char* url, void* dest);
unsigned __fastcall__ WebPut(char* url, void* buf, unsigned size);

typedef struct {
    char password[20];
    char header[20];
    char btntext[20];
    bool hide;
    char hook[20];
} rcdata;

extern rcdata frcdata;

extern unsigned runcount;
extern content_handler load_addr;
