#include <stdio.h>
#include <stdlib.h>

#define N 10

__global__ 
void outputFromGPU() {
	printf("Hello from GPU!\n");
}

__global__
void add(int a, int b, int * c) {
	*c = a + b;
}

__global__
void addTwoArrays(int* a, int* b, int* c) {
	int bid = blockIdx.x;
	if(bid < N) {
		c[bid] = a[bid] + b[bid];
	}
}

void mainForAdd() {
	// printf("Hello from CPU!\n");
        // outputFromGPU<<<2,5>>>();
        // cudaDeviceSynchronize();
	int a, b, c;
        int * dev_c;
        a = 3;
        b = 4;
        cudaMalloc((void **) &dev_c, sizeof(int));
        add<<<1,1>>>(a,b,dev_c);
        cudaMemcpy(&c, dev_c, sizeof(int), cudaMemcpyDeviceToHost);
        printf("%d + %d = %d\n", a, b, c);
        cudaFree(dev_c);
}

void mainForAddTwoArrays() {
	int i, a[N], b[N], c[N];
	int *dev_a; 
	int *dev_b; 
	int *dev_c;

	cudaMalloc((void**) &dev_a, N*sizeof(int));
	cudaMalloc((void**) &dev_b, N*sizeof(int));
	cudaMalloc((void**) &dev_c, N*sizeof(int));
	
	for(i = 0; i < N; i++) {
		a[i] = i;
		b[i] = i*i;
	}
	cudaMemcpy(dev_a, a, N*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, b, N*sizeof(int), cudaMemcpyHostToDevice);
	// printf("here1\n");
	addTwoArrays<<<N, 1>>>(dev_a, dev_b, dev_c);
	// printf("here2\n");
	cudaMemcpy(c, dev_c, N*sizeof(int), cudaMemcpyDeviceToHost);
	
	printf("\na + b = c\n");
	for(i = 0; i < N; i++) {
		printf("\n%5d + %5d = %5d\n", a[i], b[i], c[i]);
	}

	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
}

int main(void) {
	mainForAddTwoArrays();
}
