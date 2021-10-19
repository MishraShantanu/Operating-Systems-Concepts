#include "M_Init.h"
#include "M_Display.h"
#include "M_Alloc.h"
#include "M_Free.h"

int main(int argc, char *argv[])
{

    //Pick an arbitrary size to init, exit if failed.
    if (M_Init(3000) == -1)
    {
        return -1;
    }

    void* ptr = M_Alloc(200);
    void* ptr2 = M_Alloc(50);
    void* ptr3 = M_Alloc(145);
    void* ptr4 = M_Alloc(344);
    void* ptr5 = M_Alloc(134);
    void* ptr6 = M_Alloc(605);
    void* ptr7 = M_Alloc(866);
    void* ptr8 = M_Alloc(6);
    M_Display();
    //void* ptr9 = M_Alloc(287);
    void* ptr10 = M_Alloc(304);



    //M_Free(ptr);
    //M_Free(ptr3);
    //M_Free(ptr5);
    //M_Free(ptr2);
    //M_Free(ptr4);
    //M_Free(ptr9);
    //M_Free(ptr6);
    //M_Display();


    //void* ptr11 = M_Alloc(15000);


    M_Display();
    //M_Free(ptr2);
}