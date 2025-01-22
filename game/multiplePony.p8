pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
#include player.lua
#include net.lua
#include debug.lua
#include utils.lua
#include sprites.lua
#include countdown.lua
#include arrows.lua
#include lobby.lua
#include progress.lua
#include circles.lua
#include end.lua
#include main.lua

__gfx__
00000000000000000000000060000000000006666660000000000666666000000000000000006666600000000000000000000000000000000000000000000000
00000060000000000000000666000000000660000006600000066000000660006600000000000000000000000000000000000000000000000000000000000000
000006600000000000000066066000000060000000000600006000000000060000600000000000000000000000000000004499aaaaa9aa900000000000000000
0000666000000000000006600066000006000000000000600600000000000060000600000000000000000000000000059a9a9aaa9a9a9aa00000000000000000
0006606666666660000066000006600006006666666000600600600000600060000600000000000000000000000004aa9aaaaa9aa9aaaaa00000000000000000
00660000000000600006600000006600600000006600000660000600060000060000600000000000000000000559a99aa9aaaaa9aaaaa9a00000000000000000
06600000000000600066660000066660600000006000000660000060600000060000600000006666600000004aa9a9aaaaa949aaaaa9aa900000000000000000
6600000000000060000006000006000060000006000000066000000600000006000060000000000000000000a9aaaaa9a9444aaa9a9a9aa00000000000000000
0660000000000060000006000006000060000006000000066000000600000006000060000000000000000000aa9a9a9444445a9aa9aaaaa00000000000000000
0066000000000060000006000006000060000060000000066000006060000006000060000000000000000000aaaa444440000aa9aaa9aaa00000000000000000
00066066666666600000060000060000600006600000000660000600060000060000600000000000000000004444400000000aaa9aaa9aa00000000000000000
00006660000000000000060000060000060066666660006006006000006000600006000000000000000000000000000000000a9aa9aaaaa00000000000000000
000006600000000000000600000600000600000000000060060000000000006000060000000000000000000000000000000009a9aaa9aa900000000000000000
000000600000000000000600000600000060000000000600006000000000060000600000000000000000000000000000000009aaaaaa9a900000000000000000
00000000000000000000066666660000000660000006600000066000000660006600000000006666600000000000000000000aaa9aaa9a900000000000000000
00000000000000000000000000000000000006666660000000000666666000000000000000000000000000000000000000000aaaa9aaaa900000000000000000
000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000009a9aaa9a9900000000000000000
00000000000000000000000000000000000000000014500000000000000000000000000000000000000000000000000000000aaa9a9a9a400000000000000000
00000000000000000000000000000000000000000245000000005445500000000000014445000000005555000000000000000aaaaaaaaa500000000000000000
000000000000000000000000000010000000000152100000004aaaaa94400000000499aaaa9d000000aa9a0000000000000009aaaaa9a9400000000000000000
000000000000000000000000000d61000000000d420000000aa9a99aa9a400000009aaaa99aa4000009aa4100000000000000a9a9a9a9a400000000000000000
00000000000000000000000001ddd5115d100144500000004aaaaaa9aa9a0000004a9a9aaa9aad0005a9a5000000000000000a9aaaaaa9400000000000000000
00000000000000000000d100056052eeedd0144200000000a9aa9a9aaaaa500004aa9aa9aaaaa4d004aa94000000000000000aa9a9aaa4400000000000000000
00000000000000000000e20015505288ee2d644000000000aa9aa4444aa9900004a9a44449aaaa500aaa440000000000000009aaaaa9a4400000000000000000
00000000000000000000edd282d15288e846d500000000009aa94455559aa400da994445559a9a405a9a440000000000000009aa9a9a94400000000000000000
000000000000000e2001eee8226dd222dd94500020000000aaa44500055aa4504aa44410004aaa4059a94500000000000000049aa9aaa4500000000000000000
000000000000000ee22eeee8256766d51cd5200120000000a9a445000004444099a441000009a99059a9450000004444444449a9a9a9a4444444444000000000
00000000000000002eeeee82d6677777d1ccdddee00000009aa4500000004105aa940000000a9a904a9450000000a9aaaaaa99aaaaaaaa9aaaaaaa9000000000
0000000000000001dddede2d66777d55dd11122200000000aaa44000000000049aa40000000aaa45994450000000aaa9aa9a9aaa9aaa9aaaaa9aa95400000000
000000000000001cccdeee266777766d566d5d0000000000aaa440000000000aa9a000000009a945aa5400000000044444444444444444444444444400000000
0000000000111cccccdee2d66777ed6156776600000000004a9440000000000aaaa00000000a9a44aa4400000000000000000000000000000000000000000000
000000000011111cdee822666777ee11d6777d60000000005aa450000000000aaa900000000a9a4a994500000000000000000000000000000000000000000000
0000000000001ccded2e2d76677776777777776d0000000009a94000199999499aa00000000aa94aa44100000000000000000000000000000000000000000000
000000000005cccddde8d6766777777777776666d50000000aaa50000aaa9aa4a9a000000049a449a44000000000000000000000000000000000000000000000
00000000000ccc111ee2d77d677777777776d156771000000aaa400009a9a9a4aaa00000004a944a445000000000000000000000000000000000000000000000
00000000001c1111ee82677dd677777776dd66676600000005aa900004aaaaa59a900000009aa44a445000000000000000000000000000000000000000000000
00000000001d11cdee2d77665d6666666d00d67765000000004a950000044aa5aaa000000aa94459450000000000000000000000000000000000000000000000
000000000001dccee8267766d05dddd6d5001115dd0000000009a900000549a49aa0000004aa4455450000000000000000000000000000000000000000000000
00000000000dcc1ee2567767610005dd61000000000000000009a900000049a44a9000000a944004450000000000000000000000000000000000000000000000
000000000111cc12e2d677777d015111100000000000000000009a0000004a945aa500000aa54004400000000000000000000000000000000000000000000000
0000000005d1cc12e2d777777611d000000000000000000000004a4400004aa459a000004aa44000000000000000000000000000000000000000000000000000
00000000000111c182d7777677d1d0000000000000000000000009944444aaa45499000099440440000000000000000000000000000000000000000000000000
00000000000111c122d777767765d0000000000000000000000004a9a44aa9a454aa944aa44454ad000000000000000000000000000000000000000000000000
00000000000151cc12d77777776d50000000000000000000000000aaaaaaaa4454aa9aa9a44559a4000000000000000000000000000000000000000000000000
000000000001ddcc11d777776776d00000000000000000000000004a9aa994450059a9aaa4405a95000000000000000000000000000000000000000000000000
000000000000dd111567666777100000000000000000000000000005944444500004494445004445000000000000000000000000000000000000000000000000
00000000000dd111d677777655000000000000000000000000000000044445000005444440000440000000000000000000000000000000000000000000000000
000000000011101d77777dd000000000000000000000000000000000005450000000555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000045544a9a9aa9994455000000000000000000000049a9aa9aa9aaa94450000000000000000000000000000000000000000000000000000000000000
000000554a9aaaaa9aa9a9aaa9aaa94500000000000054999aaaaaa9a9aaaaaaaa9a995000000000000000000000000000000000000000000000000000000000
00000499aaaaa9aaa9aaaaa9aa9aaaaa440000000004a9aaaaa9aa99aaaa9aaa9aaaaa9940000000000000000000000000000000000000000000000000000000
0005a9aaaaa9aaa9aa9a9aaa9aaa9a9aa950000000a9aa9aa9aa9aaa9a9aaa9aaaaaa9a9aa000000000000000000000000000000000000000000000000000000
0099aaaa99aa9aa44444444aaaa9aaa9aaa00000099aaaaa9a9aa994444449a9a9a9a9aaaa000000000000000000000000000000000000000000000000000000
00aaaa9aaa9aa4544444444499aaa9aaaaa500000aaa9aa99aa9444444444459aa9aaa9a9a500000000000000000000000000000000000000000000000000000
009a9aa9aaaa544000000000599aaaaa9a99500049a9a9aaaaa44454000000159aaaaaaaa9a50000000000000000000000000000000000000000000000000000
0099a9aaa9a440000000000004aa9a9aa9944000aaaaaa9aaa545000000000005aaaa9a9aa450000000000000000000000000000000000000000000000000000
00004444444440000000000004aaa9aaaa4440000444444444450000000000004a9aaa9aaa450000000000000000000000000000000000000000000000000000
0000000000000000000000000a9aaaaa9a4410000044444444400000000000049aaaaaa9a9450000000000000000000000000000000000000000000000000000
0000000000000000000000549aaa9aaaa440000000000000000000000000004aaaaaa9aa95400000000000000000000000000000000000000000000000000000
00000000000000000004549aaaa9a994440000000000000000000000000009a9a9a9aaaa44500000000000000000000000000000000000000000000000000000
000000000000004aa9a9aaa9a9aa4444440000000000000000000000000599aa9a9aaa4444000000000000000000000000000000000000000000000000000000
0000000000000059a9aaaaaa44444445000000000000000000000000004a9a9aaaaa944455000000000000000000000000000000000000000000000000000000
000000000000001aaaaa9a9a994455500000000000000000000000004aa9aaaaaaa4444500000000000000000000000000000000000000000000000000000000
000000000000001a9aa9a9aaa9a9a445000000000000000000000059a9aaaaa9a944455000000000000000000000000000000000000000000000000000000000
000000000000000555544499a9aaaaaa5000000000000000000004a9aaaa99a94445500000000000000000000000000000000000000000000000000000000000
0000000000000000000000000aa99aa9a900000000000000049a9aaa9aa994445500000000000000000000000000000000000000000000000000000000000000
00000000000000000000000004aaa9aaaa000000000000004aaaaaaaa94544510000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000049aaaaa9a50000000000004aaa9aa99444440000000000000000000000000000000000000000000000000000000000000000000
000044a9aaa940000000000009aaaa9aa94000000000000aa9aa9aa4444500000000000000000000000000000000000000000000000000000000000000000000
00005aaaa9aa9500000000000aa99aa9a55000000000049aaa9aa994450000000000000000000000000000000000000000000000000000000000000000000000
0000009a9a9aaa500000000499aaa9aa4400000000005aa99aaaa945500000000000000000000000000000000000000000000000000000000000000000000000
00000049aaaaa9a500000049aa9aaaa9440000000000a9aaaaa9a401555555555555555000000000000000000000000000000000000000000000000000000000
0000000599a9aa99aa994aaa9aaa9a44400000000000aaaaaaaa9aaa9a9aaa9aaaaaa9a000000000000000000000000000000000000000000000000000000000
0000000059aa9aaaaa9aa99aaaa99444500000000000aaaa9a9aa9aaaaa9aaa9a9a9aa9440000000000000000000000000000000000000000000000000000000
00000000049aaaaa9aa9aaaaa9aa44450000000000009aa9a9aaaaa9a9aaa9aaaa9aaa4400000000000000000000000000000000000000000000000000000000
00000000000444444415144444441000000000000000044444444444444444444444444000000000000000000000000000000000000000000000000000000000
00000000000000004444444000000000000000000000004444444444444444444444444000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000000
00889988000000000088998800000000008899880000000000889988000000000088998800000000008899880000000000889988000000000088998800000000
0899aa99800000000899aa99800000000899aa99800000000899aa99800000000899aa99800000000899aa99800000000899aa99800000000899aa9980000000
89aabbaa9800000089aabbaa9800000089aabbaa9800000089aabbaa9800000089aabbaa9800000089aabbaa9800000089aabbaa9800000089aabbaa98000000
9abbeebba98800889abbeebba98800889abbeebba98800889abbeebba98800889abbeebba98800889abbeebba98800889abbeebba98800889abbeebba9880088
abeecceeba998899abeecceeba998899abeecceeba998899abeecceeba998899abeecceeba998899abeecceeba998899abeecceeba998899abeecceeba998899
becc11ccebaa99aabecc11ccebaa99aabecc11ccebaa99aabecc11ccebaa99aabecc11ccebaa99aabecc11ccebaa99aabecc11ccebaa99aabecc11ccebaa99aa
ec112211cebbaabbec112211cebbaabbec112211cebbaabbec112211cebbaabbec112211cebbaabbec112211cebbaabbec112211cebbaabbec112211cebbaabb
c12200221ceebbeec12200221ceebbeec12200221ceebbeec12200221ceebbeec12200221ceebbeec12200221ceebbeec12200221ceebbeec12200221ceebbee
1200000021cceecc1200000021cceecc1200000021cceecc1200000021cceecc1200000021cceecc1200000021cceecc1200000021cceecc1200000021cceecc
200000000211cc11200000000211cc11200000000211cc11200000000211cc11200000000211cc11200000000211cc11200000000211cc11200000000211cc11
00000000002211220000000000221122000000000022112200000000002211220000000000221122000000000022112200000000002211220000000000221122
00000000000022000000000000002200000000000000220000000000000022000000000000002200000000000000220000000000000022000000000000002200
__map__
1515151515151515151515151515151716001616001616000016161616161616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151516001616001616000016161616161616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151516001616001616000016160000000016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151516001616001616000016160000000016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151516001616001616000000000000000016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151516001616001616000016160000000016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151516001616001616000016161616161616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151516001616001616000016161616161616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151516001616000000001616161616161616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151516001616001616001616161616161616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151516001616161616001616161616161616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151516001616161616001616161616161616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141416000000000000001616161616161616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141416161616161616161616161616161616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
