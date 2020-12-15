#include <pthread.h>
#include <semaphore.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>


const int bufSize = 10;
int buf[bufSize];
int rear = 0;
int front = 0;

sem_t  empty;
sem_t  full;

//Класс писателя
void* Writer(void* param) {
	int pNum = *((int*)param);
	while (1) {
		int data = rand() % 11 - 5;
		//Не даем другим потокам писать
		sem_wait(&empty);
		buf[rear] = data;
		rear = (rear + 1) % bufSize;
		sem_post(&full);
		printf("Writer %d: Writes value = %d to cell [%d]\n", pNum, data, rear - 1 < 0 ? bufSize - 1 : rear - 1);
		sleep(6);
	}
	return nullptr;
}

//Класс читателя
void* Reader(void* param) {
	int cNum = *((int*)param);
	int result;
	while (1) {
		sleep(10);
		result = buf[front];
		front = (front + 1) % bufSize;
		printf("Reader %d: Reads value = %d from cell [%d]\n", cNum, result, front - 1 < 0 ? bufSize - 1 : front - 1);
	}
	return nullptr;
}

int main() {
	int i;
	sem_init(&empty, 0, bufSize);
	sem_init(&full, 0, 0);
	pthread_t threadP[3];
	int writers[3];
	for (i = 0; i < 3; i++) {
		writers[i] = i + 1;
		pthread_create(&threadP[i], nullptr, Writer, (void*)(writers + i));
	}

	pthread_t threadC[4];
	int readers[4];
	for (i = 0; i < 4; i++) {
		readers[i] = i + 1;
		pthread_create(&threadC[i], nullptr, Reader, (void*)(readers + i));
	}
	int mNum = 0;
	Reader((void*)&mNum);
	return 0;
}
