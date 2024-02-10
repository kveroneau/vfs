#include <stdbool.h>

void __fastcall__ SetSiteTitle(char* title);
void __fastcall__ SetPageTitle(char* title);
void __fastcall__ SetTemplate(char* tmpl);
void __fastcall__ SetSiteHeader(char* header);
void __fastcall__ SetAdminPass(char* pass);

typedef void (*content_handler) (void);

void __fastcall__ SetContentHandler(content_handler f);
void __fastcall__ SetFolderVector(content_handler f);
void EndRequest();

void __fastcall__ GetQuery(char* param, char* buf);
char __fastcall__ IsQuery(char* param, char* s);
void __fastcall__ GetPost(char* param, char* buf);
void __fastcall__ SetSession(char* skey, char* svalue);
void __fastcall__ GetSession(char* skey, char* buf);

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

void __fastcall__ LogHTML(char* msg);
void __fastcall__ LogVersion(unsigned ver);

typedef struct {
    char password[20];
    char header[20];
    char btntext[20];
    bool hide;
    char hook[20];
} rcdata;

extern rcdata frcdata;
