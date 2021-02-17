using CSC.TemplateAttacks, Test

# Test simple template load (single byte)
function single_template_load(secret)
    template = random_uncorrelated_template(3, 256)
    attack_vectors = generate_attack_vectors(template, secret, fun = single_load_instruction)
    res = single_byte_template_attack(template, attack_vectors, fun = single_load_instruction)
    # 8 is probably reasonable
    flag = false
    for i = 1:8
        if res[i][2] == secret
            flag = true
        end
    end
    @test flag
end

function test_likely_key()
    mykey = LikelyKey([[1,2,3], [4, 5, 6], [7, 8, 9]])

    @test length(mykey) == 27
    for k = mykey
        @test k == [1, 4, 7]
        break
    end
end

function test_single_in_multi()
    @test true
end

function multi_template_load(threshold)
    size = 4
    template = random_uncorrelated_template(3, 256)
    secret = [0x4, 0x42, 0xCA, 0xFA] # rand(UInt8, size)
    attack_vectors = generate_attack_vectors(template, secret, fun = multi_load_instructions, N = 2^14)
    ## res = single_byte_template_attack(template, attack_vectors, fun = single_load_instruction)
    res = multi_byte_template_attack(template, attack_vectors, size, fun = multi_load_instructions, N = 2^14)
    display(res)
    ct = 1
    for k = res
        if k == secret
            break
        end
        ct += 1
        if ct > threshold
            @test false
        end
    end
    println("Found after $ct iterations")
    @test ct <= threshold
end

single_template_load(0)
single_template_load(42)
single_template_load(137)
test_likely_key()

multi_template_load(10000)