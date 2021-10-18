#include "M_Init.h"
#include "M_Display.h"
#include "M_Alloc.h"
#include "M_Free.h"

int main(int argc, char *argv[])
{

    //Pick an arbitrary size to init, exit if failed.
    if (M_Init(16000) == -1)
    {
        return -1;
    }

    void* ptr = M_Alloc(200);
    void* ptr2 = M_Alloc(50);
    void* ptr3 = M_Alloc(145);
    void* ptr4 = M_Alloc(344);
    void* ptr5 = M_Alloc(134);




    //M_Free(ptr);
    //M_Free(ptr2);
    //M_Free(ptr3);
    M_Free(ptr4);
    //M_Free(ptr5);
    //M_Display();
    //M_Display();
    M_Display();
}