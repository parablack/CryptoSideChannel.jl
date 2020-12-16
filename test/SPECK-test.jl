using CSC, Test
import CSC.HammingWeightLog

@test CSC.SPECK.encrypt([0,0], [0,0], 32) == (7375773579082960246, 2346049177382750829)
@test CSC.SPECK.encrypt(convert(Array{UInt64}, [0,1]), [0,0], 32) == (11942982297637201430, 4129396787835963234)
@test CSC.SPECK.encrypt(convert(Array{UInt64}, [0xBABE,0xCAFE]), [0,0], 32) == (12121182276052938422, 13524186897420644308)
# @test CSC.SPECK.encrypt([0xBABE,0xCAFE], [0,0], 32) == (12121182276052938422, 13524186897420644308)
@test CSC.SPECK.encrypt([HammingWeightLog(0),HammingWeightLog(0)], [HammingWeightLog(0),HammingWeightLog(0)], 32) == (HammingWeightLog(convert(UInt64, 7375773579082960246)), HammingWeightLog(convert(UInt64, 2346049177382750829)))
