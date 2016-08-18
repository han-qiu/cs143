#include <iostream>
#include <fstream>
using namespace std;
int main()
{
	const char* fileName = "tmp";
	ofstream fout;
	fout.open(fileName);
	for(int i=0;i<1024;++i)
		fout << i % 10;
	fout.close();
	return 0;
}