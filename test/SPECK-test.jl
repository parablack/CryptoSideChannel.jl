using CSC, Test
import CSC.HammingWeightLog
using StaticArrays

u(i) = convert(UInt64, i)
h(i) = HammingWeightLog(u(i))

@test CSC.SPECK.encrypt(SVector(u(0),u(0)), SVector(u(0),u(0)), 32) == (u(7375773579082960246), u(2346049177382750829))
@test CSC.SPECK.encrypt(SVector(u(0),u(1)), SVector(u(0),u(0)), 32) == (u(11942982297637201430), u(4129396787835963234))
@test CSC.SPECK.encrypt(SVector(u(0xBABE),u(0xCAFE)), SVector(u(0),u(0)), 32) == (12121182276052938422, 13524186897420644308)
@test CSC.SPECK.encrypt(SVector(h(0),h(0)),           SVector(h(0),h(0)), 32) == (h(7375773579082960246), h(2346049177382750829))
