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

int main()
{
    int N = 1 << 20;
    int nBytes = N * sizeof(float);

    // �����й��ڴ�
    float* x, * y, * z;
    cudaMallocManaged((void**)&x, nBytes);
    cudaMallocManaged((void**)&y, nBytes);
    cudaMallocManaged((void**)&z, nBytes);

    // ��ʼ������
    for (int i = 0; i < N; ++i)
    {
        x[i] = 10.0;
        y[i] = 20.0;
    }

    // ����kernel��ִ������
    dim3 blockSize(256);
    dim3 gridSize((N + blockSize.x - 1) / blockSize.x);
    // ִ��kernel
    add << < gridSize, blockSize >>> (x, y, z, N);

    // ͬ��device ��֤�������ȷ����
    cudaDeviceSynchronize();
    // ���ִ�н��
    float maxError = 0.0;
    for (int i = 0; i < N; i++)
        maxError = fmax(maxError, fabs(z[i] - 31.0));
    std::cout << "������: " << maxError << std::endl;

    // �ͷ��ڴ�
    cudaFree(x);
    cudaFree(y);
    cudaFree(z);

    return 0;
}