#include <iostream>
#include <fstream>
using namespace std;
int main()
{
	//test some character
	const char* fileName = "test.cl";
	ofstream fout;
	fout.open(fileName);
	fout << "\"";
	for(int i=0;i<256*2;++i)
		fout << (char)i;
	fout << "\"";
	for(int i=0;i<256*2;++i)
		fout << (char)i;
	fout.close();
	return 0;
}