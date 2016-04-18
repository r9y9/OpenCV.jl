using OpenCV
using Cxx
using Base.Test


@testset "Mat{T,N}" begin
    mat = cv2.Mat{Float64}()
    @test cv2.empty(mat)

    mat = cv2.Mat{UInt8}(10, 20)
    @test size(mat) == (10, 20)
    @test cv2.channels(mat) == 1
    @test !cv2.empty(mat)

    mat = cv2.Mat{UInt8}(10, 20, 2)
    @test cv2.channels(mat) == 2
    @test size(mat) == (10, 20, 2)

    mat = cv2.Mat{UInt8}(10, 20, 3)
    @test cv2.channels(mat) == 3
    @test size(mat) == (10, 20, 3)

    @testset "Array to cv::Mat conversion" begin
        arr = rand(Float64, 10, 2)
        m = cv2.Mat(arr)
        @test eltype(m) == eltype(arr)
        @test size(arr) == reverse(size(m))
    end
end

@testset "UMat{T,N}" begin
    umat = cv2.UMat{UInt8}(3, 3)
    mat = cv2.Mat(umat)
    @test isa(mat, cv2.Mat)
    @test size(umat) == (3, 3)

    # make sure cv2.resize doesn't change the type of mat
    umat_resized = cv2.resize(umat, size(umat))
    @test isa(umat_resized, cv2.UMat)
    @test size(umat) == size(umat_resized)
end

macro mat_op_testdata()
    #=
    2x12 Array{Float64,2}:
     1.0  3.0  5.0  7.0   9.0  11.0  13.0  15.0  17.0  19.0  21.0  23.0
     2.0  4.0  6.0  8.0  10.0  12.0  14.0  16.0  18.0  20.0  22.0  24.0
    =#
    esc(quote
        x = map(Float64, reshape([1:24;], 2,3*4))
        xt = x'
        m = cv2.Mat(xt)
    end)
end

@testset "Matrix operations" begin
    @testset "+" begin
        @mat_op_testdata
        ret = m + m
        retmat = cv2.Mat(ret)
        @test all(retmat .== 2x)
    end

    @testset "-" begin
        @mat_op_testdata
        ret = m - m
        retmat = cv2.Mat(ret)
        @test all(retmat .== 0)
    end

    @testset ".*" begin
        @mat_op_testdata
        ret = m .* 5
        @test isa(ret, cv2.MatExpr)
        retmat = cv2.Mat(ret)
        @test all(retmat .== 5x)
    end

    @testset "./" begin
        @mat_op_testdata
        ret = m ./ 2
        @test isa(ret, cv2.MatExpr)
        retmat = cv2.Mat(ret)
        expected = x ./ 2
        @test all(retmat .== expected)
    end

    @testset "*" begin
        @mat_op_testdata
        @test cv2.Mat(m * m') == x * x'
    end

    @testset "transpose" begin
        @mat_op_testdata
        retexpr = m'
        retmat = cv2.Mat(retexpr)
        @test all(retmat .== x')
    end

    @testset "inv" begin
        @mat_op_testdata
        square_mat = m * m'
        #=
        2x2 Array{Float64,2}:
        2300.0  2444.0
        2444.0  2600.0
        =#
        inv_x = inv(x * xt)
        ret = inv(square_mat)
        inv_m = cv2.Mat(ret)
        @test_approx_eq inv_x inv_m
    end
end

@testset "Matrix channels" begin
    @test cv2.mat_channel(cv2.CV_32FC1) == 1
    @test cv2.mat_channel(cv2.CV_32FC2) == 2
    @test cv2.mat_channel(cv2.CV_32FC3) == 3
    @test cv2.mat_channel(cv2.CV_32FC4) == 4

    @test cv2.mat_channel(cv2.CV_8UC1) == 1
    @test cv2.mat_channel(cv2.CV_8UC2) == 2
    @test cv2.mat_channel(cv2.CV_8UC3) == 3
    @test cv2.mat_channel(cv2.CV_8UC4) == 4
end

@testset "Matrix depth" begin
    for flags in [
            cv2.CV_32FC1,
            cv2.CV_32FC2,
            cv2.CV_32FC3,
            cv2.CV_32FC4
            ]
        @test cv2.mat_depth(flags) == cv2.CV_32F
    end

    for flags in [
            cv2.CV_8UC1,
            cv2.CV_8UC2,
            cv2.CV_8UC3,
            cv2.CV_8UC4
            ]
        @test cv2.mat_depth(flags) == cv2.CV_8U
    end
end

@testset "maketype" begin
    @test cv2.maketype(cv2.CV_8U, 1) == cv2.CV_8UC1
    @test cv2.maketype(cv2.CV_8U, 2) == cv2.CV_8UC2
    @test cv2.maketype(cv2.CV_8U, 3) == cv2.CV_8UC3
    @test cv2.maketype(cv2.CV_8U, 4) == cv2.CV_8UC4

    @test cv2.maketype(cv2.CV_32F, 1) == cv2.CV_32FC1
    @test cv2.maketype(cv2.CV_32F, 2) == cv2.CV_32FC2
    @test cv2.maketype(cv2.CV_32F, 3) == cv2.CV_32FC3
    @test cv2.maketype(cv2.CV_32F, 4) == cv2.CV_32FC4
end
