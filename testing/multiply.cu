#include <unittest/unittest.h>

#define CUSP_USE_TEXTURE_MEMORY

#include <cusp/multiply.h>
#include <cusp/linear_operator.h>
#include <cusp/coo_matrix.h>
#include <cusp/print.h>
#include <cusp/gallery/poisson.h>
#include <cusp/gallery/random.h>

/////////////////////////////////////////
// Sparse Matrix-Matrix Multiplication //
/////////////////////////////////////////

template <typename SparseMatrixType, typename DenseMatrixType>
void CompareSparseMatrixMatrixMultiply(DenseMatrixType A, DenseMatrixType B)
{
    DenseMatrixType C;
    cusp::multiply(A, B, C);

    SparseMatrixType _A(A), _B(B), _C;
    cusp::multiply(_A, _B, _C);
    
    ASSERT_EQUAL(C == DenseMatrixType(_C), true);
}

template <typename TestMatrix>
void TestSparseMatrixMatrixMultiply(void)
{
    cusp::array2d<float,cusp::host_memory> A(3,2);
    A(0,0) = 1.0; A(0,1) = 2.0;
    A(1,0) = 3.0; A(1,1) = 0.0;
    A(2,0) = 5.0; A(2,1) = 6.0;
    
    cusp::array2d<float,cusp::host_memory> B(2,4);
    B(0,0) = 0.0; B(0,1) = 2.0; B(0,2) = 3.0; B(0,3) = 4.0;
    B(1,0) = 5.0; B(1,1) = 0.0; B(1,2) = 0.0; B(1,3) = 8.0;

    cusp::array2d<float,cusp::host_memory> C(2,2);
    C(0,0) = 0.0; C(0,1) = 0.0;
    C(1,0) = 3.0; C(1,1) = 5.0;
    
    cusp::array2d<float,cusp::host_memory> D(2,1);
    D(0,0) = 2.0;
    D(1,0) = 3.0;
    
    cusp::array2d<float,cusp::host_memory> E(2,2);
    E(0,0) = 0.0; E(0,1) = 0.0;
    E(1,0) = 0.0; E(1,1) = 0.0;
    
    cusp::array2d<float,cusp::host_memory> F(2,3);
    F(0,0) = 0.0; F(0,1) = 1.5; F(0,2) = 3.0;
    F(1,0) = 0.5; F(1,1) = 0.0; F(1,2) = 0.0;
    
    cusp::array2d<float,cusp::host_memory> G;
    cusp::gallery::poisson5pt(G, 4, 6);

    cusp::array2d<float,cusp::host_memory> H;
    cusp::gallery::poisson5pt(H, 8, 3);

    cusp::array2d<float,cusp::host_memory> I;
    cusp::gallery::random(24, 24, 150, I);
    
    cusp::array2d<float,cusp::host_memory> J;
    cusp::gallery::random(24, 24, 50, J);

    cusp::array2d<float,cusp::host_memory> K;
    cusp::gallery::random(24, 12, 20, K);
  
    std::vector< cusp::array2d<float,cusp::host_memory> > matrices;
    matrices.push_back(A);
    matrices.push_back(B);
    matrices.push_back(C);
    matrices.push_back(D);
    matrices.push_back(E);
    matrices.push_back(F);
    matrices.push_back(G);
    matrices.push_back(H);
    matrices.push_back(I);
    matrices.push_back(J);
    matrices.push_back(K);

    // test matrix multiply for every pair of compatible matrices
    for(size_t i = 0; i < matrices.size(); i++)
    {
        const cusp::array2d<float,cusp::host_memory>& left = matrices[i];
        for(size_t j = 0; j < matrices.size(); j++)
        {
            const cusp::array2d<float,cusp::host_memory>& right = matrices[j];

            if (left.num_cols == right.num_rows)
                CompareSparseMatrixMatrixMultiply<TestMatrix>(left, right);
        }
    }

}

template <typename Space>
void TestSparseMatrixMatrixMultiplyCoo(void)
{
    TestSparseMatrixMatrixMultiply< cusp::coo_matrix<int,float,Space> >();
}
DECLARE_HOST_DEVICE_UNITTEST(TestSparseMatrixMatrixMultiplyCoo);



/////////////////////////////////////////
// Sparse Matrix-Vector Multiplication //
/////////////////////////////////////////

template <typename SparseMatrixType, typename DenseMatrixType>
void CompareSparseMatrixVectorMultiply(DenseMatrixType A)
{
    typedef typename SparseMatrixType::memory_space MemorySpace;

    // setup reference input
    cusp::array1d<float, cusp::host_memory> x(A.num_cols);
    cusp::array1d<float, cusp::host_memory> y(A.num_rows, 10);
    for(size_t i = 0; i < x.size(); i++)
        x[i] = i % 10;
  
    // setup test input
    SparseMatrixType _A(A);
    cusp::array1d<float, MemorySpace> _x(x);
    cusp::array1d<float, MemorySpace> _y(A.num_rows, 10);

    cusp::multiply(A, x, y);
    cusp::multiply(_A, _x, _y);
    
    ASSERT_EQUAL(_y, y);
}

