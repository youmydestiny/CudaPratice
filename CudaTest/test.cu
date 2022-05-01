#include "cuda_runtime.h" 
#include "device_launch_parameters.h"
#include "cublas_v2.h"  
 
#include <time.h>  
#include <iostream>  
// ���������ӷ�kernel��grid��block��Ϊһά
__global__ void add(float* x, float* y, float* z, int n)
{
    // ��ȡȫ������
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    // ����
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < n; i += stride)
    {
        z[i] = x[i] + y[i];
    }
}

int main(){

    int N = 1 << 20;
    int nBytes = N * sizeof(float);
    // ����host�ڴ�
    float* x, * y, * z;
    x = (float*)malloc(nBytes);
    y = (float*)malloc(nBytes);
    z = (float*)malloc(nBytes);

    // ��ʼ������
    for (int i = 0; i < N; ++i)
    {
        x[i] = 10.0;
        y[i] = 20.0;
    }

    // ����device�ڴ�
    float* d_x, * d_y, * d_z;
    cudaMalloc((void**)&d_x, nBytes);
    cudaMalloc((void**)&d_y, nBytes);
    cudaMalloc((void**)&d_z, nBytes);

    // ��host���ݿ�����device
    cudaMemcpy((void*)d_x, (void*)x, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy((void*)d_y, (void*)y, nBytes, cudaMemcpyHostToDevice);
    // ����kernel��ִ������
    dim3 blockSize(256);
    dim3 gridSize((N + blockSize.x - 1) / blockSize.x);
    // ִ��kernel
    add <<<gridSize, blockSize>>> (d_x, d_y, d_z, N);

    // ��device�õ��Ľ��������host
    cudaMemcpy((void*)z, (void*)d_z, nBytes, cudaMemcpyDeviceToHost);

    // ���ִ�н��
    float maxError = 0.0;
    for (int i = 0; i < N; i++)
        maxError = fmax(maxError, fabs(z[i] - 31.0));
    std::cout << "������: " << maxError << std::endl;

    // �ͷ�device�ڴ�
    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_z);
    // �ͷ�host�ڴ�
    free(x);
    free(y);
    free(z);
	return 0;
}