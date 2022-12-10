---
layout: article
category: SwiftUI
---

```cpp
#include <iostream>
#include <string>
#include <iomanip>

#ifndef Custom_h
#define Custom_h

using namespace std;

typedef struct{
    DataType data[ListSize];
    int length;
}SeqList;

int main() {
    int a=10;
    int b=sizeof(a);
    
    cout<<b;
    cout<<endl;
    return 0;
}

class myDate
{
public:
    myDate();
//    myDate(int);
//    myDate(int, int);
    myDate(int, int, int);
    int returnDate();
    friend myDate operator+(myDate a, myDate b);
    friend ostream& operator<<(ostream& os, const myDate & a);
private:
    int year, month, day;
};
```