template <class TestMatrix>
void TestSparseMatrixVectorMultiply()
{
    typedef typename TestMatrix::memory_space MemorySpace;

    cusp::array2d<float, cusp::host_memory> A(5,4);
    A(0,0) = 13; A(0,1) = 80; A(0,2) =  0; A(0,3) =  0; 
    A(1,0) =  0; A(1,1) = 27; A(1,2) =  0; A(1,3) =  0;
    A(2,0) = 55; A(2,1) =  0; A(2,2) = 24; A(2,3) = 42;
    A(3,0) =  0; A(3,1) = 69; A(3,2) =  0; A(3,3) = 83;
    A(4,0) =  0; A(4,1) =  0; A(4,2) = 27; A(4,3) =  0;
    
    cusp::array2d<float,cusp::host_memory> B(2,4);
    B(0,0) = 0.0; B(0,1) = 2.0; B(0,2) = 3.0; B(0,3) = 4.0;
    B(1,0) = 5.0; B(1,1) = 0.0; B(1,2) = 0.0; B(1,3) = 8.0;

    cusp::array2d<float,cusp::host_memory> C(2,2);
    C(0,0) = 0.0; C(0,1) = 0.0;
    C(1,0) = 3.0; C(1,1) = 5.0;
    
    cusp::array2d<float,cusp::host_memory> D(2,1);
    D(0,0) = 2.0;
    D(1,0) = 3.0;
    
    cusp::array2d<float,cusp::host_memory> E(2,2);
    E(0,0) = 0.0; E(0,1) = 0.0;
    E(1,0) = 0.0; E(1,1) = 0.0;
    
    cusp::array2d<float,cusp::host_memory> F(2,3);
    F(0,0) = 0.0; F(0,1) = 1.5; F(0,2) = 3.0;
    F(1,0) = 0.5; F(1,1) = 0.0; F(1,2) = 0.0;
    
    cusp::array2d<float,cusp::host_memory> G;
    cusp::gallery::poisson5pt(G, 4, 6);

    cusp::array2d<float,cusp::host_memory> H;
    cusp::gallery::poisson5pt(H, 8, 3);

    CompareSparseMatrixVectorMultiply<TestMatrix>(A);
    CompareSparseMatrixVectorMultiply<TestMatrix>(B);
    CompareSparseMatrixVectorMultiply<TestMatrix>(C);
    CompareSparseMatrixVectorMultiply<TestMatrix>(D);
    CompareSparseMatrixVectorMultiply<TestMatrix>(E);
    CompareSparseMatrixVectorMultiply<TestMatrix>(F);
    CompareSparseMatrixVectorMultiply<TestMatrix>(G);
    CompareSparseMatrixVectorMultiply<TestMatrix>(H);
}
DECLARE_SPARSE_MATRIX_UNITTEST(TestSparseMatrixVectorMultiply);

template <class TestMatrix>
void TestSparseMatrixVectorMultiplyTextureCache()
{
    typedef typename TestMatrix::memory_space MemorySpace;

    // test with aligned memory
    {
        // initialize example matrix
        cusp::array2d<float, cusp::host_memory> A(5,4);
        A(0,0) = 13; A(0,1) = 80; A(0,2) =  0; A(0,3) =  0; 
        A(1,0) =  0; A(1,1) = 27; A(1,2) =  0; A(1,3) =  0;
        A(2,0) = 55; A(2,1) =  0; A(2,2) = 24; A(2,3) = 42;
        A(3,0) =  0; A(3,1) = 69; A(3,2) =  0; A(3,3) = 83;
        A(4,0) =  0; A(4,1) =  0; A(4,2) = 27; A(4,3) =  0;

        // convert to desired format
        TestMatrix test_matrix = A;

        // allocate vectors
        cusp::array1d<float, MemorySpace> x(4);
        cusp::array1d<float, MemorySpace> y(5);

        // initialize input and output vectors
        x[0] = 1.0f; y[0] = 10.0f; 
        x[1] = 2.0f; y[1] = 20.0f;
        x[2] = 3.0f; y[2] = 30.0f;
        x[3] = 4.0f; y[3] = 40.0f;
                     y[4] = 50.0f;

        cusp::detail::device::spmv_tex(test_matrix,
                                       thrust::raw_pointer_cast(&x[0]),
                                       thrust::raw_pointer_cast(&y[0]));

        ASSERT_EQUAL(y[0], 173.0f);
        ASSERT_EQUAL(y[1],  54.0f);
        ASSERT_EQUAL(y[2], 295.0f);
        ASSERT_EQUAL(y[3], 470.0f);
        ASSERT_EQUAL(y[4],  81.0f);
    }
    
    // test with unaligned memory
    {
        TestMatrix test_matrix;
        cusp::gallery::poisson5pt(test_matrix, 10, 10);

        // allocate vectors
        cusp::array1d<float, MemorySpace> x(test_matrix.num_cols + 1); // offset by one
        cusp::array1d<float, MemorySpace> y(test_matrix.num_rows);

        ASSERT_THROWS(cusp::detail::device::spmv_tex(test_matrix, thrust::raw_pointer_cast(&x[0]) + 1, thrust::raw_pointer_cast(&y[0])),
                      cusp::invalid_input_exception);

    }
}
DECLARE_DEVICE_SPARSE_MATRIX_UNITTEST(TestSparseMatrixVectorMultiplyTextureCache);


//////////////////////////////
// General Linear Operators //
//////////////////////////////

template <class MemorySpace>
void TestMultiplyIdentityOperator(void)
{
    cusp::array1d<float, MemorySpace> x(4);
    cusp::array1d<float, MemorySpace> y(4);

    x[0] =  7.0f;   y[0] =  0.0f; 
    x[1] =  5.0f;   y[1] = -2.0f;
    x[2] =  4.0f;   y[2] =  0.0f;
    x[3] = -3.0f;   y[3] =  5.0f;

    cusp::identity_operator<float, MemorySpace> A(4,4);
    
    cusp::multiply(A, x, y);

    ASSERT_EQUAL(y[0],  7.0f);
    ASSERT_EQUAL(y[1],  5.0f);
    ASSERT_EQUAL(y[2],  4.0f);
    ASSERT_EQUAL(y[3], -3.0f);
}
DECLARE_HOST_DEVICE_UNITTEST(TestMultiplyIdentityOperator);

