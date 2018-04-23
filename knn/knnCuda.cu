#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

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

int checker(char* input, char* check) {
    int i,result=1;
    for(i=0; input[i]!='\0' || check[i]!='\0'; i++) {
        if(input[i] != check[i]) {
            result=0;
            break;
        }
    }
    return result;
}

void preliminarySteps(int argc, char** argv, int** dataSetPtr, int** scoresPtr, int* usersPtr, int* attributesPtr, int* kPtr) {
    // Check input
    if(argc < 5) {
        printf("Usage: %s <k> <users> <attributes> <serial/parallel>\n", argv[0]);
        exit(0);
    }
	int * dataSet;
	int k = atoi(argv[1]);
	int users = atoi(argv[2]);
	int attributes = atoi(argv[3]);
	*usersPtr = users;
	*attributesPtr = attributes;
	*kPtr = k;

	dataSet = (int*) malloc(sizeof(int) * users * attributes);
    if(dataSet != NULL) {
//        printf("Allocated an array for %d users and %d attributes\n", users, attributes);
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
  //      printf("Allocated a square scores array for %d users\n", users);
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

	if(user1 >= 0 && user1 < users && user2 >= 0 && user2 < users) {
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
	/*
	# if __CUDA_ARCH__>=200
                printf("%d, %d, %d, %d => %d \n", blockIdx.x, blockIdx.y, threadIdx.x, threadIdx.y, answer);
        #endif
	*/
        scores[user1*users + user2] = answer;
	}
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

__global__ void calculateKNearestKernel(int * scores, int * kNearest, int users, int K) {
		int minValue, minIndex, value, user, k, index;
		user = numThreads*blockIdx.x + threadIdx.x;
                for(k = 0; k < K; k++) {
                        minValue = MAX_VALUE;
                        minIndex = -1;
                        for(index = 0; index < users; index++) {
                                value = scores[user*users + index];
                                if(value < minValue && index != user) {
                                        minValue = value;
                                        minIndex = index;
                                }
                        }
                        if(minIndex != -1) {
                                // scores[user*users + minIndex] = MAX_VALUE;
                        }
                        // kNearest[user*users + k] = minIndex;
                }
}

// arguments: scores, kNearest, users, k
void launchCalculateKNearestKernel(int * dataSet, int * scores, int users, int k) {
	int * dev_dataSet;
        int * dev_scores;

        cudaMalloc((void**) &dev_dataSet, users*users*sizeof(int));
        cudaMalloc((void**) &dev_scores, users*k*sizeof(int));

        cudaMemcpy(dev_dataSet, dataSet, users*users*sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(dev_scores, scores, users*k*sizeof(int), cudaMemcpyHostToDevice);

        int numBlocks = (int) ceil(users*1.0/numThreads);
        dim3 grid( numBlocks, numBlocks, 1 );
        dim3 block( numThreads, numThreads, 1 );
        calculateKNearestKernel<<< grid, block >>>(dev_dataSet, dev_scores, users, k);

        cudaMemcpy(scores, dev_scores, users*k*sizeof(int), cudaMemcpyDeviceToHost);
}

void writeToFile(clock_t start, clock_t end, char * whichProgramToRun, int users, int attributes, int k, char * fileName) {
	FILE * file;
	if(checker(whichProgramToRun, (char*) "serial")) {
		file = fopen(fileName, "a");
	}else {
		file = fopen(fileName, "a");
	}
        long double timeTaken = (long double)(end - start)/CLOCKS_PER_SEC;
        fprintf(file, "%s, %d, %d, %d, %Lf\n", whichProgramToRun, users, attributes, k, timeTaken);
        fclose(file);
	printf("%s, %d, %d, %d, %Lf\n", whichProgramToRun, users, attributes, k, timeTaken);
}

void calculateKNearestSerial(int * scores, int * kNearest, int users, int K) {
        int minValue, minIndex, value, user, k, index;
        for(user = 0; user < users; user++) {
                for(k = 0; k < K; k++) {
                        minValue = MAX_VALUE;
                        minIndex = -1;
                        for(index = 0; index < users; index++) {
                                value = scores[user*users + index];
                                if(value < minValue && index != user) {
                                        minValue = value;
                                        minIndex = index;
                                }
                        }
                        if(minIndex != -1) {
                                // scores[user*users + minIndex] = MAX_VALUE;
                        }
                        // kNearest[user*users + k] = minIndex;
                }
        }
}

int main(int argc, char **argv) {
	int * dataSet; int * scores; int users; int attributes; int k;
	preliminarySteps(argc, argv, &dataSet, &scores, &users, &attributes, &k);
	
	char* whichProgramToRun = argv[4];
	
	clock_t start = clock();

	printf("k = %d\n", k);
	// printMatrix(dataSet, users, attributes);

	if(checker(whichProgramToRun, (char*) "serial")) {
		// serial
		calculateScores(dataSet, scores, users, attributes);
		free(dataSet);
		int * kNearest = (int*) malloc(sizeof(int) * users * k);
		calculateKNearestSerial(scores, kNearest, users, k);
		free(scores);
		free(kNearest);
	}else if(checker(whichProgramToRun, (char*) "parallel")) {
		// cuda parallel
		launchCalculateScoreKernel(dataSet, scores, users, attributes);
		free(dataSet);
		int * kNearest = (int*) malloc(sizeof(int) * users * k);
                launchCalculateKNearestKernel(scores, kNearest, users, k);
                free(scores);
                free(kNearest);
	}else {
		printf("Enter correct program to run: serial or parallel.\n");
		free(dataSet); free(scores);
		exit(0);
	}	
	
	// printf("Scores:-\n");
	// printMatrix(scores, users, users);

	clock_t end = clock();

	char * fileName = argv[5];
	writeToFile(start, end, whichProgramToRun, users, attributes, k, fileName);

	return 0;
}
