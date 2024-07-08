// RUN: byteir-opt %s -affine-opt | FileCheck %s

// CHECK-LABEL: func.func @forward

#map = affine_map<() -> ()>
module attributes {torch.debug_module_name = "GraphModule"} {
  memref.global "private" constant @__constant_20x10xf32 : memref<20x10xf32> = dense<"0xEDAEFD3D2456463E409C203E725C76BE7D51683ED8D783BEA67B8F3E85C231BE4225383D620472BE6B88963EA8E7983EA0BE27BCCA748B3E7ADA4B3E562D9ABEB62B78BEEB7CF33B967059BD67FB97BE1051E33DCE3D9EBCA3380BBED59EA23DDA6EDD3D2B60943E0D424E3DF5FF363DC197B8BDFBAE8CBDFC7732BE690042BEC03C5A3E63F6103E2DFDF1BD88C91ABE5EBB7F3D32DCDBBD4FA407BEF08F553E055CEE3CF0D34CBD2775633D2F3527BEC9A5D5BDB2DC513E056098BEFBFED83D5C0C17BEFAB77D3E07F9413E5AFCAB3D62069C3E354722BE948E7E3E136825BEC5F011BDB640623D0F16953EFCC7D3BC080B9CBECC1AF13D0DF3963DCE329DBECFCE7FBEBB0DBD3DCB26033E66E5EA3D9884E7BC76249D3E9B2F4ABE8E3CF43B259F883E39E496BE6E9E813D8E26E7BD1656DD3C785D2B3E2E6CF6BDA2C404BE5608BD3B0BF2583E7AAD743E46C71CBD85DBE43BF4464EBD60B90DBE4E7470BEAF01453E937B9B3EF8E6DFBDC82B583DEB5AC8BDC849E83D6543143DD9E68E3E7EFF583D651C673EB6F466BE14197E3D507F46BE658D653C4B210F3E8BD2ADBD379970BE5B5115BEE9C118BDDC57473E37968ABE30212D3EC61183BE79C131BECE1F303E2596A73DA80F16BE3FCF123EDDF5673E601A24BE5BC056BE262F63BDACE23ABE9AEF24BD3D4983BDF2DA0ABED17C18BD1E194FBE451A58BDCF5FFABDCBD28E3E7899D1BDF010903E85B4B03DA3A3F63DD46BA03D05E9193E2CACBF3D8E0C32BE38AA14BED9AC493DF72C993E824129BE46DBAF3D3D993FBE752989BD0F403B3DC71E153D121C05BC9EFC60BCACC7103D7537DE3DAFB6D83CEB4013BD868FF1BCB8624CBE26EDA43B96F24B3E8D148E3EE3E5983E46EB73BE6FD39D3E779721BE26A9693E89B98ABE971808BE808C9ABE53E9E9BDD80AEA3D10EE7D3EBB39213D988D4B3D953B2B3EB17CC43C13D72E3DB1C184BDA6A2823D407141BEBE27AA3A2BE0453EFD30F0BDDB132B3E8B44CB3BEDAF77BE5012703ECC23743E08D786BE714361BE1F534B3ECE3C41BE835CD4BD097461BDB09383BEA24E5BBE826D35BE36B4AB3C2314AABC4D2E963D97023EBD0A3B753E426F4FBD8461313C">
  memref.global "private" constant @__constant_20xf32_0 : memref<20xf32> = dense<[0.101879634, -0.178835288, -0.0953023583, -0.0698504745, -0.19658649, -0.297641844, -0.223349303, 0.168986112, 9.007710e-02, 0.101534814, -0.0601868108, -0.0958566219, -0.243612081, 0.198881537, -0.293788224, -0.240900397, 0.184188008, 0.210917979, 0.121171109, -0.155078679]>
  memref.global "private" constant @__constant_20x20xf32 : memref<20x20xf32> = dense<"0x32A148BE6D99D1BD3C565A3E614360BC1E9BDF3B265A9D3DBD5F18BE8FE25B3EC201E4BC085E783CA941FFBDD2D3953D6BA636BCD3A570BDBF6DFBBD50263FBE6514C1BCC2C95FBEFCD7B43DE477DBBC93869BBDBEED34BD62E5843DC40D4F3EFF38F73C45B35D3EDE0A0EBECC6652BE35B79BBD9044093DF13E123EC271633D17C3273E3C32473E5F161E3C52262FBE1F9E173EA30B07BE3C7D24BE674E2CBEDF0E313EA2CFA0BCA45CAF3C5A313E3EC33C35BD112654BBEDE673BD20FF4CBE09665BBE916844BE4C305C3E6BF8053DBE032E3E614DAD3AB941F3BD207BA93DA59780BD15F2E4BDCE26BD3DD5E3593DADAE1EBDBFCE46BE41EC6DBB34D6FDBD40D157BE8BEEB6BD23F447BED78823BD2F2FC8BD162F39BE5C838CBDA6DFECBD34F4173C6978643EF40BB2BD661E823D511514BD611C4BBE48BF20BEBCCB2FBE5C52443E85B19BBCE2019E3D9C3519BEDD478A3CBD70993DB37F3BBE32E5003EBEFA293E955128BEF44A6EBD5728953D54B10A3EC49A543E4C2E6ABDEC4B56BE9AB8F4BD4FEF053CF7F0D7BBD7D1303E3506E7BB4D7659BE1D3A013E72500C3DD1E6373E7DDE62BE052B503E392A323D668CEDBDB6F210BD2A505EBEB72E1DBD9452EB3D02AA16BE3B33963D58CF3A3E339719BEC73E013E421F193EA9753FBEF2CFB3BD398863BE42C74CBE1B39AABD436BEEBDDB8017BE5683343EE1BAA13D0F397ABDA4C90BBDF0BFA83A2B345DBD82FDD33DDFDE243D7B3507BE913828BEB72639BE9DF7B5BD85BA77BD017FC43D4CF5A13DC7A3DD3D4E3CE63D9B2983BD04BE2E3EE2AC4FBE13D6283EFB3A9BBDC1675D3ECD44643E8BC9E03D7053E83C005014BE7ADBE9BD3344553ED66E42BE38C9D73CED4160BECAE272BAA94A9B3DBC209B3D590C1ABE734E60BE110010BDBD5F2B3D9F8E213EC693A03D9FF356BDC0F1E03D511B3DBED0DA303DE305B1BD578D51BDE1224FBED50454BD57F2B2BDB5062F3E917CFDBDB0FD9CBDE74A0E3E697E213D4A942DBE530B01BEAFAD27BC1D7813BE592C1B3E751BB5BD3C4FE13D164A5FBD8941593E64522C3EF2F3013EF3E116BE6C6826BE689A233EFFB9503E895743BD7FC9523E487E3FBE2FFC273E4A14543D9EB929BECD1844BEEAFFB5BD0EF101BE809B3DBEF94F243EFDFA51BDAA43353C30FEC73C58A96FBD0DE876BD4EDE0F3E5EC4083E263939BEE2FD4A3E413055BE0A8B643EBBF9603DA596B2BDAB303B3E6A0D20BEEC38BE3C4A82103D0369A1BD7DF30B3E5014C23CB60E2C3E19AC2FBEBEC5D73D7211593E8F1098BD47BF58BE7B00783D1D60D1BB2F23A43C423D12BCC300013E8B5E24BED8554A3CB6C1FA3B941C90BD19E862BE8E7AD13C8FF8D93DD463133D003410BEBEE61D3E1A2E90BC8FF2A2BDC3BEA6BC7232E23DC35E793D9E975C3E4E3959BE542B493E402404BE966686BD27A9C33D703E19BE3524DBBC097A76BCFC6F0DBED2693FBE829D3A3E672DEB3DEBBD613EC5EFDA3D3881E6BDCB4F4B3E14EF8ABD4CDE0C3D7195303EEF3A1FBD0BAF203CE2CA34BEB4A8463ED0DC1ABE95A2063E04CF7BBDE1C81ABE0640443EE58D4F3D3E6125BE85CB2EBCEB5A44BECADD55BEE721A0BDC3EA5EBE4F6DC2BBFE5949BEAF43A93DD3A822BEC7AD1DBD719EC8BD2966513E4EA9F0BD05B535BE6DD0BC3D9155863D9DDF51BEAE5B30BE03A7AA3D03FD743D6A2B023EFFA2B03C56C2C3BD13E8F3BC550D21BE2249463E43880FBE1A34DE3DA331963ACB200EBD48F3273EBB4B1FBD57EA383CCD8A573EA359173E65FA1EBEBF11173E723C573E1DCF543C3B3825BEEF8C273E894A33BE8922313D0C34F5BDB6B3023E35888ABC46CE16BDFB1247BD9CF9403EE55E993DFB4B103D391127BE2432453C475E283DDA01A5BD144C573EFFDA4C3EC0EE403E756D503EB7FCD53DB6F3C2BD8A2935BEA41CF7BD3E911D3E1E97B0BD80299C3D097B633D569B3F3E1FD32DBD734D97BC7943B0BDC942A7BD9611263ECECB5EBD505B97BD709798BB6E8A2DBE0F2024BE81D23BBECCDA58BE27F955BD93A6223E0CF8D5BDFD7F38BD500C6DBD70BAFEBD7775193E09619BBD4EFCBB3D4C6E543EA66038BE196DD9BDD58B283EFDE8B13DDEE6713DF860CA3CF9F5013E3D24D53DE0D914BE2B3A4CBEAE3B4ABCE10741BE13AA29BE3C54933D9577BB3D40F617BEB7E90F3E54502A3EB47251BD762EE83DC91500BE8AC012BD6313C13D367E3EBE5283B43DC63F44BE">
  memref.global "private" constant @__constant_20xf32 : memref<20xf32> = dense<[0.124238588, -0.0375917405, -0.178324029, 2.1018261E-4, -0.0708629936, 0.179958493, 0.201986402, -0.0302014686, -0.0842267424, 0.0796111747, 0.0201944318, -0.183529228, -0.133614406, -0.0192934573, 0.193412527, 0.219010666, -0.0464102961, 0.00334274326, -0.0029087835, 0.0903228372]>
  memref.global "private" constant @__constant_10x20xf32 : memref<10x20xf32> = dense<"0xD60ED23DDEFF3B3DFBC1653B7AFAC43DAB54263EDA0774BD602A03BE747C53BEC754B93D306D813DBFD7253E96216E3CEA885CBCB90511BEA1F012BEDCF4F23DAC1B29BD128D2ABD6024AD3D838E9CBD6677593E5270AF3D77D0473E933CF8BDC31061BE37FD1E3D522F3FBEC1814A3EC9CB88BCE33C16BECFBD0D3E0351123E19FFD9BD36A5443ED3483E3EA4D8C3BDDEB4CD3D46CA34BD0D0EE9BDA171FA3DEDD4253D461635BC7920B43CFE637BBDF81913BE1EB44BBE9C1DDC3DA77B363EB5D84DBE39B00EBEDC6CD83D034807BE8B68F83C86AA713CB3F664BE4877DFBC6C5006BEDDA5BABDBD5A80BCDCED3EBE579F523E07D5B8BD2135C43C21BE53BE3E001C3E38E409BE486F1EBE551E113EF14E443E946CD7BDA6EA563D0929E7BD6FE3B5BC3698A3BCEB093DBE1B13303B61B08FBCE0C404BD7FA6E83D9FEDA6BD952583BDB82761BE1780C2BBADCA233E4D7A0E3E994A1FBEB99D21BE65E5673DD54E1EBEB97CC9BD9238C53CD3E3453DC302633EB129A93DEF2FB7BC60330D3E5AD9DA3B533F223D400BFBBDAD78A8BD454F62BE33120CBED145D43C250529BDE4CE4EBE74FFDB3DE05813BE0EDAC4BD659C343E08A411BD1405B2BDCD388B3D736E193E517218BE3243F6BCCA5569BD80340EBE3072B4BD616438BED19702BD2C2AB53D692C35BC15B1203D4576FABD2119CFBDBB05A93D074943BEC9732E3D349F62BEC933103E4948D83C68C034BCD8D1503EA7BB51BE2EFA283E97A090BD933AD83D7D7C413E34CBC73D18B3043E827CF4BDDB70183EAAD3623C2B7B84BCC6B6123E29209A3D4233E33CD45C3C3EF5BBD73DDE725FBE0A72B03DE7650E3EBEB64B3ECA19393EB41EF5BD3A5E9C3D6334E93CB831DABD4769D73D39CF873C7F4D41BDED6F4D3E9A1808BECCB48FBCB3CA01BE756B01BD32BBFA3D1BCB113E1042FDBDF3C1553DEC8AD93D41C70D3EE0263C3E8948043EF16A573D3565B63DE5F18EBD3359BBBB4E295EBE46E602BC15896C3D271EAD3DCF144D3E84B3D6BDB506BF3DEAA162BD81F31ABE9DD61DBDBFDD4EBD830E3B3CD04F3A3E392C32BEAC4E223D5DE08BBD19E6E83DE54F6BBDCC3D73BD0A69993DECBE843CD0CBC33D">
  memref.global "private" constant @__constant_10xf32 : memref<10xf32> = dense<[0.0670170113, 0.0825609341, -0.125343189, -0.0073415176, -0.100303039, -0.214000896, 0.114002995, 0.21737574, 0.166609675, -0.119800359]>
  func.func private @Unknown0(%arg0: memref<20xf32>, %arg1: memref<2x20xf32>) -> memref<2x20xf32> attributes {__byteir_elementwise_fusion__} {
    %cst = arith.constant 0.000000e+00 : f32
    %c0 = arith.constant 0 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %c20 = arith.constant 20 : index
    %alloc = memref.alloc() : memref<2x20xf32>
    scf.for %arg2 = %c0 to %c2 step %c1 {
      scf.for %arg3 = %c0 to %c20 step %c1 {
        %subview = memref.subview %arg0[%arg3] [1] [1] : memref<20xf32> to memref<f32, strided<[], offset: ?>>
        %subview_0 = memref.subview %alloc[%arg2, %arg3] [1, 1] [1, 1] : memref<2x20xf32> to memref<f32, strided<[], offset: ?>>
        %subview_1 = memref.subview %arg1[%arg2, %arg3] [1, 1] [1, 1] : memref<2x20xf32> to memref<f32, strided<[], offset: ?>>
        linalg.generic {indexing_maps = [#map, #map, #map], iterator_types = []} ins(%subview, %subview_1 : memref<f32, strided<[], offset: ?>>, memref<f32, strided<[], offset: ?>>) outs(%subview_0 : memref<f32, strided<[], offset: ?>>) {
        ^bb0(%in: f32, %in_2: f32, %out: f32):
          %0 = arith.addf %in_2, %in : f32
          %1 = arith.maximumf %0, %cst : f32
          linalg.yield %1 : f32
        }
      }
    }
    return %alloc : memref<2x20xf32>
  }
  func.func private @Unknown2(%arg0: memref<10xf32>, %arg1: memref<2x10xf32>) -> memref<2x10xf32> attributes {__byteir_elementwise_fusion__} {
    %c0 = arith.constant 0 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %c10 = arith.constant 10 : index
    %alloc = memref.alloc() : memref<2x10xf32>
    scf.for %arg2 = %c0 to %c2 step %c1 {
      scf.for %arg3 = %c0 to %c10 step %c1 {
        %subview = memref.subview %arg0[%arg3] [1] [1] : memref<10xf32> to memref<f32, strided<[], offset: ?>>
        %subview_0 = memref.subview %alloc[%arg2, %arg3] [1, 1] [1, 1] : memref<2x10xf32> to memref<f32, strided<[], offset: ?>>
        %subview_1 = memref.subview %arg1[%arg2, %arg3] [1, 1] [1, 1] : memref<2x10xf32> to memref<f32, strided<[], offset: ?>>
        linalg.generic {indexing_maps = [#map, #map, #map], iterator_types = []} ins(%subview, %subview_1 : memref<f32, strided<[], offset: ?>>, memref<f32, strided<[], offset: ?>>) outs(%subview_0 : memref<f32, strided<[], offset: ?>>) {
        ^bb0(%in: f32, %in_2: f32, %out: f32):
          %0 = arith.addf %in_2, %in : f32
          linalg.yield %0 : f32
        }
      }
    }
    return %alloc : memref<2x10xf32>
  }
  func.func @forward(%arg0: memref<2x10xf32>) -> memref<2x10xf32> attributes {__placeholder__byre.entry_point} {
    %0 = memref.get_global @__constant_10xf32 : memref<10xf32>
    %1 = memref.get_global @__constant_10x20xf32 : memref<10x20xf32>
    %2 = memref.get_global @__constant_20xf32 : memref<20xf32>
    %3 = memref.get_global @__constant_20x20xf32 : memref<20x20xf32>
    %4 = memref.get_global @__constant_20xf32_0 : memref<20xf32>
    %5 = memref.get_global @__constant_20x10xf32 : memref<20x10xf32>
    %alloc = memref.alloc() : memref<2x20xf32>
    byre.compute @MatmulOp_f32f32_f32(%arg0, %5, %alloc) {lhs_contracting_dimension = 1 : i64, memory_effects = [1 : i32, 1 : i32, 2 : i32], rhs_contracting_dimension = 1 : i64} : memref<2x10xf32>, memref<20x10xf32>, memref<2x20xf32>
    %6 = call @Unknown0(%4, %alloc) : (memref<20xf32>, memref<2x20xf32>) -> memref<2x20xf32>
    %alloc_0 = memref.alloc() : memref<2x20xf32>
    byre.compute @MatmulOp_f32f32_f32(%6, %3, %alloc_0) {lhs_contracting_dimension = 1 : i64, memory_effects = [1 : i32, 1 : i32, 2 : i32], rhs_contracting_dimension = 1 : i64} : memref<2x20xf32>, memref<20x20xf32>, memref<2x20xf32>
    %7 = call @Unknown0(%2, %alloc_0) : (memref<20xf32>, memref<2x20xf32>) -> memref<2x20xf32>
    %alloc_1 = memref.alloc() : memref<2x10xf32>
    byre.compute @MatmulOp_f32f32_f32(%7, %1, %alloc_1) {lhs_contracting_dimension = 1 : i64, memory_effects = [1 : i32, 1 : i32, 2 : i32], rhs_contracting_dimension = 1 : i64} : memref<2x20xf32>, memref<10x20xf32>, memref<2x10xf32>
    %8 = call @Unknown2(%0, %alloc_1) : (memref<10xf32>, memref<2x10xf32>) -> memref<2x10xf32>
    return %8 : memref<2x10xf32>
  }
}