#include <stdio.h>
#include "crack.hpp"

PatchCode patch (char* fileName);

int main (void)
{
    char* fileName = "CRACKANDREW.COM";

    patch (fileName);
}

PatchCode patch (char* fileName)
{
    FILE* patchFile = fopen (fileName, "r+b");

    if (patchFile) 
    {   // 4ch -> eb, 5f -> 90 90
        const int patchAddress1 = 0x4c;
        fseek (patchFile, patchAddress1, SEEK_SET);

        const short patchHex1 = 0xeb;
        fwrite (&patchHex1, sizeof(patchHex1) / 2, 1, patchFile);

        const int patchAddress2 = 0x5f;
        fseek (patchFile, patchAddress2, SEEK_SET);

        const short patchHex2 = 0x9090; // nop nop
        fwrite (&patchHex2, sizeof(patchHex2), 1, patchFile); 

        fclose (patchFile);

        return PatchCode::PATCH_SUCCESS;
    }
    else
    {
        printf ("File (%s) not found!", fileName);

        fclose (patchFile);

        return PatchCode::PATCH_FILE_NOT_FOUND;
    }    
}
