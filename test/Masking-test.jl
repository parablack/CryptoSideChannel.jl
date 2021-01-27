using Test, StaticArrays, Random, CSC.Masking

TEST_VECTOR = [0,1,2,3,4,13,255,1337,2^31-1, 2^32, -1, -2, -10, -100, -1337, -2^32, 0x0, 0xAB, 0xFF, 0xCAFE, 0xFFFF]
TEST_VECTOR_SMALL = [0,1,5,255,2^32, -1, -3, 0xAB, 0xCA]

for i = TEST_VECTOR
    val1 = Masking.BooleanMask(i);
    @test Masking.unmask(Masking.booleanToArithmetic(val1)) == i

    val2 = Masking.ArithmeticMask(i);
    @test Masking.unmask(Masking.arithmeticToBoolean(val2)) == i
end

for i = TEST_VECTOR
    for j = TEST_VECTOR
        for op = [xor, |, &, +, -]
            val1 = Masking.BooleanMask(i);
            val2 = Masking.BooleanMask(j);

            @test Masking.unmask(op(val1, j)) == op(i, j)
            @test Masking.unmask(op(i, val2)) == op(i, j)

            val1 = Masking.ArithmeticMask(i);
            val2 = Masking.ArithmeticMask(j);
            @test Masking.unmask(op(val1, j)) == op(i, j)
            @test Masking.unmask(op(i, val2)) == op(i, j)
        end
    end
end
for i = TEST_VECTOR
    for j = (0:32)
        for op = [>>>, <<, Base.bitrotate]
            val1 = Masking.BooleanMask(i);
            val2 = Masking.ArithmeticMask(i);

            @test Masking.unmask(op(val1, j)) == op(i, j)
            @test Masking.unmask(op(val2, j)) == op(i, j)
        end
    end
end

for i = TEST_VECTOR_SMALL
    for j = TEST_VECTOR_SMALL
        for k = TEST_VECTOR_SMALL
            for op1 = [xor, +, -]
                for op2 = [xor, +, -]
                    val1 = Masking.BooleanMask(i);
                    val2 = Masking.BooleanMask(j);
                    val3 = Masking.BooleanMask(k);
                    masres = op1(val1, op2(val2, val3));
                    refres = op1(i, op2(j, k))
                    @test Masking.unmask(masres) == refres
                end
            end
        end
    end
end