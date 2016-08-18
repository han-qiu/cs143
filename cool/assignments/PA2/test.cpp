#include <iostream>
#include <fstream>
using namespace std;
int main()
{
	const char* fileName = "test5.cl";
	ofstream fout;
	fout.open(fileName);
	fout << "\"";
	for(int i=0;i<256*2;++i)
		fout << (char)0;
	fout << "\"";
	fout.close();
	return 0;
}