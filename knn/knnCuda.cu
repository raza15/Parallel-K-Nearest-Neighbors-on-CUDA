#include <stdio.h>
#include <stdlib.h>
#define MAX_VALUE 2147483647
#define numThreads 32

void printMatrix(int *matrix, int users, int attributes) {
	// printf("Matrix:-\n");
	for(int i = 0; i < (users * attributes); i++) {
		if(i % attributes == 0 && i != 0) {
			printf("\n%d ", matrix[i]);
		} else {
			printf("%d ", matrix[i]);
		}
	}
	printf("\n");
}

void preliminarySteps(int argc, char** argv, int** dataSetPtr, int** scoresPtr, int* usersPtr, int* attributesPtr) {
    // Check input
    if(argc < 4) {
        printf("Usage: %s <k> <users> <attributes>\n", argv[0]);
        exit(0);
    }
	int * dataSet;
	int k = atoi(argv[1]);
	int users = atoi(argv[2]);
	int attributes = atoi(argv[3]);
	*usersPtr = users;
	*attributesPtr = attributes;

	dataSet = (int *)malloc(sizeof(int) * users * attributes);
    if(dataSet != NULL) {
        printf("Allocated an array for %d users and %d attributes\n", users, attributes);
    } else {
        printf("Couldn't allocate dataSet array, quitting!\n");
        exit(0);
    }

    // Seed the RNG
    srand(time(NULL));
    // Now fill dataSet with some values
    for(int i=0; i < (users * attributes); i++)
        //dataSet[i] = rand() % 1000; // Random integers between 0 and 1,000
        dataSet[i] = rand() % 15; // Random integers between 0 and 1,000
    *dataSetPtr = dataSet;
    int *scores;
    scores = (int *)malloc(sizeof(int) * users * users);
    if(scores != NULL) {
        printf("Allocated a square scores array for %d users\n", users);
    } else {
        printf("Couldn't allocate scores array, quitting!\n");
        exit(0);
    }
    *scoresPtr = scores;
}

void calculateScore(int* matrix, int* scores, int users, int attributes, int user1, int user2) {
	int answer = 0;
	int user1Start = attributes*user1;
	int user1End = user1Start + attributes - 1;
	int user2Start = attributes*user2;
	int user2End = user2Start + attributes - 1;
	
	int i; int j; int difference;
	for(i = user1Start, j = user2Start; i <= user1End && j <= user2End ; i++, j++) {
		difference = matrix[i] - matrix[j];
		answer += difference*difference;
	}
	
	scores[user1*users + user2] = answer;
}

void calculateScores(int *matrix, int *scores, int users, int attributes) {
	int user1; int user2;
	for(user1 = 0; user1 < users; user1++) {
		for(user2 = 0; user2 < users; user2++) {
			calculateScore(matrix, scores, users, attributes, user1, user2);
		}
	}
}

__global__ void calculateScoreKernel(int *matrix, int *scores, int users, int attributes) {
        int user1 = numThreads*blockIdx.x + threadIdx.x;
	int user2 = numThreads*blockIdx.y + threadIdx.y;
	
        int answer = 0;
        int user1Start = attributes*user1;
        int user1End = user1Start + attributes - 1;
        int user2Start = attributes*user2;
        int user2End = user2Start + attributes - 1;

        int i; int j; int difference;
        for(i = user1Start, j = user2Start; i <= user1End && j <= user2End ; i++, j++) {
                difference = matrix[i] - matrix[j];
                answer += difference*difference;
        }

        scores[user1*users + user2] = answer;
}

void launchCalculateScoreKernel(int * dataSet, int * scores, int users, int attributes) {
	int * dev_dataSet;
	int * dev_scores;
	
	cudaMalloc((void**) &dev_dataSet, users*attributes*sizeof(int));
	cudaMalloc((void**) &dev_scores, users*users*sizeof(int));
	
	cudaMemcpy(dev_dataSet, dataSet, users*attributes*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_scores, scores, users*users*sizeof(int), cudaMemcpyHostToDevice);

	int numBlocks = (int) ceil(users*1.0/numThreads);
	dim3 grid( numBlocks, numBlocks, 1 );
	dim3 block( numThreads, numThreads, 1 );
	calculateScoreKernel<<< grid, block >>>(dev_dataSet, dev_scores, users, attributes);

	cudaMemcpy(scores, dev_scores, users*users*sizeof(int), cudaMemcpyDeviceToHost);
}

int main(int argc, char **argv) {
	int * dataSet; int * scores; int users; int attributes;
	preliminarySteps(argc, argv, &dataSet, &scores, &users, &attributes);
	
	printf("Matrix:-\n");
	printMatrix(dataSet, users, attributes);

	// serial
	// calculateScores(dataSet, scores, users, attributes);

	launchCalculateScoreKernel(dataSet, scores, users, attributes);	
	
	printf("Scores:-\n");
	printMatrix(scores, users, users);
	
	// Clean up after ourselves
	free(dataSet); free(scores);
	return 0;
}
