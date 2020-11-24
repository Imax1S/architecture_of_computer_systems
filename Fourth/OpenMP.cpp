// c++ main.cpp -fopenmp
#include <iostream>
#include <omp.h>
#include <set>
#include <vector>
#include <algorithm>
#include <iterator>
#include <thread>

using namespace std;

void checkUnion(vector<int> A, vector<int> B, vector<int> C) {
	set<int> s;

	s.insert(A.begin(), A.end());
	s.insert(B.begin(), B.end());

	sort(C.begin(), C.end());

	vector<int> AB(s.size());
	copy(s.begin(), s.end(), AB.begin());

	if (AB.size() == C.size())
	{
		for (size_t i = 0; i < AB.size(); i++)
		{
			if (AB[i] != C[i])
			{
				cout << "C is not a union of A and B" << endl;
				return;
			}
		}
		cout << "C is a union of A and B" << endl;
	}
	else
	{
		cout << "C is not union of A and B" << endl;
	}
}

void checkIntersection(vector<int> A, vector<int> B, vector<int> C) {
	vector <int> v_intersection;
	set<int> s;

	sort(A.begin(), A.end());
	sort(B.begin(), B.end());

	set_intersection(A.begin(), A.end(),
		B.begin(), B.end(),
		back_inserter(v_intersection));

	s.insert(v_intersection.begin(), v_intersection.end());

	std::vector<int> AB(s.size());
	std::copy(s.begin(), s.end(), AB.begin());

	if (AB.size() == C.size())
	{
		for (size_t i = 0; i < AB.size(); i++)
		{
			if (AB[i] != C[i])
			{
				cout << "C is not an intersection of A and B" << endl;
				return;
			}
		}
		cout << "C is an intersection of A and B" << endl;
	}
	else
	{
		cout << "C is not an intersection of A and B" << endl;
	}
}

void checkResidualAB(vector<int> A, vector<int> B, vector<int> C) {
	set<int> s;
	vector <int> v_intersection;

	sort(A.begin(), A.end());
	sort(B.begin(), B.end());

	set_difference(A.begin(), A.end(),
		B.begin(), B.end(),
		back_inserter(v_intersection));

	s.insert(v_intersection.begin(), v_intersection.end());

	std::vector<int> AB(s.size());
	std::copy(s.begin(), s.end(), AB.begin());

	if (AB.size() == C.size())
	{
		for (size_t i = 0; i < AB.size(); i++)
		{
			if (AB[i] != C[i])
			{
				cout << "C is not A/B" << endl;
				return;
			}
		}
		cout << "C is A/B" << endl;
	}
	else
	{
		cout << "C is not A/B" << endl;
	}
}

void checkResidualBA(vector<int> B, vector<int> A, vector<int> C) {
	set<int> s;
	vector <int> v_intersection;

	sort(A.begin(), A.end());
	sort(B.begin(), B.end());

	set_difference(B.begin(), B.end(),
		A.begin(), A.end(),
		back_inserter(v_intersection));

	s.insert(v_intersection.begin(), v_intersection.end());

	std::vector<int> AB(s.size());
	std::copy(s.begin(), s.end(), AB.begin());

	if (AB.size() == C.size())
	{
		for (size_t i = 0; i < AB.size(); i++)
		{
			if (AB[i] != C[i])
			{
				cout << "C is not B/A" << endl;
				return;
			}
		}
		cout << "C is B/A" << endl;
	}
	else
	{
		cout << "C is not B/A" << endl;
	}
}

int main()
{
	/*vector<int> A;
	vector<int> B;
	vector<int> C;*/

	//C is a union of A and B
	vector<int> A = { 1, 3, 3, 4 };
	vector<int> B = { 1, 3, 3 };
	vector<int> C = { 1, 3, 4 };

	//C is an intersection
	/*vector<int> A = { 1, 3, 3, 4 };
	vector<int> B = { 4, 5 };
	vector<int> C = { 4 };*/

	//C is A/B
	/*vector<int> A = { 1, 3, 3, 4, 5 };
	vector<int> B = { 1, 3, 3, 7, 8 };
	vector<int> C = { 4, 5 };*/

	//C is B/A
	/*vector<int> A = { 1, 3, 3};
	vector<int> B = { 1, 3, 3, 4 };
	vector<int> C = { 4 };*/

	/*int sizeofA = rand() % 5 + 1;
	int sizeofB = rand() % 5 + 1;
	int sizeofC = rand() % 5 + 1;
	cout << "A: ";
	for (int i = 0; i < sizeofA; i++)
	{
		A.push_back(rand() % 10 + 1);
		cout << A[i] << " ";
	}
	cout << endl << "B: ";
	for (int i = 0; i < sizeofB; i++)
	{
		B.push_back(rand() % 10 + 1);
		cout << B[i] << " ";
	}
	cout << endl << "C: ";
	for (int i = 0; i < sizeofC; i++)
	{
		C.push_back(rand() % 10 + 1);
		cout << C[i] << " ";
	}*/
	cout << endl;

#pragma omp parallel 
	{
#pragma omp sections
		{
#pragma omp section 
			{
				checkUnion(A, B, C);
			}
#pragma omp section 
			{
				checkIntersection(A, B, C);
			}
#pragma omp section 
			{
				checkResidualAB(A, B, C); 
			}
#pragma omp section 
			{	
				checkResidualBA(B, A, C); 
			}
		}
	}
}

