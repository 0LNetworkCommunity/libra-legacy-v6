///////////////////////////////////////////////////////////////////
// 0L Module
// Globals
// Error code: 0710
///////////////////////////////////////////////////////////////////

address 0x1 {

/// # Summary 
/// This module is used to record migrations from old versions of stdlib to new 
/// versions when a breaking change is introduced (e.g. a resource is altered)
/// The code for the actual migrations is instantiated in seperate modules. 
/// When running a migration, one must: 
/// 1. check it has not been run using the `has_run` function 
/// 2. run the migration 
/// 3. record that the migration has run using the `push` function
module Migrations {
  use 0x1::Vector;
  use 0x1::CoreAddresses;
  use 0x1::Option::{Self,Option};

  /// A list of Migrations that have been 
  /// Note: Used ids are (add to this list when needed): 1, 10, 11, ...
  struct Migrations has key {
    list: vector<Job>
  }

  /// A specific Migration (e.g. altering a struct)
  /// `uid` is a unique identifier for the migration, selected by the vm 
  /// `name` is for reference purposes only and is not used by the module 
  /// to distinguish between migrations
  struct Job has copy, drop, store {
    uid: u64,
    name: vector<u8>, // experiment with using text labels
  }

  /// initialize the Migrations structure
  public fun init(vm: &signer){
    CoreAddresses::assert_diem_root(vm);
    if (!exists<Migrations>(@0x0)) {
      move_to<Migrations>(vm, Migrations {
        list: Vector::empty<Job>(),
      })
    }
  }

  /// Returns true if a migration has been added to the Migrations list
  public fun has_run(uid: u64): bool acquires Migrations {
    let opt_job = find(uid);
    if (Option::is_some<Job>(&opt_job)) {
      true
    }
    else {
      false
    }
  }

  /// Adds a job to the migrations list if it has not been added already
  /// Only the vm can add a job to this list in order to prevent others from 
  /// preventing a migration by inserting the migration's UID to this list 
  /// before it occurs
  public fun push(vm: &signer, uid: u64, text: vector<u8>) acquires Migrations {   
    CoreAddresses::assert_diem_root(vm);
    if (has_run(uid)) return;
    let s = borrow_global_mut<Migrations>(@0x0);
    let j = Job {
      uid: uid,
      name: text,
    };

    Vector::push_back<Job>(&mut s.list, j);
  }

  /// Searches for a job within the Migrations list, returns `some` if 
  /// is found, returns `none` otherwise
  fun find(uid: u64): Option<Job> acquires Migrations {
    let job_list = &borrow_global<Migrations>(@0x0).list;
    let len = Vector::length(job_list);
    let i = 0;
    while (i < len) {
      let j = *Vector::borrow<Job>(job_list, i);
      if (j.uid == uid) {
        return Option::some<Job>(j)
      };
      i = i + 1;
    };
    Option::none<Job>()
  }
}

/// # Summary 
/// Module to make whole underpaid Carpe users
module MigrateMakeWhole{
  use 0x1::Migrations;
  use 0x1::DiemAccount;
  use 0x1::Vector;
  use 0x1::CoreAddresses;
  use 0x1::GAS::GAS;
  use 0x1::Diem;

  const UID:u64 = 11;
  

  // I've split this into two pieces to ease testing. 
  public fun migrate_make_whole(vm: &signer){
    CoreAddresses::assert_diem_root(vm);
    if (!Migrations::has_run(UID)) {
      let payees: vector<address> = Vector::empty<address>();
      let amounts: vector<u64> = Vector::empty<u64>();

      // This can be done more easily in more recent version of move, but it seems 0L currently does not support them. 
      Vector::push_back<address>(&mut payees, @0xb94b8aa1b69a47802f8d66a7a33affef);
      Vector::push_back<u64>(&mut amounts, 82556298);
      
      Vector::push_back<address>(&mut payees, @0x613b6d9599f72134a4fa20bba4c75c36);
      Vector::push_back<u64>(&mut amounts, 82556298);
      
      Vector::push_back<address>(&mut payees, @0x7b2eb58b8589a6c36da57c5875b12b0b);
      Vector::push_back<u64>(&mut amounts, 1371514396);
      
      Vector::push_back<address>(&mut payees, @0x1bea7d44bc9d2fa151a393319ab75530);
      Vector::push_back<u64>(&mut amounts, 276520612);
      
      Vector::push_back<address>(&mut payees, @0x5a82287240450b7cc4ba9e09e74a2bd5);
      Vector::push_back<u64>(&mut amounts, 227110545);
      
      Vector::push_back<address>(&mut payees, @0x74745f89883134d270d0a57c6c854b4b);
      Vector::push_back<u64>(&mut amounts, 4040616894);
      
      Vector::push_back<address>(&mut payees, @0x83d389e87414849de5e483dd94ec2f28);
      Vector::push_back<u64>(&mut amounts, 1578127603);
      
      Vector::push_back<address>(&mut payees, @0x53726a2d4ad271f5ee955703ee099d1c);
      Vector::push_back<u64>(&mut amounts, 1564126574);
      
      Vector::push_back<address>(&mut payees, @0xd876c3c28ad5d1a20b23796bf968a422);
      Vector::push_back<u64>(&mut amounts, 1583569238);
      
      Vector::push_back<address>(&mut payees, @0x3c54f7b1c106065ea89623585d1297c7);
      Vector::push_back<u64>(&mut amounts, 1585759812);
      
      Vector::push_back<address>(&mut payees, @0xb3b70da983ec63d88cc53abd266591f8);
      Vector::push_back<u64>(&mut amounts, 1584851882);
      
      Vector::push_back<address>(&mut payees, @0xdc47fbac49a0c711de1b90a68e795d5d);
      Vector::push_back<u64>(&mut amounts, 1598316236);
      
      Vector::push_back<address>(&mut payees, @0xde71bdcfef072856c165f711d4bb327c);
      Vector::push_back<u64>(&mut amounts, 1613010485);
      
      Vector::push_back<address>(&mut payees, @0x5b35607b309843a0099b5b7b5216d360);
      Vector::push_back<u64>(&mut amounts, 1581401500);
      
      Vector::push_back<address>(&mut payees, @0x07d114f33659da59700423a0dad6ce7b);
      Vector::push_back<u64>(&mut amounts, 1595559927);
      
      Vector::push_back<address>(&mut payees, @0x7282cbc15b49127bd207ad4c19c12bfb);
      Vector::push_back<u64>(&mut amounts, 1592248054);
      
      Vector::push_back<address>(&mut payees, @0x9c522bd75cc7a1f6803e98de96284169);
      Vector::push_back<u64>(&mut amounts, 1605714089);
      
      Vector::push_back<address>(&mut payees, @0xcb7a218ebc69ef139b733d83775cf66f);
      Vector::push_back<u64>(&mut amounts, 1623541574);
      
      Vector::push_back<address>(&mut payees, @0x3bae220b259ee2bfd33d844f2a223a47);
      Vector::push_back<u64>(&mut amounts, 1631911935);
      
      Vector::push_back<address>(&mut payees, @0x41c497685d313414e98af14f0543484f);
      Vector::push_back<u64>(&mut amounts, 1618805908);
      
      Vector::push_back<address>(&mut payees, @0xb1cc93b8faecc6c3ba52239eb3452b96);
      Vector::push_back<u64>(&mut amounts, 1596674394);
      
      Vector::push_back<address>(&mut payees, @0x543b4fb6b12092e088e6db90573c6d96);
      Vector::push_back<u64>(&mut amounts, 1596495463);
      
      Vector::push_back<address>(&mut payees, @0x7daae7f9ba449820756b4e207ec33006);
      Vector::push_back<u64>(&mut amounts, 1596537400);
      
      Vector::push_back<address>(&mut payees, @0x2749ee9566399c97828f6e3e83496d66);
      Vector::push_back<u64>(&mut amounts, 1568151632);
      
      Vector::push_back<address>(&mut payees, @0x1bc321f8d224223514cd12afd3ebebcb);
      Vector::push_back<u64>(&mut amounts, 1560574026);
      
      Vector::push_back<address>(&mut payees, @0xad50e8b6c9236b9c4d186797f0ccf5f2);
      Vector::push_back<u64>(&mut amounts, 1611220767);
      
      Vector::push_back<address>(&mut payees, @0xbe0335fcc3113205b3b0ec67711398a3);
      Vector::push_back<u64>(&mut amounts, 1592834251);
      
      Vector::push_back<address>(&mut payees, @0x662114fcbcd16bfb3fce559b5458ee74);
      Vector::push_back<u64>(&mut amounts, 1288653087);
      
      Vector::push_back<address>(&mut payees, @0xf538b64ba66555ba50617fd2ed04153a);
      Vector::push_back<u64>(&mut amounts, 1308556650);
      
      Vector::push_back<address>(&mut payees, @0x5f54a85b86d672edc807946d0eacde7f);
      Vector::push_back<u64>(&mut amounts, 2125426582);
      
      Vector::push_back<address>(&mut payees, @0xa7d8272554725d6d1de6eb089f5e6e9a);
      Vector::push_back<u64>(&mut amounts, 2128176382);
      
      Vector::push_back<address>(&mut payees, @0x240905dd3b6b90d2bc90fafc63c5d198);
      Vector::push_back<u64>(&mut amounts, 1587040399);
      
      Vector::push_back<address>(&mut payees, @0x6374bbc81eddd9533739c439b9ffed0c);
      Vector::push_back<u64>(&mut amounts, 1576757646);
      
      Vector::push_back<address>(&mut payees, @0xc22e383ab15a8f9e4084ac9230bc6936);
      Vector::push_back<u64>(&mut amounts, 2839071935);
      
      Vector::push_back<address>(&mut payees, @0xc464c2be4a6f5b4bd28413699f6d527f);
      Vector::push_back<u64>(&mut amounts, 2936102992);
      
      Vector::push_back<address>(&mut payees, @0x47195a81bf1f66324d3edae1564eb802);
      Vector::push_back<u64>(&mut amounts, 2349468270);
      
      Vector::push_back<address>(&mut payees, @0xab6a140582085c2a4acfd1595e1686cb);
      Vector::push_back<u64>(&mut amounts, 2357824383);
      
      Vector::push_back<address>(&mut payees, @0x9eacae16e4d9f406fda87b1ec021f9ff);
      Vector::push_back<u64>(&mut amounts, 2339630529);
      
      Vector::push_back<address>(&mut payees, @0xe2513703e5df0d2fd8b05654158dbda7);
      Vector::push_back<u64>(&mut amounts, 2138398408);
      
      Vector::push_back<address>(&mut payees, @0xa96e427180d93854e9a41ec9820dcba6);
      Vector::push_back<u64>(&mut amounts, 2172354199);
      
      Vector::push_back<address>(&mut payees, @0x3c639971cab4aaa59d499145e3ab1535);
      Vector::push_back<u64>(&mut amounts, 2249533309);
      
      Vector::push_back<address>(&mut payees, @0x12ad8e25d6d24502167aa7ba664c0ddf);
      Vector::push_back<u64>(&mut amounts, 2202928677);
      
      Vector::push_back<address>(&mut payees, @0x328dff341a2a3a272172c4ac445c4b71);
      Vector::push_back<u64>(&mut amounts, 2133790719);
      
      Vector::push_back<address>(&mut payees, @0xaefefac2767e39cbad4d0ab32adff58f);
      Vector::push_back<u64>(&mut amounts, 2130820254);
      
      Vector::push_back<address>(&mut payees, @0xf3ff6fafa3c5ea214acd930514e06125);
      Vector::push_back<u64>(&mut amounts, 2106408445);
      
      Vector::push_back<address>(&mut payees, @0x50bf9cec5cd43db322eb8e3ff2cd1d34);
      Vector::push_back<u64>(&mut amounts, 2083432027);
      
      Vector::push_back<address>(&mut payees, @0x5edfbf4c520972e9d36e07384b9a37e4);
      Vector::push_back<u64>(&mut amounts, 2071632797);
      
      Vector::push_back<address>(&mut payees, @0x908c2885afbc075a53c6125b0b1ad50a);
      Vector::push_back<u64>(&mut amounts, 2104442385);
      
      Vector::push_back<address>(&mut payees, @0x044e5acc10a1d6ba383e9667d6b8b886);
      Vector::push_back<u64>(&mut amounts, 2085816049);
      
      Vector::push_back<address>(&mut payees, @0xb98f9dc049753834d3a0aecf9a6f1960);
      Vector::push_back<u64>(&mut amounts, 1958256833);
      
      Vector::push_back<address>(&mut payees, @0xf8ae1377cb8a4166c3408b80bea1dc62);
      Vector::push_back<u64>(&mut amounts, 1926687713);
      
      Vector::push_back<address>(&mut payees, @0xb0f01eb296cff738f87e07df35b39a1f);
      Vector::push_back<u64>(&mut amounts, 462494039);
      
      Vector::push_back<address>(&mut payees, @0x744da35c0c7eac6a23144c79f7afbb0a);
      Vector::push_back<u64>(&mut amounts, 1318008548);
      
      Vector::push_back<address>(&mut payees, @0x753e72be1e993d2b469b1987550787b8);
      Vector::push_back<u64>(&mut amounts, 1312983567);
      
      Vector::push_back<address>(&mut payees, @0x0cbfd120dcdbbd8358d0c4ded831d17b);
      Vector::push_back<u64>(&mut amounts, 468137264);
      
      Vector::push_back<address>(&mut payees, @0x45d856b1ba25310561d8aa5f5575c1c0);
      Vector::push_back<u64>(&mut amounts, 1099721584);
      
      Vector::push_back<address>(&mut payees, @0x3fb5330c2b5899edc41d16102222cacf);
      Vector::push_back<u64>(&mut amounts, 1694528949);
      
      Vector::push_back<address>(&mut payees, @0xaa66edcbe676b691ac87f45b95e5467a);
      Vector::push_back<u64>(&mut amounts, 1574576458);
      
      Vector::push_back<address>(&mut payees, @0x098523db266e79ffad2df45480df9041);
      Vector::push_back<u64>(&mut amounts, 2577593415);
      
      Vector::push_back<address>(&mut payees, @0xbe1744c30abefa2260f62e4049eceb1c);
      Vector::push_back<u64>(&mut amounts, 2176602012);
      
      Vector::push_back<address>(&mut payees, @0x80ca4c38988cd6f70a017e141bf7068a);
      Vector::push_back<u64>(&mut amounts, 2180712133);
      
      Vector::push_back<address>(&mut payees, @0x43bd1ba38bfaf8bf81b46521065b5cca);
      Vector::push_back<u64>(&mut amounts, 2001686290);
      
      Vector::push_back<address>(&mut payees, @0x50165494792ff874902a6d624e0066f1);
      Vector::push_back<u64>(&mut amounts, 2031896157);
      
      Vector::push_back<address>(&mut payees, @0x8971b2cb602defc628a7110864547af3);
      Vector::push_back<u64>(&mut amounts, 2140814365);
      
      Vector::push_back<address>(&mut payees, @0x0b02fa610b1ba84351bf74d290b5e7c8);
      Vector::push_back<u64>(&mut amounts, 2176681427);
      
      Vector::push_back<address>(&mut payees, @0xa37997fd15a9bf06fc7c8eff82235af4);
      Vector::push_back<u64>(&mut amounts, 1633035490);
      
      Vector::push_back<address>(&mut payees, @0xb3581f04cd1985d6f5c80410507605a7);
      Vector::push_back<u64>(&mut amounts, 1447442097);
      
      Vector::push_back<address>(&mut payees, @0x5c8aff27002ac0bff02fbf4318304a3a);
      Vector::push_back<u64>(&mut amounts, 1433869447);
      
      Vector::push_back<address>(&mut payees, @0xcefe81e4948954675ca33d53cb5818ed);
      Vector::push_back<u64>(&mut amounts, 1336069907);
      
      Vector::push_back<address>(&mut payees, @0x2595f1802869c1f8d3eb07b47fe4a58d);
      Vector::push_back<u64>(&mut amounts, 1289259451);
      
      Vector::push_back<address>(&mut payees, @0xa6e1103a1045bb1e2970a0c7aa65e180);
      Vector::push_back<u64>(&mut amounts, 1378244607);
      
      Vector::push_back<address>(&mut payees, @0x6f71e21e30f29c1fc8430efa0a7451ac);
      Vector::push_back<u64>(&mut amounts, 1547685125);
      
      Vector::push_back<address>(&mut payees, @0x47c1c8eb30fef756c1376eaeeb2ef184);
      Vector::push_back<u64>(&mut amounts, 1537316243);
      
      Vector::push_back<address>(&mut payees, @0x070e30ca603de3067e2f510879eaa389);
      Vector::push_back<u64>(&mut amounts, 1531333498);
      
      Vector::push_back<address>(&mut payees, @0x086a2f42855967208247682dba0d71fe);
      Vector::push_back<u64>(&mut amounts, 1622378240);
      
      Vector::push_back<address>(&mut payees, @0x6d02ccf040f4c9722b670d816c02feb9);
      Vector::push_back<u64>(&mut amounts, 1597060883);
      
      Vector::push_back<address>(&mut payees, @0x000d01405a2b5f3f875ae98df897222c);
      Vector::push_back<u64>(&mut amounts, 1570586673);
      
      Vector::push_back<address>(&mut payees, @0xe93e077a4093c3da5c33cc2acd2aabcb);
      Vector::push_back<u64>(&mut amounts, 1624626630);
      
      Vector::push_back<address>(&mut payees, @0x590a525a9ad902e51d1bec0677f19abe);
      Vector::push_back<u64>(&mut amounts, 1619732670);
      
      Vector::push_back<address>(&mut payees, @0x5904babb2d996fdf65e0baf405a6504b);
      Vector::push_back<u64>(&mut amounts, 1532215097);
      
      Vector::push_back<address>(&mut payees, @0xea271f9dbeac61d9ffbbb833a590c49b);
      Vector::push_back<u64>(&mut amounts, 1621909878);
      
      Vector::push_back<address>(&mut payees, @0x27529afdddfbd7294c37594ac4d5d4c1);
      Vector::push_back<u64>(&mut amounts, 1599930166);
      
      Vector::push_back<address>(&mut payees, @0x987b9a90ea1e70b2637b15c4e36a6aa1);
      Vector::push_back<u64>(&mut amounts, 1587487651);
      
      Vector::push_back<address>(&mut payees, @0x05c41a075617852d2cddfd9e8ae69177);
      Vector::push_back<u64>(&mut amounts, 1599102387);
      
      Vector::push_back<address>(&mut payees, @0x57d824956b8f1fe86b069852dae82a5a);
      Vector::push_back<u64>(&mut amounts, 1586842337);
      
      Vector::push_back<address>(&mut payees, @0x867f04f5f8f99a57d4c98a6da965ac87);
      Vector::push_back<u64>(&mut amounts, 1587538060);
      
      Vector::push_back<address>(&mut payees, @0x5050ba46dcf513a371564eb36e338e6d);
      Vector::push_back<u64>(&mut amounts, 1609862819);
      
      Vector::push_back<address>(&mut payees, @0xc3930fec6992ec4d965881b01f440737);
      Vector::push_back<u64>(&mut amounts, 1630586610);
      
      Vector::push_back<address>(&mut payees, @0x3ae360a80ad5c68edb5dc1d1479631af);
      Vector::push_back<u64>(&mut amounts, 1561912190);
      
      Vector::push_back<address>(&mut payees, @0xf8e41b78e0d7eef7c6d4731dd819b83b);
      Vector::push_back<u64>(&mut amounts, 1632331558);
      
      Vector::push_back<address>(&mut payees, @0x06b20fd8ba407060b8c76cd82b39a63d);
      Vector::push_back<u64>(&mut amounts, 1572201725);
      
      Vector::push_back<address>(&mut payees, @0x64b70dbeddc7c52d331d926797ffa93a);
      Vector::push_back<u64>(&mut amounts, 1571565235);
      
      Vector::push_back<address>(&mut payees, @0xffaa8a7b976575d9ad145eea3bf4b934);
      Vector::push_back<u64>(&mut amounts, 1593551570);
      
      Vector::push_back<address>(&mut payees, @0xd7002d7cc52dd5066e5e01168a79591e);
      Vector::push_back<u64>(&mut amounts, 1509025648);
      
      Vector::push_back<address>(&mut payees, @0xe450473a77114343341e137995486bb5);
      Vector::push_back<u64>(&mut amounts, 1500577680);
      
      Vector::push_back<address>(&mut payees, @0xe1827272c86577ee4d02505bb46d798c);
      Vector::push_back<u64>(&mut amounts, 1513954990);
      
      Vector::push_back<address>(&mut payees, @0x9c922f53174936961f29a934ce2b4409);
      Vector::push_back<u64>(&mut amounts, 1502088782);
      
      Vector::push_back<address>(&mut payees, @0x1a23ee70b3984ebfee639f77d1a22131);
      Vector::push_back<u64>(&mut amounts, 1502325177);
      
      Vector::push_back<address>(&mut payees, @0xb4a29a3edaca74ad9ed767f8c26d096c);
      Vector::push_back<u64>(&mut amounts, 1610060461);
      
      Vector::push_back<address>(&mut payees, @0xccfbc98cf7ffd6a211878190394428b3);
      Vector::push_back<u64>(&mut amounts, 1605227530);
      
      Vector::push_back<address>(&mut payees, @0x62ab37450a2ad9d141d8f6bb399ca9eb);
      Vector::push_back<u64>(&mut amounts, 1598715816);
      
      Vector::push_back<address>(&mut payees, @0xbd8fc8d68131d6040c0daae0270292e4);
      Vector::push_back<u64>(&mut amounts, 1551757096);
      
      Vector::push_back<address>(&mut payees, @0xd581ad7c890c293a63c1f71d65da03f0);
      Vector::push_back<u64>(&mut amounts, 1575894819);
      
      Vector::push_back<address>(&mut payees, @0x2695407c8107717e495bd1c24d43f322);
      Vector::push_back<u64>(&mut amounts, 1624194531);
      
      Vector::push_back<address>(&mut payees, @0xcf8d65eeaca9a6863d057b778ee24e12);
      Vector::push_back<u64>(&mut amounts, 1593277702);
      
      Vector::push_back<address>(&mut payees, @0x2c6cfef082e833308c21a5ece621e8d1);
      Vector::push_back<u64>(&mut amounts, 1609745428);
      
      Vector::push_back<address>(&mut payees, @0xa8382f5c5c07978cd28d321499aac49c);
      Vector::push_back<u64>(&mut amounts, 1608207109);
      
      Vector::push_back<address>(&mut payees, @0x1a6cdc5ed178a2fe49b1c2cc2f60c06a);
      Vector::push_back<u64>(&mut amounts, 2018615503);
      
      Vector::push_back<address>(&mut payees, @0x5910ae2439a7d4e024d0518682efa771);
      Vector::push_back<u64>(&mut amounts, 1986251424);
      
      Vector::push_back<address>(&mut payees, @0x02485b620ce54f8943d666a3db932e28);
      Vector::push_back<u64>(&mut amounts, 1955309349);
      
      Vector::push_back<address>(&mut payees, @0xd8956ce10a22c034056fe7ef4a43b48e);
      Vector::push_back<u64>(&mut amounts, 2013714570);
      
      Vector::push_back<address>(&mut payees, @0x43df98c689a2497d9e625a51684717da);
      Vector::push_back<u64>(&mut amounts, 1947978985);
      
      Vector::push_back<address>(&mut payees, @0x4f2fc6394e5e73fc6f7d91a98cb74f26);
      Vector::push_back<u64>(&mut amounts, 2145190727);
      
      Vector::push_back<address>(&mut payees, @0x0a30e5a6bdaa26b4eb3e755078be14bc);
      Vector::push_back<u64>(&mut amounts, 2116766252);
      
      Vector::push_back<address>(&mut payees, @0xf4a40c8d47d49984c1f3ff5a31895941);
      Vector::push_back<u64>(&mut amounts, 2069383944);
      
      Vector::push_back<address>(&mut payees, @0x67f7fa1369b7b3ed0ef34dd04811cf1e);
      Vector::push_back<u64>(&mut amounts, 2178250416);
      
      Vector::push_back<address>(&mut payees, @0x1a61af18bce2c7355dad1916f70e5341);
      Vector::push_back<u64>(&mut amounts, 2111141179);
      
      Vector::push_back<address>(&mut payees, @0x22fb9aa5b4f8aac786a0752a22d53eb3);
      Vector::push_back<u64>(&mut amounts, 2148224206);
      
      Vector::push_back<address>(&mut payees, @0x1f41da5b1216ba90be7cd0f9aafce276);
      Vector::push_back<u64>(&mut amounts, 2094255127);
      
      Vector::push_back<address>(&mut payees, @0x2844a9d716153213263de5f333982d29);
      Vector::push_back<u64>(&mut amounts, 1960998253);
      
      Vector::push_back<address>(&mut payees, @0x40eaed88c828649f06976386be3aa35f);
      Vector::push_back<u64>(&mut amounts, 1995812941);
      
      Vector::push_back<address>(&mut payees, @0x2678e7c2be4708df1bdea9856ab399e5);
      Vector::push_back<u64>(&mut amounts, 1783675318);
      
      Vector::push_back<address>(&mut payees, @0x60ad6155e2a1d755320185712cd6561b);
      Vector::push_back<u64>(&mut amounts, 1742890455);
      
      Vector::push_back<address>(&mut payees, @0x1e069560db9a03ee802ab712313f43d4);
      Vector::push_back<u64>(&mut amounts, 1766114062);
      
      Vector::push_back<address>(&mut payees, @0xee5cc2fb7392bc82ed11bb464eb2726a);
      Vector::push_back<u64>(&mut amounts, 1711412017);
      
      Vector::push_back<address>(&mut payees, @0x772afce4cd2254ad07c022303c1e7623);
      Vector::push_back<u64>(&mut amounts, 1675262696);
      
      Vector::push_back<address>(&mut payees, @0x3f3fa98d4aede7719097d95870189834);
      Vector::push_back<u64>(&mut amounts, 1735144320);
      
      Vector::push_back<address>(&mut payees, @0xa912beae04db774df58af0defdeb1fe6);
      Vector::push_back<u64>(&mut amounts, 1725519669);
      
      Vector::push_back<address>(&mut payees, @0xab9baaf1bd5f8b26f0beeb4138c2321a);
      Vector::push_back<u64>(&mut amounts, 1308832592);
      
      Vector::push_back<address>(&mut payees, @0x5579e00dd85886a7dbc714104bd685a3);
      Vector::push_back<u64>(&mut amounts, 2282805257);
      
      Vector::push_back<address>(&mut payees, @0x86ea91e266287d11011f5c0b3963d2ea);
      Vector::push_back<u64>(&mut amounts, 1150651440);
      
      Vector::push_back<address>(&mut payees, @0x3047f2504d9564f2a510a242313d5030);
      Vector::push_back<u64>(&mut amounts, 869230166);
      
      Vector::push_back<address>(&mut payees, @0x05b4f2851ee79affadd7be9a84d17c38);
      Vector::push_back<u64>(&mut amounts, 250419969);
      
      Vector::push_back<address>(&mut payees, @0x7fb18bdae9df23b2f51d85b1d27428a2);
      Vector::push_back<u64>(&mut amounts, 1544810266);
      
      Vector::push_back<address>(&mut payees, @0x322e6fbd4f5241ef40ad022d90fd22bb);
      Vector::push_back<u64>(&mut amounts, 2092354097);
      
      Vector::push_back<address>(&mut payees, @0x50466f7a4b17752c68ee300d3d5836b8);
      Vector::push_back<u64>(&mut amounts, 1502007118);
      
      Vector::push_back<address>(&mut payees, @0x5f733353bee56f9474e633d7c9e9d1ae);
      Vector::push_back<u64>(&mut amounts, 3817690232);
      
      Vector::push_back<address>(&mut payees, @0xcb4a7682cdc9b0e119f655b396117428);
      Vector::push_back<u64>(&mut amounts, 1599312323);
      
      Vector::push_back<address>(&mut payees, @0x62050c41cabc6ef0134c7e743db5b759);
      Vector::push_back<u64>(&mut amounts, 1474367759);
      
      Vector::push_back<address>(&mut payees, @0xcdfdb9ab370d6394433f68e7e0456811);
      Vector::push_back<u64>(&mut amounts, 1570432318);
      
      Vector::push_back<address>(&mut payees, @0x41e65a6be60cc04a6d5e29621ab7f656);
      Vector::push_back<u64>(&mut amounts, 1556057296);
      
      Vector::push_back<address>(&mut payees, @0x2bbbbb0d7a96d33e377f92cf1204d769);
      Vector::push_back<u64>(&mut amounts, 1539731260);
      
      Vector::push_back<address>(&mut payees, @0xbb3efc310cf88a5fea5158b5a0ad08d6);
      Vector::push_back<u64>(&mut amounts, 1981753920);
      
      Vector::push_back<address>(&mut payees, @0xa2fc4a246a73db4d5fed58f127fddfa1);
      Vector::push_back<u64>(&mut amounts, 1613475980);
      
      Vector::push_back<address>(&mut payees, @0x08834e3e901cd0031171ba4c11d844cb);
      Vector::push_back<u64>(&mut amounts, 1523794463);
      
      Vector::push_back<address>(&mut payees, @0x124a91e5782cf40a1376faf84bd65c44);
      Vector::push_back<u64>(&mut amounts, 1500122334);
      
      Vector::push_back<address>(&mut payees, @0x2da26cdf7425bdbc48b62ebfde875d1c);
      Vector::push_back<u64>(&mut amounts, 1621275394);
      
      Vector::push_back<address>(&mut payees, @0x7ca19673009dfcd330e211b869e94fcb);
      Vector::push_back<u64>(&mut amounts, 3572976073);
      
      Vector::push_back<address>(&mut payees, @0x3b5e203a65ed0b4a0aec2ef9aaf8c75c);
      Vector::push_back<u64>(&mut amounts, 1582207797);
      
      Vector::push_back<address>(&mut payees, @0xc9298bb80b6fb3fa37add402bd238d88);
      Vector::push_back<u64>(&mut amounts, 1493035076);
      
      Vector::push_back<address>(&mut payees, @0x60ec45a6bac1629b62104708a877defe);
      Vector::push_back<u64>(&mut amounts, 1554597335);
      
      Vector::push_back<address>(&mut payees, @0xa22924e1406b191d99faf7b0f41e3775);
      Vector::push_back<u64>(&mut amounts, 1391509729);
      
      Vector::push_back<address>(&mut payees, @0xaf0ab505c21cd483e8c901ba62d27e0e);
      Vector::push_back<u64>(&mut amounts, 4086171346);
      
      Vector::push_back<address>(&mut payees, @0x5219f9db22242e66492118b6ee2ccb7d);
      Vector::push_back<u64>(&mut amounts, 1614271166);
      
      Vector::push_back<address>(&mut payees, @0x36f80e4e750caf30d2cf7a54888c7ba9);
      Vector::push_back<u64>(&mut amounts, 1575762916);
      
      Vector::push_back<address>(&mut payees, @0xc0fc6b93612ada367c0b1240afd4d8a8);
      Vector::push_back<u64>(&mut amounts, 1605202649);
      
      Vector::push_back<address>(&mut payees, @0xb8db505a67af28b0c095d2b85cc5828a);
      Vector::push_back<u64>(&mut amounts, 1619082956);
      
      Vector::push_back<address>(&mut payees, @0x87382b8180ec748babfecd1b66527c7c);
      Vector::push_back<u64>(&mut amounts, 1595738681);
      
      Vector::push_back<address>(&mut payees, @0xa5cfdc2e4d661e403f4183b01c13e82f);
      Vector::push_back<u64>(&mut amounts, 1454356996);
      
      Vector::push_back<address>(&mut payees, @0x8f9f792f069d4d55b160f640cede0ed9);
      Vector::push_back<u64>(&mut amounts, 1639468902);
      
      Vector::push_back<address>(&mut payees, @0xa86a98c1e0961f26cd3d882a6e11d853);
      Vector::push_back<u64>(&mut amounts, 1312836844);
      
      Vector::push_back<address>(&mut payees, @0xdefb8c06ba7b9ed58a108fed3d4f4422);
      Vector::push_back<u64>(&mut amounts, 1388565446);
      
      Vector::push_back<address>(&mut payees, @0x3875f46b96f3a044e1b88945ebfe9c94);
      Vector::push_back<u64>(&mut amounts, 896550659);
      
      Vector::push_back<address>(&mut payees, @0x05dd4b69a541ba7231d77248a29ad99d);
      Vector::push_back<u64>(&mut amounts, 1388546624);
      
      Vector::push_back<address>(&mut payees, @0xa442b36e25691fc3d3d96cbf91686e98);
      Vector::push_back<u64>(&mut amounts, 611139907);
      
      Vector::push_back<address>(&mut payees, @0x49ac56edff9423691c774b3e8f797ef2);
      Vector::push_back<u64>(&mut amounts, 1906308180);
      
      Vector::push_back<address>(&mut payees, @0x5e8b9eb9fb5b807c4d2148f7fa3a0c67);
      Vector::push_back<u64>(&mut amounts, 773150851);
      
      Vector::push_back<address>(&mut payees, @0x1a17c34bb0aac74c0589d0b68347e56f);
      Vector::push_back<u64>(&mut amounts, 1231819901);
      
      Vector::push_back<address>(&mut payees, @0x588a30ab42221065c513b48c01e9e1c5);
      Vector::push_back<u64>(&mut amounts, 565873375);
      
      Vector::push_back<address>(&mut payees, @0xe2ffff37e1e882905f6f6380b21b6ad7);
      Vector::push_back<u64>(&mut amounts, 569611555);
      
      Vector::push_back<address>(&mut payees, @0x9783ea34cde3dc682cfca4b11b6b4dae);
      Vector::push_back<u64>(&mut amounts, 575304822);
      
      Vector::push_back<address>(&mut payees, @0xeb3bbc48f62eb771be12396da12a65ef);
      Vector::push_back<u64>(&mut amounts, 583436698);
      
      Vector::push_back<address>(&mut payees, @0x0909d78b0d3beb0d6458b81d405fb56a);
      Vector::push_back<u64>(&mut amounts, 569830365);
      
      Vector::push_back<address>(&mut payees, @0x1ad3b45cd2176a3aaca9e52fe90e1114);
      Vector::push_back<u64>(&mut amounts, 567790781);
      
      Vector::push_back<address>(&mut payees, @0xdf72c26c56fa4b619be87dbdd24e29e3);
      Vector::push_back<u64>(&mut amounts, 569754539);
      
      Vector::push_back<address>(&mut payees, @0x2c4f3ef8cba6c8a3aa3ea5d310bfc67b);
      Vector::push_back<u64>(&mut amounts, 442908007);
      
      Vector::push_back<address>(&mut payees, @0x81bb33a08011fe4d11c35d661d3b27ab);
      Vector::push_back<u64>(&mut amounts, 454557556);
      
      Vector::push_back<address>(&mut payees, @0xbdea0dd65034916e446c41f65fe9456e);
      Vector::push_back<u64>(&mut amounts, 626947316);
      
      Vector::push_back<address>(&mut payees, @0xae92c3d30a13b32c19ae109a9ef45de3);
      Vector::push_back<u64>(&mut amounts, 1310123076);
      
      Vector::push_back<address>(&mut payees, @0xdd1fa1797cb5835bd8614d6cd1bb5da8);
      Vector::push_back<u64>(&mut amounts, 284900728);
      
      Vector::push_back<address>(&mut payees, @0xc191aa38030faa7aee9815c6595ef8cc);
      Vector::push_back<u64>(&mut amounts, 1322534955);
      
      Vector::push_back<address>(&mut payees, @0xb774e9979a218125b32f48e1842e80d2);
      Vector::push_back<u64>(&mut amounts, 322321714);
      
      Vector::push_back<address>(&mut payees, @0x3b32f656aeef1c076097a3042b90385b);
      Vector::push_back<u64>(&mut amounts, 852874412);
      
      Vector::push_back<address>(&mut payees, @0xa32ff04bc85df3abe72c5bffc12156f7);
      Vector::push_back<u64>(&mut amounts, 485695369);
      
      Vector::push_back<address>(&mut payees, @0x6592b386d8c8475d741e666a363721e0);
      Vector::push_back<u64>(&mut amounts, 317839202);
      
      Vector::push_back<address>(&mut payees, @0xbf5b14d29c9b52260ea3290c9510685f);
      Vector::push_back<u64>(&mut amounts, 2535792540);
      
      Vector::push_back<address>(&mut payees, @0xa5057841ebc5c2f9d76481d50745efd5);
      Vector::push_back<u64>(&mut amounts, 2360390225);
      
      Vector::push_back<address>(&mut payees, @0xaeeec279b8f7be8bfd75e7afb06f3849);
      Vector::push_back<u64>(&mut amounts, 2608761583);
      
      Vector::push_back<address>(&mut payees, @0x46c72fedb2b6735a6617c2632f8ace3b);
      Vector::push_back<u64>(&mut amounts, 3098031478);
      
      Vector::push_back<address>(&mut payees, @0x983efe00d7f1b5ed3095d6376e93b9de);
      Vector::push_back<u64>(&mut amounts, 2091380105);
      
      Vector::push_back<address>(&mut payees, @0x7597ca5392c2bec4843a37eaed689288);
      Vector::push_back<u64>(&mut amounts, 4817794323);
      
      Vector::push_back<address>(&mut payees, @0xd42d0aeac06a7477b7a68346136a12c8);
      Vector::push_back<u64>(&mut amounts, 6326240997);
      
      Vector::push_back<address>(&mut payees, @0x8421cb22e56f687395f5973bbf0cbdfb);
      Vector::push_back<u64>(&mut amounts, 1908653747);
      
      Vector::push_back<address>(&mut payees, @0x088e7f751692c42777f511a0e93625df);
      Vector::push_back<u64>(&mut amounts, 5711371645);
      
      Vector::push_back<address>(&mut payees, @0xe8ae01541078d83b713f0782628650ee);
      Vector::push_back<u64>(&mut amounts, 2469032012);
      
      Vector::push_back<address>(&mut payees, @0xfe5e9be5950a2baf19804478ac054c4b);
      Vector::push_back<u64>(&mut amounts, 757039068);
      
      Vector::push_back<address>(&mut payees, @0xc3b87fda83b5bd65ce8afa0a62fedded);
      Vector::push_back<u64>(&mut amounts, 2162096212);
      
      Vector::push_back<address>(&mut payees, @0x55171e51b261d902964dd128a057c23a);
      Vector::push_back<u64>(&mut amounts, 6588885096);
      
      Vector::push_back<address>(&mut payees, @0xa1fbce9eb29d0b9e67cbe69abe975cd1);
      Vector::push_back<u64>(&mut amounts, 2583998898);
      
      Vector::push_back<address>(&mut payees, @0x9bbf2287831ab440f331bc94de1b616a);
      Vector::push_back<u64>(&mut amounts, 2818809454);
      
      Vector::push_back<address>(&mut payees, @0x62aa596a51b1ec2ba96beb8e15284987);
      Vector::push_back<u64>(&mut amounts, 6428702639);
      
      Vector::push_back<address>(&mut payees, @0xb5e1013e9ab7a874c5282844627c99ac);
      Vector::push_back<u64>(&mut amounts, 5691970903);
      
      Vector::push_back<address>(&mut payees, @0x57e870b95be77187ec9f80afac8df761);
      Vector::push_back<u64>(&mut amounts, 3293712074);
      
      Vector::push_back<address>(&mut payees, @0x48a15ad2caad3daefe92988b8c099abb);
      Vector::push_back<u64>(&mut amounts, 4673438776);
      
      Vector::push_back<address>(&mut payees, @0x79e798987f62bc88eca07b58b3351824);
      Vector::push_back<u64>(&mut amounts, 4252012127);
      
      Vector::push_back<address>(&mut payees, @0xa7f32b2a5a8a73f08a6742b616e3ce4b);
      Vector::push_back<u64>(&mut amounts, 2262101084);
      
      Vector::push_back<address>(&mut payees, @0xe5ff39b2bca1b7d4c154a07f8d2699a9);
      Vector::push_back<u64>(&mut amounts, 5521449417);
      
      Vector::push_back<address>(&mut payees, @0x00104782518b8368f963d550b7c94209);
      Vector::push_back<u64>(&mut amounts, 2106551926);
      
      Vector::push_back<address>(&mut payees, @0xe59e3d102ad890cabda449092bfd9e69);
      Vector::push_back<u64>(&mut amounts, 141594572);
      
      Vector::push_back<address>(&mut payees, @0xfacc653d707bd500044dcb99bf4c3d5b);
      Vector::push_back<u64>(&mut amounts, 6910213592);
      
      Vector::push_back<address>(&mut payees, @0x8d2af531022d6fd76f98661b95da3cf6);
      Vector::push_back<u64>(&mut amounts, 665368482);
      
      Vector::push_back<address>(&mut payees, @0xdcf8fd880e9b155104a8d40e7edbc3a7);
      Vector::push_back<u64>(&mut amounts, 470326117);
      
      Vector::push_back<address>(&mut payees, @0xc0099ab5aec4849f2c4ecbcd7af4ac32);
      Vector::push_back<u64>(&mut amounts, 448542219);
      
      Vector::push_back<address>(&mut payees, @0xeb0d6ebbc1ece305682312dd1b706407);
      Vector::push_back<u64>(&mut amounts, 952144003);
      
      Vector::push_back<address>(&mut payees, @0x3497dcd64b13e3d3c42634ca7ce2153c);
      Vector::push_back<u64>(&mut amounts, 418585437);
      
      Vector::push_back<address>(&mut payees, @0xab6da4854443c0093290e04da814c48f);
      Vector::push_back<u64>(&mut amounts, 343566991);
      
      Vector::push_back<address>(&mut payees, @0x4271fb7a96e4dd0aa2ac6e8122be235a);
      Vector::push_back<u64>(&mut amounts, 5174829446);
      
      Vector::push_back<address>(&mut payees, @0x9279ee513c9afefe0e7ddf2f3c7abb88);
      Vector::push_back<u64>(&mut amounts, 5060601832);
      
      Vector::push_back<address>(&mut payees, @0x754ebf04a9478c549c6c8ca5d29cbd0d);
      Vector::push_back<u64>(&mut amounts, 1362529817);
      
      Vector::push_back<address>(&mut payees, @0x98b52dbcccf7757601b3540986ecd2dd);
      Vector::push_back<u64>(&mut amounts, 5952705061);
      
      Vector::push_back<address>(&mut payees, @0x4d18b6f0481115ea32c96b81d4c35041);
      Vector::push_back<u64>(&mut amounts, 6030196688);
      
      Vector::push_back<address>(&mut payees, @0x59357260c14bc6576749d87eb627d727);
      Vector::push_back<u64>(&mut amounts, 3719726595);
      
      Vector::push_back<address>(&mut payees, @0xc001106b430f2660732102f2875d1059);
      Vector::push_back<u64>(&mut amounts, 271912080);
      
      Vector::push_back<address>(&mut payees, @0x4a922b47c180a59383fa435b8923b52c);
      Vector::push_back<u64>(&mut amounts, 412197422);
      
      Vector::push_back<address>(&mut payees, @0xaec2461c0c9d8188fd6ae01d9d9f785e);
      Vector::push_back<u64>(&mut amounts, 5017639819);
      
      Vector::push_back<address>(&mut payees, @0x1d281e527124c0ebb466a553a3d5063e);
      Vector::push_back<u64>(&mut amounts, 5583687969);
      
      Vector::push_back<address>(&mut payees, @0x6acbc3b1ec4ddf7bf85801e32aec3c45);
      Vector::push_back<u64>(&mut amounts, 4948380131);
      
      Vector::push_back<address>(&mut payees, @0xf250b723e488fe6f32a8f512b6379ecb);
      Vector::push_back<u64>(&mut amounts, 2645778271);
      
      Vector::push_back<address>(&mut payees, @0xc54a7a74ff2f16e3fa581b897aad7ed3);
      Vector::push_back<u64>(&mut amounts, 3416831377);
      
      Vector::push_back<address>(&mut payees, @0x7efc95a19e1c8d7e38e730ddb7b34332);
      Vector::push_back<u64>(&mut amounts, 2064463401);
      
      Vector::push_back<address>(&mut payees, @0xca3c5e7218645ab53781c0b58b2401d6);
      Vector::push_back<u64>(&mut amounts, 2355656219);
      
      Vector::push_back<address>(&mut payees, @0x5d2015186dbc5727d4ff45528d169f0d);
      Vector::push_back<u64>(&mut amounts, 5370445262);
      
      Vector::push_back<address>(&mut payees, @0x5479ce9086e36d5d540eb35ea34fb291);
      Vector::push_back<u64>(&mut amounts, 4091722992);
      
      Vector::push_back<address>(&mut payees, @0xe3b89d3dc8e4fbe83ba29ada5e04f169);
      Vector::push_back<u64>(&mut amounts, 4370951615);
      
      Vector::push_back<address>(&mut payees, @0x4f3fdf3c284665f43469a6e317ea878b);
      Vector::push_back<u64>(&mut amounts, 3914509235);
      
      Vector::push_back<address>(&mut payees, @0x76484d6025e1310f3c89f4467e024a24);
      Vector::push_back<u64>(&mut amounts, 6751608257);
      
      Vector::push_back<address>(&mut payees, @0x6498aee4af012802362721361210484a);
      Vector::push_back<u64>(&mut amounts, 2891871893);
      
      Vector::push_back<address>(&mut payees, @0x6179b9e8d844c0906fa5cb70b807c295);
      Vector::push_back<u64>(&mut amounts, 5362232480);
      
      Vector::push_back<address>(&mut payees, @0x68b6d5503a5a0ce2a6f8027ec481ec7c);
      Vector::push_back<u64>(&mut amounts, 5003434949);
      
      Vector::push_back<address>(&mut payees, @0xf5c74530fbdb8e4fb9a11df0c98e553e);
      Vector::push_back<u64>(&mut amounts, 4992687485);
      
      Vector::push_back<address>(&mut payees, @0xa25a563e5029210d60a1ed53e9761fcf);
      Vector::push_back<u64>(&mut amounts, 5036311551);
      
      Vector::push_back<address>(&mut payees, @0x779fd01dfe608a4288b4b514d17da48b);
      Vector::push_back<u64>(&mut amounts, 810326566);
      
      Vector::push_back<address>(&mut payees, @0xf1ea95ffab3f82f1d35aaaf3bccbb4a1);
      Vector::push_back<u64>(&mut amounts, 3100103513);
      
      Vector::push_back<address>(&mut payees, @0x7a85639ce8923ecebac4d89ff968df12);
      Vector::push_back<u64>(&mut amounts, 5353797083);
      
      Vector::push_back<address>(&mut payees, @0xf8961ea426908f153ed40105801b508b);
      Vector::push_back<u64>(&mut amounts, 262265869);
      
      Vector::push_back<address>(&mut payees, @0x47bcde97da006d467fcb4ce25f7e96e4);
      Vector::push_back<u64>(&mut amounts, 4801074766);
      
      Vector::push_back<address>(&mut payees, @0x1c03e956dd7afc612e4efe240c23365d);
      Vector::push_back<u64>(&mut amounts, 1165850487);
      
      Vector::push_back<address>(&mut payees, @0x0329f10f139c2b58cf7195c3e560f751);
      Vector::push_back<u64>(&mut amounts, 5099630726);
      
      Vector::push_back<address>(&mut payees, @0x06b8a51ea859408a82b93388eeb877c3);
      Vector::push_back<u64>(&mut amounts, 5182449248);
      
      Vector::push_back<address>(&mut payees, @0x5846a6af218acc6d99bc7a54d2649e5d);
      Vector::push_back<u64>(&mut amounts, 4155404910);
      
      Vector::push_back<address>(&mut payees, @0xe985cbb111a6e7210f1f07aa1f8a75dd);
      Vector::push_back<u64>(&mut amounts, 3720133833);
      
      Vector::push_back<address>(&mut payees, @0x8ab6489146a5ebc6890dd532bc249545);
      Vector::push_back<u64>(&mut amounts, 6459870546);
      
      Vector::push_back<address>(&mut payees, @0x4ba0442bef452b7f68cdc83d5b7c3c8f);
      Vector::push_back<u64>(&mut amounts, 1608743175);
      
      Vector::push_back<address>(&mut payees, @0x0a5dec37f0fbb014b1071d224660a260);
      Vector::push_back<u64>(&mut amounts, 5170589051);
      
      Vector::push_back<address>(&mut payees, @0xdc75c1d21c5cab6a8f8978678a4af699);
      Vector::push_back<u64>(&mut amounts, 8910998847);
      
      Vector::push_back<address>(&mut payees, @0x66b628974b5b5d59b28416276cf3434b);
      Vector::push_back<u64>(&mut amounts, 3428132279);
      
      Vector::push_back<address>(&mut payees, @0x52ef98ab89717b958b84ffa8619d5eec);
      Vector::push_back<u64>(&mut amounts, 4572609328);
      
      Vector::push_back<address>(&mut payees, @0x3ae58c7d166b385954b5d7dd12e28e65);
      Vector::push_back<u64>(&mut amounts, 4266775107);
      
      Vector::push_back<address>(&mut payees, @0xeee71da3d631e81ac8a804b629c3d8f9);
      Vector::push_back<u64>(&mut amounts, 5096037047);
      
      Vector::push_back<address>(&mut payees, @0x5c0f70485dcd1f3084affc9b50847f92);
      Vector::push_back<u64>(&mut amounts, 5152086351);
      
      Vector::push_back<address>(&mut payees, @0x00717c6028cfe2338a644fa5011c5941);
      Vector::push_back<u64>(&mut amounts, 5435404214);
      
      Vector::push_back<address>(&mut payees, @0x17d277fe88c4a4d22f29553b70def4c0);
      Vector::push_back<u64>(&mut amounts, 2017831698);
      
      Vector::push_back<address>(&mut payees, @0xe264023342b41accdbb61a190b6cb2a7);
      Vector::push_back<u64>(&mut amounts, 4698277059);
      
      Vector::push_back<address>(&mut payees, @0xbba20d1e57dc0ee0ef56a2dc3a058ca4);
      Vector::push_back<u64>(&mut amounts, 721601199);
      
      Vector::push_back<address>(&mut payees, @0x3d9dfecece643c772810161af84c89f7);
      Vector::push_back<u64>(&mut amounts, 2891957242);
      
      Vector::push_back<address>(&mut payees, @0x6b4124692f988f8accb3584d11915b16);
      Vector::push_back<u64>(&mut amounts, 106700025);
      
      Vector::push_back<address>(&mut payees, @0x0ef85e1723530edd76f2bb13614ac5c5);
      Vector::push_back<u64>(&mut amounts, 894815396);
      
      Vector::push_back<address>(&mut payees, @0xd03a4bd3d92a8a9aec44a5d83c41674b);
      Vector::push_back<u64>(&mut amounts, 4058595066);
      
      Vector::push_back<address>(&mut payees, @0xa4987f392e32442229f15fb73dac5e50);
      Vector::push_back<u64>(&mut amounts, 3360805136);
      
      Vector::push_back<address>(&mut payees, @0x91185ed5a1976f2e01be08ee96e4d9d2);
      Vector::push_back<u64>(&mut amounts, 1130746064);
      
      Vector::push_back<address>(&mut payees, @0xabe72a40a1ad44aca90427bbcd6cdf77);
      Vector::push_back<u64>(&mut amounts, 932524418);
      
      Vector::push_back<address>(&mut payees, @0x21cd09faf46f73533e58e11ee1f4fe62);
      Vector::push_back<u64>(&mut amounts, 2480063023);
      
      Vector::push_back<address>(&mut payees, @0x23738f9e7d61505f726fe490e4a9e8ec);
      Vector::push_back<u64>(&mut amounts, 1027473039);
      
      Vector::push_back<address>(&mut payees, @0x0a5ebedef02da43222b82fe419c97a40);
      Vector::push_back<u64>(&mut amounts, 1225524190);
      
      Vector::push_back<address>(&mut payees, @0x756d518db499a22c1dad0e2ee353c21d);
      Vector::push_back<u64>(&mut amounts, 4030820331);
      
      Vector::push_back<address>(&mut payees, @0xac1de724c0cea61b55c29394b595f95b);
      Vector::push_back<u64>(&mut amounts, 3997036334);
      
      Vector::push_back<address>(&mut payees, @0x199c55469075a3f96880d4a63e74dcf4);
      Vector::push_back<u64>(&mut amounts, 1532511843);
      
      Vector::push_back<address>(&mut payees, @0xe77ddb76c9afcb3d5511e46cbc89023d);
      Vector::push_back<u64>(&mut amounts, 1961679765);
      
      Vector::push_back<address>(&mut payees, @0xf90d6e620b0f53df1675d6c15a3a2b7c);
      Vector::push_back<u64>(&mut amounts, 1841902867);
      
      Vector::push_back<address>(&mut payees, @0x749b9d353724b2844d4aae34125ce1d0);
      Vector::push_back<u64>(&mut amounts, 5219435810);
      
      Vector::push_back<address>(&mut payees, @0x8a446db47cfb62ba00e6111a3cdefd04);
      Vector::push_back<u64>(&mut amounts, 4682564048);
      
      Vector::push_back<address>(&mut payees, @0xb3d680cd888d0d067af852caf7512a23);
      Vector::push_back<u64>(&mut amounts, 5057038129);
      
      Vector::push_back<address>(&mut payees, @0x3ff4882ed2a2c894443701bdf7506d3f);
      Vector::push_back<u64>(&mut amounts, 4142296977);
      
      Vector::push_back<address>(&mut payees, @0xde3ee4da7b1779a78fef729bf88fd465);
      Vector::push_back<u64>(&mut amounts, 3367405548);
      
      Vector::push_back<address>(&mut payees, @0x382f1d6be4aad83ab646ee123d60be60);
      Vector::push_back<u64>(&mut amounts, 2829617057);
      
      Vector::push_back<address>(&mut payees, @0x83504d7263dca66fe97109233cf1eb12);
      Vector::push_back<u64>(&mut amounts, 2492550649);
      
      Vector::push_back<address>(&mut payees, @0x22f09282869112d71d5d8196c6178c7c);
      Vector::push_back<u64>(&mut amounts, 4662894648);
      
      Vector::push_back<address>(&mut payees, @0xf0eb80e19c587c661d573b691873c2af);
      Vector::push_back<u64>(&mut amounts, 248585029);
      
      Vector::push_back<address>(&mut payees, @0x9eac9413282071760fd94e84faee931b);
      Vector::push_back<u64>(&mut amounts, 3931126055);
      
      Vector::push_back<address>(&mut payees, @0x4be425e5306776a0bd9e2db152b856e6);
      Vector::push_back<u64>(&mut amounts, 6439242269);
      
      Vector::push_back<address>(&mut payees, @0x733c4caa99f3fa11dddc80f27d014344);
      Vector::push_back<u64>(&mut amounts, 721665643);
      
      Vector::push_back<address>(&mut payees, @0xee221338e87976c3d18c6673735aa4ce);
      Vector::push_back<u64>(&mut amounts, 168196490);
      
      Vector::push_back<address>(&mut payees, @0xbca52657ab18aadee8a66becc82a4031);
      Vector::push_back<u64>(&mut amounts, 6645417482);
      
      Vector::push_back<address>(&mut payees, @0x71628c08dddd6926d933d6ee57d2cfb9);
      Vector::push_back<u64>(&mut amounts, 3353967633);
      
      Vector::push_back<address>(&mut payees, @0x2c3d4d3278cc74f346e7283a7f89383e);
      Vector::push_back<u64>(&mut amounts, 2116791458);
      
      Vector::push_back<address>(&mut payees, @0x7385899948ad7463007d3b90786c391a);
      Vector::push_back<u64>(&mut amounts, 4233645152);
      
      Vector::push_back<address>(&mut payees, @0xff15a52fecefed9e4476477a1a119767);
      Vector::push_back<u64>(&mut amounts, 3299799882);
      
      Vector::push_back<address>(&mut payees, @0xa117aa80ce9add73e443791c17232448);
      Vector::push_back<u64>(&mut amounts, 5176405064);
      
      Vector::push_back<address>(&mut payees, @0x562c6735970b233cd8032ecf718421f9);
      Vector::push_back<u64>(&mut amounts, 1115796592);
      
      Vector::push_back<address>(&mut payees, @0xa654aab809f6562c3ee62c5a6ef43eb7);
      Vector::push_back<u64>(&mut amounts, 3723205547);
      
      Vector::push_back<address>(&mut payees, @0xe2cfdbfc970da38c1f11bb2bf939fb2a);
      Vector::push_back<u64>(&mut amounts, 4130294759);
      
      Vector::push_back<address>(&mut payees, @0x720d3107684174cf114904c7aafed6c6);
      Vector::push_back<u64>(&mut amounts, 2983937646);
      
      Vector::push_back<address>(&mut payees, @0xd460f367df5e03ed05c87c4a54902915);
      Vector::push_back<u64>(&mut amounts, 3179495329);
      
      Vector::push_back<address>(&mut payees, @0xeb61a0036cbecd183b5eb9fc03f597b5);
      Vector::push_back<u64>(&mut amounts, 3697518169);
      
      Vector::push_back<address>(&mut payees, @0x23a14159ad0de5f4c6a4c3856736a060);
      Vector::push_back<u64>(&mut amounts, 3773404533);
      
      Vector::push_back<address>(&mut payees, @0x562945a0318e392740f25e9630f10ea9);
      Vector::push_back<u64>(&mut amounts, 6754410022);
      
      Vector::push_back<address>(&mut payees, @0xa3656a653f356002d16457353a3e97bb);
      Vector::push_back<u64>(&mut amounts, 4149081940);
      
      Vector::push_back<address>(&mut payees, @0xded5ab32af77723987af26413b112862);
      Vector::push_back<u64>(&mut amounts, 5250500036);
      
      Vector::push_back<address>(&mut payees, @0x40ed7061ce593a448fec341041209955);
      Vector::push_back<u64>(&mut amounts, 5933385688);
      
      Vector::push_back<address>(&mut payees, @0xc8221126329265df7494eb4ef72f42df);
      Vector::push_back<u64>(&mut amounts, 6375697670);
      
      Vector::push_back<address>(&mut payees, @0x4e8ae80fb0a869c52c9644297afea09b);
      Vector::push_back<u64>(&mut amounts, 1001834548);
      
      Vector::push_back<address>(&mut payees, @0x409ab37d13b0099f5b209f0568d95a23);
      Vector::push_back<u64>(&mut amounts, 6160518925);
      
      Vector::push_back<address>(&mut payees, @0x3c41e3a59d75a505f9b0416512d0d6b7);
      Vector::push_back<u64>(&mut amounts, 907271589);
      
      Vector::push_back<address>(&mut payees, @0xd0ccf388975f81b387a0b0bf931900c7);
      Vector::push_back<u64>(&mut amounts, 371409686);
      
      Vector::push_back<address>(&mut payees, @0xc9236c9fbe8f79aef0fbf666aad22a21);
      Vector::push_back<u64>(&mut amounts, 126254864);
      
      Vector::push_back<address>(&mut payees, @0x608e87e275c94ffc69dca73726d7f446);
      Vector::push_back<u64>(&mut amounts, 126254864);
      
      Vector::push_back<address>(&mut payees, @0xe94cfd3e87ebc254e78e32db6cd873b5);
      Vector::push_back<u64>(&mut amounts, 894826220);
      
      Vector::push_back<address>(&mut payees, @0x374af873fb04f4c4d679e8894360c256);
      Vector::push_back<u64>(&mut amounts, 2569286603);
      
      Vector::push_back<address>(&mut payees, @0xea7782a50dabc1a18d2c6d06819bffcb);
      Vector::push_back<u64>(&mut amounts, 5034733263);
      
      Vector::push_back<address>(&mut payees, @0x29dc2d569a6489376b56521e18a0ab3d);
      Vector::push_back<u64>(&mut amounts, 4235320063);
      
      Vector::push_back<address>(&mut payees, @0xbae47d4a4f4a3ffc21ac5bfe1d782e08);
      Vector::push_back<u64>(&mut amounts, 1767863376);
      
      Vector::push_back<address>(&mut payees, @0xa38e7b75d69dbf478cceb9df06190b4c);
      Vector::push_back<u64>(&mut amounts, 4350663196);
      
      Vector::push_back<address>(&mut payees, @0x8e45677162e4fbfe7252e3c96eee3e06);
      Vector::push_back<u64>(&mut amounts, 5297823071);
      
      Vector::push_back<address>(&mut payees, @0xa65ca0b697c91efdc8521b4e751d391a);
      Vector::push_back<u64>(&mut amounts, 6180454013);
      
      Vector::push_back<address>(&mut payees, @0x0285159467a10a77a50dfa40ddda5ff1);
      Vector::push_back<u64>(&mut amounts, 4011780319);
      
      Vector::push_back<address>(&mut payees, @0xd8f82ce59686dd9f11e53ac3372e39d6);
      Vector::push_back<u64>(&mut amounts, 3347857164);
      
      Vector::push_back<address>(&mut payees, @0x4b6a22131b71adb1d14dc74c191e78bc);
      Vector::push_back<u64>(&mut amounts, 2611336972);
      
      Vector::push_back<address>(&mut payees, @0x08b5d088d55667b2b44ba8171d8515f9);
      Vector::push_back<u64>(&mut amounts, 4109647372);
      
      Vector::push_back<address>(&mut payees, @0xd7aa7ee6e574a7263713dd1ec2fde155);
      Vector::push_back<u64>(&mut amounts, 4667631615);
      
      Vector::push_back<address>(&mut payees, @0x35b6a7ed524874ceee7a6d8dc00a9693);
      Vector::push_back<u64>(&mut amounts, 1810218852);
      
      Vector::push_back<address>(&mut payees, @0xf622ff0432f9c477d7f32645eb791d2a);
      Vector::push_back<u64>(&mut amounts, 4244793394);
      
      Vector::push_back<address>(&mut payees, @0x7bfb6890025f47a7812714cd60710849);
      Vector::push_back<u64>(&mut amounts, 3043036408);
      
      Vector::push_back<address>(&mut payees, @0x2000146c871fc552339f9b1718c0b975);
      Vector::push_back<u64>(&mut amounts, 5151054840);
      
      Vector::push_back<address>(&mut payees, @0x54be57c4ccdbdcc56dd4ce115cf774f1);
      Vector::push_back<u64>(&mut amounts, 2932001094);
      
      Vector::push_back<address>(&mut payees, @0x003a47a42fa29a9f63c0f80c431e6964);
      Vector::push_back<u64>(&mut amounts, 7022285394);
      
      Vector::push_back<address>(&mut payees, @0xf448b74936c38b47b22aeb2381272d68);
      Vector::push_back<u64>(&mut amounts, 82556298);
      
      Vector::push_back<address>(&mut payees, @0x51f32b3c6c3e20eb6ea25874ab737f27);
      Vector::push_back<u64>(&mut amounts, 3025932329);
      
      Vector::push_back<address>(&mut payees, @0x7025d084887b0688fc8e324ad1391479);
      Vector::push_back<u64>(&mut amounts, 2033194489);
      
      Vector::push_back<address>(&mut payees, @0xcd888a3da562fc5d0d7a31d609b52eb1);
      Vector::push_back<u64>(&mut amounts, 1076393720);
      
      Vector::push_back<address>(&mut payees, @0x77e8601adf1fed32dfe09ea7c938b2f9);
      Vector::push_back<u64>(&mut amounts, 2949075067);
      
      Vector::push_back<address>(&mut payees, @0xc10328ecdea3c0c8da49c79e96d809c0);
      Vector::push_back<u64>(&mut amounts, 2719507338);
      
      Vector::push_back<address>(&mut payees, @0x66ff206ad30daeebff8b55fca2241a4a);
      Vector::push_back<u64>(&mut amounts, 6697350299);
      
      Vector::push_back<address>(&mut payees, @0x4cb136b1ff72bc1e83ab468739219be0);
      Vector::push_back<u64>(&mut amounts, 2751839464);
      
      Vector::push_back<address>(&mut payees, @0xdc297119242aace22ab6b5e1e4372e59);
      Vector::push_back<u64>(&mut amounts, 2712402374);
      
      Vector::push_back<address>(&mut payees, @0x129f3cdcc32b119628177f56b9a65dff);
      Vector::push_back<u64>(&mut amounts, 2733994494);
      
      Vector::push_back<address>(&mut payees, @0x1555565d02f38a0f01033c519e21a6e6);
      Vector::push_back<u64>(&mut amounts, 2716332659);
      
      Vector::push_back<address>(&mut payees, @0xa4295b144805abfcf755fd2eb3683110);
      Vector::push_back<u64>(&mut amounts, 2711945617);
      
      Vector::push_back<address>(&mut payees, @0x5edd1d187b4fca5325ecff4ac8a42023);
      Vector::push_back<u64>(&mut amounts, 7336577580);
      
      Vector::push_back<address>(&mut payees, @0xb3279314fe85282d2f50a0c290ca83c0);
      Vector::push_back<u64>(&mut amounts, 2725016030);
      
      Vector::push_back<address>(&mut payees, @0x933e6fd4c2e5896d065cd916d8ac65a5);
      Vector::push_back<u64>(&mut amounts, 2748101998);
      
      Vector::push_back<address>(&mut payees, @0x88d2ed4905f65b8b841e1707069126e2);
      Vector::push_back<u64>(&mut amounts, 5044812075);
      
      Vector::push_back<address>(&mut payees, @0xdee1a11c0a2f1cee7c1409d606d94501);
      Vector::push_back<u64>(&mut amounts, 3822660448);
      
      Vector::push_back<address>(&mut payees, @0x443898ef3b16239e6c1921b1b5f585aa);
      Vector::push_back<u64>(&mut amounts, 4144827750);
      
      Vector::push_back<address>(&mut payees, @0x1910ca1429ac0e71cf8a7ab7cc546ff6);
      Vector::push_back<u64>(&mut amounts, 1434076494);
      
      Vector::push_back<address>(&mut payees, @0x102f5f8fb243ecf41d98f49f98712fff);
      Vector::push_back<u64>(&mut amounts, 1812869576);
      
      Vector::push_back<address>(&mut payees, @0xefff3721c356f7d95f08aa780a447df9);
      Vector::push_back<u64>(&mut amounts, 8508968451);
      
      Vector::push_back<address>(&mut payees, @0x2d7cee663acd936d98c03ec00b787cd6);
      Vector::push_back<u64>(&mut amounts, 4726562139);
      
      Vector::push_back<address>(&mut payees, @0x33eb7e29634cf801aed532526db80830);
      Vector::push_back<u64>(&mut amounts, 1823533741);
      
      Vector::push_back<address>(&mut payees, @0x85eae0bda113df19d7db8f20899bbf84);
      Vector::push_back<u64>(&mut amounts, 1849131373);
      
      Vector::push_back<address>(&mut payees, @0x78db4ef8299e06a99abd7b47c51310f0);
      Vector::push_back<u64>(&mut amounts, 1844200307);
      
      Vector::push_back<address>(&mut payees, @0xfdb3872d5906e756083e830483745b89);
      Vector::push_back<u64>(&mut amounts, 4864537552);
      
      Vector::push_back<address>(&mut payees, @0xf07d8be3d6042a9830f6c9765112adb9);
      Vector::push_back<u64>(&mut amounts, 1839562806);
      
      Vector::push_back<address>(&mut payees, @0x9e13fe49c6fe6855aa68c891bcb17354);
      Vector::push_back<u64>(&mut amounts, 1843550506);
      
      Vector::push_back<address>(&mut payees, @0x202d50484348b63f616012b28a3b98ff);
      Vector::push_back<u64>(&mut amounts, 1836834802);
      
      Vector::push_back<address>(&mut payees, @0xcd0002f20fac0735ea3ee2ee6383687e);
      Vector::push_back<u64>(&mut amounts, 1851894059);
      
      Vector::push_back<address>(&mut payees, @0x6e873a65739c9e54ebd4f7983a7a303b);
      Vector::push_back<u64>(&mut amounts, 1848312698);
      
      Vector::push_back<address>(&mut payees, @0x84ebcb26903f9cc52627ec8b7d4a3784);
      Vector::push_back<u64>(&mut amounts, 1844200307);
      
      Vector::push_back<address>(&mut payees, @0x7798f4b9e9c35c35e8cfe7375985cbb0);
      Vector::push_back<u64>(&mut amounts, 1841586410);
      
      Vector::push_back<address>(&mut payees, @0x567036ac9543976069504c8f92d3850d);
      Vector::push_back<u64>(&mut amounts, 1843643995);
      
      Vector::push_back<address>(&mut payees, @0x3e123b5ca7845bb656047fba812560cf);
      Vector::push_back<u64>(&mut amounts, 1846420586);
      
      Vector::push_back<address>(&mut payees, @0xec9e0eac9aeffa9c47db0db9f4e72e57);
      Vector::push_back<u64>(&mut amounts, 1844452004);
      
      Vector::push_back<address>(&mut payees, @0xda26a623fcf0a7fb067c482a50c86ea3);
      Vector::push_back<u64>(&mut amounts, 1848737868);
      
      Vector::push_back<address>(&mut payees, @0xd31acbfd47fc0e8cf5602f15fc103308);
      Vector::push_back<u64>(&mut amounts, 1846190209);
      
      Vector::push_back<address>(&mut payees, @0x4d63b923ad8241249865555ccd2c93f9);
      Vector::push_back<u64>(&mut amounts, 1854431258);
      
      Vector::push_back<address>(&mut payees, @0x32d0db65b80c6ba5ff38c602c015402e);
      Vector::push_back<u64>(&mut amounts, 1826586158);
      
      Vector::push_back<address>(&mut payees, @0xf4a0ccfe1529502ce3e43fbd3faae8e7);
      Vector::push_back<u64>(&mut amounts, 1843834800);
      
      Vector::push_back<address>(&mut payees, @0xeaf56c57ad1f005a50cb75def55f4ef6);
      Vector::push_back<u64>(&mut amounts, 1857289209);
      
      Vector::push_back<address>(&mut payees, @0x66e64650e22ed0d05d063f640aa51550);
      Vector::push_back<u64>(&mut amounts, 5465274528);
      
      Vector::push_back<address>(&mut payees, @0xaa508e69ed22a31324cb0f3c49ca5be3);
      Vector::push_back<u64>(&mut amounts, 1846278172);
      
      Vector::push_back<address>(&mut payees, @0xf225ca53e2c65b254f1a5adba9916b36);
      Vector::push_back<u64>(&mut amounts, 1849609722);
      
      Vector::push_back<address>(&mut payees, @0x4a68912ceca2e164bea24a2b7903ccc4);
      Vector::push_back<u64>(&mut amounts, 1821176803);
      
      Vector::push_back<address>(&mut payees, @0xab6baf752a60f937974df5d4a3fd202c);
      Vector::push_back<u64>(&mut amounts, 1849860374);
      
      Vector::push_back<address>(&mut payees, @0x28419fa12866530ed702c0623756fc74);
      Vector::push_back<u64>(&mut amounts, 1374530285);
      
      Vector::push_back<address>(&mut payees, @0xe48e99008c10c061b4bc22f156d169e4);
      Vector::push_back<u64>(&mut amounts, 1854328389);
      
      Vector::push_back<address>(&mut payees, @0xf6ba89a0598c308be9477eb173bbbef6);
      Vector::push_back<u64>(&mut amounts, 1849521760);
      
      Vector::push_back<address>(&mut payees, @0xc4a6a95be863945ed9c86f935f950c71);
      Vector::push_back<u64>(&mut amounts, 3344453841);
      
      Vector::push_back<address>(&mut payees, @0xfc9f48473f30dcdf102ec0c521c4a3d8);
      Vector::push_back<u64>(&mut amounts, 1836697213);
      
      Vector::push_back<address>(&mut payees, @0x587847de32d7cc2ee597e0998a1f3072);
      Vector::push_back<u64>(&mut amounts, 1837003931);
      
      Vector::push_back<address>(&mut payees, @0x2548fb5c2191b420c98bb3a71bde148d);
      Vector::push_back<u64>(&mut amounts, 76862179);
      
      Vector::push_back<address>(&mut payees, @0x81ba66ce38960d9a7404b32e02936c3a);
      Vector::push_back<u64>(&mut amounts, 1846272777);
      
      Vector::push_back<address>(&mut payees, @0xb3d831278cfc7f0b8aaa60e9df06c2fd);
      Vector::push_back<u64>(&mut amounts, 1828741562);
      
      Vector::push_back<address>(&mut payees, @0xf85ee438b0c107826682f55e370ebabb);
      Vector::push_back<u64>(&mut amounts, 1844452004);
      
      Vector::push_back<address>(&mut payees, @0x0ed2db8d46a607908bfe7219dcb6182b);
      Vector::push_back<u64>(&mut amounts, 1099685197);
      
      Vector::push_back<address>(&mut payees, @0xaadfde6a31290a6ef869a0ed4994fc62);
      Vector::push_back<u64>(&mut amounts, 1096623406);
      
      Vector::push_back<address>(&mut payees, @0x8e69a089cdfb1842b57c7e6e79f8a4bb);
      Vector::push_back<u64>(&mut amounts, 1104363700);
      
      Vector::push_back<address>(&mut payees, @0x4ec9e979cfc61f64ced3c23d6d6afa27);
      Vector::push_back<u64>(&mut amounts, 3229641073);
      
      Vector::push_back<address>(&mut payees, @0x93558b1572e0a45197ac30b267058491);
      Vector::push_back<u64>(&mut amounts, 1113342353);
      
      Vector::push_back<address>(&mut payees, @0x2e01b76969c3a751f7ad27449c59cc96);
      Vector::push_back<u64>(&mut amounts, 1114613026);
      
      Vector::push_back<address>(&mut payees, @0x240640b0c169ebf6b02c2707050c2fcf);
      Vector::push_back<u64>(&mut amounts, 1106065200);
      
      Vector::push_back<address>(&mut payees, @0x089d8383e672237a35460b6439b75597);
      Vector::push_back<u64>(&mut amounts, 7008606731);
      
      Vector::push_back<address>(&mut payees, @0xcb8239273bdf82f2b865b931b274d97c);
      Vector::push_back<u64>(&mut amounts, 4491066759);
      
      Vector::push_back<address>(&mut payees, @0xc550b974588aecc33fa98a8730278fe2);
      Vector::push_back<u64>(&mut amounts, 1096377525);
      
      Vector::push_back<address>(&mut payees, @0x53d2186c762d0945281f8cb1753fa55a);
      Vector::push_back<u64>(&mut amounts, 1114673913);
      
      Vector::push_back<address>(&mut payees, @0x69ff159519274d828793563b14056e4c);
      Vector::push_back<u64>(&mut amounts, 2073084541);
      
      Vector::push_back<address>(&mut payees, @0x30ea471095b6abbd86e484c6e1d9a523);
      Vector::push_back<u64>(&mut amounts, 1092836843);
      
      Vector::push_back<address>(&mut payees, @0xab510b4c6616778c3c3dd56c6d714699);
      Vector::push_back<u64>(&mut amounts, 1112249658);
      
      Vector::push_back<address>(&mut payees, @0xd3020d4924a33a14ddc4614f0b016552);
      Vector::push_back<u64>(&mut amounts, 1116570512);
      
      Vector::push_back<address>(&mut payees, @0xcff6f1a8eac1cf0be9d7db872e82a533);
      Vector::push_back<u64>(&mut amounts, 2825148683);
      
      Vector::push_back<address>(&mut payees, @0x5d6fe45fe8dd4c030b7fbd7523c48ac4);
      Vector::push_back<u64>(&mut amounts, 1102641350);
      
      Vector::push_back<address>(&mut payees, @0x6c15758d25ea2d1bb9f8fead6e083ad0);
      Vector::push_back<u64>(&mut amounts, 2411656559);
      
      Vector::push_back<address>(&mut payees, @0x8fcdd5aa1bd386c4739c5f7d9687c531);
      Vector::push_back<u64>(&mut amounts, 1103785986);
      
      Vector::push_back<address>(&mut payees, @0xfc68faba26f67e7bb07b6d594023c0ec);
      Vector::push_back<u64>(&mut amounts, 1297859516);
      
      Vector::push_back<address>(&mut payees, @0xedc623def41d26f61f0bf915791a9b47);
      Vector::push_back<u64>(&mut amounts, 1111725752);
      
      Vector::push_back<address>(&mut payees, @0x172f67fa898ceab7d5dbac8a48f5e542);
      Vector::push_back<u64>(&mut amounts, 1089733480);
      
      Vector::push_back<address>(&mut payees, @0xcb8efc6b670e227ec5434f0f6f4ed100);
      Vector::push_back<u64>(&mut amounts, 1113919886);
      
      Vector::push_back<address>(&mut payees, @0xca949aa34965a5984c2bffff69237216);
      Vector::push_back<u64>(&mut amounts, 943048790);
      
      Vector::push_back<address>(&mut payees, @0xc9ecb4f084a85fee7e5c19875cc491b0);
      Vector::push_back<u64>(&mut amounts, 1110515673);
      
      Vector::push_back<address>(&mut payees, @0x81aedab86d78d4eba48e0a166076dba8);
      Vector::push_back<u64>(&mut amounts, 1116479780);
      
      Vector::push_back<address>(&mut payees, @0xefa89bd641e532be111a9e1ebfa3a515);
      Vector::push_back<u64>(&mut amounts, 2367712787);
      
      Vector::push_back<address>(&mut payees, @0x4498b2490b70b8ace45eb75b6152c41d);
      Vector::push_back<u64>(&mut amounts, 1091957924);
      
      Vector::push_back<address>(&mut payees, @0x2b3c6f99b9838fd5dfda2d85adf7f93e);
      Vector::push_back<u64>(&mut amounts, 1110619038);
      
      Vector::push_back<address>(&mut payees, @0x59e17aec701997b095e9e76de9b842da);
      Vector::push_back<u64>(&mut amounts, 1102696036);
      
      Vector::push_back<address>(&mut payees, @0x64e82f1bf6cdc0e241bad5468a82cbb0);
      Vector::push_back<u64>(&mut amounts, 6933064591);
      
      Vector::push_back<address>(&mut payees, @0x0d22db425dce9e10803da05395fc0110);
      Vector::push_back<u64>(&mut amounts, 1437316804);
      
      Vector::push_back<address>(&mut payees, @0x2d7c776596e1ba2cf7890dc90a7f928b);
      Vector::push_back<u64>(&mut amounts, 3702879425);
      
      Vector::push_back<address>(&mut payees, @0x2403c0ab0a3a0e6864c166ee91462cf0);
      Vector::push_back<u64>(&mut amounts, 1434620339);
      
      Vector::push_back<address>(&mut payees, @0x8e18af0a3668d0c9629eb62aa60a7937);
      Vector::push_back<u64>(&mut amounts, 1433001718);
      
      Vector::push_back<address>(&mut payees, @0x3e12bf7221f6d2a74f9e861cf040b6c4);
      Vector::push_back<u64>(&mut amounts, 1440141828);
      
      Vector::push_back<address>(&mut payees, @0x2fa12852e87dacac8da59b56f781d90f);
      Vector::push_back<u64>(&mut amounts, 1444701818);
      
      Vector::push_back<address>(&mut payees, @0x07b467f6cdb969dd949dc8a30c770261);
      Vector::push_back<u64>(&mut amounts, 1440141828);
      
      Vector::push_back<address>(&mut payees, @0xb7c0294fa353c029f7ccc1540725011d);
      Vector::push_back<u64>(&mut amounts, 1437316804);
      
      Vector::push_back<address>(&mut payees, @0x3f5898c4ae87881bf584e02f814de491);
      Vector::push_back<u64>(&mut amounts, 1437474694);
      
      Vector::push_back<address>(&mut payees, @0x9c5a42f60f309a4db101dceab8c1fb3c);
      Vector::push_back<u64>(&mut amounts, 1440124165);
      
      Vector::push_back<address>(&mut payees, @0xbd47ce7975af0fdcc4e1eccde85aff16);
      Vector::push_back<u64>(&mut amounts, 1440124165);
      
      Vector::push_back<address>(&mut payees, @0x91f13415f3f190553a9c6555ac491163);
      Vector::push_back<u64>(&mut amounts, 1412693374);
      
      Vector::push_back<address>(&mut payees, @0x3a44c98b358f7924307e5bab342bb3b9);
      Vector::push_back<u64>(&mut amounts, 1420226840);
      
      Vector::push_back<address>(&mut payees, @0xff3d756a300638f835b3c38ef64eeeb3);
      Vector::push_back<u64>(&mut amounts, 1405265178);
      
      Vector::push_back<address>(&mut payees, @0x60426552926a2570770b7f28d2a87713);
      Vector::push_back<u64>(&mut amounts, 1401042865);
      
      Vector::push_back<address>(&mut payees, @0xaf7384e8cc2ac670e18c9558aa5bc797);
      Vector::push_back<u64>(&mut amounts, 1400967039);
      
      Vector::push_back<address>(&mut payees, @0x198805eb5587118a81cf67448d2564bd);
      Vector::push_back<u64>(&mut amounts, 1396520233);
      
      Vector::push_back<address>(&mut payees, @0xf83e50b50124b47c48a6e25e6a8065f6);
      Vector::push_back<u64>(&mut amounts, 1395736341);
      
      Vector::push_back<address>(&mut payees, @0x178a850a05167bf8b145f13384f248fa);
      Vector::push_back<u64>(&mut amounts, 3796804634);
      
      Vector::push_back<address>(&mut payees, @0xdc86560326f5010a4cd992575ead4985);
      Vector::push_back<u64>(&mut amounts, 1405483988);
      
      Vector::push_back<address>(&mut payees, @0x9b160f03bd71dfdd44559d679b457a52);
      Vector::push_back<u64>(&mut amounts, 1403193753);
      
      Vector::push_back<address>(&mut payees, @0x29df831c9884ee7311c23c8a722a82fd);
      Vector::push_back<u64>(&mut amounts, 1405363222);
      
      Vector::push_back<address>(&mut payees, @0xc38dde755a65e90e5ecd642ee0119a94);
      Vector::push_back<u64>(&mut amounts, 1405396025);
      
      Vector::push_back<address>(&mut payees, @0x1ad28489b468e8b3a5e02c433b9b2cc8);
      Vector::push_back<u64>(&mut amounts, 1407928390);
      
      Vector::push_back<address>(&mut payees, @0x939d39662c04615657fdf167ad735889);
      Vector::push_back<u64>(&mut amounts, 3496347492);
      
      Vector::push_back<address>(&mut payees, @0x49c053815089b65a6eda76bf546b2541);
      Vector::push_back<u64>(&mut amounts, 1402212279);
      
      Vector::push_back<address>(&mut payees, @0xf95c922f5d8d1bd63c0aa7423c96858b);
      Vector::push_back<u64>(&mut amounts, 1402297484);
      
      Vector::push_back<address>(&mut payees, @0xb7aaa47b4e665b1b26e17a66f375d314);
      Vector::push_back<u64>(&mut amounts, 996056655);
      
      Vector::push_back<address>(&mut payees, @0x3f5aaa374a1a0e40b91b1dab1981892b);
      Vector::push_back<u64>(&mut amounts, 996085109);
      
      Vector::push_back<address>(&mut payees, @0x89577b9c44fe0cb7d3fda7a39c5fc737);
      Vector::push_back<u64>(&mut amounts, 990358901);
      
      Vector::push_back<address>(&mut payees, @0x24d4444b83e1bc574a1ca2943cca64e9);
      Vector::push_back<u64>(&mut amounts, 996085109);
      
      Vector::push_back<address>(&mut payees, @0xf918dcc4262c8cb5b6afb9bae686e75b);
      Vector::push_back<u64>(&mut amounts, 5640668653);
      
      Vector::push_back<address>(&mut payees, @0x7d1c160e08b666d3a47e9812924f323b);
      Vector::push_back<u64>(&mut amounts, 992272124);
      
      Vector::push_back<address>(&mut payees, @0x7e8eed9edc268e3bd2b5645f9156d892);
      Vector::push_back<u64>(&mut amounts, 998041555);
      
      Vector::push_back<address>(&mut payees, @0xfc4d78eba7c8ddc74a177828591cd06b);
      Vector::push_back<u64>(&mut amounts, 994180860);
      
      Vector::push_back<address>(&mut payees, @0xb01d6811ed92cefc9cc7007a45cb303e);
      Vector::push_back<u64>(&mut amounts, 996056655);
      
      Vector::push_back<address>(&mut payees, @0x15c59ea366bab3e965e3ed5f82b460f4);
      Vector::push_back<u64>(&mut amounts, 993930209);
      
      Vector::push_back<address>(&mut payees, @0x8afed6b30c15b38c346f15393f01a054);
      Vector::push_back<u64>(&mut amounts, 5058797396);
      
      Vector::push_back<address>(&mut payees, @0x2d4767b70a876b75521682f79cb3ebdd);
      Vector::push_back<u64>(&mut amounts, 998123619);
      
      Vector::push_back<address>(&mut payees, @0xcc82f03654535c0b19a184769ad7942e);
      Vector::push_back<u64>(&mut amounts, 994180860);
      
      Vector::push_back<address>(&mut payees, @0xfdc33edf325b9bee82c675de892bd9b6);
      Vector::push_back<u64>(&mut amounts, 998123619);
      
      Vector::push_back<address>(&mut payees, @0x7b031749465e73fd986470f163eb6d18);
      Vector::push_back<u64>(&mut amounts, 993990055);
      
      Vector::push_back<address>(&mut payees, @0x8c5707c094bb08b0ac2afb71fed2109b);
      Vector::push_back<u64>(&mut amounts, 996085109);
      
      Vector::push_back<address>(&mut payees, @0x2d9dbcbaaedde0f2c6c8fcc951eb84fc);
      Vector::push_back<u64>(&mut amounts, 993842246);
      
      Vector::push_back<address>(&mut payees, @0x16fffcce80dc40bf7b7d3cca89435849);
      Vector::push_back<u64>(&mut amounts, 991927983);
      
      Vector::push_back<address>(&mut payees, @0xf0b4469a00615b3a0ce3138ac3629311);
      Vector::push_back<u64>(&mut amounts, 996085109);
      
      Vector::push_back<address>(&mut payees, @0x7b537399ee7859120d250c09b28c32e1);
      Vector::push_back<u64>(&mut amounts, 996085109);
      
      Vector::push_back<address>(&mut payees, @0x84a5c4dddc27dc498deef21e61d5eff6);
      Vector::push_back<u64>(&mut amounts, 993990055);
      
      Vector::push_back<address>(&mut payees, @0x628178e7d108cf9f658343d7f7d34287);
      Vector::push_back<u64>(&mut amounts, 996056655);
      
      Vector::push_back<address>(&mut payees, @0x3a0be21dcc53695d9ea1ad804b7a015c);
      Vector::push_back<u64>(&mut amounts, 996056655);
      
      Vector::push_back<address>(&mut payees, @0x45da249c90a4a77804d2644a3cffc7d1);
      Vector::push_back<u64>(&mut amounts, 992003809);
      
      Vector::push_back<address>(&mut payees, @0x56a7094213d3d0415ecb21a7a3817f5e);
      Vector::push_back<u64>(&mut amounts, 3345165658);
      
      Vector::push_back<address>(&mut payees, @0x93743a2755b1be13c817fc4c22245708);
      Vector::push_back<u64>(&mut amounts, 996056655);
      
      Vector::push_back<address>(&mut payees, @0x5a4cf01c911d3b2bb840ce613e62a1a4);
      Vector::push_back<u64>(&mut amounts, 1642658797);
      
      Vector::push_back<address>(&mut payees, @0xe866cfda544b394d78b5fa986e73c3db);
      Vector::push_back<u64>(&mut amounts, 993824583);
      
      Vector::push_back<address>(&mut payees, @0x745c9dc4a51062b928d42a2fa7e29757);
      Vector::push_back<u64>(&mut amounts, 1006371163);
      
      Vector::push_back<address>(&mut payees, @0x455c3e2c7c6d5dd7d456d50d976f34d6);
      Vector::push_back<u64>(&mut amounts, 1004466914);
      
      Vector::push_back<address>(&mut payees, @0x81f29b02799a6748a434b47fe6665075);
      Vector::push_back<u64>(&mut amounts, 1006371163);
      
      Vector::push_back<address>(&mut payees, @0x4cad9cc00c4d0215eaa16038958aaace);
      Vector::push_back<u64>(&mut amounts, 1006518972);
      
      Vector::push_back<address>(&mut payees, @0x79fbd7993869339a7e8597cd05af1d5c);
      Vector::push_back<u64>(&mut amounts, 1006518972);
      
      Vector::push_back<address>(&mut payees, @0x337f71b187bd1dc42fab032f95471473);
      Vector::push_back<u64>(&mut amounts, 1006361082);
      
      Vector::push_back<address>(&mut payees, @0x20acec5bd452ab73ccdf4653d200a14e);
      Vector::push_back<u64>(&mut amounts, 1006431010);
      
      Vector::push_back<address>(&mut payees, @0x4a500ccd9026feb7900460a04fcb2b47);
      Vector::push_back<u64>(&mut amounts, 1006518972);
      
      Vector::push_back<address>(&mut payees, @0xf7c540fd70d8ddc754733e15c44e8592);
      Vector::push_back<u64>(&mut amounts, 4597795347);
      
      Vector::push_back<address>(&mut payees, @0xd1c796b9b5e91c088ab41d358c7a9c06);
      Vector::push_back<u64>(&mut amounts, 1004554877);
      
      Vector::push_back<address>(&mut payees, @0x88a7fbfee20ed0054ae14df747970aaa);
      Vector::push_back<u64>(&mut amounts, 1006371163);
      
      Vector::push_back<address>(&mut payees, @0xf344c21223f38119721bc3b60e169549);
      Vector::push_back<u64>(&mut amounts, 3121828528);
      
      Vector::push_back<address>(&mut payees, @0x95fb69352570f66255e27ade3bf6985c);
      Vector::push_back<u64>(&mut amounts, 1004337478);
      
      Vector::push_back<address>(&mut payees, @0xe8e37d2e49738a58a4a4d3714d34c374);
      Vector::push_back<u64>(&mut amounts, 1006371163);
      
      Vector::push_back<address>(&mut payees, @0x905dba2cee3093577896fdca6cf7af37);
      Vector::push_back<u64>(&mut amounts, 981465693);
      
      Vector::push_back<address>(&mut payees, @0x30d2561019ac9b58e57ab2e961c10ddd);
      Vector::push_back<u64>(&mut amounts, 983842667);
      
      Vector::push_back<address>(&mut payees, @0xfd25243a6501cc431be66567257271ef);
      Vector::push_back<u64>(&mut amounts, 983842667);
      
      Vector::push_back<address>(&mut payees, @0x871ea5492cceeda0f5d81fcd1ae350cb);
      Vector::push_back<u64>(&mut amounts, 975399493);
      
      Vector::push_back<address>(&mut payees, @0x3eeb485e63f4a152395523b52fe09dc7);
      Vector::push_back<u64>(&mut amounts, 983930629);
      
      Vector::push_back<address>(&mut payees, @0x11036637df53818456e1e68cd5b57e56);
      Vector::push_back<u64>(&mut amounts, 983842667);
      
      Vector::push_back<address>(&mut payees, @0xf37b58c86ca58d07d51e847ddb196d31);
      Vector::push_back<u64>(&mut amounts, 983930629);
      
      Vector::push_back<address>(&mut payees, @0xcfbe506a9010c2a6664c5e1b4c36be48);
      Vector::push_back<u64>(&mut amounts, 983713230);
      
      Vector::push_back<address>(&mut payees, @0x48e24dd5aca63f73e48d0588ea491a91);
      Vector::push_back<u64>(&mut amounts, 983713230);
      
      Vector::push_back<address>(&mut payees, @0x8b6beee603e319b19a28d69a8c575bc0);
      Vector::push_back<u64>(&mut amounts, 985806762);
      
      Vector::push_back<address>(&mut payees, @0xc577c0922106b5077aaebbd16a2677c5);
      Vector::push_back<u64>(&mut amounts, 4168646571);
      
      Vector::push_back<address>(&mut payees, @0xc338cc68464493d992f8e46adff61c1b);
      Vector::push_back<u64>(&mut amounts, 985746915);
      
      Vector::push_back<address>(&mut payees, @0x85eba38fe6d46e6530301b813d71ef3f);
      Vector::push_back<u64>(&mut amounts, 983713230);
      
      Vector::push_back<address>(&mut payees, @0x682ca25f4bdf0299a922e93cfd6cc652);
      Vector::push_back<u64>(&mut amounts, 3951867985);
      
      Vector::push_back<address>(&mut payees, @0x768d425c64e9a812ced31258260fc4f0);
      Vector::push_back<u64>(&mut amounts, 983930629);
      
      Vector::push_back<address>(&mut payees, @0xb7b5a20f2b0c5b3143a477e7e7162dc8);
      Vector::push_back<u64>(&mut amounts, 2785912766);
      
      Vector::push_back<address>(&mut payees, @0x2c099722f267b86012b05b27777c1c0b);
      Vector::push_back<u64>(&mut amounts, 991784661);
      
      Vector::push_back<address>(&mut payees, @0x4b43f8d1566cd0b65ee38bebf91b659e);
      Vector::push_back<u64>(&mut amounts, 989963888);
      
      Vector::push_back<address>(&mut payees, @0x04b7716d23ee196dc611ed655e457d80);
      Vector::push_back<u64>(&mut amounts, 870946409);
      
      Vector::push_back<address>(&mut payees, @0x10444e9a399edc4bb325dcffd2ca1105);
      Vector::push_back<u64>(&mut amounts, 993906647);
      
      Vector::push_back<address>(&mut payees, @0x601f9be73b18603d557498ae88ec5067);
      Vector::push_back<u64>(&mut amounts, 996023740);
      
      Vector::push_back<address>(&mut payees, @0x415cedefd055c5dde8348a4294f60a37);
      Vector::push_back<u64>(&mut amounts, 980712211);
      
      Vector::push_back<address>(&mut payees, @0x574f849a238b3de204fe3d1e92aecc6a);
      Vector::push_back<u64>(&mut amounts, 991932470);
      
      Vector::push_back<address>(&mut payees, @0xd264040737746b6d8687953681a835ef);
      Vector::push_back<u64>(&mut amounts, 995968719);
      
      Vector::push_back<address>(&mut payees, @0x73fa972a52a458589317ed535d4cb82f);
      Vector::push_back<u64>(&mut amounts, 974120010);
      
      Vector::push_back<address>(&mut payees, @0xfe4ee66f80b56c88285e1e9c093f75ac);
      Vector::push_back<u64>(&mut amounts, 995953813);
      
      Vector::push_back<address>(&mut payees, @0x70c0258ceaf0790a1b4a1e7e75028134);
      Vector::push_back<u64>(&mut amounts, 991987492);
      
      Vector::push_back<address>(&mut payees, @0xb6bb45be857bf886fac7a5533f264f13);
      Vector::push_back<u64>(&mut amounts, 237852578);
      
      Vector::push_back<address>(&mut payees, @0x3afb4a06c280b5900d7511a8a53f4e83);
      Vector::push_back<u64>(&mut amounts, 991987492);
      
      Vector::push_back<address>(&mut payees, @0xc24653bca41878c2816d5e62428a3203);
      Vector::push_back<u64>(&mut amounts, 1001987072);
      
      Vector::push_back<address>(&mut payees, @0xba6f51b998f344950c8c5247d3f145fb);
      Vector::push_back<u64>(&mut amounts, 1000163202);
      
      Vector::push_back<address>(&mut payees, @0x56a8447044bdbc1a973118451ef43edd);
      Vector::push_back<u64>(&mut amounts, 1002144962);
      
      Vector::push_back<address>(&mut payees, @0x8ac0b6c15fe9031bc476c2d42da8878f);
      Vector::push_back<u64>(&mut amounts, 1002001978);
      
      Vector::push_back<address>(&mut payees, @0x7c2c06ff0794a7b59bb39f3d691fa0eb);
      Vector::push_back<u64>(&mut amounts, 3834111255);
      
      Vector::push_back<address>(&mut payees, @0xeecf63897b8646377780117841ba563c);
      Vector::push_back<u64>(&mut amounts, 1002089940);
      
      Vector::push_back<address>(&mut payees, @0x31d0f05a5805d4d1d889c6b229efa05d);
      Vector::push_back<u64>(&mut amounts, 1002144962);
      
      Vector::push_back<address>(&mut payees, @0x129107530df589347d5dd92da18801e4);
      Vector::push_back<u64>(&mut amounts, 1001987072);
      
      Vector::push_back<address>(&mut payees, @0x8c83aa0585def60bbd3d6a104d3a4a36);
      Vector::push_back<u64>(&mut amounts, 1002144962);
      
      Vector::push_back<address>(&mut payees, @0x89178d8919cc3608eaf05b6755c96f59);
      Vector::push_back<u64>(&mut amounts, 1000163202);
      
      Vector::push_back<address>(&mut payees, @0xab405d616150994b7c372e418d9271ba);
      Vector::push_back<u64>(&mut amounts, 998041555);
      
      Vector::push_back<address>(&mut payees, @0xb3ad9d3c8d03d97327cbb9719731bda4);
      Vector::push_back<u64>(&mut amounts, 996056655);
      
      Vector::push_back<address>(&mut payees, @0xdb53e79d846fc9b82641218966295ffc);
      Vector::push_back<u64>(&mut amounts, 3105882643);
      
      Vector::push_back<address>(&mut payees, @0x4f7f35f0673fb2ea3f076858a7d0e1ce);
      Vector::push_back<u64>(&mut amounts, 1002089940);
      
      Vector::push_back<address>(&mut payees, @0xe480db3fe69e2277837e435aebe1e703);
      Vector::push_back<u64>(&mut amounts, 3001930205);
      
      Vector::push_back<address>(&mut payees, @0x386fe7e1dda88f8bc8174f8eab13a66b);
      Vector::push_back<u64>(&mut amounts, 2921549757);
      
      Vector::push_back<address>(&mut payees, @0x52c041e794b9f0eb3b0e02c865f67d29);
      Vector::push_back<u64>(&mut amounts, 2714081789);
      
      Vector::push_back<address>(&mut payees, @0x45e51e7159a7125b50f0abc18e07e6b7);
      Vector::push_back<u64>(&mut amounts, 2279020587);
      
      Vector::push_back<address>(&mut payees, @0x43d978eac357ae1eca1f6eceb2dfe85f);
      Vector::push_back<u64>(&mut amounts, 4088264875);
      
      Vector::push_back<address>(&mut payees, @0x80fd39527d6f18ea594372c2077f7ea3);
      Vector::push_back<u64>(&mut amounts, 2243657816);
      
      Vector::push_back<address>(&mut payees, @0xe0dee4287c94dc78964d02cd1c2aa69a);
      Vector::push_back<u64>(&mut amounts, 4695775916);
      
      Vector::push_back<address>(&mut payees, @0xdd54531f39a5582a263e849b482b1c77);
      Vector::push_back<u64>(&mut amounts, 189237899);
      
      Vector::push_back<address>(&mut payees, @0x5cfa5ac6b228987c6a212966a2d1cec7);
      Vector::push_back<u64>(&mut amounts, 278005282);
      
      Vector::push_back<address>(&mut payees, @0xd6fa7c9790e3de5d0b631fd2094c6096);
      Vector::push_back<u64>(&mut amounts, 598496666);
      
      Vector::push_back<address>(&mut payees, @0xd73ae54e74f81bca6ce90e1b0b72d39c);
      Vector::push_back<u64>(&mut amounts, 480091896);
      
      Vector::push_back<address>(&mut payees, @0x1fa3103eb6103ae794792af5c4c023a7);
      Vector::push_back<u64>(&mut amounts, 3637413442);
      
      Vector::push_back<address>(&mut payees, @0x085144acdcfc33d9e9095420b24d0aee);
      Vector::push_back<u64>(&mut amounts, 695503327);
      
      Vector::push_back<address>(&mut payees, @0x8b7ade2879be9cc839af34b56f3f9aaa);
      Vector::push_back<u64>(&mut amounts, 1280467857);
      
      Vector::push_back<address>(&mut payees, @0xfa7848c002783ab0c872efd30fbbeae2);
      Vector::push_back<u64>(&mut amounts, 1142591227);
      
      Vector::push_back<address>(&mut payees, @0x08a80a2ea14315a3880e38ff3d455e4d);
      Vector::push_back<u64>(&mut amounts, 3585631644);
      
      Vector::push_back<address>(&mut payees, @0x5c96b89ed7b87445f427c5a3bd64318c);
      Vector::push_back<u64>(&mut amounts, 2230200606);
      
      Vector::push_back<address>(&mut payees, @0xadc65909c96ba2b4bb86a95a2e11c597);
      Vector::push_back<u64>(&mut amounts, 5132874222);
      
      Vector::push_back<address>(&mut payees, @0x5c2bb72eda587773c618ac787e3b6f00);
      Vector::push_back<u64>(&mut amounts, 3701483054);
      
      Vector::push_back<address>(&mut payees, @0xca9f59f1667dc637b3fb776e871f04c8);
      Vector::push_back<u64>(&mut amounts, 1542047490);
      
      Vector::push_back<address>(&mut payees, @0x8b13ae50576f167125b10aae3570e8a4);
      Vector::push_back<u64>(&mut amounts, 1589030831);
      
      Vector::push_back<address>(&mut payees, @0x2b9a4bbb08ef0ab260e12b0edf30f825);
      Vector::push_back<u64>(&mut amounts, 4219256204);
      
      Vector::push_back<address>(&mut payees, @0xa3b9dd207432ef1a82029cca0ae4c2ed);
      Vector::push_back<u64>(&mut amounts, 1704192286);
      
      Vector::push_back<address>(&mut payees, @0x71588c735a0081c62b4ef91be0b2ccd2);
      Vector::push_back<u64>(&mut amounts, 2393983637);
      
      Vector::push_back<address>(&mut payees, @0x98eb646414e3b42980e56ac536b51979);
      Vector::push_back<u64>(&mut amounts, 2073340484);
      
      Vector::push_back<address>(&mut payees, @0x595bd5ff9ef6919d4c454a45671c0519);
      Vector::push_back<u64>(&mut amounts, 1913855792);
      
      Vector::push_back<address>(&mut payees, @0x979ca6900e0fc4c1367d6c3505453c78);
      Vector::push_back<u64>(&mut amounts, 4872048411);
      
      Vector::push_back<address>(&mut payees, @0xbbb791ef00892309bff01a898ad005c2);
      Vector::push_back<u64>(&mut amounts, 3798553067);
      
      Vector::push_back<address>(&mut payees, @0x0aa58392d4277bda5f70f2f9e0f4d69e);
      Vector::push_back<u64>(&mut amounts, 1668628403);
      
      Vector::push_back<address>(&mut payees, @0xd5cf704b4cab391e6154b3a7e860838d);
      Vector::push_back<u64>(&mut amounts, 4719996929);
      
      Vector::push_back<address>(&mut payees, @0x05a5016099ab9ab588f006f283e9c133);
      Vector::push_back<u64>(&mut amounts, 1515126517);
      
      Vector::push_back<address>(&mut payees, @0xf19878c18ef0494ff8c70e8621904c44);
      Vector::push_back<u64>(&mut amounts, 3784148311);
      
      Vector::push_back<address>(&mut payees, @0x3f8ef5abbd0f43f61b2d742218675f9b);
      Vector::push_back<u64>(&mut amounts, 3794792453);
      
      Vector::push_back<address>(&mut payees, @0x2b5f14b5b7445b54a8628e1f1cf1abf4);
      Vector::push_back<u64>(&mut amounts, 3717177921);
      
      Vector::push_back<address>(&mut payees, @0xf22dc1b46f750c906cf1dfebd58fae0a);
      Vector::push_back<u64>(&mut amounts, 4463703837);
      
      Vector::push_back<address>(&mut payees, @0x525093982c54c10ca912408365628bf9);
      Vector::push_back<u64>(&mut amounts, 2446055483);
      
      Vector::push_back<address>(&mut payees, @0xd8cf2a43feeb8b3e6b3186cc7c420fa3);
      Vector::push_back<u64>(&mut amounts, 1714702093);
      
      Vector::push_back<address>(&mut payees, @0x496b62e7dd5b4c4d2f35d2ada6db57a5);
      Vector::push_back<u64>(&mut amounts, 2670568457);
      
      Vector::push_back<address>(&mut payees, @0x96e865befc44731176d8ef60235959e0);
      Vector::push_back<u64>(&mut amounts, 2036060544);
      
      Vector::push_back<address>(&mut payees, @0x3076794c34ea390026aef4b01a083e75);
      Vector::push_back<u64>(&mut amounts, 1899036071);
      
      Vector::push_back<address>(&mut payees, @0x32c9c4ccd21b0d163a6f336431584527);
      Vector::push_back<u64>(&mut amounts, 1653592371);
      
      Vector::push_back<address>(&mut payees, @0xcb2457a49bebff00eb6d12a4fc39d662);
      Vector::push_back<u64>(&mut amounts, 2627872594);
      
      Vector::push_back<address>(&mut payees, @0x10242359b4cb88815f0c2326059e491d);
      Vector::push_back<u64>(&mut amounts, 1426624910);
      
      Vector::push_back<address>(&mut payees, @0xbfc9b12182329e55055f82b5a7784bb8);
      Vector::push_back<u64>(&mut amounts, 2119528651);
      
      Vector::push_back<address>(&mut payees, @0x54c2ea476466320e12fc3b152b56ab00);
      Vector::push_back<u64>(&mut amounts, 2551473921);
      
      Vector::push_back<address>(&mut payees, @0x0a1b788638b6824e62661c2067ae70ef);
      Vector::push_back<u64>(&mut amounts, 2194968607);
      
      Vector::push_back<address>(&mut payees, @0x7a4018c192ff3b045744858202d9dbbd);
      Vector::push_back<u64>(&mut amounts, 2452741280);
      
      Vector::push_back<address>(&mut payees, @0x5ccc45fd380c6a21b4da01aadf914874);
      Vector::push_back<u64>(&mut amounts, 2356772162);
      
      Vector::push_back<address>(&mut payees, @0xa17170adc206f8992b25b8362165a777);
      Vector::push_back<u64>(&mut amounts, 2192899624);
      
      Vector::push_back<address>(&mut payees, @0xdf928d70b711312926973169a0621888);
      Vector::push_back<u64>(&mut amounts, 2245485607);
      
      Vector::push_back<address>(&mut payees, @0x2b4d0e46befded3acc339901f6610266);
      Vector::push_back<u64>(&mut amounts, 2152700564);
      
      Vector::push_back<address>(&mut payees, @0xed325cdc1ce8a648ab4d0ca191de5115);
      Vector::push_back<u64>(&mut amounts, 2071942407);
      
      Vector::push_back<address>(&mut payees, @0xabef570181d1282ed41dfd93f7550de0);
      Vector::push_back<u64>(&mut amounts, 1238893690);
      
      Vector::push_back<address>(&mut payees, @0xf57e7b10407cfe44bc021b259f855511);
      Vector::push_back<u64>(&mut amounts, 1901776914);
      
      Vector::push_back<address>(&mut payees, @0xe18a3f3db265ce264559fd638ffd6c2e);
      Vector::push_back<u64>(&mut amounts, 1108449759);
      
      Vector::push_back<address>(&mut payees, @0x338cb6fff868fa0f94f5ce4210f9b666);
      Vector::push_back<u64>(&mut amounts, 1914937615);
      
      Vector::push_back<address>(&mut payees, @0xd0547008058a5e45ab9b93cfa77a754f);
      Vector::push_back<u64>(&mut amounts, 1806534383);
      
      Vector::push_back<address>(&mut payees, @0xcca859b8f11d60e16d3c5c85684be7ac);
      Vector::push_back<u64>(&mut amounts, 1464372519);
      
      Vector::push_back<address>(&mut payees, @0xfb31fff6414a7bc48d97cdb4899faf6d);
      Vector::push_back<u64>(&mut amounts, 1938329796);
      
      Vector::push_back<address>(&mut payees, @0x401a9629c18beee8ceca48cd23c70333);
      Vector::push_back<u64>(&mut amounts, 2323547209);
      
      Vector::push_back<address>(&mut payees, @0x28a80ecacb79e0f6853fe266464d298f);
      Vector::push_back<u64>(&mut amounts, 252743293);
      
      Vector::push_back<address>(&mut payees, @0xb3125c49b173c7a437cf7cef06550f66);
      Vector::push_back<u64>(&mut amounts, 4604644621);
      
      Vector::push_back<address>(&mut payees, @0x344e8da65e124c02fd7416278ed0d2da);
      Vector::push_back<u64>(&mut amounts, 3376825782);
      
      Vector::push_back<address>(&mut payees, @0xb3b77d203bf13c97626137b2ca9d981d);
      Vector::push_back<u64>(&mut amounts, 6210148566);
      
      Vector::push_back<address>(&mut payees, @0xe2e626d231bd870e09df5eab95eac67b);
      Vector::push_back<u64>(&mut amounts, 1562609118);
      
      Vector::push_back<address>(&mut payees, @0x28d09829a777722cd932f821385d0ab8);
      Vector::push_back<u64>(&mut amounts, 6204656626);
      
      Vector::push_back<address>(&mut payees, @0xb27a2e8f37241d589a8678c3a776b013);
      Vector::push_back<u64>(&mut amounts, 5926973103);
      
      Vector::push_back<address>(&mut payees, @0x52532933d816416e2599d7ca3b52dd05);
      Vector::push_back<u64>(&mut amounts, 5830776654);
      
      Vector::push_back<address>(&mut payees, @0x9f48e3897a7cc657f689ea00769928e0);
      Vector::push_back<u64>(&mut amounts, 5776954713);
      
      Vector::push_back<address>(&mut payees, @0x551bc125a630cdfe50bd18b47d5f57fe);
      Vector::push_back<u64>(&mut amounts, 5435093695);
      
      Vector::push_back<address>(&mut payees, @0x65f8367cf3f1f8b95e59ec247ba428cd);
      Vector::push_back<u64>(&mut amounts, 2933346867);
      
      Vector::push_back<address>(&mut payees, @0xdb595dbb4332432672cc9c1f4a7645d7);
      Vector::push_back<u64>(&mut amounts, 5699080413);
      
      Vector::push_back<address>(&mut payees, @0x77e636ca4692414373511f133d5a7f6c);
      Vector::push_back<u64>(&mut amounts, 5877299590);
      
      Vector::push_back<address>(&mut payees, @0x05599bf662059185634c7418747fe883);
      Vector::push_back<u64>(&mut amounts, 5467626699);
      
      Vector::push_back<address>(&mut payees, @0xea791158c3052450ec4b864829f64d77);
      Vector::push_back<u64>(&mut amounts, 2830902965);
      
      Vector::push_back<address>(&mut payees, @0xa36e0699476d5e5808540a4e96ccd0db);
      Vector::push_back<u64>(&mut amounts, 5221548116);
      
      Vector::push_back<address>(&mut payees, @0xebad35513e82a383dcc64c585582871f);
      Vector::push_back<u64>(&mut amounts, 4634685394);
      
      Vector::push_back<address>(&mut payees, @0x3d9dcc78689238baa4e4f7e859372188);
      Vector::push_back<u64>(&mut amounts, 109797735);
      
      Vector::push_back<address>(&mut payees, @0x3cc938e874f5cdac4e075306ba7fbb7f);
      Vector::push_back<u64>(&mut amounts, 5314146855);
      
      Vector::push_back<address>(&mut payees, @0xdeb286b844f9572bd0741c6672fd0d61);
      Vector::push_back<u64>(&mut amounts, 4241338189);
      
      Vector::push_back<address>(&mut payees, @0xebc8c86331b4f7726db504c1aa3c8f28);
      Vector::push_back<u64>(&mut amounts, 790294686);
      
      Vector::push_back<address>(&mut payees, @0x2afecdf5366b010d92701bc65e268bce);
      Vector::push_back<u64>(&mut amounts, 4583251543);
      
      Vector::push_back<address>(&mut payees, @0x8e9258291161d846459584b4814d15ba);
      Vector::push_back<u64>(&mut amounts, 4445037075);
      
      Vector::push_back<address>(&mut payees, @0xc510f0c11cc0443d029d423b58e84f8f);
      Vector::push_back<u64>(&mut amounts, 2831142542);
      
      Vector::push_back<address>(&mut payees, @0xf98d4875e499bb37377365f954e8769c);
      Vector::push_back<u64>(&mut amounts, 6883901787);
      
      Vector::push_back<address>(&mut payees, @0x8c7a03307f35ebea04a9e4ecf5131a66);
      Vector::push_back<u64>(&mut amounts, 2919478369);
      
      Vector::push_back<address>(&mut payees, @0xafb7dbdbe67d9b21d0f48035b6cae9be);
      Vector::push_back<u64>(&mut amounts, 4256129318);
      
      Vector::push_back<address>(&mut payees, @0xcc3317639e4210a557428fe0085b943a);
      Vector::push_back<u64>(&mut amounts, 82714188);
      
      Vector::push_back<address>(&mut payees, @0x547c27ce25c3ef365ff3ba1f9a2c296a);
      Vector::push_back<u64>(&mut amounts, 232007549);
      
      Vector::push_back<address>(&mut payees, @0xd9e75f5b8b9e17e31b4f0d0ad3a08d1c);
      Vector::push_back<u64>(&mut amounts, 233986213);
      
      Vector::push_back<address>(&mut payees, @0x336ae39a9ba20b6b586914f1004afe0b);
      Vector::push_back<u64>(&mut amounts, 5439760863);
      
      Vector::push_back<address>(&mut payees, @0x7cd2d92326dd19c563e2d596813772f8);
      Vector::push_back<u64>(&mut amounts, 5796186087);
      
      Vector::push_back<address>(&mut payees, @0x7f88d645a234aa1adb624363e522e902);
      Vector::push_back<u64>(&mut amounts, 4587574586);
      
      Vector::push_back<address>(&mut payees, @0x2c9faf418e2df5878f2778d63ff0b56c);
      Vector::push_back<u64>(&mut amounts, 2555403389);
      
      Vector::push_back<address>(&mut payees, @0x4f116dc5bfd8a04c55c40c32b9e4a05b);
      Vector::push_back<u64>(&mut amounts, 3599417515);
      
      Vector::push_back<address>(&mut payees, @0x77d2b491246bf31a370fdf47dab960ab);
      Vector::push_back<u64>(&mut amounts, 3368286134);
      
      Vector::push_back<address>(&mut payees, @0xc0e65392a20b66b1a1d2b89ad10ffe64);
      Vector::push_back<u64>(&mut amounts, 1758258137);
      
      Vector::push_back<address>(&mut payees, @0x52255058328649cbcbf6853acb3c0706);
      Vector::push_back<u64>(&mut amounts, 640033522);
      
      Vector::push_back<address>(&mut payees, @0x1b2d7b44668eb195f4e7c5fd1472adcf);
      Vector::push_back<u64>(&mut amounts, 2183763026);
      
      Vector::push_back<address>(&mut payees, @0x2d38e605d8c1ba7706ff91df282eedf8);
      Vector::push_back<u64>(&mut amounts, 754012679);
      
      Vector::push_back<address>(&mut payees, @0x47be2d9926b940fb6906a7a141872cd0);
      Vector::push_back<u64>(&mut amounts, 657332562);
      
      Vector::push_back<address>(&mut payees, @0x2e09737501753c3e5d924155a64a2bbe);
      Vector::push_back<u64>(&mut amounts, 398435459);
      
      Vector::push_back<address>(&mut payees, @0x5c595178ad2ba3f0e2e2694f4d9c6389);
      Vector::push_back<u64>(&mut amounts, 4294780090);
      
      Vector::push_back<address>(&mut payees, @0x9a0d2f907cf354b108364b3a8fe66807);
      Vector::push_back<u64>(&mut amounts, 404574416);
      
      Vector::push_back<address>(&mut payees, @0x3f3dda0044267aff410515d973ecf8b8);
      Vector::push_back<u64>(&mut amounts, 385003390);
      
      Vector::push_back<address>(&mut payees, @0x9abec4f7206075c036d412368c562a68);
      Vector::push_back<u64>(&mut amounts, 2714400017);
      
      Vector::push_back<address>(&mut payees, @0xd508a165f0bde1eb6e14f9aca097045d);
      Vector::push_back<u64>(&mut amounts, 378441530);
      
      Vector::push_back<address>(&mut payees, @0x0c22c23e8c836160ce887a742f77ff00);
      Vector::push_back<u64>(&mut amounts, 137773621);
      
      Vector::push_back<address>(&mut payees, @0x83f26b31cfef3aa89c58049edefaec85);
      Vector::push_back<u64>(&mut amounts, 361117647);
      
      Vector::push_back<address>(&mut payees, @0x4874602aa6c9e5197d910b6f659bc454);
      Vector::push_back<u64>(&mut amounts, 5187801078);
      
      Vector::push_back<address>(&mut payees, @0x36617fa26586cd6309b6baa2244b5214);
      Vector::push_back<u64>(&mut amounts, 362997929);
      
      Vector::push_back<address>(&mut payees, @0xb19e353f64f951b0dffeee396d506b48);
      Vector::push_back<u64>(&mut amounts, 374389626);
      
      Vector::push_back<address>(&mut payees, @0x53df84e66a768ad6f89b3d3d3ee0aa14);
      Vector::push_back<u64>(&mut amounts, 375053476);
      
      Vector::push_back<address>(&mut payees, @0x6a7ef912c475c06a16d9a65670c5f0eb);
      Vector::push_back<u64>(&mut amounts, 335217619);
      
      Vector::push_back<address>(&mut payees, @0x31b3ef9468670ce3284b36cebc82e769);
      Vector::push_back<u64>(&mut amounts, 339342708);
      
      Vector::push_back<address>(&mut payees, @0xd07745d1287b3a26cc820f12185199cd);
      Vector::push_back<u64>(&mut amounts, 466242994);
      
      Vector::push_back<address>(&mut payees, @0xa3adc9fd642d49b84f7f294320e1c9c1);
      Vector::push_back<u64>(&mut amounts, 4102150704);
      
      Vector::push_back<address>(&mut payees, @0x11677af57c7fb37df0da64dcea38500c);
      Vector::push_back<u64>(&mut amounts, 2565702544);
      
      Vector::push_back<address>(&mut payees, @0x156ea56b1911a5eb31af6466307d7d4b);
      Vector::push_back<u64>(&mut amounts, 3995067047);
      
      Vector::push_back<address>(&mut payees, @0xb1577d678f22a9c095d1d1f44fa77cf0);
      Vector::push_back<u64>(&mut amounts, 4517027221);
      
      Vector::push_back<address>(&mut payees, @0x837ee2c454b400c56fc2ccafdfcb0b96);
      Vector::push_back<u64>(&mut amounts, 1668798355);
      
      Vector::push_back<address>(&mut payees, @0x07c50e671cb97d80e4b6176821735d82);
      Vector::push_back<u64>(&mut amounts, 2059941889);
      
      Vector::push_back<address>(&mut payees, @0x03a2a1f289fbafcbae7dd632bc90f188);
      Vector::push_back<u64>(&mut amounts, 3540423484);
      
      Vector::push_back<address>(&mut payees, @0x3827c8738d5e9158e5c4f900e03b6ac4);
      Vector::push_back<u64>(&mut amounts, 2011894572);
      
      Vector::push_back<address>(&mut payees, @0x9bf4ef736b815a62eef490d987bc3506);
      Vector::push_back<u64>(&mut amounts, 1921422256);
      
      Vector::push_back<address>(&mut payees, @0x79c07e19410374ab815d14ad1e5fa05f);
      Vector::push_back<u64>(&mut amounts, 3962744808);
      
      Vector::push_back<address>(&mut payees, @0xa2b2671686f08ac2b8abc4015624f4b7);
      Vector::push_back<u64>(&mut amounts, 3395789553);
      
      Vector::push_back<address>(&mut payees, @0x7f284ee971d4723c43e2b17e4a42085e);
      Vector::push_back<u64>(&mut amounts, 664404184);
      
      Vector::push_back<address>(&mut payees, @0xa122ff535a5cb32c640d350bebe0f847);
      Vector::push_back<u64>(&mut amounts, 154631635);
      
      Vector::push_back<address>(&mut payees, @0xc6c1432795ac91164445cc35007aa169);
      Vector::push_back<u64>(&mut amounts, 2796117361);
      
      Vector::push_back<address>(&mut payees, @0x5f428943f611aff097445a20e6d5e951);
      Vector::push_back<u64>(&mut amounts, 5583273417);
      
      Vector::push_back<address>(&mut payees, @0x34bf279712a61f82742b81ede1eceeef);
      Vector::push_back<u64>(&mut amounts, 3782635342);
      
      Vector::push_back<address>(&mut payees, @0x7a9b0cfcb73253578928980eee71ec21);
      Vector::push_back<u64>(&mut amounts, 1058372025);
      
      Vector::push_back<address>(&mut payees, @0x0b2d8ecd9ca97ec9a62f1ac546e9b576);
      Vector::push_back<u64>(&mut amounts, 1915243589);
      
      Vector::push_back<address>(&mut payees, @0x64d54a14ba2f83c14de003fac6e8f6ad);
      Vector::push_back<u64>(&mut amounts, 5360421351);
      
      Vector::push_back<address>(&mut payees, @0x0ef6e80eb8005dcc917232d1207b71d7);
      Vector::push_back<u64>(&mut amounts, 4577166512);
      
      Vector::push_back<address>(&mut payees, @0x2103ffd555b7208b7daad311e11c114c);
      Vector::push_back<u64>(&mut amounts, 4648911833);
      
      Vector::push_back<address>(&mut payees, @0xe22f996510d837959432fc588eff2a51);
      Vector::push_back<u64>(&mut amounts, 2716892006);
      
      Vector::push_back<address>(&mut payees, @0x9a7a608240eb0a77b511f646f65c5ac2);
      Vector::push_back<u64>(&mut amounts, 3349008548);
      
      Vector::push_back<address>(&mut payees, @0x476a779f4cf14c9f07c40c50420720cf);
      Vector::push_back<u64>(&mut amounts, 2008404034);
      
      Vector::push_back<address>(&mut payees, @0xf8f4c67720890bbbf4ba714d05cd57c2);
      Vector::push_back<u64>(&mut amounts, 2785876138);
      
      Vector::push_back<address>(&mut payees, @0x0edb70ee769863be5677ea87710795fa);
      Vector::push_back<u64>(&mut amounts, 1446103857);
      
      Vector::push_back<address>(&mut payees, @0x4c29ad1d3df4d1d0c97f4062ba65d10b);
      Vector::push_back<u64>(&mut amounts, 2391372015);
      
      Vector::push_back<address>(&mut payees, @0xc09a90f416a1d0690a829eb569cf4c5a);
      Vector::push_back<u64>(&mut amounts, 6878440413);
      
      Vector::push_back<address>(&mut payees, @0x01d2c531008d5b01f42cf8ad9fe8a001);
      Vector::push_back<u64>(&mut amounts, 2980809100);
      
      Vector::push_back<address>(&mut payees, @0x72be90b02744d7fac856dffc3b106d9d);
      Vector::push_back<u64>(&mut amounts, 1364746192);
      
      Vector::push_back<address>(&mut payees, @0xd305f66badf80de970b013e3c0d08e3d);
      Vector::push_back<u64>(&mut amounts, 3533937337);
      
      Vector::push_back<address>(&mut payees, @0xdaf9856e82887a123af4833d582fa200);
      Vector::push_back<u64>(&mut amounts, 2738587045);
      
      Vector::push_back<address>(&mut payees, @0xfeb7eb135a089ad62b75cb9de2854ff1);
      Vector::push_back<u64>(&mut amounts, 3371850311);
      
      Vector::push_back<address>(&mut payees, @0x442e1516622f8ac512218c21c2495764);
      Vector::push_back<u64>(&mut amounts, 2351745965);
      
      Vector::push_back<address>(&mut payees, @0x430f0c735925e6cc6e84cf451bbab016);
      Vector::push_back<u64>(&mut amounts, 2053451878);
      
      Vector::push_back<address>(&mut payees, @0xa16077772837e47b720f708659f8181d);
      Vector::push_back<u64>(&mut amounts, 3517143425);
      
      Vector::push_back<address>(&mut payees, @0x4c8d163116b65b27b2b0a3deb1bed3da);
      Vector::push_back<u64>(&mut amounts, 977675247);
      
      Vector::push_back<address>(&mut payees, @0x3837ffd2400354bbf969859211d82bd6);
      Vector::push_back<u64>(&mut amounts, 448054100);
      
      Vector::push_back<address>(&mut payees, @0x85b857bbc58652702ae4a5000405372d);
      Vector::push_back<u64>(&mut amounts, 3584569438);
      
      Vector::push_back<address>(&mut payees, @0xdc9982fcc069a667430a3b1e0a3ee5e9);
      Vector::push_back<u64>(&mut amounts, 6305939153);
      
      Vector::push_back<address>(&mut payees, @0x851a3baf866951b36a3fe0da92ba38fc);
      Vector::push_back<u64>(&mut amounts, 3019926231);
      
      Vector::push_back<address>(&mut payees, @0x088c88cb98a44bd389764a7089b895ac);
      Vector::push_back<u64>(&mut amounts, 567788599);
      
      Vector::push_back<address>(&mut payees, @0x3ea61239a0045dbc301dc350be1f0a89);
      Vector::push_back<u64>(&mut amounts, 681878132);
      
      Vector::push_back<address>(&mut payees, @0xf4956624f4c00ccb674e806f473bf2e4);
      Vector::push_back<u64>(&mut amounts, 2388365537);
      
      Vector::push_back<address>(&mut payees, @0x536bd36e9b85db441427a2d2a951e6e0);
      Vector::push_back<u64>(&mut amounts, 2256026277);
      
      Vector::push_back<address>(&mut payees, @0xf85bb8a1c58ef920864a9bf555700bfc);
      Vector::push_back<u64>(&mut amounts, 4245777989);
      
      Vector::push_back<address>(&mut payees, @0x65a26fd8f380e3a978d7ec53aa16591b);
      Vector::push_back<u64>(&mut amounts, 761870778);
      
      Vector::push_back<address>(&mut payees, @0xf85f7ce992e9bdd7da31db20687a58af);
      Vector::push_back<u64>(&mut amounts, 3789733325);
      
      Vector::push_back<address>(&mut payees, @0x90be96494587ef009960fa6997757be7);
      Vector::push_back<u64>(&mut amounts, 3786373875);
      
      Vector::push_back<address>(&mut payees, @0xb81bd2ab415f9457b5631b2603dcc356);
      Vector::push_back<u64>(&mut amounts, 1284240750);
      
      Vector::push_back<address>(&mut payees, @0x865f6842dbbd425684761fbd3583624b);
      Vector::push_back<u64>(&mut amounts, 5423498138);
      
      Vector::push_back<address>(&mut payees, @0x40b23269c1c77aea129d251f9b891b85);
      Vector::push_back<u64>(&mut amounts, 1768016981);
      
      Vector::push_back<address>(&mut payees, @0x79c0f4bf7ce3ad9d6f6408b9e196e5ed);
      Vector::push_back<u64>(&mut amounts, 4040024429);
      
      Vector::push_back<address>(&mut payees, @0x22f878237369df0034f3158461086a6c);
      Vector::push_back<u64>(&mut amounts, 1119449455);
      
      Vector::push_back<address>(&mut payees, @0x98047df2062912ebbc138fd3cb3e8c1d);
      Vector::push_back<u64>(&mut amounts, 1258986775);
      
      Vector::push_back<address>(&mut payees, @0xdb3489c4674251fb7c8da7f3b9d2c33c);
      Vector::push_back<u64>(&mut amounts, 3832712013);
      
      Vector::push_back<address>(&mut payees, @0x29b875c576895f8bc5989553f1784b42);
      Vector::push_back<u64>(&mut amounts, 4543709575);
      
      Vector::push_back<address>(&mut payees, @0x3814d57cafddccf7bc28a8737fd89a09);
      Vector::push_back<u64>(&mut amounts, 3743348468);
      
      Vector::push_back<address>(&mut payees, @0xaa067cad39f6aa148255c5828dd73e1e);
      Vector::push_back<u64>(&mut amounts, 3653537943);
      
      Vector::push_back<address>(&mut payees, @0xf02f6547d21688f96e0faeb72e026301);
      Vector::push_back<u64>(&mut amounts, 2031191082);
      
      Vector::push_back<address>(&mut payees, @0x22e0707127066f9a91b22dbefa58936b);
      Vector::push_back<u64>(&mut amounts, 1392544904);
      
      Vector::push_back<address>(&mut payees, @0x9ef30bedf54a855144b9a591e0d81113);
      Vector::push_back<u64>(&mut amounts, 4836044317);
      
      Vector::push_back<address>(&mut payees, @0xfc342a7c18719cc7c81353bfeb1fee1d);
      Vector::push_back<u64>(&mut amounts, 4675867216);
      
      Vector::push_back<address>(&mut payees, @0x68e08a837f8e8ee356ada4b5f2cc6f5b);
      Vector::push_back<u64>(&mut amounts, 4412200323);
      
      Vector::push_back<address>(&mut payees, @0x8e23f25bc0df35142b6b6cb34d63a9f1);
      Vector::push_back<u64>(&mut amounts, 5466154606);
      
      Vector::push_back<address>(&mut payees, @0xe1c91d948ff7051b2bb608cdc6a20df2);
      Vector::push_back<u64>(&mut amounts, 4738080974);
      
      Vector::push_back<address>(&mut payees, @0xba9cb35fb754442af0e5c81b6560b44d);
      Vector::push_back<u64>(&mut amounts, 4481072816);
      
      Vector::push_back<address>(&mut payees, @0xf284e1d3a3dc46d07f5c66f83d23b381);
      Vector::push_back<u64>(&mut amounts, 6666628221);
      
      Vector::push_back<address>(&mut payees, @0x6ff9743408436b4ad0568d17392e8b9f);
      Vector::push_back<u64>(&mut amounts, 4271407925);
      
      Vector::push_back<address>(&mut payees, @0xec3e4e4f3c29e363d097e1843cb3a6c8);
      Vector::push_back<u64>(&mut amounts, 2894944327);
      
      Vector::push_back<address>(&mut payees, @0x82eb2e85a1c3c8cfe3d97b1933623894);
      Vector::push_back<u64>(&mut amounts, 5562385127);
      
      Vector::push_back<address>(&mut payees, @0xe5159363d9d5e558725e56156751d70e);
      Vector::push_back<u64>(&mut amounts, 1481912145);
      
      Vector::push_back<address>(&mut payees, @0x19d9139d91b13e7cd9323f7ada7fcb16);
      Vector::push_back<u64>(&mut amounts, 4509825708);
      
      Vector::push_back<address>(&mut payees, @0xbe089210512b41d2d0b1c41b810d2c3c);
      Vector::push_back<u64>(&mut amounts, 487613585);
      
      Vector::push_back<address>(&mut payees, @0xc033247d0f88c4cc796b0ebd09210ff4);
      Vector::push_back<u64>(&mut amounts, 415222435);
      
      Vector::push_back<address>(&mut payees, @0xb84f911ea210d23130ef68e222d5dca7);
      Vector::push_back<u64>(&mut amounts, 3721726702);
      
      Vector::push_back<address>(&mut payees, @0xda03aa486b8e5ff85be073484712bcfb);
      Vector::push_back<u64>(&mut amounts, 399033943);
      
      Vector::push_back<address>(&mut payees, @0xeb54c76c6e3e6c3cca4b83e8f61112ad);
      Vector::push_back<u64>(&mut amounts, 381712968);
      
      Vector::push_back<address>(&mut payees, @0x1e8f905234261dd575462f8facd5dc2b);
      Vector::push_back<u64>(&mut amounts, 3082061464);
      
      Vector::push_back<address>(&mut payees, @0x8211f452baa248cbab103474f6f47a43);
      Vector::push_back<u64>(&mut amounts, 1615585634);
      
      Vector::push_back<address>(&mut payees, @0xabcbe68e1cafd1d4b5d31337a5a48782);
      Vector::push_back<u64>(&mut amounts, 962053391);
      
      Vector::push_back<address>(&mut payees, @0x709eedcac3ff9a8c1a956e6f069effd4);
      Vector::push_back<u64>(&mut amounts, 461018788);
      
      Vector::push_back<address>(&mut payees, @0x3c81639f06cce18391a53180a515a961);
      Vector::push_back<u64>(&mut amounts, 283938766);
      
      Vector::push_back<address>(&mut payees, @0xa2c6015b69fcb867d9e1410d737ea7f1);
      Vector::push_back<u64>(&mut amounts, 477237953);
      
      Vector::push_back<address>(&mut payees, @0x6c2edd399bd29dddffe79fa7efd8d978);
      Vector::push_back<u64>(&mut amounts, 586338158);
      
      Vector::push_back<address>(&mut payees, @0x87797cf31cf451d4735bd66600860e12);
      Vector::push_back<u64>(&mut amounts, 458977884);
      
      Vector::push_back<address>(&mut payees, @0xd13b85884c472b33775120039e5dde61);
      Vector::push_back<u64>(&mut amounts, 125507674);
      
      Vector::push_back<address>(&mut payees, @0xda825df005e2cf9766da80d932328a6b);
      Vector::push_back<u64>(&mut amounts, 127328448);
      
      Vector::push_back<address>(&mut payees, @0x4eca94bd48f536ff9a16d5a95552a999);
      Vector::push_back<u64>(&mut amounts, 127328448);
      
      Vector::push_back<address>(&mut payees, @0xf6aa1d7acce548546fcf513c88ffb40c);
      Vector::push_back<u64>(&mut amounts, 1369011893);
      
      Vector::push_back<address>(&mut payees, @0xe2b3406d4847de1cbda0bc76c9358a20);
      Vector::push_back<u64>(&mut amounts, 412424134);
      
      Vector::push_back<address>(&mut payees, @0x3e88f3c81563a9db32b7629b4ee9bd77);
      Vector::push_back<u64>(&mut amounts, 410974114);
      
      Vector::push_back<address>(&mut payees, @0x7209c13e1253ad8fb2d96a30552052aa);
      Vector::push_back<u64>(&mut amounts, 885828329);
      
      Vector::push_back<address>(&mut payees, @0x0161ede19a4ccfeb63a02ad2f98a537c);
      Vector::push_back<u64>(&mut amounts, 2217927283);
      
      Vector::push_back<address>(&mut payees, @0xa8e9cd790bc2c385b36fee66a428a8f9);
      Vector::push_back<u64>(&mut amounts, 2462578699);
      
      Vector::push_back<address>(&mut payees, @0x8d96559733778274793f59a1438b32bd);
      Vector::push_back<u64>(&mut amounts, 702357350);
      
      Vector::push_back<address>(&mut payees, @0xb5678055f9598c602dabe84ba3b04593);
      Vector::push_back<u64>(&mut amounts, 853024650);
      
      Vector::push_back<address>(&mut payees, @0xd20cc2989a2fb029d90f4ac2ab058fd9);
      Vector::push_back<u64>(&mut amounts, 181899321);
      
      Vector::push_back<address>(&mut payees, @0x49f83959925bde908d684e63d9cfcc95);
      Vector::push_back<u64>(&mut amounts, 3592505305);
      
      Vector::push_back<address>(&mut payees, @0x5d06cbeae9e2dc589c6e396e65a5c3b7);
      Vector::push_back<u64>(&mut amounts, 833947467);
      
      Vector::push_back<address>(&mut payees, @0xdc8d2a2c8eb3711b52cb9572356267d0);
      Vector::push_back<u64>(&mut amounts, 805196465);
      
      Vector::push_back<address>(&mut payees, @0x82952c9802d5a9eda4d08cd919cde08f);
      Vector::push_back<u64>(&mut amounts, 801263787);
      
      Vector::push_back<address>(&mut payees, @0x31f9556705fb0ff226e80aea7f2295ea);
      Vector::push_back<u64>(&mut amounts, 688532596);
      
      Vector::push_back<address>(&mut payees, @0xdb5ade4a07d0ff7567ec05231049e5cf);
      Vector::push_back<u64>(&mut amounts, 688532596);
      
      Vector::push_back<address>(&mut payees, @0x2e90d84e4203c18d3bdf831d4f1e2854);
      Vector::push_back<u64>(&mut amounts, 210663862);
      
      Vector::push_back<address>(&mut payees, @0x43f0f9ad642063f66c52bebd055f02f2);
      Vector::push_back<u64>(&mut amounts, 2781437145);
      
      Vector::push_back<address>(&mut payees, @0xd883ea4f4209410c1b9ff9d4cc5c173a);
      Vector::push_back<u64>(&mut amounts, 212447650);
      
      Vector::push_back<address>(&mut payees, @0x65c57ae3c8cf8670e054dd5cf76aa5f2);
      Vector::push_back<u64>(&mut amounts, 210751825);
      
      Vector::push_back<address>(&mut payees, @0xedccbef0ddbc3d111e82908569b3fc7f);
      Vector::push_back<u64>(&mut amounts, 216617888);
      
      Vector::push_back<address>(&mut payees, @0xdbb08a7c8fd5f3ebf31c344e650aa842);
      Vector::push_back<u64>(&mut amounts, 208783242);
      
      Vector::push_back<address>(&mut payees, @0x40ed902d91912049f35f565159a24738);
      Vector::push_back<u64>(&mut amounts, 2324311000);
      
      Vector::push_back<address>(&mut payees, @0x3e4d4488b8c8c9d33869388045abf540);
      Vector::push_back<u64>(&mut amounts, 216459998);
      
      Vector::push_back<address>(&mut payees, @0xaa31765524619f8b5b42ed32df33ad3d);
      Vector::push_back<u64>(&mut amounts, 153545201);
      
      Vector::push_back<address>(&mut payees, @0xb0392177b8c1d4e9d456f18e14819b2f);
      Vector::push_back<u64>(&mut amounts, 169783798);
      
      Vector::push_back<address>(&mut payees, @0x7c265bb2bdbe586e8507fb11ff3350ed);
      Vector::push_back<u64>(&mut amounts, 2627450070);
      
      Vector::push_back<address>(&mut payees, @0x83ff4547172ed294a5b36f846fcd57b2);
      Vector::push_back<u64>(&mut amounts, 155433774);
      
      Vector::push_back<address>(&mut payees, @0x0f5c96256fcf97a34a0b95d17a720dc4);
      Vector::push_back<u64>(&mut amounts, 169713870);
      
      Vector::push_back<address>(&mut payees, @0xfb27eb4f07cefb49fecccecb7841ac9e);
      Vector::push_back<u64>(&mut amounts, 169734032);
      
      Vector::push_back<address>(&mut payees, @0xca659c2d5f30573a521b6d10cb241d43);
      Vector::push_back<u64>(&mut amounts, 2639623883);
      
      Vector::push_back<address>(&mut payees, @0xd9c136ed4feb78902b665f132a9c3847);
      Vector::push_back<u64>(&mut amounts, 173611351);
      
      Vector::push_back<address>(&mut payees, @0xd46c480b39e552f7c7931e6a0c9bf591);
      Vector::push_back<u64>(&mut amounts, 175854609);
      
      Vector::push_back<address>(&mut payees, @0xfe9f0dc203321ff0f0a24ca484e90823);
      Vector::push_back<u64>(&mut amounts, 2997993751);
      
      Vector::push_back<address>(&mut payees, @0xeec046693470e8ecac6ca94e0e3b34db);
      Vector::push_back<u64>(&mut amounts, 1477373280);
      
      Vector::push_back<address>(&mut payees, @0xb40fd0520f0689f9fbf724371fe149a3);
      Vector::push_back<u64>(&mut amounts, 3967235451);
      
      Vector::push_back<address>(&mut payees, @0x1a6f29d250c3daa9b505623c0e047f2c);
      Vector::push_back<u64>(&mut amounts, 3698880961);
      
      Vector::push_back<address>(&mut payees, @0x1b3c71beb96d597c1f24a4b3586cdee3);
      Vector::push_back<u64>(&mut amounts, 4320545361);
      
      Vector::push_back<address>(&mut payees, @0x7cd465e3c047471cb81e750638149bd3);
      Vector::push_back<u64>(&mut amounts, 2965535324);
      
      Vector::push_back<address>(&mut payees, @0x37b96f5a653632b9ab07e4a439b23000);
      Vector::push_back<u64>(&mut amounts, 778785582);
      
      Vector::push_back<address>(&mut payees, @0x1d5b4ed7e7d8b81d65779fdb39c09379);
      Vector::push_back<u64>(&mut amounts, 1480231669);
      
      Vector::push_back<address>(&mut payees, @0x4588d649f8ac4ce6989cbfdd15d87b2a);
      Vector::push_back<u64>(&mut amounts, 1665715851);
      
      Vector::push_back<address>(&mut payees, @0x5964fc4d3bbee909bf0e3f93a5d88059);
      Vector::push_back<u64>(&mut amounts, 4265726513);
      
      Vector::push_back<address>(&mut payees, @0x908e0a73a8314708d902c0e7c381f49c);
      Vector::push_back<u64>(&mut amounts, 1327477832);
      
      Vector::push_back<address>(&mut payees, @0xd8f264d8c48b43969821cfca5a7e67a6);
      Vector::push_back<u64>(&mut amounts, 1612597958);
      
      Vector::push_back<address>(&mut payees, @0x6d9ba5db2988e18346581699bf2f553c);
      Vector::push_back<u64>(&mut amounts, 1739683015);
      
      Vector::push_back<address>(&mut payees, @0xf430898f869584eea7f4ad7ea9978ef3);
      Vector::push_back<u64>(&mut amounts, 1978660400);
      
      Vector::push_back<address>(&mut payees, @0xa26b65be2eae2538fb680d29d17267dc);
      Vector::push_back<u64>(&mut amounts, 2177667966);
      
      Vector::push_back<address>(&mut payees, @0xed0a8b35ceb981b643ef73a1ee321f24);
      Vector::push_back<u64>(&mut amounts, 2906902110);
      
      Vector::push_back<address>(&mut payees, @0x20067f3a9101eecb2f9368b93ebf8b36);
      Vector::push_back<u64>(&mut amounts, 243578786);
      
      Vector::push_back<address>(&mut payees, @0xff8002816bbb0ba5836c7b3ec7f8312a);
      Vector::push_back<u64>(&mut amounts, 4328140641);
      
      Vector::push_back<address>(&mut payees, @0x5096c87ccaae9e22bbb0afa407df7bbe);
      Vector::push_back<u64>(&mut amounts, 1148982101);
      
      Vector::push_back<address>(&mut payees, @0xd2aa4935b02afc713465ae2521db1a60);
      Vector::push_back<u64>(&mut amounts, 2787772152);
      
      Vector::push_back<address>(&mut payees, @0x8389fb3d6337b7feb7e53f82d8ad6920);
      Vector::push_back<u64>(&mut amounts, 2807452121);
      
      Vector::push_back<address>(&mut payees, @0x9e2298855cf84174878eb8a2354b1b4c);
      Vector::push_back<u64>(&mut amounts, 3283857635);
      
      Vector::push_back<address>(&mut payees, @0xbe6ea727168b3d77a2a13065c0470855);
      Vector::push_back<u64>(&mut amounts, 142168608);
      
      Vector::push_back<address>(&mut payees, @0xea604cab2122da760b0a6281f5fa0fb8);
      Vector::push_back<u64>(&mut amounts, 2738602981);
      
      Vector::push_back<address>(&mut payees, @0x2146347c273e74c7f34f292ce6cc5d21);
      Vector::push_back<u64>(&mut amounts, 2610341783);
      
      Vector::push_back<address>(&mut payees, @0x8bb678d503167f49adf7e1270233c4fc);
      Vector::push_back<u64>(&mut amounts, 1965946560);
      
      Vector::push_back<address>(&mut payees, @0xe0da2a11481cc043bfa219972ff007ed);
      Vector::push_back<u64>(&mut amounts, 2580677405);
      
      Vector::push_back<address>(&mut payees, @0xba587434a45dd0fbc228753da045a568);
      Vector::push_back<u64>(&mut amounts, 2564056984);
      
      Vector::push_back<address>(&mut payees, @0xdafd3d41474e1b39768c6dbc86627661);
      Vector::push_back<u64>(&mut amounts, 2582351712);
      
      Vector::push_back<address>(&mut payees, @0x4fc61312f63c01604f50f30cd45d3a47);
      Vector::push_back<u64>(&mut amounts, 2446944773);
      
      Vector::push_back<address>(&mut payees, @0xc6f34ed02f86e8120bbba6537800e246);
      Vector::push_back<u64>(&mut amounts, 2556083921);
      
      Vector::push_back<address>(&mut payees, @0x21d801e001079b9fa172c7f5decbeeea);
      Vector::push_back<u64>(&mut amounts, 2522460568);
      
      Vector::push_back<address>(&mut payees, @0x427db65905b2a98e3d2d96a6c34de858);
      Vector::push_back<u64>(&mut amounts, 3839752880);
      
      Vector::push_back<address>(&mut payees, @0x1fd2e081f6f67d9ea7f1e0c491211e7f);
      Vector::push_back<u64>(&mut amounts, 2513442126);
      
      Vector::push_back<address>(&mut payees, @0x6845705d1f88dd69f7b5ee36cf00627e);
      Vector::push_back<u64>(&mut amounts, 2595922942);
      
      Vector::push_back<address>(&mut payees, @0x29b895ff3f046cb6a41c95940c6b9d25);
      Vector::push_back<u64>(&mut amounts, 2583812252);
      
      Vector::push_back<address>(&mut payees, @0x605c0fff52eb6b99613d5818b8e23ce0);
      Vector::push_back<u64>(&mut amounts, 4156128396);
      
      Vector::push_back<address>(&mut payees, @0x3479513e8439cd605a29b34e447d0015);
      Vector::push_back<u64>(&mut amounts, 2481016766);
      
      Vector::push_back<address>(&mut payees, @0xb1d0171fe29e27347882b02d30d94917);
      Vector::push_back<u64>(&mut amounts, 3964084353);
      
      Vector::push_back<address>(&mut payees, @0x4f2b12f18d31c681a0f2e722484a6615);
      Vector::push_back<u64>(&mut amounts, 2403095974);
      
      Vector::push_back<address>(&mut payees, @0x20fbc1a3be8a4784049a37d1477ce735);
      Vector::push_back<u64>(&mut amounts, 2354672027);
      
      Vector::push_back<address>(&mut payees, @0xa3f865bc8935eea1deb6bc35597fb1ef);
      Vector::push_back<u64>(&mut amounts, 2334983641);
      
      Vector::push_back<address>(&mut payees, @0x3d4216833e2f4f2278eb6c2faa41ba47);
      Vector::push_back<u64>(&mut amounts, 2363985656);
      
      Vector::push_back<address>(&mut payees, @0xa206bec6891ad961c8532f2acdd70e5a);
      Vector::push_back<u64>(&mut amounts, 2357936899);
      
      Vector::push_back<address>(&mut payees, @0x6fcfd01ce948c4bb46e4c255c610e12d);
      Vector::push_back<u64>(&mut amounts, 2367175785);
      
      Vector::push_back<address>(&mut payees, @0xdf68346495fc8517d231d1eba7ab28d2);
      Vector::push_back<u64>(&mut amounts, 3611905747);
      
      Vector::push_back<address>(&mut payees, @0x351eaf2d51366e57e68b7d027766d6d0);
      Vector::push_back<u64>(&mut amounts, 2399651219);
      
      Vector::push_back<address>(&mut payees, @0x404266076249c6f483f42c94cdb7faf7);
      Vector::push_back<u64>(&mut amounts, 2430649533);
      
      Vector::push_back<address>(&mut payees, @0x870f7f81b57daf2880c03ba287f269b3);
      Vector::push_back<u64>(&mut amounts, 2474477938);
      
      Vector::push_back<address>(&mut payees, @0x7355e047e103e2bb5f31137d068ad68d);
      Vector::push_back<u64>(&mut amounts, 2495939047);
      
      Vector::push_back<address>(&mut payees, @0x5b26e6e485b66f5dad35cafce4fddbd6);
      Vector::push_back<u64>(&mut amounts, 2392312343);
      
      Vector::push_back<address>(&mut payees, @0xfe319051cab95208dd0ea7afd403f33a);
      Vector::push_back<u64>(&mut amounts, 2348493458);
      
      Vector::push_back<address>(&mut payees, @0x1033bd8739089336f8d4e1d66995ba9f);
      Vector::push_back<u64>(&mut amounts, 2342919842);
      
      Vector::push_back<address>(&mut payees, @0x0ad0cee657ea90f6523056bf06ed99b4);
      Vector::push_back<u64>(&mut amounts, 1961952430);
      
      Vector::push_back<address>(&mut payees, @0xfca7250767e0acbd4840b56155d08558);
      Vector::push_back<u64>(&mut amounts, 1998568095);
      
      Vector::push_back<address>(&mut payees, @0xf87a7d18ad956f230b85fbc5d7c76096);
      Vector::push_back<u64>(&mut amounts, 3065189646);
      
      Vector::push_back<address>(&mut payees, @0xe3b8db1d66797a99863ed1ad88b64e81);
      Vector::push_back<u64>(&mut amounts, 1541056429);
      
      Vector::push_back<address>(&mut payees, @0xc5dcffbf39c1357daa7ddb79e8f5bf85);
      Vector::push_back<u64>(&mut amounts, 2031127536);
      
      Vector::push_back<address>(&mut payees, @0xa51a24ef73f93badd0c0ad6dd75d3946);
      Vector::push_back<u64>(&mut amounts, 2102183821);
      
      Vector::push_back<address>(&mut payees, @0x862e8c86626a55f5480ec6e006ca69a4);
      Vector::push_back<u64>(&mut amounts, 1899667055);
      
      Vector::push_back<address>(&mut payees, @0xb39f87734cf1b2560d4012bd7a5f9b47);
      Vector::push_back<u64>(&mut amounts, 1941264137);
      
      Vector::push_back<address>(&mut payees, @0xc3ea931b0a4133e59e8d921f542f437e);
      Vector::push_back<u64>(&mut amounts, 2030787139);
      
      Vector::push_back<address>(&mut payees, @0x32129f6d8c240f0135cdd965987ee7e2);
      Vector::push_back<u64>(&mut amounts, 1863988725);
      
      Vector::push_back<address>(&mut payees, @0x85602cc707fa670160029d1f482fe198);
      Vector::push_back<u64>(&mut amounts, 2178397334);
      
      Vector::push_back<address>(&mut payees, @0x1b639139aeada87fb044fdd6a52f2ef0);
      Vector::push_back<u64>(&mut amounts, 737184636);
      
      Vector::push_back<address>(&mut payees, @0xb2ff477bef2084fcae76ac8a77ff8eb7);
      Vector::push_back<u64>(&mut amounts, 1902815731);
      
      Vector::push_back<address>(&mut payees, @0x18b85913df83c8fc24717b06baaa20eb);
      Vector::push_back<u64>(&mut amounts, 2060120110);
      
      Vector::push_back<address>(&mut payees, @0xbd2350b9a864862fde0cc35d6fa81115);
      Vector::push_back<u64>(&mut amounts, 2282161494);
      
      Vector::push_back<address>(&mut payees, @0x582f31b27debbbb4969067544d2606fe);
      Vector::push_back<u64>(&mut amounts, 2040583404);
      
      Vector::push_back<address>(&mut payees, @0xb8eaa669103f7c65bc232ffd0df08885);
      Vector::push_back<u64>(&mut amounts, 2129893924);
      
      Vector::push_back<address>(&mut payees, @0x6b45c9f9d67d66f7f50c84869e559a91);
      Vector::push_back<u64>(&mut amounts, 1978128037);
      
      Vector::push_back<address>(&mut payees, @0x33b17e77c80bb760540e63528aef76a6);
      Vector::push_back<u64>(&mut amounts, 743547653);
      
      Vector::push_back<address>(&mut payees, @0x1dff026af05d93d566d2887bae1b4baa);
      Vector::push_back<u64>(&mut amounts, 2000499043);
      
      Vector::push_back<address>(&mut payees, @0x52572c2227d9aad3384d4bbac0047761);
      Vector::push_back<u64>(&mut amounts, 2047778045);
      
      Vector::push_back<address>(&mut payees, @0x85ce186d86fe4e9cf5fdebde17117a28);
      Vector::push_back<u64>(&mut amounts, 3728476350);
      
      Vector::push_back<address>(&mut payees, @0x3a65e03286106abe55fcff848380befa);
      Vector::push_back<u64>(&mut amounts, 1992570241);
      
      Vector::push_back<address>(&mut payees, @0xa7b983d569bfaff0a3e6a685fd7da166);
      Vector::push_back<u64>(&mut amounts, 2057703818);
      
      Vector::push_back<address>(&mut payees, @0xffd7104d222373b7275aa67c9304b4a7);
      Vector::push_back<u64>(&mut amounts, 2047683400);
      
      Vector::push_back<address>(&mut payees, @0xe0c5b5eabfd88fc407ef430f79acf414);
      Vector::push_back<u64>(&mut amounts, 2140796011);
      
      Vector::push_back<address>(&mut payees, @0x4387ba840ee2197ac5149ea1d85d638f);
      Vector::push_back<u64>(&mut amounts, 4454004931);
      
      Vector::push_back<address>(&mut payees, @0xb3f17df88cafc977c02775ba611bf922);
      Vector::push_back<u64>(&mut amounts, 3575699433);
      
      Vector::push_back<address>(&mut payees, @0xd44cc4a5f9b8074d7cb64e6aaa46b8a7);
      Vector::push_back<u64>(&mut amounts, 4294675076);
      
      Vector::push_back<address>(&mut payees, @0x88b324eb7356d9bdfaa5c5c0da777a7e);
      Vector::push_back<u64>(&mut amounts, 3829329025);
      
      Vector::push_back<address>(&mut payees, @0x1b79fc53c6358093bf9ed5487e5d1804);
      Vector::push_back<u64>(&mut amounts, 2531644407);
      
      Vector::push_back<address>(&mut payees, @0x2ea8bfb57da5e5535f2d6ae47f6ba5fb);
      Vector::push_back<u64>(&mut amounts, 1206186609);
      
      Vector::push_back<address>(&mut payees, @0x9de40b3ebd3d12fb2883cc12977ed5f5);
      Vector::push_back<u64>(&mut amounts, 6384701422);
      
      Vector::push_back<address>(&mut payees, @0xdaa5914fbb196a15ead501a7d22049b3);
      Vector::push_back<u64>(&mut amounts, 2780437594);
      
      Vector::push_back<address>(&mut payees, @0xdef1058fc8ebd90656a9f62ffe9c5252);
      Vector::push_back<u64>(&mut amounts, 343716643);
      
      Vector::push_back<address>(&mut payees, @0x2c27cf859a7919b1ed0a8f2aac006f68);
      Vector::push_back<u64>(&mut amounts, 1053710230);
      
      Vector::push_back<address>(&mut payees, @0x80cc5384359bdbc6add6329831daacce);
      Vector::push_back<u64>(&mut amounts, 1157330600);
      
      Vector::push_back<address>(&mut payees, @0xe42d13064128989229ec02e252fc8dd3);
      Vector::push_back<u64>(&mut amounts, 1011028600);
      
      Vector::push_back<address>(&mut payees, @0x043ad3ab1868e162fa5ef59deadf6139);
      Vector::push_back<u64>(&mut amounts, 273557528);
      
      Vector::push_back<address>(&mut payees, @0x1f627c1d2568f548d9f2be5b7ba52b17);
      Vector::push_back<u64>(&mut amounts, 3925855648);
      
      Vector::push_back<address>(&mut payees, @0x623222c248a69ca58970b0c53256091c);
      Vector::push_back<u64>(&mut amounts, 1699543364);
      
      Vector::push_back<address>(&mut payees, @0x622c22ad4a9c83a4c082ac16d8f8fe0d);
      Vector::push_back<u64>(&mut amounts, 1482687244);
      
      Vector::push_back<address>(&mut payees, @0x5b36e8e7bae69c32a7c7e5532768842d);
      Vector::push_back<u64>(&mut amounts, 2512292489);
      
      Vector::push_back<address>(&mut payees, @0xcdaedae0eedbcaa532ee4ac090333334);
      Vector::push_back<u64>(&mut amounts, 465887649);
      
      Vector::push_back<address>(&mut payees, @0xe9bd97ea6d9d9d4d7463f0f72a619bc3);
      Vector::push_back<u64>(&mut amounts, 1788060569);
      
      Vector::push_back<address>(&mut payees, @0x4a0078fe4425dae4d6bee31dd4e63fcd);
      Vector::push_back<u64>(&mut amounts, 2064442602);
      
      Vector::push_back<address>(&mut payees, @0xca6726044c1318dabdedbd88d0801f88);
      Vector::push_back<u64>(&mut amounts, 4132532820);
      
      Vector::push_back<address>(&mut payees, @0xa280fa1f3cde95fe968137644270ef69);
      Vector::push_back<u64>(&mut amounts, 2624644899);
      
      Vector::push_back<address>(&mut payees, @0xe3c36f789c17dce96ad5a9521bcfd55f);
      Vector::push_back<u64>(&mut amounts, 2240095198);
      
      Vector::push_back<address>(&mut payees, @0xb3d5a6da7a5bd6be9b810fe13524e4f7);
      Vector::push_back<u64>(&mut amounts, 3493125380);
      
      Vector::push_back<address>(&mut payees, @0x6e708cb801c22d14e54f764013553797);
      Vector::push_back<u64>(&mut amounts, 3277144486);
      
      Vector::push_back<address>(&mut payees, @0x069007bb7ab2d0f0631eb01b42438b0e);
      Vector::push_back<u64>(&mut amounts, 4242682131);
      
      Vector::push_back<address>(&mut payees, @0xbed293808df535747361540d6f1addbb);
      Vector::push_back<u64>(&mut amounts, 3072829277);
      
      Vector::push_back<address>(&mut payees, @0xf6b097cbeb02df717e7c6dbf471646fc);
      Vector::push_back<u64>(&mut amounts, 4210995296);
      
      Vector::push_back<address>(&mut payees, @0x92e0f5949e9946a1ebf318c112f28ca4);
      Vector::push_back<u64>(&mut amounts, 2042824163);
      
      Vector::push_back<address>(&mut payees, @0x55eb0ce2b80ec1b66152bc19a44f9eb6);
      Vector::push_back<u64>(&mut amounts, 4924811995);
      
      Vector::push_back<address>(&mut payees, @0xa164ca45b99603970c5e7fcc23609317);
      Vector::push_back<u64>(&mut amounts, 65295902);
      
      Vector::push_back<address>(&mut payees, @0x50c399340efa7393c2c95ce1e9954254);
      Vector::push_back<u64>(&mut amounts, 82556298);
      
      Vector::push_back<address>(&mut payees, @0x66a0c9899e1986d1c36bec897959ed4f);
      Vector::push_back<u64>(&mut amounts, 2323897212);
      
      Vector::push_back<address>(&mut payees, @0xe076ab3f2f35ec51c0dd5021d2eadb38);
      Vector::push_back<u64>(&mut amounts, 2326850061);
      
      Vector::push_back<address>(&mut payees, @0xd74f75285231012593cee01161d8b1ac);
      Vector::push_back<u64>(&mut amounts, 335081910);
      
      Vector::push_back<address>(&mut payees, @0x74f21e48d5396d50403ee0c284ec5b1c);
      Vector::push_back<u64>(&mut amounts, 2288533722);
      
      Vector::push_back<address>(&mut payees, @0x16ed7128b19179a8c30f9103f9c64da2);
      Vector::push_back<u64>(&mut amounts, 301168382);
      
      Vector::push_back<address>(&mut payees, @0x7c6966817e21bfc8e3ec3c37d064e58f);
      Vector::push_back<u64>(&mut amounts, 2296134414);
      
      Vector::push_back<address>(&mut payees, @0x8b1db5524b3d07133ce83f230352869a);
      Vector::push_back<u64>(&mut amounts, 219680482);
      
      Vector::push_back<address>(&mut payees, @0xa42c8859da0c0f9120976c36b4b84091);
      Vector::push_back<u64>(&mut amounts, 174781124);
      
      Vector::push_back<address>(&mut payees, @0x711ee4ea20d15d64567cf5e93ef6e0f8);
      Vector::push_back<u64>(&mut amounts, 2305997635);
      
      Vector::push_back<address>(&mut payees, @0xd139069cd6a8d67d6477f41f14f5eff2);
      Vector::push_back<u64>(&mut amounts, 78911344);
      
      Vector::push_back<address>(&mut payees, @0x3c0af0e90031c2d3fedd27f5ad4f1b5e);
      Vector::push_back<u64>(&mut amounts, 235730705);
      
      Vector::push_back<address>(&mut payees, @0xeb5eef52aa7786d75f8d63816c030c12);
      Vector::push_back<u64>(&mut amounts, 2326930573);
      
      Vector::push_back<address>(&mut payees, @0x45bda98321118bbd7a4e9c0cda951e4b);
      Vector::push_back<u64>(&mut amounts, 210620840);
      
      Vector::push_back<address>(&mut payees, @0xd13e66f7bc5549ab6eea61ea862b5b99);
      Vector::push_back<u64>(&mut amounts, 2285418457);
      
      Vector::push_back<address>(&mut payees, @0x6718daef7f1c730621c7927d55810ec4);
      Vector::push_back<u64>(&mut amounts, 138814722);
      
      Vector::push_back<address>(&mut payees, @0xadb1d3d1cc6c6a20095d471d5477e1f8);
      Vector::push_back<u64>(&mut amounts, 2315231635);
      
      Vector::push_back<address>(&mut payees, @0xd372dcb7e4319508cc470ac09bca5a42);
      Vector::push_back<u64>(&mut amounts, 1284981237);
      
      Vector::push_back<address>(&mut payees, @0x431c17c5a7eba324605a2ad7c2adab73);
      Vector::push_back<u64>(&mut amounts, 2285301379);
      
      Vector::push_back<address>(&mut payees, @0xf1dbfb2b922850dd06ae8077630d68e8);
      Vector::push_back<u64>(&mut amounts, 2319222937);
      
      Vector::push_back<address>(&mut payees, @0x6a8ac18d0fa03ac324ae9b9cbc96e723);
      Vector::push_back<u64>(&mut amounts, 2165080132);
      
      Vector::push_back<address>(&mut payees, @0xdd2fdcffd05cad686fb3116e4877a0b7);
      Vector::push_back<u64>(&mut amounts, 1571525439);
      
      Vector::push_back<address>(&mut payees, @0xd62d5a56291dab1edc81744271b059d2);
      Vector::push_back<u64>(&mut amounts, 2215934009);
      
      Vector::push_back<address>(&mut payees, @0xf671e6d79b71ee3f2b02d3f52c7ec6b5);
      Vector::push_back<u64>(&mut amounts, 1614595487);
      
      Vector::push_back<address>(&mut payees, @0x1765d8b59157af3d3ef5bce9bd14fd79);
      Vector::push_back<u64>(&mut amounts, 2182196016);
      
      Vector::push_back<address>(&mut payees, @0x822676ce88bc33b90c0de6547698278f);
      Vector::push_back<u64>(&mut amounts, 1574100183);
      
      Vector::push_back<address>(&mut payees, @0x515de306486e262d7b40449e8b405167);
      Vector::push_back<u64>(&mut amounts, 2207807577);
      
      Vector::push_back<address>(&mut payees, @0xc253ea74278c89584a027e258ea4ca51);
      Vector::push_back<u64>(&mut amounts, 2222546387);
      
      Vector::push_back<address>(&mut payees, @0xa3d9dd7d57356be3831aac9f91c0cfb6);
      Vector::push_back<u64>(&mut amounts, 1581686000);
      
      Vector::push_back<address>(&mut payees, @0x3a84bfdd7994e1ccf536d521a1434805);
      Vector::push_back<u64>(&mut amounts, 2224321006);
      
      Vector::push_back<address>(&mut payees, @0xc8ccf1f79b8809da5c651daf38dd89fb);
      Vector::push_back<u64>(&mut amounts, 2180380721);
      
      Vector::push_back<address>(&mut payees, @0x1c9d5ef94c7c7794368008e0a217d993);
      Vector::push_back<u64>(&mut amounts, 1568025878);
      
      Vector::push_back<address>(&mut payees, @0x6782248feb1ce3d4a90d2257fb477cd9);
      Vector::push_back<u64>(&mut amounts, 2209832015);
      
      Vector::push_back<address>(&mut payees, @0x2dbf3505fcca59f161335fc74d755906);
      Vector::push_back<u64>(&mut amounts, 1593674467);
      
      Vector::push_back<address>(&mut payees, @0xd616b63b57a3223958a52dbb10889e04);
      Vector::push_back<u64>(&mut amounts, 2203774717);
      
      Vector::push_back<address>(&mut payees, @0x391fa64aaeb77146902273bee811b6e0);
      Vector::push_back<u64>(&mut amounts, 2206763996);
      
      Vector::push_back<address>(&mut payees, @0x5887ab2b8f8ba5dc16274fddd44cb3d0);
      Vector::push_back<u64>(&mut amounts, 1612218229);
      
      Vector::push_back<address>(&mut payees, @0x8184465d83c2b48192c117609a6dd590);
      Vector::push_back<u64>(&mut amounts, 2189797613);
      
      Vector::push_back<address>(&mut payees, @0x2df4a71aed114444544e57a7690a6ce1);
      Vector::push_back<u64>(&mut amounts, 2222072753);
      
      Vector::push_back<address>(&mut payees, @0xaef0b75a511a81695064af49002e38ea);
      Vector::push_back<u64>(&mut amounts, 2214924532);
      
      Vector::push_back<address>(&mut payees, @0xe1daff5b32fe72f04eddb4b6072ab73a);
      Vector::push_back<u64>(&mut amounts, 2206506476);
      
      Vector::push_back<address>(&mut payees, @0xa81b9e4937e34627d530a278af2a621f);
      Vector::push_back<u64>(&mut amounts, 1571488826);
      
      Vector::push_back<address>(&mut payees, @0xd1bd324825f062065935d278c0aea4c9);
      Vector::push_back<u64>(&mut amounts, 2186778422);
      
      Vector::push_back<address>(&mut payees, @0xa9d2dfc33d8fc9b009de0caed6c339c2);
      Vector::push_back<u64>(&mut amounts, 2216775024);
      
      Vector::push_back<address>(&mut payees, @0x913f9866834dfff8bb6018134fa6a8d6);
      Vector::push_back<u64>(&mut amounts, 1964005003);
      
      Vector::push_back<address>(&mut payees, @0x0ca761af163c38550604ace27add1901);
      Vector::push_back<u64>(&mut amounts, 1968298554);
      
      Vector::push_back<address>(&mut payees, @0x365b72e7c1ffefc701d328b24bf9ea7f);
      Vector::push_back<u64>(&mut amounts, 1970710418);
      
      Vector::push_back<address>(&mut payees, @0x40db723477ad162d1882ffeeaf6620b3);
      Vector::push_back<u64>(&mut amounts, 1957988508);
      
      Vector::push_back<address>(&mut payees, @0x5ded979ac62316433e0e4ef183db79e9);
      Vector::push_back<u64>(&mut amounts, 1986112629);
      
      Vector::push_back<address>(&mut payees, @0x5ec1c8f5bc8f73225a535d9798fa1251);
      Vector::push_back<u64>(&mut amounts, 1573504103);
      
      Vector::push_back<address>(&mut payees, @0x6ce8516136b10aff02b63a223eec150f);
      Vector::push_back<u64>(&mut amounts, 1985821343);
      
      Vector::push_back<address>(&mut payees, @0xeed80844497b781281292439d62ebb7e);
      Vector::push_back<u64>(&mut amounts, 1958118131);
      
      Vector::push_back<address>(&mut payees, @0xa282970fa0e104651b540fdc294cd12f);
      Vector::push_back<u64>(&mut amounts, 1985278691);
      
      Vector::push_back<address>(&mut payees, @0x29cd44921748384657449c0efaeb031c);
      Vector::push_back<u64>(&mut amounts, 1947032596);
      
      Vector::push_back<address>(&mut payees, @0x64e31246c7ed2e486b064fbb9615d19b);
      Vector::push_back<u64>(&mut amounts, 1993330661);
      
      Vector::push_back<address>(&mut payees, @0x8aa9e5f9ef062815bb036c5e79efa866);
      Vector::push_back<u64>(&mut amounts, 1954194404);
      
      Vector::push_back<address>(&mut payees, @0xc926928e68157da331be406d41eb61f1);
      Vector::push_back<u64>(&mut amounts, 1989461136);
      
      Vector::push_back<address>(&mut payees, @0x7a6155e6fb52cb3814ac2e9ca2d100e6);
      Vector::push_back<u64>(&mut amounts, 1978864925);
      
      Vector::push_back<address>(&mut payees, @0x32e31d566ad9c152345d538ba17fb6c2);
      Vector::push_back<u64>(&mut amounts, 1562588565);
      
      Vector::push_back<address>(&mut payees, @0x010f56cc16f28f4b868145a4f4df7871);
      Vector::push_back<u64>(&mut amounts, 1971800595);
      
      Vector::push_back<address>(&mut payees, @0x2fcab14988361b66179ac04e15a34d81);
      Vector::push_back<u64>(&mut amounts, 1594374360);
      
      Vector::push_back<address>(&mut payees, @0xcf4e4665eb6a5c1cffcf115c17175fb3);
      Vector::push_back<u64>(&mut amounts, 1991161402);
      
      Vector::push_back<address>(&mut payees, @0xa11b635d863eede6fd7a4a8ae0c14679);
      Vector::push_back<u64>(&mut amounts, 1560857702);
      
      Vector::push_back<address>(&mut payees, @0x5c40351b488ab441f79525f4909e28d5);
      Vector::push_back<u64>(&mut amounts, 1909722812);
      
      Vector::push_back<address>(&mut payees, @0x3ef220e67cad08148906d03bcc5179e0);
      Vector::push_back<u64>(&mut amounts, 1619951096);
      
      Vector::push_back<address>(&mut payees, @0xba69ca326ae5ee7241daa3d1cf8ca723);
      Vector::push_back<u64>(&mut amounts, 1573014071);
      
      Vector::push_back<address>(&mut payees, @0xcca95e6accb8d7d1eb9a9cc019bb62b3);
      Vector::push_back<u64>(&mut amounts, 1613555063);
      
      Vector::push_back<address>(&mut payees, @0x152be19617f1772be12cd1cd5c472826);
      Vector::push_back<u64>(&mut amounts, 1539204635);
      
      Vector::push_back<address>(&mut payees, @0xe4d80fd7d4ba3c41259dacf6e6902d0e);
      Vector::push_back<u64>(&mut amounts, 1587955677);
      
      Vector::push_back<address>(&mut payees, @0x93f86799148b03f09ca1fe6b7a8f2d6e);
      Vector::push_back<u64>(&mut amounts, 1299686729);
      
      Vector::push_back<address>(&mut payees, @0x7292544bbf4e6dd2381645176f02d3d9);
      Vector::push_back<u64>(&mut amounts, 1310748828);
      
      Vector::push_back<address>(&mut payees, @0xfb5aac3e555d096e392ace7b3e630b2a);
      Vector::push_back<u64>(&mut amounts, 1308000665);
      
      Vector::push_back<address>(&mut payees, @0x529db97c5a2bb703b68334ff1bef46b4);
      Vector::push_back<u64>(&mut amounts, 4479674913);
      
      Vector::push_back<address>(&mut payees, @0xd203bebf240f93dace0cc6857879610e);
      Vector::push_back<u64>(&mut amounts, 1387134486);
      
      Vector::push_back<address>(&mut payees, @0xe210b35e264c527d1b5c647b382808ed);
      Vector::push_back<u64>(&mut amounts, 1474970545);
      
      Vector::push_back<address>(&mut payees, @0xe2f5f40560e8993ef96c55698c1671f4);
      Vector::push_back<u64>(&mut amounts, 1575847306);
      
      Vector::push_back<address>(&mut payees, @0x874304e5578964aea4423539946109c9);
      Vector::push_back<u64>(&mut amounts, 1477488446);
      
      Vector::push_back<address>(&mut payees, @0xc6c88d0ae669ad52b254ac07c4189c2e);
      Vector::push_back<u64>(&mut amounts, 2968632518);
      
      Vector::push_back<address>(&mut payees, @0x4e53e94644860c4203d5068387363e34);
      Vector::push_back<u64>(&mut amounts, 1449153038);
      
      Vector::push_back<address>(&mut payees, @0x06619b491d539c27c5a51842f3d52362);
      Vector::push_back<u64>(&mut amounts, 2299165771);
      
      Vector::push_back<address>(&mut payees, @0x92d0d4198561211d0c1e3d063822980c);
      Vector::push_back<u64>(&mut amounts, 1649668407);
      
      Vector::push_back<address>(&mut payees, @0x6fac39c71f8755410ddcc903e453056a);
      Vector::push_back<u64>(&mut amounts, 2790642685);
      
      Vector::push_back<address>(&mut payees, @0x2ac339f1da56f2f10a149d0faa1f45b5);
      Vector::push_back<u64>(&mut amounts, 2799095151);
      
      Vector::push_back<address>(&mut payees, @0x82205ff77291b357bb12b147be2479eb);
      Vector::push_back<u64>(&mut amounts, 4014357977);
      
      Vector::push_back<address>(&mut payees, @0x7d6eafdd9c8f2d4f451bded5374af0e3);
      Vector::push_back<u64>(&mut amounts, 2912011893);
      
      Vector::push_back<address>(&mut payees, @0x6152db215858d3bfdbc82a0c0138170b);
      Vector::push_back<u64>(&mut amounts, 6802162583);
      
      Vector::push_back<address>(&mut payees, @0xcbaeb56e891ed0292f0cbb10ec78b133);
      Vector::push_back<u64>(&mut amounts, 2866860657);
      
      Vector::push_back<address>(&mut payees, @0xda10b8dd4ea38af165b563a958ce908a);
      Vector::push_back<u64>(&mut amounts, 7884216749);
      
      Vector::push_back<address>(&mut payees, @0xd794fc787036a61da611aa9afe6495db);
      Vector::push_back<u64>(&mut amounts, 2820745343);
      
      Vector::push_back<address>(&mut payees, @0xf289071ed2c77b7eeb77a80e2b3d18c0);
      Vector::push_back<u64>(&mut amounts, 2296340022);
      
      Vector::push_back<address>(&mut payees, @0x356e58619def49e8456caed45d30bd12);
      Vector::push_back<u64>(&mut amounts, 2357840454);
      
      Vector::push_back<address>(&mut payees, @0xa895a36571cf9ed5618e394f801c86aa);
      Vector::push_back<u64>(&mut amounts, 4425976762);
      
      Vector::push_back<address>(&mut payees, @0x9282ff7f6421a9f454b5664b19d3f3f1);
      Vector::push_back<u64>(&mut amounts, 2361058159);
      
      Vector::push_back<address>(&mut payees, @0xfc66b9e5d1497918c4f405c98b20bcd6);
      Vector::push_back<u64>(&mut amounts, 2335842500);
      
      Vector::push_back<address>(&mut payees, @0x7e3224f5216749a6b221856c5e75225d);
      Vector::push_back<u64>(&mut amounts, 2330553013);
      
      Vector::push_back<address>(&mut payees, @0x501d71a70b291c8beeec4a4ed1c04561);
      Vector::push_back<u64>(&mut amounts, 2343368606);
      
      Vector::push_back<address>(&mut payees, @0x1d03a4db2370e8d2536f682d3864f020);
      Vector::push_back<u64>(&mut amounts, 1321685180);
      
      Vector::push_back<address>(&mut payees, @0xb3afbdab4bb65f7f4b279d17b2f2e428);
      Vector::push_back<u64>(&mut amounts, 472911593);
      
      Vector::push_back<address>(&mut payees, @0x4e36f70696b235f8b88d2698bfbb2f13);
      Vector::push_back<u64>(&mut amounts, 476585195);
      
      Vector::push_back<address>(&mut payees, @0xdca0da4546228b03d19037d5daa9d732);
      Vector::push_back<u64>(&mut amounts, 1330959938);
      
      Vector::push_back<address>(&mut payees, @0xe12e1cec5ea73bb34c1c717af67e7a58);
      Vector::push_back<u64>(&mut amounts, 459409298);
      
      Vector::push_back<address>(&mut payees, @0x4fb0873635fc370d52faa75bdeaa0a6d);
      Vector::push_back<u64>(&mut amounts, 1325228751);
      
      Vector::push_back<address>(&mut payees, @0x1f1df4f8b0d7cbd006fce445fb6ca329);
      Vector::push_back<u64>(&mut amounts, 2846517833);
      
      Vector::push_back<address>(&mut payees, @0x3ef6a66e588e03368d8e4cd5d4f11f10);
      Vector::push_back<u64>(&mut amounts, 2925644160);
      
      Vector::push_back<address>(&mut payees, @0xad04cfff6701525ab6ed551618e39187);
      Vector::push_back<u64>(&mut amounts, 2527741178);
      
      Vector::push_back<address>(&mut payees, @0xf08c00a694433d494e6ff57051f7ead1);
      Vector::push_back<u64>(&mut amounts, 2379088920);
      
      Vector::push_back<address>(&mut payees, @0x4cdbb44165e74a9f90fe98040eb79909);
      Vector::push_back<u64>(&mut amounts, 2477268296);
      
      Vector::push_back<address>(&mut payees, @0x29e37d58e98f8b449e42c0a95f640961);
      Vector::push_back<u64>(&mut amounts, 2350559582);
      
      Vector::push_back<address>(&mut payees, @0x55fe47b618b57cc5b5fdc08971ac6ec7);
      Vector::push_back<u64>(&mut amounts, 2401072920);
      
      Vector::push_back<address>(&mut payees, @0x0c565d67373b09873f2db9d1a04a953a);
      Vector::push_back<u64>(&mut amounts, 2309227957);
      
      Vector::push_back<address>(&mut payees, @0x8b6f7a351edefa220e93b359815c5d99);
      Vector::push_back<u64>(&mut amounts, 2012551583);
      
      Vector::push_back<address>(&mut payees, @0xa8e727297ae14a5c5597fccc6b32fd73);
      Vector::push_back<u64>(&mut amounts, 2257373663);
      
      Vector::push_back<address>(&mut payees, @0x84076cb12e5758e18c87be4628379e77);
      Vector::push_back<u64>(&mut amounts, 2158211947);
      
      Vector::push_back<address>(&mut payees, @0xd991184ee47db6b2c40aec9d66a8ef88);
      Vector::push_back<u64>(&mut amounts, 2232832637);
      
      Vector::push_back<address>(&mut payees, @0xba39e4955eacfae29fce4b30e35abd5f);
      Vector::push_back<u64>(&mut amounts, 2184041890);
      
      Vector::push_back<address>(&mut payees, @0xa36b477046420db5fc5713a3870cf2a6);
      Vector::push_back<u64>(&mut amounts, 2191657753);
      
      Vector::push_back<address>(&mut payees, @0x73fcaefc65d0da68c4ff05b3991cad9c);
      Vector::push_back<u64>(&mut amounts, 2198559924);
      
      Vector::push_back<address>(&mut payees, @0x26e6e154c49e4121e3f2366038e0ad4e);
      Vector::push_back<u64>(&mut amounts, 2258759334);
      
      Vector::push_back<address>(&mut payees, @0x834feceb7366679877dde7e50ebc5675);
      Vector::push_back<u64>(&mut amounts, 2302040762);
      
      Vector::push_back<address>(&mut payees, @0x6d7651e498f4c7dee97480a4002737e1);
      Vector::push_back<u64>(&mut amounts, 2140737762);
      
      Vector::push_back<address>(&mut payees, @0x49f250f03065c630879889f7c0e6077b);
      Vector::push_back<u64>(&mut amounts, 2055652428);
      
      Vector::push_back<address>(&mut payees, @0xe300f69d62f2fb58b4c2a1403614cc82);
      Vector::push_back<u64>(&mut amounts, 2107636034);
      
      Vector::push_back<address>(&mut payees, @0xcc6e37a390e83ae53710938599990765);
      Vector::push_back<u64>(&mut amounts, 2028494406);
      
      Vector::push_back<address>(&mut payees, @0x17cae8af525724f50475c4203f8255f9);
      Vector::push_back<u64>(&mut amounts, 6860596582);
      
      Vector::push_back<address>(&mut payees, @0xf1a04e85a0190e1a17426c1b6c49b71f);
      Vector::push_back<u64>(&mut amounts, 1932457393);
      
      Vector::push_back<address>(&mut payees, @0xd7bb5dea8b3f1df93b547763982e26c2);
      Vector::push_back<u64>(&mut amounts, 1986483589);
      
      Vector::push_back<address>(&mut payees, @0x6704b5dad254640134381ba3a236ee0d);
      Vector::push_back<u64>(&mut amounts, 467180406);
      
      Vector::push_back<address>(&mut payees, @0x864a42ffb0d1261519c8aa9942d1bc98);
      Vector::push_back<u64>(&mut amounts, 465122821);
      
      Vector::push_back<address>(&mut payees, @0x2756641d5bd5f7cb3c5d4482eb26eb74);
      Vector::push_back<u64>(&mut amounts, 468006078);
      
      Vector::push_back<address>(&mut payees, @0x73b04426a7122c9a801a3f47f8d875bd);
      Vector::push_back<u64>(&mut amounts, 472911593);
      
      Vector::push_back<address>(&mut payees, @0xfe1792fc7f2a6e69614ce5ca15912f3a);
      Vector::push_back<u64>(&mut amounts, 1310162960);
      
      Vector::push_back<address>(&mut payees, @0x62c74bd1d53aca936e00ebb720e8bb94);
      Vector::push_back<u64>(&mut amounts, 472911593);
      
      Vector::push_back<address>(&mut payees, @0x0e2f026d1656779b15f3ab7f18edca8a);
      Vector::push_back<u64>(&mut amounts, 475777186);
      
      Vector::push_back<address>(&mut payees, @0x32d90a5e9ff569d29f8c241801c86b17);
      Vector::push_back<u64>(&mut amounts, 467180406);
      
      Vector::push_back<address>(&mut payees, @0x764e48425fb308f356509962e7687f37);
      Vector::push_back<u64>(&mut amounts, 470046000);
      
      Vector::push_back<address>(&mut payees, @0x3f6bf524b7fa0ba42c9391ffb74ff78a);
      Vector::push_back<u64>(&mut amounts, 470046000);
      
      Vector::push_back<address>(&mut payees, @0x84d27cd9a8ac878f4a3b764a275b1b63);
      Vector::push_back<u64>(&mut amounts, 2318645480);
      
      Vector::push_back<address>(&mut payees, @0x1cc621b0cd06bda4dbddb7158361aea2);
      Vector::push_back<u64>(&mut amounts, 806916289);
      
      Vector::push_back<address>(&mut payees, @0x29a166acc2372470366efe7b4b06829b);
      Vector::push_back<u64>(&mut amounts, 2940908503);
      
      Vector::push_back<address>(&mut payees, @0x30c51b7dd430a1680c8d667cbad866c0);
      Vector::push_back<u64>(&mut amounts, 1725713438);
      
      Vector::push_back<address>(&mut payees, @0xf720648bd133b258722aa598f19d8868);
      Vector::push_back<u64>(&mut amounts, 3115857290);
      
      Vector::push_back<address>(&mut payees, @0x04d97f7c236ea7f1ab46578e814f63b9);
      Vector::push_back<u64>(&mut amounts, 915036490);
      
      Vector::push_back<address>(&mut payees, @0x724ad9262acaace659a084e860dfb93b);
      Vector::push_back<u64>(&mut amounts, 1561368056);
      
      Vector::push_back<address>(&mut payees, @0x1166c966da6c555a24dcae060585384e);
      Vector::push_back<u64>(&mut amounts, 1981494385);
      
      Vector::push_back<address>(&mut payees, @0x13a6a04766338b05577346ba170845ed);
      Vector::push_back<u64>(&mut amounts, 2415374354);
      
      Vector::push_back<address>(&mut payees, @0x1c4d7dd851618f49be418ccd2b9e12d4);
      Vector::push_back<u64>(&mut amounts, 2126233799);
      
      Vector::push_back<address>(&mut payees, @0x72249a63279e034db4d6ef4bc0677bf5);
      Vector::push_back<u64>(&mut amounts, 3357297301);
      
      Vector::push_back<address>(&mut payees, @0xef6b96f79f159bc0db9bf79d6a3f8c9b);
      Vector::push_back<u64>(&mut amounts, 2146533134);
      
      Vector::push_back<address>(&mut payees, @0x6ee1a76d0a856148d854d42f704c7755);
      Vector::push_back<u64>(&mut amounts, 2102624601);
      
      Vector::push_back<address>(&mut payees, @0xb093ded7d475bb2236c1e972f1e20fd7);
      Vector::push_back<u64>(&mut amounts, 2087959609);
      
      Vector::push_back<address>(&mut payees, @0xb496f1c0464c187d7be522bcf7a4bcbf);
      Vector::push_back<u64>(&mut amounts, 2149758674);
      
      Vector::push_back<address>(&mut payees, @0x150beefdfc88a82e85d8d786a09edada);
      Vector::push_back<u64>(&mut amounts, 2081808665);
      
      Vector::push_back<address>(&mut payees, @0x821a75fb241fc503b0ec187561d555b3);
      Vector::push_back<u64>(&mut amounts, 2732219451);
      
      Vector::push_back<address>(&mut payees, @0xb316ed1021ef3a3f1702570b563d3bcf);
      Vector::push_back<u64>(&mut amounts, 2095081668);
      
      Vector::push_back<address>(&mut payees, @0xe9be0838e6f93f5eb8de94dd817a98a2);
      Vector::push_back<u64>(&mut amounts, 2133449423);
      
      Vector::push_back<address>(&mut payees, @0x84b3368bf8e26366dd3cfe504621331a);
      Vector::push_back<u64>(&mut amounts, 4734556348);
      
      Vector::push_back<address>(&mut payees, @0xea60b3f6e32e2a7a94da8e7ad4981b9c);
      Vector::push_back<u64>(&mut amounts, 3126380062);
      
      Vector::push_back<address>(&mut payees, @0xb61cbb044d17b0e193a839a1582ebfae);
      Vector::push_back<u64>(&mut amounts, 3038890068);
      
      Vector::push_back<address>(&mut payees, @0xc99b151767d15227af0c4107751dea1c);
      Vector::push_back<u64>(&mut amounts, 1583870601);
      
      Vector::push_back<address>(&mut payees, @0xe61d8d6cdbc4ae6f197fb544f5c3d9f7);
      Vector::push_back<u64>(&mut amounts, 1692383910);
      
      Vector::push_back<address>(&mut payees, @0x8bfd2ae715c96585a8bb05436d08963e);
      Vector::push_back<u64>(&mut amounts, 1591095519);
      
      Vector::push_back<address>(&mut payees, @0xb9a8bda59c571e7a52678347c5719e82);
      Vector::push_back<u64>(&mut amounts, 1442990518);
      
      Vector::push_back<address>(&mut payees, @0x606275c64a0eb463184fd8f0fdbeb583);
      Vector::push_back<u64>(&mut amounts, 4743498816);
      
      Vector::push_back<address>(&mut payees, @0xf150d045476a4677bb039b3e99540243);
      Vector::push_back<u64>(&mut amounts, 1364712989);
      
      Vector::push_back<address>(&mut payees, @0xc65c9b9d5f874234ff5a58bd7eced911);
      Vector::push_back<u64>(&mut amounts, 1553588338);
      
      Vector::push_back<address>(&mut payees, @0xb19b0697e5383fbcd7997422063a0ac0);
      Vector::push_back<u64>(&mut amounts, 1618552059);
      
      Vector::push_back<address>(&mut payees, @0x1b5a5fbf2ba8ca86d5ec87984704cbd8);
      Vector::push_back<u64>(&mut amounts, 1605943807);
      
      Vector::push_back<address>(&mut payees, @0xc6026e40216b24a2dc37e4a9ead37f1b);
      Vector::push_back<u64>(&mut amounts, 1637566175);
      
      Vector::push_back<address>(&mut payees, @0xaee944efa3ecdee245a326db1fa6ddc3);
      Vector::push_back<u64>(&mut amounts, 401212678);
      
      Vector::push_back<address>(&mut payees, @0x28c52a20dafbb4b3f1e1aaa472482f5b);
      Vector::push_back<u64>(&mut amounts, 1601781210);
      
      Vector::push_back<address>(&mut payees, @0xca0195fd38751944838e16d5129eab8f);
      Vector::push_back<u64>(&mut amounts, 2878890720);
      
      Vector::push_back<address>(&mut payees, @0x31e71e15171d04d2b85f01d46ecbd4e9);
      Vector::push_back<u64>(&mut amounts, 5842315223);
      
      Vector::push_back<address>(&mut payees, @0x9b89d344c2d8b28b5bdfc12ac2553bba);
      Vector::push_back<u64>(&mut amounts, 1652295042);
      
      Vector::push_back<address>(&mut payees, @0x9ff2e5e0cc7412bd34999b75eabd131c);
      Vector::push_back<u64>(&mut amounts, 1619709579);
      
      Vector::push_back<address>(&mut payees, @0x7bfaede4daf4e032913c443916e61446);
      Vector::push_back<u64>(&mut amounts, 5507180965);
      
      Vector::push_back<address>(&mut payees, @0x600e4d33f52dc0dd88d0f30087b545a0);
      Vector::push_back<u64>(&mut amounts, 1601294895);
      
      Vector::push_back<address>(&mut payees, @0x11da81e22f7d7acdf2b2e9abfb82f3a4);
      Vector::push_back<u64>(&mut amounts, 5439741597);
      
      Vector::push_back<address>(&mut payees, @0xe15e2cdfac79ee2ebecb3d648f508af8);
      Vector::push_back<u64>(&mut amounts, 1656521224);
      
      Vector::push_back<address>(&mut payees, @0xa6c5334f6d967c555dccc92e0b964064);
      Vector::push_back<u64>(&mut amounts, 5417222511);
      
      Vector::push_back<address>(&mut payees, @0xb87f8c8f780ff7a3213065cd282f120a);
      Vector::push_back<u64>(&mut amounts, 1644802625);
      
      Vector::push_back<address>(&mut payees, @0xe8b24de4742ec6abf55c5185c46aa539);
      Vector::push_back<u64>(&mut amounts, 2155994532);
      
      Vector::push_back<address>(&mut payees, @0x1dd19535d112ff10c74badccac4d9ec0);
      Vector::push_back<u64>(&mut amounts, 1391261408);
      
      Vector::push_back<address>(&mut payees, @0x76b07ab111149b8dda681f07b367a823);
      Vector::push_back<u64>(&mut amounts, 1594137834);
      
      Vector::push_back<address>(&mut payees, @0x4f87433e644f64f0f71ee6f8b5cc0360);
      Vector::push_back<u64>(&mut amounts, 3196813530);
      
      Vector::push_back<address>(&mut payees, @0x9843bd907316f13f7a246587fca41ed7);
      Vector::push_back<u64>(&mut amounts, 1581331033);
      
      Vector::push_back<address>(&mut payees, @0x278e6635b5a4968613187550c751334b);
      Vector::push_back<u64>(&mut amounts, 3760953234);
      
      Vector::push_back<address>(&mut payees, @0x299226308e9dbabaab1096ebd9c941ab);
      Vector::push_back<u64>(&mut amounts, 1507260524);
      
      Vector::push_back<address>(&mut payees, @0x8b2f6eaaac2c94b6542213011e766d8f);
      Vector::push_back<u64>(&mut amounts, 1495882254);
      
      Vector::push_back<address>(&mut payees, @0xd9135aca3599956487184f5924e92db7);
      Vector::push_back<u64>(&mut amounts, 1525008771);
      
      Vector::push_back<address>(&mut payees, @0x442a2fd2d63f9b552bca3c71fb46b933);
      Vector::push_back<u64>(&mut amounts, 6078759787);
      
      Vector::push_back<address>(&mut payees, @0xa8c2e5f5c08a9de060bcdce5d9135da8);
      Vector::push_back<u64>(&mut amounts, 3426528078);
      
      Vector::push_back<address>(&mut payees, @0xf1d843265c43bcc253c28a13e7432839);
      Vector::push_back<u64>(&mut amounts, 1608149191);
      
      Vector::push_back<address>(&mut payees, @0x07a4ec1654ceff7cf2f07aa8d9c309f6);
      Vector::push_back<u64>(&mut amounts, 3739303503);
      
      Vector::push_back<address>(&mut payees, @0x0fdd689802883ef0c5e3703a05d4fd71);
      Vector::push_back<u64>(&mut amounts, 1587150969);
      
      Vector::push_back<address>(&mut payees, @0x9c94a01529ff99a32ed7148f2a7614a3);
      Vector::push_back<u64>(&mut amounts, 1554160835);
      
      Vector::push_back<address>(&mut payees, @0xfc2bf6efe64efc7703a635fd7afff5db);
      Vector::push_back<u64>(&mut amounts, 1583463385);
      
      Vector::push_back<address>(&mut payees, @0x52634610095b2e05ee10424506c9fea0);
      Vector::push_back<u64>(&mut amounts, 3945261813);
      
      Vector::push_back<address>(&mut payees, @0x58f973fbefd87c773d31965a885e3a85);
      Vector::push_back<u64>(&mut amounts, 1616711785);
      
      Vector::push_back<address>(&mut payees, @0x2fc061e0206808add9bfcf96ebe59a16);
      Vector::push_back<u64>(&mut amounts, 1625122723);
      
      Vector::push_back<address>(&mut payees, @0xdfffa896b1d49819cbe0b2234efbb37d);
      Vector::push_back<u64>(&mut amounts, 4660777581);
      
      Vector::push_back<address>(&mut payees, @0xf6032e2007f31b86c2122f707906ebe0);
      Vector::push_back<u64>(&mut amounts, 462274892);
      
      Vector::push_back<address>(&mut payees, @0x342da19e72d0cdee8780a00f6673ad91);
      Vector::push_back<u64>(&mut amounts, 2431391706);
      
      Vector::push_back<address>(&mut payees, @0xc4c8dbaee47a737d6f74b10cac060a49);
      Vector::push_back<u64>(&mut amounts, 3292448935);
      
      Vector::push_back<address>(&mut payees, @0x80d00d1ffa61fa3946fd56136130691b);
      Vector::push_back<u64>(&mut amounts, 2015989821);
      
      Vector::push_back<address>(&mut payees, @0x15bbd12c822d89ba9b3c03985a7f6f88);
      Vector::push_back<u64>(&mut amounts, 2047118755);
      
      Vector::push_back<address>(&mut payees, @0x5ff1512db526fc9f95e37eacfae2f548);
      Vector::push_back<u64>(&mut amounts, 4060888070);
      
      Vector::push_back<address>(&mut payees, @0x911c054a121ecbb1fab52eba16d5bc83);
      Vector::push_back<u64>(&mut amounts, 3034758673);
      
      Vector::push_back<address>(&mut payees, @0xea6334be2415e5a9904337e69a02aa74);
      Vector::push_back<u64>(&mut amounts, 1681463637);
      
      Vector::push_back<address>(&mut payees, @0x74ace8d647cdf55b49ed25cd4efa40ad);
      Vector::push_back<u64>(&mut amounts, 1973355099);
      
      Vector::push_back<address>(&mut payees, @0xc0859fb4c5099a8f90b5f67cb1cfbaab);
      Vector::push_back<u64>(&mut amounts, 1318817348);
      
      Vector::push_back<address>(&mut payees, @0x771fdac3a588d84adea7c50728f8b933);
      Vector::push_back<u64>(&mut amounts, 2028549538);
      
      Vector::push_back<address>(&mut payees, @0x1f2e588e2c9fd0544807641b33102643);
      Vector::push_back<u64>(&mut amounts, 3169451555);
      
      Vector::push_back<address>(&mut payees, @0x59d1fdd6d05491efe85f22d5684abbd9);
      Vector::push_back<u64>(&mut amounts, 1964280411);
      
      Vector::push_back<address>(&mut payees, @0xaf0618bb1220b9f03b0044293db7a9b9);
      Vector::push_back<u64>(&mut amounts, 2143741842);
      
      Vector::push_back<address>(&mut payees, @0x80bb684c90cc4ca342b3e4b071ed8325);
      Vector::push_back<u64>(&mut amounts, 2030638866);
      
      Vector::push_back<address>(&mut payees, @0x695c91b6c5c1bc97abc1646db944dcfc);
      Vector::push_back<u64>(&mut amounts, 1996406874);
      
      Vector::push_back<address>(&mut payees, @0xee7374e30e652049f2840d3909b68ddf);
      Vector::push_back<u64>(&mut amounts, 4983720619);
      
      Vector::push_back<address>(&mut payees, @0xd0688adc09d064b624903b3928a6ded5);
      Vector::push_back<u64>(&mut amounts, 2069334034);
      
      Vector::push_back<address>(&mut payees, @0x211ecb11596400df2ac5aec396b488ad);
      Vector::push_back<u64>(&mut amounts, 2042107543);
      
      Vector::push_back<address>(&mut payees, @0xc7e61f9678371fab1d70e6a872050d94);
      Vector::push_back<u64>(&mut amounts, 2099769750);
      
      Vector::push_back<address>(&mut payees, @0x85c8891c8b8f395df4d407963338dffa);
      Vector::push_back<u64>(&mut amounts, 2077216123);
      
      Vector::push_back<address>(&mut payees, @0xdb95bd7aa383d093ef105c20814070cd);
      Vector::push_back<u64>(&mut amounts, 1735211352);
      
      Vector::push_back<address>(&mut payees, @0x2e32ecdf161aeba14e0dbe6be06349bc);
      Vector::push_back<u64>(&mut amounts, 1721378241);
      
      Vector::push_back<address>(&mut payees, @0x80303e502a035d8b79bc742c2da06694);
      Vector::push_back<u64>(&mut amounts, 1740447734);
      
      Vector::push_back<address>(&mut payees, @0x439bf8ced8971b04bdb30ee15820d8c1);
      Vector::push_back<u64>(&mut amounts, 1736565649);
      
      Vector::push_back<address>(&mut payees, @0x22d4d6e266a861ade8e3c415deed617b);
      Vector::push_back<u64>(&mut amounts, 2850168577);
      
      Vector::push_back<address>(&mut payees, @0x048ccb33bf48a0f333023e0e8ecce568);
      Vector::push_back<u64>(&mut amounts, 132982517);
      
      Vector::push_back<address>(&mut payees, @0xbe9cd7860812dc1b7aa1f782597d0427);
      Vector::push_back<u64>(&mut amounts, 1709466632);
      
      Vector::push_back<address>(&mut payees, @0xadcb1d42a46292ae89e938bd982f2867);
      Vector::push_back<u64>(&mut amounts, 135432640);
      
      Vector::push_back<address>(&mut payees, @0x8cafd3ad53953417d66dfb8eecb3404c);
      Vector::push_back<u64>(&mut amounts, 95617493);
      
      Vector::push_back<address>(&mut payees, @0xbf38a08c1c7f2e862f27d59ba9af9da7);
      Vector::push_back<u64>(&mut amounts, 1713963841);
      
      Vector::push_back<address>(&mut payees, @0x4bf2ef7a3cfc82412aaf23ccbdc8b0c9);
      Vector::push_back<u64>(&mut amounts, 385919309);
      
      Vector::push_back<address>(&mut payees, @0x26fba9c1a270054c2a8b4a9df49f702a);
      Vector::push_back<u64>(&mut amounts, 1513170640);
      
      Vector::push_back<address>(&mut payees, @0x6cd27cf11d30918b6a21fa8a42a57a05);
      Vector::push_back<u64>(&mut amounts, 1499032613);
      
      Vector::push_back<address>(&mut payees, @0xb87f919b420a70ff1e971fe713dc9ba3);
      Vector::push_back<u64>(&mut amounts, 1381701213);
      
      Vector::push_back<address>(&mut payees, @0xd21c73fd773cd60b43c51029e2fb36b5);
      Vector::push_back<u64>(&mut amounts, 2147544901);
      
      Vector::push_back<address>(&mut payees, @0xa0bf75d3343d4f39d08a210b49d93ac5);
      Vector::push_back<u64>(&mut amounts, 1631721493);
      
      Vector::push_back<address>(&mut payees, @0x425ddbc8efc8ffe71172ad1527541682);
      Vector::push_back<u64>(&mut amounts, 1808284936);
      
      Vector::push_back<address>(&mut payees, @0x200b528d82041167b6ef268357e61f13);
      Vector::push_back<u64>(&mut amounts, 1561221413);
      
      Vector::push_back<address>(&mut payees, @0x7db3171a208bd8d3f0a552580c12be16);
      Vector::push_back<u64>(&mut amounts, 1602431778);
      
      Vector::push_back<address>(&mut payees, @0x8433758ea90ba3eb1cd22dba5ccaacba);
      Vector::push_back<u64>(&mut amounts, 1452748468);
      
      Vector::push_back<address>(&mut payees, @0x51edc65c94fbb959d51d5113a5598912);
      Vector::push_back<u64>(&mut amounts, 2676327061);
      
      Vector::push_back<address>(&mut payees, @0xfe052954c6cab2c33235656256075161);
      Vector::push_back<u64>(&mut amounts, 1571865620);
      
      Vector::push_back<address>(&mut payees, @0x0907232efd8542be7052aaa602879ebc);
      Vector::push_back<u64>(&mut amounts, 1522622319);
      
      Vector::push_back<address>(&mut payees, @0x96df3c1519f2cd117c1a208d563dbdd0);
      Vector::push_back<u64>(&mut amounts, 1472596891);
      
      Vector::push_back<address>(&mut payees, @0xd4f886b30f613cabd515bb8155d76f33);
      Vector::push_back<u64>(&mut amounts, 1545494806);
      
      Vector::push_back<address>(&mut payees, @0xacf6412c705cc35d1e2594d023779266);
      Vector::push_back<u64>(&mut amounts, 1566587812);
      
      Vector::push_back<address>(&mut payees, @0x63d372b0ea77fbc0dcbb29988fe8dffb);
      Vector::push_back<u64>(&mut amounts, 3960360521);
      
      Vector::push_back<address>(&mut payees, @0x42858255ca593fa982563337401c0743);
      Vector::push_back<u64>(&mut amounts, 1531709349);
      
      Vector::push_back<address>(&mut payees, @0x7904943ab941e967a5a57c2e508a2fbf);
      Vector::push_back<u64>(&mut amounts, 1524215287);
      
      Vector::push_back<address>(&mut payees, @0x02ac22550cd38db602ea2d1a1bb8ab0b);
      Vector::push_back<u64>(&mut amounts, 1600686967);
      
      Vector::push_back<address>(&mut payees, @0xfa6012837fba68f6d663c1c60be9ee77);
      Vector::push_back<u64>(&mut amounts, 1376945030);
      
      Vector::push_back<address>(&mut payees, @0x3db2b238068612f575cdcf66a7989b0f);
      Vector::push_back<u64>(&mut amounts, 1505555961);
      
      Vector::push_back<address>(&mut payees, @0x61b2e63aaf073a7b798fad2f008380e2);
      Vector::push_back<u64>(&mut amounts, 1474047450);
      
      Vector::push_back<address>(&mut payees, @0x35d1362139ed7dc3931327f4d217761b);
      Vector::push_back<u64>(&mut amounts, 1610420457);
      
      Vector::push_back<address>(&mut payees, @0x3183353e06b1817c3a8c56eba12c7b0a);
      Vector::push_back<u64>(&mut amounts, 1359491947);
      
      Vector::push_back<address>(&mut payees, @0x94bd433c114d9d33060c60fa66bffbfe);
      Vector::push_back<u64>(&mut amounts, 1432297002);
      
      Vector::push_back<address>(&mut payees, @0x835588cf1a0a2288f123c590d3be009f);
      Vector::push_back<u64>(&mut amounts, 1589233458);
      
      Vector::push_back<address>(&mut payees, @0x50e05842af5192ba048be3115c10371a);
      Vector::push_back<u64>(&mut amounts, 1961310031);
      
      Vector::push_back<address>(&mut payees, @0x83cddc7ede143841599360efd237a3c4);
      Vector::push_back<u64>(&mut amounts, 596563073);
      
      Vector::push_back<address>(&mut payees, @0xde3c2ae40c9bfdd86e8f3ac1f370f0b3);
      Vector::push_back<u64>(&mut amounts, 577492552);
      
      Vector::push_back<address>(&mut payees, @0xf72c1f1b6926fdb63cfba2d434e8d764);
      Vector::push_back<u64>(&mut amounts, 573645605);
      
      Vector::push_back<address>(&mut payees, @0x612dfe4a5e82810aa6c29d7504879f7b);
      Vector::push_back<u64>(&mut amounts, 569602885);
      
      Vector::push_back<address>(&mut payees, @0xa3ff725159cbe61631bf32e958b7a17a);
      Vector::push_back<u64>(&mut amounts, 563773607);
      
      Vector::push_back<address>(&mut payees, @0xd667034d24422f74a83792a67e2858d2);
      Vector::push_back<u64>(&mut amounts, 569596649);
      
      Vector::push_back<address>(&mut payees, @0x30a335d5f4a30548875226689625bcd5);
      Vector::push_back<u64>(&mut amounts, 1315357294);
      
      Vector::push_back<address>(&mut payees, @0x8d0c80c550658874fa3dd2b68e18c622);
      Vector::push_back<u64>(&mut amounts, 1611419293);
      
      Vector::push_back<address>(&mut payees, @0xeda42cb83eaab53dee1b037e4ad21af6);
      Vector::push_back<u64>(&mut amounts, 485720991);
      
      Vector::push_back<address>(&mut payees, @0x8f809aac78f9d13aad385aa104c52572);
      Vector::push_back<u64>(&mut amounts, 585579596);
      
      Vector::push_back<address>(&mut payees, @0xb8c8fa437a050fdc505f6ef016fefb74);
      Vector::push_back<u64>(&mut amounts, 254587225);
      
      Vector::push_back<address>(&mut payees, @0xdf9af8814624a12d9bbbdf6105fb8ac3);
      Vector::push_back<u64>(&mut amounts, 300097398);
      
      Vector::push_back<address>(&mut payees, @0xf8a560beddf73dd07751f33f8dc397df);
      Vector::push_back<u64>(&mut amounts, 210824278);
      
      Vector::push_back<address>(&mut payees, @0x09e9bb473e6fbc0c02df3b27fc61e205);
      Vector::push_back<u64>(&mut amounts, 124173711);
      
      Vector::push_back<address>(&mut payees, @0x1dd0c0c980bfd33dc9b3fe56e49aeb0c);
      Vector::push_back<u64>(&mut amounts, 203335246);
      
      Vector::push_back<address>(&mut payees, @0x277303d9c17985a6eae7ffcb0a92abe7);
      Vector::push_back<u64>(&mut amounts, 90227311);
      
      Vector::push_back<address>(&mut payees, @0x53a4ca2b5867c037866ac67e220daee5);
      Vector::push_back<u64>(&mut amounts, 2594227890);
      
      Vector::push_back<address>(&mut payees, @0xaaa64537848b83a34635d5cd294e51b4);
      Vector::push_back<u64>(&mut amounts, 2759458182);
      
      Vector::push_back<address>(&mut payees, @0x6ad479c68a49a17bfb44346a3f6720a8);
      Vector::push_back<u64>(&mut amounts, 2623173900);
      
      Vector::push_back<address>(&mut payees, @0xa704611ebd0f23b3ceed95ec140198ff);
      Vector::push_back<u64>(&mut amounts, 2473940798);
      
      Vector::push_back<address>(&mut payees, @0xc51d33af1e159fbc7b05845de392036f);
      Vector::push_back<u64>(&mut amounts, 2217828101);
      
      Vector::push_back<address>(&mut payees, @0x0c05ba3aea36beeedf56ccece5e4a91e);
      Vector::push_back<u64>(&mut amounts, 1839150724);
      
      Vector::push_back<address>(&mut payees, @0x668190d5dc15b5a395bb2f4754c1c007);
      Vector::push_back<u64>(&mut amounts, 1147970519);
      
      Vector::push_back<address>(&mut payees, @0x3997aa9f058f1154aa042dd41db76bc5);
      Vector::push_back<u64>(&mut amounts, 1309055747);
      
      Vector::push_back<address>(&mut payees, @0x33a91fb6b7284ab5fee6046b7416be25);
      Vector::push_back<u64>(&mut amounts, 808415258);
      
      Vector::push_back<address>(&mut payees, @0x7abbfc1036a9e7a7caa8b45aa0adb491);
      Vector::push_back<u64>(&mut amounts, 4282820465);
      
      Vector::push_back<address>(&mut payees, @0xf2ab0b61499122392cae0277f096ffa2);
      Vector::push_back<u64>(&mut amounts, 4878070542);
      
      Vector::push_back<address>(&mut payees, @0x9a81275cbad2fcc6f3809367af8907fb);
      Vector::push_back<u64>(&mut amounts, 4262789811);
      
      Vector::push_back<address>(&mut payees, @0x5cb05098bcca54e15bd51977743a82bb);
      Vector::push_back<u64>(&mut amounts, 1615594092);
      
      Vector::push_back<address>(&mut payees, @0xd888258f1516b4f82680d36e9a1f16e8);
      Vector::push_back<u64>(&mut amounts, 4722594371);
      
      Vector::push_back<address>(&mut payees, @0xcaabf6591358b6968fbc4d6be062c4e8);
      Vector::push_back<u64>(&mut amounts, 2833081458);
      
      Vector::push_back<address>(&mut payees, @0xc8336044cdf1878d9738ed0a041b235e);
      Vector::push_back<u64>(&mut amounts, 5298634068);
      
      Vector::push_back<address>(&mut payees, @0xf973667c742b6e877d11398fbe5697d5);
      Vector::push_back<u64>(&mut amounts, 4987119520);
      
      Vector::push_back<address>(&mut payees, @0xfa87af326d8dee1d97971ed86d6f1b35);
      Vector::push_back<u64>(&mut amounts, 5483943082);
      
      Vector::push_back<address>(&mut payees, @0x3104a9c3a84b03dababae3704db7ca0a);
      Vector::push_back<u64>(&mut amounts, 1766324982);
      
      Vector::push_back<address>(&mut payees, @0xe7fd87b088f4fc19bc51038a90d70e55);
      Vector::push_back<u64>(&mut amounts, 5062346921);
      
      Vector::push_back<address>(&mut payees, @0x4cad63c16adc604d774f719250a63fe5);
      Vector::push_back<u64>(&mut amounts, 277086946);
      
      Vector::push_back<address>(&mut payees, @0x00a7c9b758095176d29e5936ba9fb1d6);
      Vector::push_back<u64>(&mut amounts, 5407176406);
      
      Vector::push_back<address>(&mut payees, @0xc990ecb24c5362c0cfdb8c646a85f602);
      Vector::push_back<u64>(&mut amounts, 1560703658);
      
      Vector::push_back<address>(&mut payees, @0x23e2a43dd91667ce668ce107705f4c75);
      Vector::push_back<u64>(&mut amounts, 6250258758);
      
      Vector::push_back<address>(&mut payees, @0x148c808f4063d03966c10f61dd6f3711);
      Vector::push_back<u64>(&mut amounts, 4127867292);
      
      Vector::push_back<address>(&mut payees, @0xa959fa2fa2f9fdf9b7c0d2f692de7e1e);
      Vector::push_back<u64>(&mut amounts, 174734533);
      
      Vector::push_back<address>(&mut payees, @0xbc5ac6b47a669f9eb4b9805a5e8505c2);
      Vector::push_back<u64>(&mut amounts, 5904776220);
      
      Vector::push_back<address>(&mut payees, @0xe05c57655cc851bc4bcbfeeb4ada8b75);
      Vector::push_back<u64>(&mut amounts, 238403658);
      
      Vector::push_back<address>(&mut payees, @0xfa6f7ec7bb58b1d7c5d266cd96d5f78e);
      Vector::push_back<u64>(&mut amounts, 3496951815);
      
      Vector::push_back<address>(&mut payees, @0xae4582dda8cc5601d6c81b4a27a46b58);
      Vector::push_back<u64>(&mut amounts, 3673680849);
      
      Vector::push_back<address>(&mut payees, @0xdfe8a91b9e8ee3bdda336487a5b646a8);
      Vector::push_back<u64>(&mut amounts, 1511368845);
      
      Vector::push_back<address>(&mut payees, @0x83735fd7058c6bfb13987cb5f99e97da);
      Vector::push_back<u64>(&mut amounts, 1887776674);
      
      Vector::push_back<address>(&mut payees, @0x9401af0f29d2afd49b8e48a0c361f661);
      Vector::push_back<u64>(&mut amounts, 1289462205);
      
      Vector::push_back<address>(&mut payees, @0x5790d2075ea54c3ee4ac67f281ef38a1);
      Vector::push_back<u64>(&mut amounts, 3182383311);
      
      Vector::push_back<address>(&mut payees, @0x192c29ed42d6c3f761491cafcce69ed1);
      Vector::push_back<u64>(&mut amounts, 3543194266);
      
      Vector::push_back<address>(&mut payees, @0x89953d4db946ab82be4c996d97fa5023);
      Vector::push_back<u64>(&mut amounts, 881118582);
      
      Vector::push_back<address>(&mut payees, @0xa7c9151ad7c846fcd576932d1d97a737);
      Vector::push_back<u64>(&mut amounts, 2198212000);
      
      Vector::push_back<address>(&mut payees, @0x4e4e14eb9b9f0f8252ecf4137d25499a);
      Vector::push_back<u64>(&mut amounts, 3936737288);
      
      Vector::push_back<address>(&mut payees, @0x7e2a48c54258e052cd30295bb082dbea);
      Vector::push_back<u64>(&mut amounts, 430625293);
      
      Vector::push_back<address>(&mut payees, @0x9f395754547c76fda1577edd53a959d9);
      Vector::push_back<u64>(&mut amounts, 5152202787);
      
      Vector::push_back<address>(&mut payees, @0x0528d2246894d91298206414178a66fa);
      Vector::push_back<u64>(&mut amounts, 1444260776);
      
      Vector::push_back<address>(&mut payees, @0xf6a8a417a2efe3afce59fcea5b54b130);
      Vector::push_back<u64>(&mut amounts, 110292708);
      
      Vector::push_back<address>(&mut payees, @0x9b29465a7bb3cf90f312f0233abaf77f);
      Vector::push_back<u64>(&mut amounts, 124276201);
      
      Vector::push_back<address>(&mut payees, @0xadf111bd541290b34f8ae39ac4317208);
      Vector::push_back<u64>(&mut amounts, 377443141);
      
      Vector::push_back<address>(&mut payees, @0x790ee459417abc79aec5055f6966ed9f);
      Vector::push_back<u64>(&mut amounts, 1925601649);
      
      Vector::push_back<address>(&mut payees, @0xdcfccf8e24d43affaabe19177e742b5b);
      Vector::push_back<u64>(&mut amounts, 2116012711);
      
      Vector::push_back<address>(&mut payees, @0xd59761d906dd1365d3c759e036547c49);
      Vector::push_back<u64>(&mut amounts, 2536407659);
      
      Vector::push_back<address>(&mut payees, @0x6e601f3bdcc7b2118ef656fd20c842fb);
      Vector::push_back<u64>(&mut amounts, 1890917029);
      
      Vector::push_back<address>(&mut payees, @0x6e518e456df8e23393cd1860db864c38);
      Vector::push_back<u64>(&mut amounts, 718375552);
      
      Vector::push_back<address>(&mut payees, @0x9c283c053c99f0e062cd9575086c5718);
      Vector::push_back<u64>(&mut amounts, 2553280064);
      
      Vector::push_back<address>(&mut payees, @0x69bf0a1c4bbc00beb0d1f289fad7d0ca);
      Vector::push_back<u64>(&mut amounts, 2767436408);
      
      Vector::push_back<address>(&mut payees, @0xd99fefe5a936c799dfa0a8418523ff77);
      Vector::push_back<u64>(&mut amounts, 578649501);
      
      Vector::push_back<address>(&mut payees, @0x85f92663dec4037affd7404f52de3cb0);
      Vector::push_back<u64>(&mut amounts, 3514928034);
      
      Vector::push_back<address>(&mut payees, @0xd25b39d425f467c532ca8fb7e8205a80);
      Vector::push_back<u64>(&mut amounts, 1619909390);
      
      Vector::push_back<address>(&mut payees, @0x9925084bd621fc4666a21928acecc504);
      Vector::push_back<u64>(&mut amounts, 2333649068);
      
      Vector::push_back<address>(&mut payees, @0x79575894c66a53aab6814cce6d2bb26e);
      Vector::push_back<u64>(&mut amounts, 1108386747);
      
      Vector::push_back<address>(&mut payees, @0x71703cbe443cd4ff87e000ccf038a31c);
      Vector::push_back<u64>(&mut amounts, 2039539824);
      
      Vector::push_back<address>(&mut payees, @0xedae61ae30053b90cd04860cb3c39c51);
      Vector::push_back<u64>(&mut amounts, 2039750043);
      
      Vector::push_back<address>(&mut payees, @0x908a421f51eacfcb723ab09b2d1265a3);
      Vector::push_back<u64>(&mut amounts, 1006064138);
      
      Vector::push_back<address>(&mut payees, @0x09e245015c921645907db2dec7633295);
      Vector::push_back<u64>(&mut amounts, 1389007075);
      
      Vector::push_back<address>(&mut payees, @0xe46b86c249f17d5dd87657e1d8f6a106);
      Vector::push_back<u64>(&mut amounts, 1331810640);
      
      Vector::push_back<address>(&mut payees, @0x9740f06ade1d8001b3b78e71f38e870c);
      Vector::push_back<u64>(&mut amounts, 1950069839);
      
      Vector::push_back<address>(&mut payees, @0xf26402cfa9cce8a0a9a3aafce1eb5c0c);
      Vector::push_back<u64>(&mut amounts, 181498446);
      
      Vector::push_back<address>(&mut payees, @0x6f6a4d9d6ebcf871b2b7ee1def1e23fc);
      Vector::push_back<u64>(&mut amounts, 407097385);
      
      Vector::push_back<address>(&mut payees, @0x29d411ae89f163fe2eb89278e0445084);
      Vector::push_back<u64>(&mut amounts, 741657662);
      
      Vector::push_back<address>(&mut payees, @0x948322d7a366dbbd4ce493b5573a16e4);
      Vector::push_back<u64>(&mut amounts, 1852953384);
      
      Vector::push_back<address>(&mut payees, @0x3810a26803ebf48dbc58fc2c19ea003d);
      Vector::push_back<u64>(&mut amounts, 2080927141);
      
      Vector::push_back<address>(&mut payees, @0x7b1216f97731f9f3d9c15bd84c4b1e7f);
      Vector::push_back<u64>(&mut amounts, 29679955);
      
      Vector::push_back<address>(&mut payees, @0x4c058c6b815dd43e4a638a16781ad2db);
      Vector::push_back<u64>(&mut amounts, 29679955);
      
      Vector::push_back<address>(&mut payees, @0x03e6bfbc2687742c4a3291b1ef84305d);
      Vector::push_back<u64>(&mut amounts, 1856465922);
      
      Vector::push_back<address>(&mut payees, @0x81c9de2cc006e5d2b76b968f9803eb3e);
      Vector::push_back<u64>(&mut amounts, 88155790);
      
      Vector::push_back<address>(&mut payees, @0x0a7802c5ce3bdcffb918c680825756aa);
      Vector::push_back<u64>(&mut amounts, 1276287935);
      
      Vector::push_back<address>(&mut payees, @0x57682e2c99cf0cd1c650807547f64069);
      Vector::push_back<u64>(&mut amounts, 328776692);
      
      Vector::push_back<address>(&mut payees, @0xf8289be2785a74ef3e812d0c7287f2c3);
      Vector::push_back<u64>(&mut amounts, 1822353131);
      
      Vector::push_back<address>(&mut payees, @0x2c3b38887f4ea4dac7dca10db503535d);
      Vector::push_back<u64>(&mut amounts, 809713841);
      
      Vector::push_back<address>(&mut payees, @0x3240f6b2e1e9941cf781ef46762f4d71);
      Vector::push_back<u64>(&mut amounts, 1022800918);
      
      Vector::push_back<address>(&mut payees, @0x1f63384afabeb097b3e4046c82f7cd15);
      Vector::push_back<u64>(&mut amounts, 129225743);
      
      Vector::push_back<address>(&mut payees, @0x3068924fdfe8d1a5df9639d8a266ec95);
      Vector::push_back<u64>(&mut amounts, 472911593);
      
      Vector::push_back<address>(&mut payees, @0x75db05a3b1365eb0796cf5f4e7ea87a7);
      Vector::push_back<u64>(&mut amounts, 468067336);
      
      Vector::push_back<address>(&mut payees, @0xcfffceaf82372896f936effa5473cc8f);
      Vector::push_back<u64>(&mut amounts, 4908383327);
      
      Vector::push_back<address>(&mut payees, @0x55c48a89a4840c417e3ca4681b01ebe7);
      Vector::push_back<u64>(&mut amounts, 465201742);
      
      Vector::push_back<address>(&mut payees, @0x034491ea00dc69bd94cf0ee6c13f6f90);
      Vector::push_back<u64>(&mut amounts, 585690634);
      
      Vector::push_back<address>(&mut payees, @0xb9f569261d3cd154fba45a37b866eb60);
      Vector::push_back<u64>(&mut amounts, 2924751961);
      
      Vector::push_back<address>(&mut payees, @0x4fa5eaeab22f6b3222cec64f296c9906);
      Vector::push_back<u64>(&mut amounts, 1359825389);
      
      Vector::push_back<address>(&mut payees, @0xe60e810e5bd44b74a68a261d5958a5ab);
      Vector::push_back<u64>(&mut amounts, 674481913);
      
      Vector::push_back<address>(&mut payees, @0x998990c7aae3d4128c4e310b3a919717);
      Vector::push_back<u64>(&mut amounts, 1521756560);
      
      Vector::push_back<address>(&mut payees, @0xe7f8917937b884b50683f4ba378567d9);
      Vector::push_back<u64>(&mut amounts, 2021535306);
      
      Vector::push_back<address>(&mut payees, @0x556274c9f8c5fb0345a134a987323cf6);
      Vector::push_back<u64>(&mut amounts, 3805940171);
      
      Vector::push_back<address>(&mut payees, @0x3866cd99f1b2e64cb681185074bd83ae);
      Vector::push_back<u64>(&mut amounts, 5245814221);
      
      Vector::push_back<address>(&mut payees, @0x878e65b64d7dd4c5f535b52e5f5b01a5);
      Vector::push_back<u64>(&mut amounts, 443755073);
      
      Vector::push_back<address>(&mut payees, @0xd821630b82b467f7102b70b65c1e71b4);
      Vector::push_back<u64>(&mut amounts, 1191523875);
      
      Vector::push_back<address>(&mut payees, @0x328919637b1da0e39a352acde9d10a61);
      Vector::push_back<u64>(&mut amounts, 6151710618);
      
      Vector::push_back<address>(&mut payees, @0x66da47aadfddf6bd95920740fdd71fdb);
      Vector::push_back<u64>(&mut amounts, 3205595316);
      
      Vector::push_back<address>(&mut payees, @0xdbaac29cb72befc6591e2795c6181202);
      Vector::push_back<u64>(&mut amounts, 4439735861);
      
      Vector::push_back<address>(&mut payees, @0x870d1297e1f8a15dbe522913ea0d3c4f);
      Vector::push_back<u64>(&mut amounts, 3768847528);
      
      Vector::push_back<address>(&mut payees, @0x8a8178ca0a71060d385fa685d8c0e54e);
      Vector::push_back<u64>(&mut amounts, 92632408);
      
      Vector::push_back<address>(&mut payees, @0x76e2b0f7cfe21f8d4d83cd6a7ac33914);
      Vector::push_back<u64>(&mut amounts, 4622196480);
      
      Vector::push_back<address>(&mut payees, @0x5a079bdf5a2013e4795f6ad95f88ee61);
      Vector::push_back<u64>(&mut amounts, 3470707877);
      
      Vector::push_back<address>(&mut payees, @0xb676a9c17e62435578388db440b3c2aa);
      Vector::push_back<u64>(&mut amounts, 2977723632);
      
      Vector::push_back<address>(&mut payees, @0x2806b827b41a7d9b3cf3e34cf28b1a6e);
      Vector::push_back<u64>(&mut amounts, 124089687);
      
      Vector::push_back<address>(&mut payees, @0xa02327c54c3a2fac07996eafb23d2ddd);
      Vector::push_back<u64>(&mut amounts, 113881544);
      
      Vector::push_back<address>(&mut payees, @0xc24649d6bc33f82097234741312b47d5);
      Vector::push_back<u64>(&mut amounts, 502109229);
      
      Vector::push_back<address>(&mut payees, @0xd26aaf7a2e6b70bdaf9be974af9fe906);
      Vector::push_back<u64>(&mut amounts, 3388092007);
      
      Vector::push_back<address>(&mut payees, @0x5745a603f45639dccb8648c907074237);
      Vector::push_back<u64>(&mut amounts, 2814626510);
      
      Vector::push_back<address>(&mut payees, @0x2050fe396a97e7a4292941cd51b45631);
      Vector::push_back<u64>(&mut amounts, 1833212852);
      
      Vector::push_back<address>(&mut payees, @0x36e234e00d6f76f395537980e12e02fb);
      Vector::push_back<u64>(&mut amounts, 2677275185);
      
      Vector::push_back<address>(&mut payees, @0x6e7e787a2e949f0de4cd35e54ab29dea);
      Vector::push_back<u64>(&mut amounts, 2672232253);
      
      Vector::push_back<address>(&mut payees, @0x7058356473f3d6a0c1a35405e885e3eb);
      Vector::push_back<u64>(&mut amounts, 2580217948);
      
      Vector::push_back<address>(&mut payees, @0x2bd35273198dec19c1cd9f3052970b08);
      Vector::push_back<u64>(&mut amounts, 1004516681);
      
      Vector::push_back<address>(&mut payees, @0x21e80848bac1b31042d61df354712e90);
      Vector::push_back<u64>(&mut amounts, 278380263);
      
      Vector::push_back<address>(&mut payees, @0x85c2bbf237dd5ebba359e84b894d7602);
      Vector::push_back<u64>(&mut amounts, 4825585391);
      
      Vector::push_back<address>(&mut payees, @0x41ae7cc1d9841551d90b60d40cdc59de);
      Vector::push_back<u64>(&mut amounts, 2594532360);
      
      Vector::push_back<address>(&mut payees, @0x98923467797b4c73a8f1fe79c050117d);
      Vector::push_back<u64>(&mut amounts, 2640445603);
      
      Vector::push_back<address>(&mut payees, @0x6186379b19c3b73d41fb6653e5e2bfad);
      Vector::push_back<u64>(&mut amounts, 553944703);
      
      Vector::push_back<address>(&mut payees, @0xf4cd516e6f20224e81284bcbcbc33c51);
      Vector::push_back<u64>(&mut amounts, 793914707);
      
      Vector::push_back<address>(&mut payees, @0x106cd364782eee36a61493198b40d7bb);
      Vector::push_back<u64>(&mut amounts, 3226552632);
      
      Vector::push_back<address>(&mut payees, @0x17926018486b4e4d0e8dce5b406f380c);
      Vector::push_back<u64>(&mut amounts, 784936516);
      
      Vector::push_back<address>(&mut payees, @0xd3eff8e107d4a29360ff8dc7e75f173e);
      Vector::push_back<u64>(&mut amounts, 7328900335);
      
      Vector::push_back<address>(&mut payees, @0x20d544a5823b0278510d1027df242299);
      Vector::push_back<u64>(&mut amounts, 5448393387);
      
      Vector::push_back<address>(&mut payees, @0xdcb2875af620121dbae7c7e0f62c90fd);
      Vector::push_back<u64>(&mut amounts, 559996539);
      
      Vector::push_back<address>(&mut payees, @0xc4e2b15611cbfcaf40065aef52f79676);
      Vector::push_back<u64>(&mut amounts, 5408233492);
      
      Vector::push_back<address>(&mut payees, @0x757d13ba3fb14d7ef1c3836a08cd8445);
      Vector::push_back<u64>(&mut amounts, 3849252337);
      
      Vector::push_back<address>(&mut payees, @0xe6cd8e067269afbe7aee18bfa54c84ae);
      Vector::push_back<u64>(&mut amounts, 839840784);
      
      Vector::push_back<address>(&mut payees, @0x33ec9e23fbee6bb2c080855e0f9c828c);
      Vector::push_back<u64>(&mut amounts, 1786419211);
      
      Vector::push_back<address>(&mut payees, @0xe5a068a10b3938ab956b9eb4667c3e13);
      Vector::push_back<u64>(&mut amounts, 57381247);
      
      Vector::push_back<address>(&mut payees, @0x2199d92000794e392c21951c00b6b28d);
      Vector::push_back<u64>(&mut amounts, 1785536309);
      
      Vector::push_back<address>(&mut payees, @0xa2101a927f34bcb6ca3403893d468648);
      Vector::push_back<u64>(&mut amounts, 2469987142);
      
      Vector::push_back<address>(&mut payees, @0x61ee63c6f0ba4015a74af73358d8091e);
      Vector::push_back<u64>(&mut amounts, 5371934433);
      
      Vector::push_back<address>(&mut payees, @0xcc2bfd28db98636083fc43567fc19de3);
      Vector::push_back<u64>(&mut amounts, 592047236);
      
      Vector::push_back<address>(&mut payees, @0x7e6da2c64e0ce4355b26308ab386b9e3);
      Vector::push_back<u64>(&mut amounts, 1526902307);
      
      Vector::push_back<address>(&mut payees, @0x42e97304f4ab329724166712dd7e8674);
      Vector::push_back<u64>(&mut amounts, 252055370);
      
      Vector::push_back<address>(&mut payees, @0x466709a59ad3a65fda5377385d2d864f);
      Vector::push_back<u64>(&mut amounts, 580319797);
      
      Vector::push_back<address>(&mut payees, @0x41bf28e948204b84daddb73bf1a4e700);
      Vector::push_back<u64>(&mut amounts, 566805119);
      
      Vector::push_back<address>(&mut payees, @0x3be519c0ee0e9443076a694bface0a9f);
      Vector::push_back<u64>(&mut amounts, 2201412567);
      
      Vector::push_back<address>(&mut payees, @0xc0938078187acf5a25645650a2e8b38a);
      Vector::push_back<u64>(&mut amounts, 3577243294);
      
      Vector::push_back<address>(&mut payees, @0x1171311a7f22d38efac19f32f4a699e3);
      Vector::push_back<u64>(&mut amounts, 1076995194);
      
      Vector::push_back<address>(&mut payees, @0xd61694e0cc7e3fdaeb6f3ed9abca7166);
      Vector::push_back<u64>(&mut amounts, 2143159321);
      
      Vector::push_back<address>(&mut payees, @0xe60ba6299e6f6673901dc382a66adc38);
      Vector::push_back<u64>(&mut amounts, 100092523);
      
      Vector::push_back<address>(&mut payees, @0x1ce42867d4ca1c1e79a94e9263c70bdc);
      Vector::push_back<u64>(&mut amounts, 220243316);
      
      Vector::push_back<address>(&mut payees, @0x1a7c1171f59338d5833e63602044571d);
      Vector::push_back<u64>(&mut amounts, 250136553);
      
      Vector::push_back<address>(&mut payees, @0x25a866e998dd477910449ce35d9ca7a6);
      Vector::push_back<u64>(&mut amounts, 250136553);
      
      Vector::push_back<address>(&mut payees, @0x16b5cb68b85aad3d5c762ece2e0119ee);
      Vector::push_back<u64>(&mut amounts, 250136553);
      
      Vector::push_back<address>(&mut payees, @0x21f2f82fea3276fdff10cab485061719);
      Vector::push_back<u64>(&mut amounts, 1801779934);
      
      Vector::push_back<address>(&mut payees, @0x5b55c39410a1ff794fb24ebd54b64952);
      Vector::push_back<u64>(&mut amounts, 5116986219);
      
      Vector::push_back<address>(&mut payees, @0x2f012014d1854855af76c61aa47f8d0f);
      Vector::push_back<u64>(&mut amounts, 3367616106);
      
      Vector::push_back<address>(&mut payees, @0xa544cf4a2af91d9e1c6a660bb65be124);
      Vector::push_back<u64>(&mut amounts, 1910274933);
      
      Vector::push_back<address>(&mut payees, @0xcbd3d460188289ce7bf3d4471c77f106);
      Vector::push_back<u64>(&mut amounts, 1046358973);
      
      Vector::push_back<address>(&mut payees, @0x0dd3a2ad8b9169ba798447631e3767fc);
      Vector::push_back<u64>(&mut amounts, 2603497635);
      
      Vector::push_back<address>(&mut payees, @0x5d7e363cb6533a84359f7933c895b0cb);
      Vector::push_back<u64>(&mut amounts, 4817362908);
      
      Vector::push_back<address>(&mut payees, @0x27d8f405c054ba2dbf9532439761e79b);
      Vector::push_back<u64>(&mut amounts, 41551938);
      
      Vector::push_back<address>(&mut payees, @0xd6b02f26dd90f897ddcda8ef276030e9);
      Vector::push_back<u64>(&mut amounts, 1179445955);
      
      Vector::push_back<address>(&mut payees, @0x65c28aba0a926125619ae5068332cb53);
      Vector::push_back<u64>(&mut amounts, 192303935);
      
      Vector::push_back<address>(&mut payees, @0x7d1d8d234fd6381d184e43b3a3441e1b);
      Vector::push_back<u64>(&mut amounts, 518256005);
      
      Vector::push_back<address>(&mut payees, @0x257753d5e701b37c44af22532acc3d24);
      Vector::push_back<u64>(&mut amounts, 2351657377);
      
      Vector::push_back<address>(&mut payees, @0xd1e1e72af62e262803fee98a4d95570b);
      Vector::push_back<u64>(&mut amounts, 1531056051);
      
      Vector::push_back<address>(&mut payees, @0xc7c84637b817e589214a36553934481d);
      Vector::push_back<u64>(&mut amounts, 229714318);
      
      Vector::push_back<address>(&mut payees, @0xf1a850c372375aa67e39f872dfecf233);
      Vector::push_back<u64>(&mut amounts, 29679955);
      
      Vector::push_back<address>(&mut payees, @0xfb67479809701ed695942d3d6c278946);
      Vector::push_back<u64>(&mut amounts, 5357071945);
      
      Vector::push_back<address>(&mut payees, @0xf25776320b905b93d2c09916b34cd789);
      Vector::push_back<u64>(&mut amounts, 2337478346);
      
      Vector::push_back<address>(&mut payees, @0x7c8e80f66d3ce519da6ca3168e838026);
      Vector::push_back<u64>(&mut amounts, 715762560);
      
      Vector::push_back<address>(&mut payees, @0xb168a9a049af64a79ca397c77e8b6e78);
      Vector::push_back<u64>(&mut amounts, 23743964);
      
      Vector::push_back<address>(&mut payees, @0x504281452ff6cf349d86f7d17dc6e3e7);
      Vector::push_back<u64>(&mut amounts, 23743964);
      
      Vector::push_back<address>(&mut payees, @0xcdb6e7f505f274e2325cda2f8708e939);
      Vector::push_back<u64>(&mut amounts, 23743964);
      
      Vector::push_back<address>(&mut payees, @0xd7ba5a9393ce5e29d3c46ecfb406e056);
      Vector::push_back<u64>(&mut amounts, 21765300);
      
      Vector::push_back<address>(&mut payees, @0x5b68985a3683d34bc6383812dfba4a60);
      Vector::push_back<u64>(&mut amounts, 21765300);
      
      Vector::push_back<address>(&mut payees, @0x0c619736d9848aa8057456f2a1bf7395);
      Vector::push_back<u64>(&mut amounts, 21765300);
      
      Vector::push_back<address>(&mut payees, @0xf9e6f0446dbb0b321ff5130d2afe05d7);
      Vector::push_back<u64>(&mut amounts, 21765300);
      
      Vector::push_back<address>(&mut payees, @0x6368d1680fdb922bd39de0f5344cb606);
      Vector::push_back<u64>(&mut amounts, 21765300);
      
      Vector::push_back<address>(&mut payees, @0xdba936a3034a380d26fc230efb2cdf05);
      Vector::push_back<u64>(&mut amounts, 21765300);
      
      Vector::push_back<address>(&mut payees, @0x2f874d436152f00d23b4edc32ac1cd18);
      Vector::push_back<u64>(&mut amounts, 21765300);
      
      Vector::push_back<address>(&mut payees, @0xeb20fead1eb7ff16800ba7ae296e23b2);
      Vector::push_back<u64>(&mut amounts, 21765300);
      
      Vector::push_back<address>(&mut payees, @0x0e80617b67db60c301ec1ccdb9f74d6f);
      Vector::push_back<u64>(&mut amounts, 1052960897);
      
      Vector::push_back<address>(&mut payees, @0xbf492fc9de0b617f948459234941dd70);
      Vector::push_back<u64>(&mut amounts, 1346058117);
      
      Vector::push_back<address>(&mut payees, @0xb1042c8906aa384b59be2e9ee1ab8ef8);
      Vector::push_back<u64>(&mut amounts, 1225830561);
      
      Vector::push_back<address>(&mut payees, @0x576006dcb54a7f543a9520a3ac7e6bfe);
      Vector::push_back<u64>(&mut amounts, 436130372);
      
      Vector::push_back<address>(&mut payees, @0xbf28fba661a7a021adf1e33508ff51fb);
      Vector::push_back<u64>(&mut amounts, 3116582017);
      
      Vector::push_back<address>(&mut payees, @0x605aabc4541db8732e481eddf4e113c9);
      Vector::push_back<u64>(&mut amounts, 3128430369);
      
      Vector::push_back<address>(&mut payees, @0x0f076d5074e1cac1362530eaf55a1f6f);
      Vector::push_back<u64>(&mut amounts, 1687826880);
      
      Vector::push_back<address>(&mut payees, @0x84b4478243273853b000f91b62d9b4e2);
      Vector::push_back<u64>(&mut amounts, 100440191);
      
      Vector::push_back<address>(&mut payees, @0x0ff10a9e1bccb9645d79faf8ba9bef87);
      Vector::push_back<u64>(&mut amounts, 2714727316);
      
      Vector::push_back<address>(&mut payees, @0xb121667a1ef32145de671cb2307c3c0f);
      Vector::push_back<u64>(&mut amounts, 1941188813);
      
      Vector::push_back<address>(&mut payees, @0x8d851706799579c36f8588a27ed9b014);
      Vector::push_back<u64>(&mut amounts, 2958772304);
      
      Vector::push_back<address>(&mut payees, @0xba01aee87b5091d9a4a17a31f697aae1);
      Vector::push_back<u64>(&mut amounts, 4223865451);
      
      Vector::push_back<address>(&mut payees, @0xbe40451e0231ec2fe53548e2b411e9d1);
      Vector::push_back<u64>(&mut amounts, 21765300);
      
      Vector::push_back<address>(&mut payees, @0xe2a379a0337f2c40e1c8cc77e8121e7a);
      Vector::push_back<u64>(&mut amounts, 2379104226);
      
      Vector::push_back<address>(&mut payees, @0xe3d2f3a375fa9ba45ef978c0648fa837);
      Vector::push_back<u64>(&mut amounts, 2315961377);
      
      Vector::push_back<address>(&mut payees, @0x78e8d5c1f27bfb25c1fd8d717e4f40bb);
      Vector::push_back<u64>(&mut amounts, 2371202528);
      
      Vector::push_back<address>(&mut payees, @0x6e37edbfc6a9347bf9783206016ccbf7);
      Vector::push_back<u64>(&mut amounts, 649390785);
      
      Vector::push_back<address>(&mut payees, @0x3b3ca7f2e753afb49090c55b6e9cf419);
      Vector::push_back<u64>(&mut amounts, 5041696831);
      
      Vector::push_back<address>(&mut payees, @0x23fcd025802ae067ab05678f87aa74ab);
      Vector::push_back<u64>(&mut amounts, 6293606045);
      
      Vector::push_back<address>(&mut payees, @0x304ca993b446d14c1efb9f41ee570fc1);
      Vector::push_back<u64>(&mut amounts, 6224847285);
      
      Vector::push_back<address>(&mut payees, @0x3dd1fa792fa8cda6e0f046bff8113f0a);
      Vector::push_back<u64>(&mut amounts, 3052533208);
      
      Vector::push_back<address>(&mut payees, @0x4af1ed85e71329bb2fd23bad022746d1);
      Vector::push_back<u64>(&mut amounts, 1894968888);
      
      Vector::push_back<address>(&mut payees, @0x7615774eec788389a882910a27bf3d97);
      Vector::push_back<u64>(&mut amounts, 4972197075);
      
      Vector::push_back<address>(&mut payees, @0xfa92f4a0d24e25b7e3ca9c20fa501a39);
      Vector::push_back<u64>(&mut amounts, 2093612076);
      
      Vector::push_back<address>(&mut payees, @0x9414b4501417e6d7f9577f42cb2a8a36);
      Vector::push_back<u64>(&mut amounts, 1141087114);
      
      Vector::push_back<address>(&mut payees, @0xcc53e9414dba5c89bfb0b47fd509079a);
      Vector::push_back<u64>(&mut amounts, 3219657838);
      
      Vector::push_back<address>(&mut payees, @0x5cc6e588602a6a6875fdb8f0f498f4c9);
      Vector::push_back<u64>(&mut amounts, 2476066422);
      
      Vector::push_back<address>(&mut payees, @0x5b3cf30f155563577f5c4035411eb511);
      Vector::push_back<u64>(&mut amounts, 1573215637);
      
      Vector::push_back<address>(&mut payees, @0x2d447b865bed06a945728dfc98c46971);
      Vector::push_back<u64>(&mut amounts, 2034552773);
      
      Vector::push_back<address>(&mut payees, @0xe4330484e9eae480fb048291f03691aa);
      Vector::push_back<u64>(&mut amounts, 483329986);
      
      Vector::push_back<address>(&mut payees, @0x9baf20d9b9f960453df8957067e35b7a);
      Vector::push_back<u64>(&mut amounts, 2687623947);
      
      Vector::push_back<address>(&mut payees, @0x547522405101b51b2625c6b15f89b56f);
      Vector::push_back<u64>(&mut amounts, 1167261884);
      
      Vector::push_back<address>(&mut payees, @0x93a91b21218aff3ceb211eb02b27cbe0);
      Vector::push_back<u64>(&mut amounts, 864209892);
      
      Vector::push_back<address>(&mut payees, @0xe31b668f0d80dc4650e2dd8f4d6ee726);
      Vector::push_back<u64>(&mut amounts, 1041149843);
      
      Vector::push_back<address>(&mut payees, @0xbe35ad8127f57849e97a3ffb81e5854d);
      Vector::push_back<u64>(&mut amounts, 1243091895);
      
      Vector::push_back<address>(&mut payees, @0x26bab9c03ad5e805557069c17460abdd);
      Vector::push_back<u64>(&mut amounts, 2225787123);
      
      Vector::push_back<address>(&mut payees, @0x706a13b19fdaf01d59532d49e85d780d);
      Vector::push_back<u64>(&mut amounts, 1963980797);
      
      Vector::push_back<address>(&mut payees, @0x4a4ce9c0efea2c2b4eb7df0b08096e64);
      Vector::push_back<u64>(&mut amounts, 3331203094);
      
      Vector::push_back<address>(&mut payees, @0xd1bf50005c88dbed661ab87e59102373);
      Vector::push_back<u64>(&mut amounts, 564601555);
      
      Vector::push_back<address>(&mut payees, @0xf76d700abedc96f8392b6a3005351b56);
      Vector::push_back<u64>(&mut amounts, 3936854290);
      
      Vector::push_back<address>(&mut payees, @0x114f535804adfe8bc4548a118acbb743);
      Vector::push_back<u64>(&mut amounts, 613179774);
      
      Vector::push_back<address>(&mut payees, @0x55537937a062c642a07ad1d949d10eed);
      Vector::push_back<u64>(&mut amounts, 595622297);
      
      Vector::push_back<address>(&mut payees, @0x556931d8542fe0cbe0860bc3240fef88);
      Vector::push_back<u64>(&mut amounts, 2949470029);
      
      Vector::push_back<address>(&mut payees, @0xeaf6023c40749bd0b59a678fa2ec48a2);
      Vector::push_back<u64>(&mut amounts, 2594047963);
      
      Vector::push_back<address>(&mut payees, @0xe06e198d3f74bf2ca103fee27567675d);
      Vector::push_back<u64>(&mut amounts, 4185012721);
      
      Vector::push_back<address>(&mut payees, @0xc3c697d8adbb6d51daddd4e3935152f0);
      Vector::push_back<u64>(&mut amounts, 1955263457);
      
      Vector::push_back<address>(&mut payees, @0x4c1cc3361fac05e6abee719e526ae75f);
      Vector::push_back<u64>(&mut amounts, 4158221663);
      
      Vector::push_back<address>(&mut payees, @0xd3810bce0b331d61ab4cb8c3b5cfbb84);
      Vector::push_back<u64>(&mut amounts, 4215246524);
      
      Vector::push_back<address>(&mut payees, @0x7845ead53ab3104ee04fbbcdc7b8aefe);
      Vector::push_back<u64>(&mut amounts, 4114487373);
      
      Vector::push_back<address>(&mut payees, @0x05ab8a4108a6281619c480ebc02d9099);
      Vector::push_back<u64>(&mut amounts, 5864195711);
      
      Vector::push_back<address>(&mut payees, @0x6c694f6c18a0df408f84c1f3f6409257);
      Vector::push_back<u64>(&mut amounts, 634408262);
      
      Vector::push_back<address>(&mut payees, @0x98dc767dbb40c5be4e9d2758eabdc6e2);
      Vector::push_back<u64>(&mut amounts, 1539880850);
      
      Vector::push_back<address>(&mut payees, @0x44d5d1702ad8550467d5a81a46c72eea);
      Vector::push_back<u64>(&mut amounts, 5841081389);
      
      Vector::push_back<address>(&mut payees, @0x513a6800ffdaecb823333bfc4ab3466e);
      Vector::push_back<u64>(&mut amounts, 101452201);
      
      Vector::push_back<address>(&mut payees, @0x3f1eb4254be5eedc821a83a7de0b836c);
      Vector::push_back<u64>(&mut amounts, 86746307);
      
      Vector::push_back<address>(&mut payees, @0xf9e32b2fc53c12b6447d6ffd70e2cac0);
      Vector::push_back<u64>(&mut amounts, 163742913);
      
      Vector::push_back<address>(&mut payees, @0xce6de36f34b62ccfccf894c026180fcb);
      Vector::push_back<u64>(&mut amounts, 2140414423);
      
      Vector::push_back<address>(&mut payees, @0xea2cb3a83631b60138757582706ecd77);
      Vector::push_back<u64>(&mut amounts, 2540134522);
      
      Vector::push_back<address>(&mut payees, @0xc31b2b7349a0ad66fe7f92cd0cbb76cc);
      Vector::push_back<u64>(&mut amounts, 1393736669);
      
      Vector::push_back<address>(&mut payees, @0x3f6e965b9f3ce1928fc6b8731fc87dfa);
      Vector::push_back<u64>(&mut amounts, 595953730);
      
      Vector::push_back<address>(&mut payees, @0xeea8a87eca6cbcaecc61ac6e191db91a);
      Vector::push_back<u64>(&mut amounts, 357995923);
      
      Vector::push_back<address>(&mut payees, @0x4c54ecbc4af6326ce40e307e8f4657d2);
      Vector::push_back<u64>(&mut amounts, 337666425);
      
      Vector::push_back<address>(&mut payees, @0x4674ef85f1cc174650b87a9e4ff63afa);
      Vector::push_back<u64>(&mut amounts, 1538570994);
      
      Vector::push_back<address>(&mut payees, @0xce1f84b07c1d4cda6ef3d60d7ee52e0f);
      Vector::push_back<u64>(&mut amounts, 1725925821);
      
      Vector::push_back<address>(&mut payees, @0x1ef72b5ee941ee24e748ba90cdc25fd1);
      Vector::push_back<u64>(&mut amounts, 4405976486);
      
      Vector::push_back<address>(&mut payees, @0x74d262a16b5bf51999c156985852d055);
      Vector::push_back<u64>(&mut amounts, 956674951);
      
      Vector::push_back<address>(&mut payees, @0xc3228b9d8ede16f9579c0846d9da0463);
      Vector::push_back<u64>(&mut amounts, 2108872160);
      
      Vector::push_back<address>(&mut payees, @0xcbed86a741f1a29ccce2021dac5aba9f);
      Vector::push_back<u64>(&mut amounts, 222860100);
      
      Vector::push_back<address>(&mut payees, @0xec3288545aa9f3fb1295a9567f3eab56);
      Vector::push_back<u64>(&mut amounts, 536027943);
      
      Vector::push_back<address>(&mut payees, @0x3d14d4474764c511aa980db37a8d1a7f);
      Vector::push_back<u64>(&mut amounts, 3913495090);
      
      Vector::push_back<address>(&mut payees, @0xdcdb1805e14de71f42ddd7c425c93138);
      Vector::push_back<u64>(&mut amounts, 1181686411);
      
      Vector::push_back<address>(&mut payees, @0xfe4e85b8a8e87d34b0e84ecb2826c307);
      Vector::push_back<u64>(&mut amounts, 1114944686);
      
      Vector::push_back<address>(&mut payees, @0x53c53ce9194e6e04119b80008f934500);
      Vector::push_back<u64>(&mut amounts, 475928533);
      
      Vector::push_back<address>(&mut payees, @0xf5f57116313476016ae95e46a7e1c992);
      Vector::push_back<u64>(&mut amounts, 240612531);
      
      Vector::push_back<address>(&mut payees, @0xef56d232749a41dd47e62b8753fd0b2f);
      Vector::push_back<u64>(&mut amounts, 3211936291);
      
      Vector::push_back<address>(&mut payees, @0xd615e9e7feaeb331dcac05e64715e51f);
      Vector::push_back<u64>(&mut amounts, 250050189);
      
      Vector::push_back<address>(&mut payees, @0x221d701e92d2a3040ca23e78a9dc4c43);
      Vector::push_back<u64>(&mut amounts, 4391485552);
      
      Vector::push_back<address>(&mut payees, @0x500401f16609ed869ccbcb792b747ab5);
      Vector::push_back<u64>(&mut amounts, 2698301868);
      
      Vector::push_back<address>(&mut payees, @0x6b412fd95a7ac0f9119cd1ab38029a4c);
      Vector::push_back<u64>(&mut amounts, 490010196);
      
      Vector::push_back<address>(&mut payees, @0x2ce05e7ca2c8e006f97582938506ecaf);
      Vector::push_back<u64>(&mut amounts, 107425643);
      
      Vector::push_back<address>(&mut payees, @0xe4a211a2d0b72a16aa1c9fa28f8a50b2);
      Vector::push_back<u64>(&mut amounts, 107425643);
      
      Vector::push_back<address>(&mut payees, @0xa87f7aca8726827fd0044c9eba32a099);
      Vector::push_back<u64>(&mut amounts, 1569110636);
      
      Vector::push_back<address>(&mut payees, @0xb09a425b45f8bd38b3273c8ff9d1705d);
      Vector::push_back<u64>(&mut amounts, 1841504644);
      
      Vector::push_back<address>(&mut payees, @0xf1ff4e5f5857abd647ce766957776786);
      Vector::push_back<u64>(&mut amounts, 3789203207);
      
      Vector::push_back<address>(&mut payees, @0xb3fcdbde54b33d45bcd2557be6b89f97);
      Vector::push_back<u64>(&mut amounts, 3010063351);
      
      Vector::push_back<address>(&mut payees, @0x1daa340d1ee608db6436838a79502551);
      Vector::push_back<u64>(&mut amounts, 3038095172);
      
      Vector::push_back<address>(&mut payees, @0x8d63698033602c1be764322b28603506);
      Vector::push_back<u64>(&mut amounts, 3415364925);
      
      Vector::push_back<address>(&mut payees, @0x5b741cfb9ed80c0cadd56fb450890b55);
      Vector::push_back<u64>(&mut amounts, 1134717589);
      
      Vector::push_back<address>(&mut payees, @0xc44a50622c2d465e6c15982b8e127349);
      Vector::push_back<u64>(&mut amounts, 676738948);
      
      Vector::push_back<address>(&mut payees, @0xfe635aa67d111bf2a394ea1df721cd9e);
      Vector::push_back<u64>(&mut amounts, 2040236117);
      
      Vector::push_back<address>(&mut payees, @0xe981c3fb2844d1e969aba763cd5a0f45);
      Vector::push_back<u64>(&mut amounts, 4190760901);
      
      Vector::push_back<address>(&mut payees, @0x880187f5c1b9c74187b3a4839d6b99c5);
      Vector::push_back<u64>(&mut amounts, 1670634862);
      
      Vector::push_back<address>(&mut payees, @0x584e89e24a5d439b7aaccec92be8a663);
      Vector::push_back<u64>(&mut amounts, 3641310298);
      
      Vector::push_back<address>(&mut payees, @0x27de1f87599fd1f8ae5bd1101511d546);
      Vector::push_back<u64>(&mut amounts, 4288877328);
      
      Vector::push_back<address>(&mut payees, @0x578b1574528dac007009621673f6608c);
      Vector::push_back<u64>(&mut amounts, 2290420195);
      
      Vector::push_back<address>(&mut payees, @0x314932578c2dd1067c4e52411d4b4491);
      Vector::push_back<u64>(&mut amounts, 2276108613);
      
      Vector::push_back<address>(&mut payees, @0x8a997bf27a21edd9c0c84ba962b951c5);
      Vector::push_back<u64>(&mut amounts, 3466964324);
      
      Vector::push_back<address>(&mut payees, @0x18478aacefe3e9b8e78b03e74220a3b6);
      Vector::push_back<u64>(&mut amounts, 2637401780);
      
      Vector::push_back<address>(&mut payees, @0xb8d7038be29dade325b9a62095035ac4);
      Vector::push_back<u64>(&mut amounts, 2769368198);
      
      Vector::push_back<address>(&mut payees, @0x9cbda8ef3082bce3989969d5fe29eb7f);
      Vector::push_back<u64>(&mut amounts, 2288664564);
      
      Vector::push_back<address>(&mut payees, @0xdf2ab02c5e14aa1c385b48c4873d12a1);
      Vector::push_back<u64>(&mut amounts, 1582166396);
      
      Vector::push_back<address>(&mut payees, @0x98fd8b5ae6140ef444d803d97d2e570f);
      Vector::push_back<u64>(&mut amounts, 100290789);
      
      Vector::push_back<address>(&mut payees, @0xc3f25f140697f44f8c393fb72e471f54);
      Vector::push_back<u64>(&mut amounts, 1234306074);
      
      Vector::push_back<address>(&mut payees, @0x431b79f419e82d6f28fa8379a11ab408);
      Vector::push_back<u64>(&mut amounts, 4465210715);
      
      Vector::push_back<address>(&mut payees, @0x1dfdb1aeceaa462e76774cf90464fd9c);
      Vector::push_back<u64>(&mut amounts, 3855102353);
      
      Vector::push_back<address>(&mut payees, @0xb411a80b55433bf4145046b84350c5aa);
      Vector::push_back<u64>(&mut amounts, 4035158778);
      
      Vector::push_back<address>(&mut payees, @0xdc52ffcd70d6aa855c301e1876f0c263);
      Vector::push_back<u64>(&mut amounts, 606408658);
      
      Vector::push_back<address>(&mut payees, @0xe3724b35042a75f4e20a68d2a2912709);
      Vector::push_back<u64>(&mut amounts, 155982243);
      
      Vector::push_back<address>(&mut payees, @0x8a3a2856555f8f86af802b1a2f13f628);
      Vector::push_back<u64>(&mut amounts, 1650455943);
      
      Vector::push_back<address>(&mut payees, @0x1dd5077cd9bf8892d97cdacaf2e4c270);
      Vector::push_back<u64>(&mut amounts, 1755952137);
      
      Vector::push_back<address>(&mut payees, @0xc7bef02a3060a643f1ae42704f5eed4c);
      Vector::push_back<u64>(&mut amounts, 1362513023);
      
      Vector::push_back<address>(&mut payees, @0xf73b01ec759ad6b262c5004cd8b71854);
      Vector::push_back<u64>(&mut amounts, 3162475881);
      
      Vector::push_back<address>(&mut payees, @0xab301354ca5780b72f40c57cb3047375);
      Vector::push_back<u64>(&mut amounts, 1649318461);
      
      Vector::push_back<address>(&mut payees, @0x6a14cd7e48865178b634514e6e81cf6a);
      Vector::push_back<u64>(&mut amounts, 251855716);
      
      Vector::push_back<address>(&mut payees, @0x74da285a66c05620cdf1d4d22ebcb5f6);
      Vector::push_back<u64>(&mut amounts, 1291465605);
      
      Vector::push_back<address>(&mut payees, @0xb8151649575106e9a42ba57852a05995);
      Vector::push_back<u64>(&mut amounts, 143793428);
      
      Vector::push_back<address>(&mut payees, @0x5d8ecc43e091b2b36efb63363c83fbea);
      Vector::push_back<u64>(&mut amounts, 57262079);
      
      Vector::push_back<address>(&mut payees, @0xc3d7a43785a648ef143e12bd1ba4bc32);
      Vector::push_back<u64>(&mut amounts, 495065941);
      
      Vector::push_back<address>(&mut payees, @0x2fc363791c4e496f4480e7b4f3627584);
      Vector::push_back<u64>(&mut amounts, 38833033);
      
      Vector::push_back<address>(&mut payees, @0x58065c1f96b85432f1fbea848cb411e5);
      Vector::push_back<u64>(&mut amounts, 20996095);
      
      Vector::push_back<address>(&mut payees, @0x349a64a657ceb0ed8f465fd2ed4acef1);
      Vector::push_back<u64>(&mut amounts, 2931772510);
      
      Vector::push_back<address>(&mut payees, @0x3fc0977c33cb16cb99e35f404cf9339a);
      Vector::push_back<u64>(&mut amounts, 41992191);
      
      Vector::push_back<address>(&mut payees, @0xc576158fd3abbe0901c0938e42dd767a);
      Vector::push_back<u64>(&mut amounts, 1390315637);
      
      Vector::push_back<address>(&mut payees, @0xbc6cb5fca62491a2426d58bf9a9cd3c5);
      Vector::push_back<u64>(&mut amounts, 2307449500);
      
      Vector::push_back<address>(&mut payees, @0x1d84840eb18f5090b196e20fc609028e);
      Vector::push_back<u64>(&mut amounts, 325061309);
      
      Vector::push_back<address>(&mut payees, @0x6a12f82bca06086d28928b841f1457e8);
      Vector::push_back<u64>(&mut amounts, 6400219314);
      
      Vector::push_back<address>(&mut payees, @0xa66a7cf7a55fa6266f40b6afc4f48d5e);
      Vector::push_back<u64>(&mut amounts, 296315001);
      
      Vector::push_back<address>(&mut payees, @0x8b7d62d5dbad53f2c2260cb9344f64d1);
      Vector::push_back<u64>(&mut amounts, 378006309);
      
      Vector::push_back<address>(&mut payees, @0x31a82811b292fcbc835e2ef147cef58b);
      Vector::push_back<u64>(&mut amounts, 3465553716);
      
      Vector::push_back<address>(&mut payees, @0x9e97ecf1e84c04780e83c518cc4f86d0);
      Vector::push_back<u64>(&mut amounts, 4792101864);
      
      Vector::push_back<address>(&mut payees, @0x3cbc8ef7c2cb04c598115142bc482fd4);
      Vector::push_back<u64>(&mut amounts, 616639802);
      
      Vector::push_back<address>(&mut payees, @0x84417cef5647097127e1bc24fd1002c6);
      Vector::push_back<u64>(&mut amounts, 5310214908);
      
      Vector::push_back<address>(&mut payees, @0xb8bfc260f380ffed1e4351515673812c);
      Vector::push_back<u64>(&mut amounts, 3082492623);
      
      Vector::push_back<address>(&mut payees, @0x5fa758980a5e7d97938ffbb880604bad);
      Vector::push_back<u64>(&mut amounts, 2033201612);
      
      Vector::push_back<address>(&mut payees, @0x1100c3367127b5b1fc258600e54d74bf);
      Vector::push_back<u64>(&mut amounts, 5437367561);
      
      Vector::push_back<address>(&mut payees, @0x1d0d9cc0deec7c0371bcc83044f9342b);
      Vector::push_back<u64>(&mut amounts, 4156440594);
      
      Vector::push_back<address>(&mut payees, @0xc2eacebac1689652318a3d2bf00ec2b4);
      Vector::push_back<u64>(&mut amounts, 4281855306);
      
      Vector::push_back<address>(&mut payees, @0x1159e2e59e6ec971a98c2eeb73b8f753);
      Vector::push_back<u64>(&mut amounts, 396045703);
      
      Vector::push_back<address>(&mut payees, @0xba28f081de02fc6cc3bf9879d6033911);
      Vector::push_back<u64>(&mut amounts, 976824546);
      
      Vector::push_back<address>(&mut payees, @0xbcd90d2bbdd465d0f72bce62179a58cd);
      Vector::push_back<u64>(&mut amounts, 328542103);
      
      Vector::push_back<address>(&mut payees, @0x818b962262805176ffcd683f08224919);
      Vector::push_back<u64>(&mut amounts, 71314807);
      
      Vector::push_back<address>(&mut payees, @0x44e4a7c94ce32233e45fbcb007ffcefe);
      Vector::push_back<u64>(&mut amounts, 2014504264);
      
      Vector::push_back<address>(&mut payees, @0xfa46a780ad2006f8c83e7058877be8fa);
      Vector::push_back<u64>(&mut amounts, 1992210739);
      
      Vector::push_back<address>(&mut payees, @0x39f4b34103dd1478e231e6f34c896885);
      Vector::push_back<u64>(&mut amounts, 560186726);
      
      Vector::push_back<address>(&mut payees, @0x54599601117b1a60ef49cb23b0c229ae);
      Vector::push_back<u64>(&mut amounts, 3134843343);
      
      Vector::push_back<address>(&mut payees, @0x885308c0c59d6c157cffa3473cb467fa);
      Vector::push_back<u64>(&mut amounts, 1171328539);
      
      Vector::push_back<address>(&mut payees, @0xd6310ac7a81caf781f03fbbb5ffb5a47);
      Vector::push_back<u64>(&mut amounts, 1403521718);
      
      Vector::push_back<address>(&mut payees, @0xe190296e057bf341a093967987543981);
      Vector::push_back<u64>(&mut amounts, 602116279);
      
      Vector::push_back<address>(&mut payees, @0xc770734f927858ac3a9cc28b6d87682e);
      Vector::push_back<u64>(&mut amounts, 190363546);
      
      Vector::push_back<address>(&mut payees, @0x527ba6f888b32bb55d153fbce9219cc7);
      Vector::push_back<u64>(&mut amounts, 2454507925);
      
      Vector::push_back<address>(&mut payees, @0xacc9f631c71890661cf11dfd62449cca);
      Vector::push_back<u64>(&mut amounts, 1254878128);
      
      Vector::push_back<address>(&mut payees, @0xdba7f0b89931e9c46b847b98fd45c7da);
      Vector::push_back<u64>(&mut amounts, 709710952);
      
      Vector::push_back<address>(&mut payees, @0xfdfb22de22c76017f928a2509ffff997);
      Vector::push_back<u64>(&mut amounts, 276293168);
      
      Vector::push_back<address>(&mut payees, @0x2fc3b035a080aeb04bb4f588b1963859);
      Vector::push_back<u64>(&mut amounts, 2287289510);
      
      Vector::push_back<address>(&mut payees, @0x8526df272d5a9531cd0fbbe34acef178);
      Vector::push_back<u64>(&mut amounts, 1825243992);
      
      Vector::push_back<address>(&mut payees, @0x4f939df9f71a4b607b91f37d0a78215f);
      Vector::push_back<u64>(&mut amounts, 950745200);
      
      Vector::push_back<address>(&mut payees, @0x0338178092889170d69a585306efeda1);
      Vector::push_back<u64>(&mut amounts, 1075569360);
      
      Vector::push_back<address>(&mut payees, @0x11084e359da58996a4238282187ed5e5);
      Vector::push_back<u64>(&mut amounts, 2368841267);
      
      Vector::push_back<address>(&mut payees, @0x525d26b7ba3d0ec784ce1bdfc8682ee9);
      Vector::push_back<u64>(&mut amounts, 1761773784);
      
      Vector::push_back<address>(&mut payees, @0x8d7fb8362c2f2800b9503806c88bcec9);
      Vector::push_back<u64>(&mut amounts, 1770546856);
      
      Vector::push_back<address>(&mut payees, @0x9e66ca133bfe63a24ab05951c1d58912);
      Vector::push_back<u64>(&mut amounts, 1633355593);
      
      Vector::push_back<address>(&mut payees, @0xf6ca47b9d2935aa2a00484ff143c3e20);
      Vector::push_back<u64>(&mut amounts, 41340236);
      
      Vector::push_back<address>(&mut payees, @0xd1cc781c4f3fd2aaf60a2d96a941a8c7);
      Vector::push_back<u64>(&mut amounts, 41340236);
      
      Vector::push_back<address>(&mut payees, @0x32c01832d093b2f5877b85ec1cfcaaca);
      Vector::push_back<u64>(&mut amounts, 2929449840);
      
      Vector::push_back<address>(&mut payees, @0xb61b1dc15fc2f21fbced860b07c7c4d9);
      Vector::push_back<u64>(&mut amounts, 1277164576);
      
      Vector::push_back<address>(&mut payees, @0x6457f568df4b8c3ba3856b617d8d872d);
      Vector::push_back<u64>(&mut amounts, 465596561);
      
      Vector::push_back<address>(&mut payees, @0xc69f7437b646aa7982b99f77f62e4e8a);
      Vector::push_back<u64>(&mut amounts, 20236039);
      
      Vector::push_back<address>(&mut payees, @0x889fa141154b8c3c8fc305a7cd136f38);
      Vector::push_back<u64>(&mut amounts, 902286055);
      
      Vector::push_back<address>(&mut payees, @0x0d6aad51c881bb086f691f5a94393af7);
      Vector::push_back<u64>(&mut amounts, 1724814663);
      
      Vector::push_back<address>(&mut payees, @0xdc87166fc316cab745c0ede13005e017);
      Vector::push_back<u64>(&mut amounts, 61363026);
      
      Vector::push_back<address>(&mut payees, @0x5802d0942e78c5cb0c02bcdc44a02045);
      Vector::push_back<u64>(&mut amounts, 4356953573);
      
      Vector::push_back<address>(&mut payees, @0x2c6a483d3f6560b90f4df22949ab83db);
      Vector::push_back<u64>(&mut amounts, 245569828);
      
      Vector::push_back<address>(&mut payees, @0xe9253af5c8e979e023a2fb79d021b445);
      Vector::push_back<u64>(&mut amounts, 1075875517);
      
      Vector::push_back<address>(&mut payees, @0xeb791a2e8c6777c33e2af1ca418956df);
      Vector::push_back<u64>(&mut amounts, 1090146421);
      
      Vector::push_back<address>(&mut payees, @0x51835d0993d566f477bda3e4561b426d);
      Vector::push_back<u64>(&mut amounts, 751602990);
      
      Vector::push_back<address>(&mut payees, @0xa64374b74ef6de25ce2c27f29fad105b);
      Vector::push_back<u64>(&mut amounts, 812863723);
      
      Vector::push_back<address>(&mut payees, @0xce95cf6edd87f504a9c94f1b84a7ac4b);
      Vector::push_back<u64>(&mut amounts, 1581516674);
      
      Vector::push_back<address>(&mut payees, @0x1fd7816f7bb0afd65b7d133c5923385f);
      Vector::push_back<u64>(&mut amounts, 107548865);
      
      Vector::push_back<address>(&mut payees, @0x9da1899e71f7225c6fcbaa44f8a8f813);
      Vector::push_back<u64>(&mut amounts, 1586579225);
      
      Vector::push_back<address>(&mut payees, @0x8b773cb5a3cf231e89dc5cac53c525f6);
      Vector::push_back<u64>(&mut amounts, 1587155860);
      
      Vector::push_back<address>(&mut payees, @0x3152fe3dbfe611b9f2355a2c0cf10f48);
      Vector::push_back<u64>(&mut amounts, 1588039762);
      
      Vector::push_back<address>(&mut payees, @0x572c8eb56867276481bb3b228c7ebb45);
      Vector::push_back<u64>(&mut amounts, 425153135);
      
      Vector::push_back<address>(&mut payees, @0x52d958f00023ad8d03a2efb5aac28811);
      Vector::push_back<u64>(&mut amounts, 425153135);
      
      Vector::push_back<address>(&mut payees, @0x1d4c12f15d72000a6150c3e9e281d2f0);
      Vector::push_back<u64>(&mut amounts, 230164241);
      
      Vector::push_back<address>(&mut payees, @0x5e7d1a45cdb7930c0b612208ea9ad67e);
      Vector::push_back<u64>(&mut amounts, 2537793329);
      
      Vector::push_back<address>(&mut payees, @0x5c2cd8f69b2ad319ed8d603cc29ed6db);
      Vector::push_back<u64>(&mut amounts, 2071374980);
      
      Vector::push_back<address>(&mut payees, @0x62c9204878770b7bea487ae3fc0ba611);
      Vector::push_back<u64>(&mut amounts, 636667502);
      
      Vector::push_back<address>(&mut payees, @0xd6689e360beb9018bdc06feb2c08c98c);
      Vector::push_back<u64>(&mut amounts, 3178010610);
      
      Vector::push_back<address>(&mut payees, @0x3d4c22881359530c8ade3dad0d87e05f);
      Vector::push_back<u64>(&mut amounts, 1602645970);
      
      Vector::push_back<address>(&mut payees, @0xfa3d8aaf3bff1cda1e9ebb1dc9679370);
      Vector::push_back<u64>(&mut amounts, 322160909);
      
      Vector::push_back<address>(&mut payees, @0x7aaf5748d813a2c0571e8f4e60261156);
      Vector::push_back<u64>(&mut amounts, 855655914);
      
      Vector::push_back<address>(&mut payees, @0xc8f7974c311ba35dfa8580db6600ff13);
      Vector::push_back<u64>(&mut amounts, 36571726);
      
      Vector::push_back<address>(&mut payees, @0x0e67d7ecb17fe99d330d29b0703f09e0);
      Vector::push_back<u64>(&mut amounts, 247733604);
      
      Vector::push_back<address>(&mut payees, @0x386d3547693fb5cb68e94194f406dcb3);
      Vector::push_back<u64>(&mut amounts, 5551853795);
      
      Vector::push_back<address>(&mut payees, @0xadf9327eedad93aacdaf3e9d50b9fa2b);
      Vector::push_back<u64>(&mut amounts, 972382100);
      
      Vector::push_back<address>(&mut payees, @0x6a3715815327f8ee768b8cd8537d11e0);
      Vector::push_back<u64>(&mut amounts, 2202134797);
      
      Vector::push_back<address>(&mut payees, @0x83d52be0cbb5f94686521575b4ebaa40);
      Vector::push_back<u64>(&mut amounts, 4006316966);
      
      Vector::push_back<address>(&mut payees, @0x4caaf67568d37c01ba05f374b738ca73);
      Vector::push_back<u64>(&mut amounts, 188171973);
      
      Vector::push_back<address>(&mut payees, @0x813ebdaae9f3a6e796138f4585ee4fbb);
      Vector::push_back<u64>(&mut amounts, 3353080315);
      
      Vector::push_back<address>(&mut payees, @0x9ff4851d3318425b4d748ccd14c01152);
      Vector::push_back<u64>(&mut amounts, 3356404734);
      
      Vector::push_back<address>(&mut payees, @0xb723027e0ea21587933aa68437dd8a93);
      Vector::push_back<u64>(&mut amounts, 1706395543);
      
      Vector::push_back<address>(&mut payees, @0xbf18b79cfa3037fd153a14ef89bb26ac);
      Vector::push_back<u64>(&mut amounts, 2849474239);
      
      Vector::push_back<address>(&mut payees, @0xd04b586c54afc649cbd5a0df06edf8a5);
      Vector::push_back<u64>(&mut amounts, 60952877);
      
      Vector::push_back<address>(&mut payees, @0x0db83e8af0e164db8d28817f00c67474);
      Vector::push_back<u64>(&mut amounts, 738283356);
      
      Vector::push_back<address>(&mut payees, @0x2fdf675b2c182ec4034b504a0166910c);
      Vector::push_back<u64>(&mut amounts, 691224618);
      
      Vector::push_back<address>(&mut payees, @0x62816ff5196f8e4849d5f889d95a3a9d);
      Vector::push_back<u64>(&mut amounts, 753797320);
      
      Vector::push_back<address>(&mut payees, @0x93c18c849d6717d051d97983b6ca5aef);
      Vector::push_back<u64>(&mut amounts, 424711803);
      
      Vector::push_back<address>(&mut payees, @0x434437ac984b03a456a9f8bc42b1e52d);
      Vector::push_back<u64>(&mut amounts, 418996714);
      
      Vector::push_back<address>(&mut payees, @0xa7a7b61ba5c90502d1e9adf84be77239);
      Vector::push_back<u64>(&mut amounts, 299620402);
      
      Vector::push_back<address>(&mut payees, @0x365e3c3a93594e0cdb08114ff608e29f);
      Vector::push_back<u64>(&mut amounts, 299620402);
      
      Vector::push_back<address>(&mut payees, @0x80185b99c2e16023b53bbed14e2c0c9c);
      Vector::push_back<u64>(&mut amounts, 299620402);
      
      Vector::push_back<address>(&mut payees, @0x73e969461a255a398c3ae59d3c3c71c8);
      Vector::push_back<u64>(&mut amounts, 299620402);
      
      Vector::push_back<address>(&mut payees, @0xc900811d8b1f9f68ce1fc48425620c06);
      Vector::push_back<u64>(&mut amounts, 1008925214);
      
      Vector::push_back<address>(&mut payees, @0xb64f29882abc22724e5f64b227f64e2a);
      Vector::push_back<u64>(&mut amounts, 337267728);
      
      Vector::push_back<address>(&mut payees, @0x6ef1333099d5d3e0f0cde618056b3125);
      Vector::push_back<u64>(&mut amounts, 684042407);
      
      Vector::push_back<address>(&mut payees, @0x6154e17d746e41da224215863c9840ce);
      Vector::push_back<u64>(&mut amounts, 577637532);
      
      Vector::push_back<address>(&mut payees, @0x194b8c1c944c12ef43fe3e333c418455);
      Vector::push_back<u64>(&mut amounts, 324566363);
      
      Vector::push_back<address>(&mut payees, @0x90db26f427971dc997921a14f1430a0b);
      Vector::push_back<u64>(&mut amounts, 3543093859);
      
      Vector::push_back<address>(&mut payees, @0x009b95f55c62c24df4fa19643ed68cd1);
      Vector::push_back<u64>(&mut amounts, 182021040);
      
      Vector::push_back<address>(&mut payees, @0x7a978d1816c13cd8b75fa8fff1644c41);
      Vector::push_back<u64>(&mut amounts, 2515456348);
      
      Vector::push_back<address>(&mut payees, @0x1c468ef2a0d3f1998fd40bb6dce9c1b8);
      Vector::push_back<u64>(&mut amounts, 173862851);
      
      Vector::push_back<address>(&mut payees, @0x6b9e7666bc4dcf28f47379ad0398644a);
      Vector::push_back<u64>(&mut amounts, 3056476802);
      
      Vector::push_back<address>(&mut payees, @0xbc975564f7535b8ab5d2b4d0ad8342bd);
      Vector::push_back<u64>(&mut amounts, 3022992967);
      
      Vector::push_back<address>(&mut payees, @0x2ac70f135c350c232a3f295b0a5d458a);
      Vector::push_back<u64>(&mut amounts, 2825247929);
      
      Vector::push_back<address>(&mut payees, @0x00a3144a8662e59756d8f17afbd7484f);
      Vector::push_back<u64>(&mut amounts, 3039698318);
      
      Vector::push_back<address>(&mut payees, @0xd4da8072f31f9e2e730212abe6e17e91);
      Vector::push_back<u64>(&mut amounts, 3029173740);
      
      Vector::push_back<address>(&mut payees, @0x3f9ec17209c1602e898bacdcd3df1296);
      Vector::push_back<u64>(&mut amounts, 3009225279);
      
      Vector::push_back<address>(&mut payees, @0xf6e7d9aa99482b3944c5ebac807a7531);
      Vector::push_back<u64>(&mut amounts, 3018973610);
      
      Vector::push_back<address>(&mut payees, @0x367aa8bea039328f0a67edf9c5391e39);
      Vector::push_back<u64>(&mut amounts, 3005299414);
      
      Vector::push_back<address>(&mut payees, @0x6c586e2269134fee794bfa64ea32691c);
      Vector::push_back<u64>(&mut amounts, 2943466454);
      
      Vector::push_back<address>(&mut payees, @0xe17e6b2ccde1a814d42ff8758c910d2c);
      Vector::push_back<u64>(&mut amounts, 2007191984);
      
      Vector::push_back<address>(&mut payees, @0x3fe4cc042db50b1bd3cd8a6075fa2a42);
      Vector::push_back<u64>(&mut amounts, 2930802889);
      
      Vector::push_back<address>(&mut payees, @0xe1f96aab14d2915f45e6ac8c03502f8c);
      Vector::push_back<u64>(&mut amounts, 2992674196);
      
      Vector::push_back<address>(&mut payees, @0x88aba97fd094b1c61b89af23765f8ca5);
      Vector::push_back<u64>(&mut amounts, 1979581587);
      
      Vector::push_back<address>(&mut payees, @0x81444074318f422aba6316e112f86504);
      Vector::push_back<u64>(&mut amounts, 2704031618);
      
      Vector::push_back<address>(&mut payees, @0x3904fe2bb6c23659df22660b471b0eaa);
      Vector::push_back<u64>(&mut amounts, 2606164492);
      
      Vector::push_back<address>(&mut payees, @0x161d6a154d0401757542ec09fab50f31);
      Vector::push_back<u64>(&mut amounts, 2730998006);
      
      Vector::push_back<address>(&mut payees, @0x0199d4576f756d0b74575a506b2182f3);
      Vector::push_back<u64>(&mut amounts, 2718638941);
      
      Vector::push_back<address>(&mut payees, @0xadaa9bcd705768bb5e7d5236b488c5ac);
      Vector::push_back<u64>(&mut amounts, 2619734994);
      
      Vector::push_back<address>(&mut payees, @0xde3ce31607ff6d34954609bab7dca990);
      Vector::push_back<u64>(&mut amounts, 2712899849);
      
      Vector::push_back<address>(&mut payees, @0xc6c3414f37d81f68f8447ddfeaf588ac);
      Vector::push_back<u64>(&mut amounts, 223474050);
      
      Vector::push_back<address>(&mut payees, @0x3c7ae08b5961871d215f3216f441c32a);
      Vector::push_back<u64>(&mut amounts, 1185364077);
      
      Vector::push_back<address>(&mut payees, @0x4cca57b8d09993a3b524223dedf2bcf7);
      Vector::push_back<u64>(&mut amounts, 1097432181);
      
      Vector::push_back<address>(&mut payees, @0xa7bf8b47ac90631fcf25c9115a6a4685);
      Vector::push_back<u64>(&mut amounts, 165673823);
      
      Vector::push_back<address>(&mut payees, @0xab2ee4c15b4860547f05c15cc5b4b879);
      Vector::push_back<u64>(&mut amounts, 3159873270);
      
      Vector::push_back<address>(&mut payees, @0xae9458aacf60f02622ed944460e8d495);
      Vector::push_back<u64>(&mut amounts, 3744808620);
      
      Vector::push_back<address>(&mut payees, @0xc82956aea02e2dca188eb1da7de83d59);
      Vector::push_back<u64>(&mut amounts, 106902612);
      
      Vector::push_back<address>(&mut payees, @0x5bb567133846213d8bcee4e8acec9d81);
      Vector::push_back<u64>(&mut amounts, 2042121240);
      
      Vector::push_back<address>(&mut payees, @0x5ff1988f042a2a65c592d35b4759ef5f);
      Vector::push_back<u64>(&mut amounts, 1598877713);
      
      Vector::push_back<address>(&mut payees, @0xd1bcd47691fbc7f8e7d527b961eb1c48);
      Vector::push_back<u64>(&mut amounts, 1031510469);
      
      Vector::push_back<address>(&mut payees, @0xa660b0d87df63af8e30c437e275a49e0);
      Vector::push_back<u64>(&mut amounts, 2040990590);
      
      Vector::push_back<address>(&mut payees, @0x8222c710267a00cdb021b847d60591ca);
      Vector::push_back<u64>(&mut amounts, 6364360009);
      
      Vector::push_back<address>(&mut payees, @0x9b443b667d3dc0ec10da6d7284ac571c);
      Vector::push_back<u64>(&mut amounts, 5884906360);
      
      Vector::push_back<address>(&mut payees, @0xdb3e53cc224714124bace1381ac23d94);
      Vector::push_back<u64>(&mut amounts, 1068361500);
      
      Vector::push_back<address>(&mut payees, @0x9cd15e61ed5c2ebf9364c68c123b582f);
      Vector::push_back<u64>(&mut amounts, 916559225);
      
      Vector::push_back<address>(&mut payees, @0xadda96997467640dadba51aa0616be72);
      Vector::push_back<u64>(&mut amounts, 2768869957);
      
      Vector::push_back<address>(&mut payees, @0xc3186803b5a56a32c47c713f617adacf);
      Vector::push_back<u64>(&mut amounts, 2884940890);
      
      Vector::push_back<address>(&mut payees, @0x335f2c900c9f62bb0d29d1c6017eaa72);
      Vector::push_back<u64>(&mut amounts, 3011784568);
      
      Vector::push_back<address>(&mut payees, @0xf2b3ff3ffd4c7ee3d122bf2cb2e43ac6);
      Vector::push_back<u64>(&mut amounts, 2992693347);
      
      Vector::push_back<address>(&mut payees, @0x9bdf68331f3bff61e63ae10b7990aa9b);
      Vector::push_back<u64>(&mut amounts, 3004018876);
      
      Vector::push_back<address>(&mut payees, @0x62922e76b6a7d6568a745020c6bfbb81);
      Vector::push_back<u64>(&mut amounts, 2939075062);
      
      Vector::push_back<address>(&mut payees, @0xa1130ac378d408c18d3e9e44e510c698);
      Vector::push_back<u64>(&mut amounts, 2994853339);
      
      Vector::push_back<address>(&mut payees, @0xfaede4336aca8eea226922c1aaed6ce1);
      Vector::push_back<u64>(&mut amounts, 2939988742);
      
      Vector::push_back<address>(&mut payees, @0x9f9be04e6c2a52337011386bb3674366);
      Vector::push_back<u64>(&mut amounts, 2996935180);
      
      Vector::push_back<address>(&mut payees, @0xe2bddd3fb3fa6b309e0270f62abada75);
      Vector::push_back<u64>(&mut amounts, 2722534125);
      
      Vector::push_back<address>(&mut payees, @0xd896e040cc3f187f17a734413e4b114c);
      Vector::push_back<u64>(&mut amounts, 2723533701);
      
      Vector::push_back<address>(&mut payees, @0x94ff3338c8e5be7f27d7ff567b18f5c5);
      Vector::push_back<u64>(&mut amounts, 2724102629);
      
      Vector::push_back<address>(&mut payees, @0x9114a5b1146ea1d2d0075a5a84a0373a);
      Vector::push_back<u64>(&mut amounts, 2646221766);
      
      Vector::push_back<address>(&mut payees, @0x80c13ab1b9d0d2de7a2c14a43378125d);
      Vector::push_back<u64>(&mut amounts, 2259908137);
      
      Vector::push_back<address>(&mut payees, @0x8e8647738d1eb7d79b11a0433edbe56e);
      Vector::push_back<u64>(&mut amounts, 2647132462);
      
      Vector::push_back<address>(&mut payees, @0xc6d16f319f06d80609ba90fc88a9d13b);
      Vector::push_back<u64>(&mut amounts, 2649094126);
      
      Vector::push_back<address>(&mut payees, @0x2dd3dffba117efc4691a8ba07e0ba39c);
      Vector::push_back<u64>(&mut amounts, 1048053493);
      
      Vector::push_back<address>(&mut payees, @0x5d6d5ef685c9bb1667687c3af71c7868);
      Vector::push_back<u64>(&mut amounts, 719333447);
      
      Vector::push_back<address>(&mut payees, @0xadb95606eb6b06e44d271e0b07918e08);
      Vector::push_back<u64>(&mut amounts, 321227372);
      
      Vector::push_back<address>(&mut payees, @0xb464b4d3672e602cbb76481d73fd6561);
      Vector::push_back<u64>(&mut amounts, 1756797336);
      
      Vector::push_back<address>(&mut payees, @0xfbbf05f537d5d5103200317cdd961cde);
      Vector::push_back<u64>(&mut amounts, 1848427284);
      
      Vector::push_back<address>(&mut payees, @0x9a3cd442f4fd62dc66a7bb87f522fec6);
      Vector::push_back<u64>(&mut amounts, 58922862);
      
      Vector::push_back<address>(&mut payees, @0xfa4b2bb18573562ea91c33d90c533f62);
      Vector::push_back<u64>(&mut amounts, 2057287528);
      
      Vector::push_back<address>(&mut payees, @0xd9859ac77fe37821ee0193b9b70dc1d1);
      Vector::push_back<u64>(&mut amounts, 2404686550);
      
      Vector::push_back<address>(&mut payees, @0x42776812493f91e519ff574f3da91aa6);
      Vector::push_back<u64>(&mut amounts, 148215936);
      
      Vector::push_back<address>(&mut payees, @0x25f1c9cf1f1a2e8473549848c1518567);
      Vector::push_back<u64>(&mut amounts, 279402579);
      
      Vector::push_back<address>(&mut payees, @0xbeed26a4db938dedea423cea750a74e4);
      Vector::push_back<u64>(&mut amounts, 1622242189);
      
      Vector::push_back<address>(&mut payees, @0x9cb373fe0196e214e116468e01ad0a08);
      Vector::push_back<u64>(&mut amounts, 173893866);
      
      Vector::push_back<address>(&mut payees, @0x0cc691f811cb4e21635a2fd17b29fbae);
      Vector::push_back<u64>(&mut amounts, 139315212);
      
      Vector::push_back<address>(&mut payees, @0x00522e0cacdeb4f0c371cb907776af10);
      Vector::push_back<u64>(&mut amounts, 642048197);
      
      Vector::push_back<address>(&mut payees, @0x56c94bab068a76c339b47dda8f2c5f4c);
      Vector::push_back<u64>(&mut amounts, 255025883);
      
      Vector::push_back<address>(&mut payees, @0xde32472c7fcdd2724a2dea35bd303272);
      Vector::push_back<u64>(&mut amounts, 3575746724);
      
      Vector::push_back<address>(&mut payees, @0x69841820f6dde82e26dce33b179f7a96);
      Vector::push_back<u64>(&mut amounts, 247433676);
      
      Vector::push_back<address>(&mut payees, @0x3b4dc78449e32295852885b9a06f0c3f);
      Vector::push_back<u64>(&mut amounts, 151066640);
      
      Vector::push_back<address>(&mut payees, @0xd4a310da2be0b6002b63353e270539bf);
      Vector::push_back<u64>(&mut amounts, 3812461804);
      
      Vector::push_back<address>(&mut payees, @0xa07366ddd6a0adea00dbe3c534a32c60);
      Vector::push_back<u64>(&mut amounts, 772630342);
      
      Vector::push_back<address>(&mut payees, @0xb7c3fc9376d5fb871ad75ccc7c018c69);
      Vector::push_back<u64>(&mut amounts, 181182772);
      
      Vector::push_back<address>(&mut payees, @0x47329e629d8c6743a3d5495b75c116f5);
      Vector::push_back<u64>(&mut amounts, 1840567023);
      
      Vector::push_back<address>(&mut payees, @0xca1f11937872850bf14c55a48de55afe);
      Vector::push_back<u64>(&mut amounts, 2415938547);
      
      Vector::push_back<address>(&mut payees, @0x7709ee30fc79b1184de74249eaa4194a);
      Vector::push_back<u64>(&mut amounts, 909791396);
      
      Vector::push_back<address>(&mut payees, @0xa9f56e630f220cf6d7edc9e69d47aee4);
      Vector::push_back<u64>(&mut amounts, 878728146);
      
      Vector::push_back<address>(&mut payees, @0xc59ffe0d970a16a5fdb8e31074f00493);
      Vector::push_back<u64>(&mut amounts, 647573771);
      
      Vector::push_back<address>(&mut payees, @0xb06cb86f58b0739475f619d182ea8409);
      Vector::push_back<u64>(&mut amounts, 1717220587);
      
      Vector::push_back<address>(&mut payees, @0x261a7078a7ee87b134af61529c904344);
      Vector::push_back<u64>(&mut amounts, 1072004786);
      
      Vector::push_back<address>(&mut payees, @0xa9f21da0117d66a89c4d2e6a4962b17b);
      Vector::push_back<u64>(&mut amounts, 1539053567);
      
      Vector::push_back<address>(&mut payees, @0xeb44e19243500ddfc6b549bbda68247c);
      Vector::push_back<u64>(&mut amounts, 3321051050);
      
      Vector::push_back<address>(&mut payees, @0xc79233026df3ce484900758906eed2d3);
      Vector::push_back<u64>(&mut amounts, 1554144123);
      
      Vector::push_back<address>(&mut payees, @0x005c829605d2bafbbe0743efaa2acf7d);
      Vector::push_back<u64>(&mut amounts, 22439133);
      
      Vector::push_back<address>(&mut payees, @0xb8ccb263d42ebcba5c56764ea1003d58);
      Vector::push_back<u64>(&mut amounts, 1471191100);
      
      Vector::push_back<address>(&mut payees, @0x9fa98bba5fbadf868f4a6c370cb22cfb);
      Vector::push_back<u64>(&mut amounts, 1718599408);
      
      Vector::push_back<address>(&mut payees, @0xda1c384aca711ae1238c1824e8d565d8);
      Vector::push_back<u64>(&mut amounts, 1485058114);
      
      Vector::push_back<address>(&mut payees, @0x88d1c07460dd34d6ae568c5d9ed06d73);
      Vector::push_back<u64>(&mut amounts, 2985599154);
      
      Vector::push_back<address>(&mut payees, @0x38ab3c72a07553ede6261af2eb3d9bd3);
      Vector::push_back<u64>(&mut amounts, 3066144030);
      
      Vector::push_back<address>(&mut payees, @0x218d6b103233ade416d2fff019f22b06);
      Vector::push_back<u64>(&mut amounts, 1942451728);
      
      Vector::push_back<address>(&mut payees, @0x53273963c0861d7878b2e6e59e6c55fc);
      Vector::push_back<u64>(&mut amounts, 3686585109);
      
      Vector::push_back<address>(&mut payees, @0xb4dc0e05154670c37f2a45250e5d3a9c);
      Vector::push_back<u64>(&mut amounts, 2692651485);
      
      Vector::push_back<address>(&mut payees, @0x297d84be6e56d5174ded356fafdeba13);
      Vector::push_back<u64>(&mut amounts, 2650951670);
      
      Vector::push_back<address>(&mut payees, @0xbd1cbd8e8e5a481cba0d625b1f8bd899);
      Vector::push_back<u64>(&mut amounts, 312239953);
      
      Vector::push_back<address>(&mut payees, @0x9d0a8f2f51a2cb0d4eceeb1fd269431d);
      Vector::push_back<u64>(&mut amounts, 1097632354);
      
      Vector::push_back<address>(&mut payees, @0xf4313c355d005f50ceb413e91bfa21e9);
      Vector::push_back<u64>(&mut amounts, 2633970651);
      
      Vector::push_back<address>(&mut payees, @0x364ed6e2dd9be051be236395e166eecc);
      Vector::push_back<u64>(&mut amounts, 988917126);
      
      Vector::push_back<address>(&mut payees, @0x87dc2e497ac6edab21511333a421e5a5);
      Vector::push_back<u64>(&mut amounts, 40811358);
      
      Vector::push_back<address>(&mut payees, @0xa32a51de1f2e0700acd6f0850d242287);
      Vector::push_back<u64>(&mut amounts, 422208061);
      
      Vector::push_back<address>(&mut payees, @0x99bb774f34f40117c04e4082ae330d3b);
      Vector::push_back<u64>(&mut amounts, 3348340409);
      
      Vector::push_back<address>(&mut payees, @0x76045e6d442182a3f2467cc81e497241);
      Vector::push_back<u64>(&mut amounts, 1884828941);
      
      Vector::push_back<address>(&mut payees, @0x12d786ecd55e453993cf3303ea9f5384);
      Vector::push_back<u64>(&mut amounts, 1460246021);
      
      Vector::push_back<address>(&mut payees, @0xbf6a52bf5f5c27fd45daa932d41caa26);
      Vector::push_back<u64>(&mut amounts, 2785060792);
      
      Vector::push_back<address>(&mut payees, @0x4e6468d95d07552e8804f637c13e1d0b);
      Vector::push_back<u64>(&mut amounts, 4379456297);
      
      Vector::push_back<address>(&mut payees, @0x4749f425b3cb3ed43df1387a1ffa7756);
      Vector::push_back<u64>(&mut amounts, 3728800441);
      
      Vector::push_back<address>(&mut payees, @0x974f510b4634961c3ec3ada8297593d8);
      Vector::push_back<u64>(&mut amounts, 2441725190);
      
      Vector::push_back<address>(&mut payees, @0x7db383b9ee673cdf8c3e597b1977599d);
      Vector::push_back<u64>(&mut amounts, 2149108385);
      
      Vector::push_back<address>(&mut payees, @0xb89c3643458200ae7295e1b1b56ad2c1);
      Vector::push_back<u64>(&mut amounts, 199522133);
      
      Vector::push_back<address>(&mut payees, @0xd7db70ee8eafed7f60ece38196a127a1);
      Vector::push_back<u64>(&mut amounts, 28806189);
      
      Vector::push_back<address>(&mut payees, @0x45b63b79a7369a4acfb4547367bf637f);
      Vector::push_back<u64>(&mut amounts, 2672300585);
      
      Vector::push_back<address>(&mut payees, @0x50a39238a5e0f9b7eced55564d059cf0);
      Vector::push_back<u64>(&mut amounts, 4143921571);
      
      Vector::push_back<address>(&mut payees, @0x1d83cf6f445a56fe9308a8b063491c99);
      Vector::push_back<u64>(&mut amounts, 2717064383);
      
      Vector::push_back<address>(&mut payees, @0xba28e97a4bc3f7f1366c0b059e0c0d79);
      Vector::push_back<u64>(&mut amounts, 331698173);
      
      Vector::push_back<address>(&mut payees, @0x548bdbe7dad3e52de6b9886b1db3fc56);
      Vector::push_back<u64>(&mut amounts, 356017939);
      
      Vector::push_back<address>(&mut payees, @0xda1a414269835e44f8cdc4077c560658);
      Vector::push_back<u64>(&mut amounts, 2297577121);
      
      Vector::push_back<address>(&mut payees, @0x0f82c1b607a1a5a5c837664c02486b15);
      Vector::push_back<u64>(&mut amounts, 3081345738);
      
      Vector::push_back<address>(&mut payees, @0x3c18813e433511af9102f80018a7b86e);
      Vector::push_back<u64>(&mut amounts, 1361433529);
      
      Vector::push_back<address>(&mut payees, @0x73538d1f243b78b7f70f789b345ca83d);
      Vector::push_back<u64>(&mut amounts, 576866999);
      
      Vector::push_back<address>(&mut payees, @0xec5d40999adb39ac8f2acd47e117355e);
      Vector::push_back<u64>(&mut amounts, 325583597);
      
      Vector::push_back<address>(&mut payees, @0x52a00d214d47a274c2ad619bc365584b);
      Vector::push_back<u64>(&mut amounts, 1707294266);
      
      Vector::push_back<address>(&mut payees, @0x06dd3a0917561c14fdb72024a2f5e7e7);
      Vector::push_back<u64>(&mut amounts, 32921359);
      
      Vector::push_back<address>(&mut payees, @0x4ad0bb6a770ab3eef540af82f88a549a);
      Vector::push_back<u64>(&mut amounts, 1159281213);
      
      Vector::push_back<address>(&mut payees, @0x1d73cf6020f95cbebf1426e8d68ba080);
      Vector::push_back<u64>(&mut amounts, 39094114);
      
      Vector::push_back<address>(&mut payees, @0x497036c16cea6ff43ca84fe0cb345e17);
      Vector::push_back<u64>(&mut amounts, 424144302);
      
      Vector::push_back<address>(&mut payees, @0x5f89cc01b25f70aff2f1afedcb8ffa03);
      Vector::push_back<u64>(&mut amounts, 1202247509);
      
      Vector::push_back<address>(&mut payees, @0xf435de1fee7e4a483b36b49660d6dcce);
      Vector::push_back<u64>(&mut amounts, 174937954);
      
      Vector::push_back<address>(&mut payees, @0x5955d5315da4fe62db245822a4810f79);
      Vector::push_back<u64>(&mut amounts, 20235508);
      
      Vector::push_back<address>(&mut payees, @0xf30e1daa832e396af53326aab3e8abfa);
      Vector::push_back<u64>(&mut amounts, 265520079);
      
      Vector::push_back<address>(&mut payees, @0x86579c13f612d8114bb2ebdc67fac1de);
      Vector::push_back<u64>(&mut amounts, 2709742156);
      
      Vector::push_back<address>(&mut payees, @0x8ad3ceec091b360597af8b78354064c5);
      Vector::push_back<u64>(&mut amounts, 776333210);
      
      Vector::push_back<address>(&mut payees, @0xfd92fa4207b69c5ff64b86f3961bf65d);
      Vector::push_back<u64>(&mut amounts, 1259173585);
      
      Vector::push_back<address>(&mut payees, @0x9007c8001e032212fb138bf3de1b01a4);
      Vector::push_back<u64>(&mut amounts, 121876876);
      
      Vector::push_back<address>(&mut payees, @0x5d4731430563120519e95aceb9f98170);
      Vector::push_back<u64>(&mut amounts, 73473710);
      
      Vector::push_back<address>(&mut payees, @0x6bba2f30f8c2991a3daa7619ba466917);
      Vector::push_back<u64>(&mut amounts, 217582756);
      
      Vector::push_back<address>(&mut payees, @0x3b676d4bc51fe730c31ed88e967f9b78);
      Vector::push_back<u64>(&mut amounts, 24732287);
      
      Vector::push_back<address>(&mut payees, @0xd1a8e905f8860a708f25a017a040840e);
      Vector::push_back<u64>(&mut amounts, 17987118);
      
      Vector::push_back<address>(&mut payees, @0x8b7be5c6248260c417d9e7329be1a6ab);
      Vector::push_back<u64>(&mut amounts, 3873974177);
      
      Vector::push_back<address>(&mut payees, @0x45f6bcf1f27256b1618ae50ecf2905c5);
      Vector::push_back<u64>(&mut amounts, 888074851);
      
      Vector::push_back<address>(&mut payees, @0x7fc2bf150a18f79cb33b277aa9c2cf49);
      Vector::push_back<u64>(&mut amounts, 836361906);
      
      Vector::push_back<address>(&mut payees, @0xadfb7bcbcfe4e466256464d3853b08b1);
      Vector::push_back<u64>(&mut amounts, 2114008946);
      
      Vector::push_back<address>(&mut payees, @0xd8ff6bbf6616266e97c31656ff506d47);
      Vector::push_back<u64>(&mut amounts, 1305625989);
      
      Vector::push_back<address>(&mut payees, @0xb337b2dc21383d5960524543d94be7ba);
      Vector::push_back<u64>(&mut amounts, 245304833);
      
      Vector::push_back<address>(&mut payees, @0xe4240cda2bcba4f42f8612458774e140);
      Vector::push_back<u64>(&mut amounts, 393285566);
      
      Vector::push_back<address>(&mut payees, @0x122ef7372f302a43d2ae74b21e48a59e);
      Vector::push_back<u64>(&mut amounts, 150964062);
      
      Vector::push_back<address>(&mut payees, @0x260afccc3e3b4f523dd5654084c76d84);
      Vector::push_back<u64>(&mut amounts, 420320547);
      
      Vector::push_back<address>(&mut payees, @0x140f35c2910b4e13743037650a309b30);
      Vector::push_back<u64>(&mut amounts, 5329130037);
      
      Vector::push_back<address>(&mut payees, @0x443d5d5338d5979645dfc8f750c17768);
      Vector::push_back<u64>(&mut amounts, 586570722);
      
      Vector::push_back<address>(&mut payees, @0xd4f360b8952a5a8f07e7e016ca8c9edd);
      Vector::push_back<u64>(&mut amounts, 1012022101);
      
      Vector::push_back<address>(&mut payees, @0xcd7c59c9d7ca50fe417e3083771fa7e8);
      Vector::push_back<u64>(&mut amounts, 1665474416);
      
      Vector::push_back<address>(&mut payees, @0xbd4bbe6233887004d246753d73416e7e);
      Vector::push_back<u64>(&mut amounts, 3586395143);
      
      Vector::push_back<address>(&mut payees, @0x59c6262930e3ebb3398d5b88790c090c);
      Vector::push_back<u64>(&mut amounts, 2259990027);
      
      Vector::push_back<address>(&mut payees, @0x1db7dc95663ea9d2ffc123373a2ccf62);
      Vector::push_back<u64>(&mut amounts, 1903967045);
      
      Vector::push_back<address>(&mut payees, @0x8fa38ec2df1f2f5c80bfe4b081262c1f);
      Vector::push_back<u64>(&mut amounts, 655214904);
      
      Vector::push_back<address>(&mut payees, @0x9124f77818589270f78ff2d8cdd3118a);
      Vector::push_back<u64>(&mut amounts, 39208444);
      
      Vector::push_back<address>(&mut payees, @0x086b0286a641e816808709d643259110);
      Vector::push_back<u64>(&mut amounts, 3519435675);
      
      Vector::push_back<address>(&mut payees, @0x87373c052426e1d13e65bd9e2925749d);
      Vector::push_back<u64>(&mut amounts, 3527125329);
      
      Vector::push_back<address>(&mut payees, @0x40ee749a693339174a71147c221ee573);
      Vector::push_back<u64>(&mut amounts, 163172181);
      
      Vector::push_back<address>(&mut payees, @0x6254999609e729e92dbf9ce6fa8279c6);
      Vector::push_back<u64>(&mut amounts, 561217376);
      
      Vector::push_back<address>(&mut payees, @0x7608e98a2a9f9ac37d4d917d63722353);
      Vector::push_back<u64>(&mut amounts, 2638694540);
      
      Vector::push_back<address>(&mut payees, @0x8329d0d6c6e5568e9f812d2b4a2a5482);
      Vector::push_back<u64>(&mut amounts, 232612895);
      
      Vector::push_back<address>(&mut payees, @0x11ffba2ddc612ed1d90d3e25f1bbf014);
      Vector::push_back<u64>(&mut amounts, 78416888);
      
      Vector::push_back<address>(&mut payees, @0x88cb6f24d7e5dd3401e7f2287c88f461);
      Vector::push_back<u64>(&mut amounts, 3892885866);
      
      Vector::push_back<address>(&mut payees, @0x2eaae391c493e55d2c0c1ad997ba1b06);
      Vector::push_back<u64>(&mut amounts, 245004312);
      
      Vector::push_back<address>(&mut payees, @0x01eaee9924e46666710628779d8d66c0);
      Vector::push_back<u64>(&mut amounts, 1978519890);
      
      Vector::push_back<address>(&mut payees, @0x2cce6a2177165025d1276db763cee74a);
      Vector::push_back<u64>(&mut amounts, 39208444);
      
      Vector::push_back<address>(&mut payees, @0x6e603be730bf47f21566a4e05adc64b4);
      Vector::push_back<u64>(&mut amounts, 1552106607);
      
      Vector::push_back<address>(&mut payees, @0x1cc0ea0f60ab8ab158ff3dd91aea2874);
      Vector::push_back<u64>(&mut amounts, 2334815147);
      
      Vector::push_back<address>(&mut payees, @0x1ad5b76c6a147a1ae3bc3e1ffb15cc74);
      Vector::push_back<u64>(&mut amounts, 26138962);
      
      Vector::push_back<address>(&mut payees, @0xffdbac37b409f9ec3efd2fd9f53f068b);
      Vector::push_back<u64>(&mut amounts, 1444779371);
      
      Vector::push_back<address>(&mut payees, @0x896faefdef01f0ece3f960a7d3b84d86);
      Vector::push_back<u64>(&mut amounts, 73189095);
      
      Vector::push_back<address>(&mut payees, @0x2787d9ecc01eab17ee824d417f780fbe);
      Vector::push_back<u64>(&mut amounts, 288947299);
      
      Vector::push_back<address>(&mut payees, @0xf75094c2e04b2cd28f3a5e034498fb23);
      Vector::push_back<u64>(&mut amounts, 20911170);
      
      Vector::push_back<address>(&mut payees, @0xc1625c5bab2175bebf2d028a705bb3b0);
      Vector::push_back<u64>(&mut amounts, 6530287784);
      
      Vector::push_back<address>(&mut payees, @0x16b180b42275f75f3e0c4e477c3eb4db);
      Vector::push_back<u64>(&mut amounts, 5650643178);
      
      Vector::push_back<address>(&mut payees, @0xfbfbaebb74e2d4c54d73c66dc329d909);
      Vector::push_back<u64>(&mut amounts, 185586636);
      
      Vector::push_back<address>(&mut payees, @0x00ecb4f8f19c0e10a1c061b02834b72e);
      Vector::push_back<u64>(&mut amounts, 3346152365);
      
      Vector::push_back<address>(&mut payees, @0xbc65c01484943cf4e40b2fc1689d0e47);
      Vector::push_back<u64>(&mut amounts, 4183142798);
      
      Vector::push_back<address>(&mut payees, @0xf1ba01485ee64e2d705d4becb55a8aaf);
      Vector::push_back<u64>(&mut amounts, 293871598);
      
      Vector::push_back<address>(&mut payees, @0xbe4fcee53b5179ce85f5d4670c9b584b);
      Vector::push_back<u64>(&mut amounts, 1024110872);
      
      Vector::push_back<address>(&mut payees, @0xf76c0bec2582fa779f0c2513b3ebbe5f);
      Vector::push_back<u64>(&mut amounts, 3503392008);
      
      Vector::push_back<address>(&mut payees, @0x526af51e4169aa9c256be7f0b0417f88);
      Vector::push_back<u64>(&mut amounts, 1471357072);
      
      Vector::push_back<address>(&mut payees, @0xac9c11f794b2d3c88859416520e18be9);
      Vector::push_back<u64>(&mut amounts, 4114984472);
      
      Vector::push_back<address>(&mut payees, @0x25b8147908f7578a7e314d3d59dc70d6);
      Vector::push_back<u64>(&mut amounts, 4610696120);
      
      Vector::push_back<address>(&mut payees, @0x57602fe4487fd67a5311b19e49883862);
      Vector::push_back<u64>(&mut amounts, 2253447397);
      
      Vector::push_back<address>(&mut payees, @0xe40393ff95a37c139feb62894bf463a4);
      Vector::push_back<u64>(&mut amounts, 2476173470);
      
      Vector::push_back<address>(&mut payees, @0x566205a9095c2eed1f3e108ca5a973bb);
      Vector::push_back<u64>(&mut amounts, 1780629007);
      
      Vector::push_back<address>(&mut payees, @0x5aef99cc7bcc0ccdc26362c1a91d80a1);
      Vector::push_back<u64>(&mut amounts, 96687061);
      
      Vector::push_back<address>(&mut payees, @0x701acc3fe3784deee61485164f39cbe6);
      Vector::push_back<u64>(&mut amounts, 761589081);
      
      Vector::push_back<address>(&mut payees, @0xcf4a0ddb8d816fca7e080f8fdf94f0d1);
      Vector::push_back<u64>(&mut amounts, 2929612873);
      
      Vector::push_back<address>(&mut payees, @0x337c08fd81eb616f6f9d206ed83c6d36);
      Vector::push_back<u64>(&mut amounts, 2521567256);
      
      Vector::push_back<address>(&mut payees, @0x5e8e6985cf5181e1cc37bfa4765acb66);
      Vector::push_back<u64>(&mut amounts, 163498673);
      
      Vector::push_back<address>(&mut payees, @0x78d88ef8f6495154e37e6f49a5212518);
      Vector::push_back<u64>(&mut amounts, 157442548);
      
      Vector::push_back<address>(&mut payees, @0x3e1cf48283a3032e612e00e03887e70e);
      Vector::push_back<u64>(&mut amounts, 157442548);
      
      Vector::push_back<address>(&mut payees, @0xa382a1ce9c36de68095e91295ac2e064);
      Vector::push_back<u64>(&mut amounts, 273713771);
      
      Vector::push_back<address>(&mut payees, @0x26bebfe3c4dddada3de38184e1699a4b);
      Vector::push_back<u64>(&mut amounts, 38962353);
      
      Vector::push_back<address>(&mut payees, @0x863d4e76d1a0c4b4c54417fda716c1e5);
      Vector::push_back<u64>(&mut amounts, 27830252);
      
      Vector::push_back<address>(&mut payees, @0xa69eb81fc7f3c1f3bb08a7fed0cb282e);
      Vector::push_back<u64>(&mut amounts, 69575632);
      
      Vector::push_back<address>(&mut payees, @0x356253dddaf8e591b450e45842f065b9);
      Vector::push_back<u64>(&mut amounts, 7498727413);
      
      Vector::push_back<address>(&mut payees, @0xf120fb81dde9db4a1f81e0d01d2936e2);
      Vector::push_back<u64>(&mut amounts, 787651201);
      
      Vector::push_back<address>(&mut payees, @0x8c780583bbdbcb799965f3eb066c6599);
      Vector::push_back<u64>(&mut amounts, 2243960746);
      
      Vector::push_back<address>(&mut payees, @0xfc15d2ef11a36a46d8c752358abdc5e8);
      Vector::push_back<u64>(&mut amounts, 307459541);
      
      Vector::push_back<address>(&mut payees, @0x745ed219affdabb64fbd933f95f13bb3);
      Vector::push_back<u64>(&mut amounts, 2005725774);
      
      Vector::push_back<address>(&mut payees, @0x0335a07f574336f7fee792dbab5390f0);
      Vector::push_back<u64>(&mut amounts, 2724803652);
      
      Vector::push_back<address>(&mut payees, @0x4c70f4abb5410dc91c08380a13102c8b);
      Vector::push_back<u64>(&mut amounts, 611674730);
      
      Vector::push_back<address>(&mut payees, @0x1a88e2bf00882194ce06925770595156);
      Vector::push_back<u64>(&mut amounts, 1252618315);
      
      Vector::push_back<address>(&mut payees, @0x0971a136e483f5d9a7d4dbf9b20792c8);
      Vector::push_back<u64>(&mut amounts, 1127652988);
      
      Vector::push_back<address>(&mut payees, @0x3ebb82eff28b51ef1a7230d49ed2636e);
      Vector::push_back<u64>(&mut amounts, 4441731284);
      
      Vector::push_back<address>(&mut payees, @0x609ecce530ea3f138b7ab9355133b003);
      Vector::push_back<u64>(&mut amounts, 634654566);
      
      Vector::push_back<address>(&mut payees, @0x8c5381a2e4c6dbf06860c9e945446318);
      Vector::push_back<u64>(&mut amounts, 1351222918);
      
      Vector::push_back<address>(&mut payees, @0x87e5a9f29f82fc56ef1bca0f7376bae3);
      Vector::push_back<u64>(&mut amounts, 2191736358);
      
      Vector::push_back<address>(&mut payees, @0xc9f603b9a89feac61ce14d63c9889b3e);
      Vector::push_back<u64>(&mut amounts, 3135279862);
      
      Vector::push_back<address>(&mut payees, @0x0305316734355823cf430cc9e4ebd6b1);
      Vector::push_back<u64>(&mut amounts, 2682541106);
      
      Vector::push_back<address>(&mut payees, @0x381eb3cc143bb03a1344e0caea86389d);
      Vector::push_back<u64>(&mut amounts, 828198671);
      
      Vector::push_back<address>(&mut payees, @0xf5ba04dd4f51668382a69af48971db35);
      Vector::push_back<u64>(&mut amounts, 3600016329);
      
      Vector::push_back<address>(&mut payees, @0x37b712c4791592b667435dd76d51ff3f);
      Vector::push_back<u64>(&mut amounts, 1430568725);
      
      Vector::push_back<address>(&mut payees, @0x76a5088ef45546b6cb50e4b6c1080d2c);
      Vector::push_back<u64>(&mut amounts, 42983900);
      
      Vector::push_back<address>(&mut payees, @0xe4c2304f4304c54a4af8c42b4363decc);
      Vector::push_back<u64>(&mut amounts, 1111392861);
      
      Vector::push_back<address>(&mut payees, @0x936815a4dbe47f45092590c596dbd0d1);
      Vector::push_back<u64>(&mut amounts, 5193889228);
      
      Vector::push_back<address>(&mut payees, @0x496d983b8bc7ce68a837a015715b465e);
      Vector::push_back<u64>(&mut amounts, 951898400);
      
      Vector::push_back<address>(&mut payees, @0x1ee5432bd3c6374e33798c4c9edcd0cf);
      Vector::push_back<u64>(&mut amounts, 983240912);
      
      Vector::push_back<address>(&mut payees, @0x651d1e5c589c2731f19b0efe626f365c);
      Vector::push_back<u64>(&mut amounts, 300246878);
      
      Vector::push_back<address>(&mut payees, @0x9d3db73983b9af098d7e45d6604e74da);
      Vector::push_back<u64>(&mut amounts, 2736866941);
      
      Vector::push_back<address>(&mut payees, @0x3dd86c00c6a25cb669ae75339a6fe049);
      Vector::push_back<u64>(&mut amounts, 2082808986);
      
      Vector::push_back<address>(&mut payees, @0xc55fd00fc859ba7bcc97622172d14122);
      Vector::push_back<u64>(&mut amounts, 3356360093);
      
      Vector::push_back<address>(&mut payees, @0xc20b24247559ac4c89b0f2f7f4e56bad);
      Vector::push_back<u64>(&mut amounts, 3015188802);
      
      Vector::push_back<address>(&mut payees, @0xfb15ffd78f064b2bdcd85027ee44ecd5);
      Vector::push_back<u64>(&mut amounts, 2740512797);
      
      Vector::push_back<address>(&mut payees, @0x1a3f3a4be5b5cff0a1215f220056e4a9);
      Vector::push_back<u64>(&mut amounts, 2299022161);
      
      Vector::push_back<address>(&mut payees, @0x9841bdfdd149fe1f239a380f5362ea77);
      Vector::push_back<u64>(&mut amounts, 831848889);
      
      Vector::push_back<address>(&mut payees, @0x7d17191642de3886b926b46b7059af62);
      Vector::push_back<u64>(&mut amounts, 1207129303);
      
      Vector::push_back<address>(&mut payees, @0x2586b278375bc9ca7b9ec9d5173a4215);
      Vector::push_back<u64>(&mut amounts, 49096489);
      
      Vector::push_back<address>(&mut payees, @0xd103284d9ce3a9f45334da55a83c2f65);
      Vector::push_back<u64>(&mut amounts, 382684335);
      
      Vector::push_back<address>(&mut payees, @0xba2604ca9f85a994786156a49485fec7);
      Vector::push_back<u64>(&mut amounts, 1196665334);
      
      Vector::push_back<address>(&mut payees, @0x23bda1e1df1828f620351cec374e39b9);
      Vector::push_back<u64>(&mut amounts, 1488279669);
      
      Vector::push_back<address>(&mut payees, @0xc43403bb1fc120a5c06adf4b134c016e);
      Vector::push_back<u64>(&mut amounts, 3139981961);
      
      Vector::push_back<address>(&mut payees, @0xa53f2079388fdbac833b9888ea9c5147);
      Vector::push_back<u64>(&mut amounts, 2294458035);
      
      Vector::push_back<address>(&mut payees, @0xde3c462f7a5e0b84bccd44189f0e9f4e);
      Vector::push_back<u64>(&mut amounts, 101466079);
      
      Vector::push_back<address>(&mut payees, @0xbb102597338d8ecd1e8c5958eeeb9d80);
      Vector::push_back<u64>(&mut amounts, 242774577);
      
      Vector::push_back<address>(&mut payees, @0xf8133e9d223b275a655dcd1f33935969);
      Vector::push_back<u64>(&mut amounts, 136136152);
      
      Vector::push_back<address>(&mut payees, @0x1198cc0a920d3cf950de882a86055f99);
      Vector::push_back<u64>(&mut amounts, 2970124375);
      
      Vector::push_back<address>(&mut payees, @0x79c98bf94a010c423769a7e8e6c5fca3);
      Vector::push_back<u64>(&mut amounts, 1370236088);
      
      Vector::push_back<address>(&mut payees, @0x3580be96574497fcdfb8f5f37ebcea3a);
      Vector::push_back<u64>(&mut amounts, 42550291);
      
      Vector::push_back<address>(&mut payees, @0x69b25c69a437549afc3f3141933db622);
      Vector::push_back<u64>(&mut amounts, 26184794);
      
      Vector::push_back<address>(&mut payees, @0xcd78d4d4e8e6953e8ac09e16bed23884);
      Vector::push_back<u64>(&mut amounts, 49096489);
      
      Vector::push_back<address>(&mut payees, @0x3e6bd0ccfa50ffc99844af6d3203c758);
      Vector::push_back<u64>(&mut amounts, 26184794);
      
      Vector::push_back<address>(&mut payees, @0xd847876200e3d1e2af4210223478b1ba);
      Vector::push_back<u64>(&mut amounts, 103227422);
      
      Vector::push_back<address>(&mut payees, @0xb005b9a80f38596e2d25e5fa383a13d9);
      Vector::push_back<u64>(&mut amounts, 425788115);
      
      Vector::push_back<address>(&mut payees, @0xddfc4425e807e39b4a35c5712240622d);
      Vector::push_back<u64>(&mut amounts, 2009745049);
      
      Vector::push_back<address>(&mut payees, @0xc7a07ec703ab189e4cad2bb98edd75e0);
      Vector::push_back<u64>(&mut amounts, 5411993034);
      
      Vector::push_back<address>(&mut payees, @0xfff5ba0ef3aecf4ee08d43c64fe78cad);
      Vector::push_back<u64>(&mut amounts, 440265593);
      
      Vector::push_back<address>(&mut payees, @0xc515dd5d6a89564e1dd12f3164c8e5f0);
      Vector::push_back<u64>(&mut amounts, 737473572);
      
      Vector::push_back<address>(&mut payees, @0xe05f539c1ce78920916eb0f47efff3f8);
      Vector::push_back<u64>(&mut amounts, 1120618967);
      
      Vector::push_back<address>(&mut payees, @0x85fb1068528090d91993e48ff536041e);
      Vector::push_back<u64>(&mut amounts, 71397167);
      
      Vector::push_back<address>(&mut payees, @0xbdee80105673b0f60fa42b242ab83e80);
      Vector::push_back<u64>(&mut amounts, 1294221586);
      
      Vector::push_back<address>(&mut payees, @0x69ae8f3ee6e00b95b2159cdaf1d77174);
      Vector::push_back<u64>(&mut amounts, 2291662612);
      
      Vector::push_back<address>(&mut payees, @0x06afe592acc5bdb600c7a2da10ad32bf);
      Vector::push_back<u64>(&mut amounts, 859873435);
      
      Vector::push_back<address>(&mut payees, @0xd0d78ba195d72cea5b2b47276e4ac3c4);
      Vector::push_back<u64>(&mut amounts, 2005900556);
      
      Vector::push_back<address>(&mut payees, @0x2fdadcaf46532dfb8da1f6bb97a096c6);
      Vector::push_back<u64>(&mut amounts, 1453326231);
      
      Vector::push_back<address>(&mut payees, @0x2862bbd41cacd57be59ae4a6e8538e2f);
      Vector::push_back<u64>(&mut amounts, 1725182420);
      
      Vector::push_back<address>(&mut payees, @0xdefd1c2a93de6ea77f68629c9ae5edae);
      Vector::push_back<u64>(&mut amounts, 3710672226);
      
      Vector::push_back<address>(&mut payees, @0x2d8a54adfe928343dd4b45b737331a2d);
      Vector::push_back<u64>(&mut amounts, 292192259);
      
      Vector::push_back<address>(&mut payees, @0xf4535ec1bcf2bf32359d87be2e2692b3);
      Vector::push_back<u64>(&mut amounts, 604905072);
      
      Vector::push_back<address>(&mut payees, @0x6944f2635a3e8b711828ecf0b00327f1);
      Vector::push_back<u64>(&mut amounts, 1413212865);
      
      Vector::push_back<address>(&mut payees, @0x2bd8e0da4a77aebb45224de9262bcc8e);
      Vector::push_back<u64>(&mut amounts, 2034651081);
      
      Vector::push_back<address>(&mut payees, @0x19b0abd3d2c954c07a391be6ed93d96e);
      Vector::push_back<u64>(&mut amounts, 371076280);
      
      Vector::push_back<address>(&mut payees, @0x39c91a8b46f70723c4822784c7dc25b9);
      Vector::push_back<u64>(&mut amounts, 1353089977);
      
      Vector::push_back<address>(&mut payees, @0x6c515401980356781f0dbcb143fc9678);
      Vector::push_back<u64>(&mut amounts, 1026189940);
      
      Vector::push_back<address>(&mut payees, @0xdd81d333de6d2486bf22d4c045afbbf0);
      Vector::push_back<u64>(&mut amounts, 2116383577);
      
      Vector::push_back<address>(&mut payees, @0xc9ea481973882b05990ba5ca131b9abf);
      Vector::push_back<u64>(&mut amounts, 88637957);
      
      Vector::push_back<address>(&mut payees, @0xc06db6aff14277ffa00262b7c3d70300);
      Vector::push_back<u64>(&mut amounts, 888378777);
      
      Vector::push_back<address>(&mut payees, @0xe1db17a42a142c693ba4c182a1524ae0);
      Vector::push_back<u64>(&mut amounts, 1179319958);
      
      Vector::push_back<address>(&mut payees, @0x6a7872ee8e13916dc48273b110a09c6f);
      Vector::push_back<u64>(&mut amounts, 109538761);
      
      Vector::push_back<address>(&mut payees, @0x670c87a649d065fd7e6dd6d55ece5bef);
      Vector::push_back<u64>(&mut amounts, 838023113);
      
      Vector::push_back<address>(&mut payees, @0xa7c07a0d72c5237850d1c9270acc2b93);
      Vector::push_back<u64>(&mut amounts, 305440544);
      
      Vector::push_back<address>(&mut payees, @0x467c1be36b3e8560b42e97e51bfd1ad2);
      Vector::push_back<u64>(&mut amounts, 310200082);
      
      Vector::push_back<address>(&mut payees, @0x8b0f9aeb59e263168d2823262fb59ff9);
      Vector::push_back<u64>(&mut amounts, 555438915);
      
      Vector::push_back<address>(&mut payees, @0x54e716e58162eec975dcb0a6dc9d0827);
      Vector::push_back<u64>(&mut amounts, 5292742807);
      
      Vector::push_back<address>(&mut payees, @0x7dab3e6cee6b6ba33c3a13f70f7b6a6a);
      Vector::push_back<u64>(&mut amounts, 1242401161);
      
      Vector::push_back<address>(&mut payees, @0x0696df4c183dc15bdf1d197f0d34130a);
      Vector::push_back<u64>(&mut amounts, 769674683);
      
      Vector::push_back<address>(&mut payees, @0x0c40862363b87f4d62b36f49e007809a);
      Vector::push_back<u64>(&mut amounts, 68968850);
      
      Vector::push_back<address>(&mut payees, @0x66146304f5d1fd84a92322c648769041);
      Vector::push_back<u64>(&mut amounts, 270660023);
      
      Vector::push_back<address>(&mut payees, @0x5322609dde43e08ad6da6964574941fd);
      Vector::push_back<u64>(&mut amounts, 711701743);
      
      Vector::push_back<address>(&mut payees, @0xd1281de242839fc939745996882c5fc2);
      Vector::push_back<u64>(&mut amounts, 3013251338);
      
      Vector::push_back<address>(&mut payees, @0xe486fc16d1a4d308cebd4844d5610421);
      Vector::push_back<u64>(&mut amounts, 443303378);
      
      Vector::push_back<address>(&mut payees, @0xf2e4e4bbfd6eaa2659cd2783483ee968);
      Vector::push_back<u64>(&mut amounts, 2554087718);
      
      Vector::push_back<address>(&mut payees, @0x74c5ee8633848c45fec005daabc5dd69);
      Vector::push_back<u64>(&mut amounts, 2704263070);
      
      Vector::push_back<address>(&mut payees, @0xa22ab6e8b3432c84c9583b4ce5f43ca4);
      Vector::push_back<u64>(&mut amounts, 1822736197);
      
      Vector::push_back<address>(&mut payees, @0x4fdf365bd3758f65208392d4da9505a5);
      Vector::push_back<u64>(&mut amounts, 360238843);
      
      Vector::push_back<address>(&mut payees, @0xf665db732c3c48b533df1c7907c3a235);
      Vector::push_back<u64>(&mut amounts, 2419643722);
      
      Vector::push_back<address>(&mut payees, @0x443059c81a0c95795adc6028d5c8f4c2);
      Vector::push_back<u64>(&mut amounts, 2559897947);
      
      Vector::push_back<address>(&mut payees, @0xa407e821f2cf7ef8172530334a8436df);
      Vector::push_back<u64>(&mut amounts, 915957207);
      
      Vector::push_back<address>(&mut payees, @0x183bce2aa2d5f9bc4db2d22dc8e9848c);
      Vector::push_back<u64>(&mut amounts, 2263583648);
      
      Vector::push_back<address>(&mut payees, @0xee3d5047ac1466cc5726b3eea3165d57);
      Vector::push_back<u64>(&mut amounts, 2772750251);
      
      Vector::push_back<address>(&mut payees, @0x5a39ea5b1677a283c337bd72aef8037b);
      Vector::push_back<u64>(&mut amounts, 1662288885);
      
      Vector::push_back<address>(&mut payees, @0xa5a5c040dc2cd58a9b106c4c1bf27311);
      Vector::push_back<u64>(&mut amounts, 342031562);
      
      Vector::push_back<address>(&mut payees, @0x09c1759c8a95b93aafa0637f4666c3e6);
      Vector::push_back<u64>(&mut amounts, 3174074520);
      
      Vector::push_back<address>(&mut payees, @0xfa4a9d8207cecc8058f219eeddc0b08b);
      Vector::push_back<u64>(&mut amounts, 2295924275);
      
      Vector::push_back<address>(&mut payees, @0xbf9874aa2127732d09445159473aa885);
      Vector::push_back<u64>(&mut amounts, 2023799943);
      
      Vector::push_back<address>(&mut payees, @0x8566dcda547dd9cdd7429dc3f6b5abba);
      Vector::push_back<u64>(&mut amounts, 186563545);
      
      Vector::push_back<address>(&mut payees, @0x80e91030c286aecff5fe7b10d5cb823f);
      Vector::push_back<u64>(&mut amounts, 47595377);
      
      Vector::push_back<address>(&mut payees, @0x0b65e6335d5d43ff49f3c07b67c4eb82);
      Vector::push_back<u64>(&mut amounts, 1657190339);
      
      Vector::push_back<address>(&mut payees, @0x5fe62d5e83bdc8adb8431f8024ce47cf);
      Vector::push_back<u64>(&mut amounts, 437718042);
      
      Vector::push_back<address>(&mut payees, @0xec319e54d882df127d469e471a890c5e);
      Vector::push_back<u64>(&mut amounts, 624594969);
      
      Vector::push_back<address>(&mut payees, @0x7e86731d1fab8c00b4e483fc4abea0cd);
      Vector::push_back<u64>(&mut amounts, 195900105);
      
      Vector::push_back<address>(&mut payees, @0xab9afcf95d49c9a0e5bcd8ed63f4e7e0);
      Vector::push_back<u64>(&mut amounts, 1918031383);
      
      Vector::push_back<address>(&mut payees, @0x6bcf631a547f45f03a97cae784bdd7ad);
      Vector::push_back<u64>(&mut amounts, 1880433631);
      
      Vector::push_back<address>(&mut payees, @0x7a90fb0f2fe2efc7e278559343c798fe);
      Vector::push_back<u64>(&mut amounts, 612611329);
      
      Vector::push_back<address>(&mut payees, @0xde4067743e3df467a0c652e446ef667f);
      Vector::push_back<u64>(&mut amounts, 133267056);
      
      Vector::push_back<address>(&mut payees, @0x6fe668b6e8563fd1898c41f8778618a6);
      Vector::push_back<u64>(&mut amounts, 118988443);
      
      Vector::push_back<address>(&mut payees, @0xba94d3a4dc7e3239b5b216d552319312);
      Vector::push_back<u64>(&mut amounts, 2882317360);
      
      Vector::push_back<address>(&mut payees, @0x39dd94372b6dd96e6a6e93f20ea0ca71);
      Vector::push_back<u64>(&mut amounts, 3886857242);
      
      Vector::push_back<address>(&mut payees, @0x97b30b99bfeb8abb2b732fb6160bffa8);
      Vector::push_back<u64>(&mut amounts, 4828153425);
      
      Vector::push_back<address>(&mut payees, @0xc28ebc733f8656871f37991f17202a08);
      Vector::push_back<u64>(&mut amounts, 2930006300);
      
      Vector::push_back<address>(&mut payees, @0x3ab7ea7fe8924b6c7fcea1b6f32dc915);
      Vector::push_back<u64>(&mut amounts, 3564571816);
      
      Vector::push_back<address>(&mut payees, @0x832604cc4c99a11e5d4b53f1ec5ab1b9);
      Vector::push_back<u64>(&mut amounts, 848064279);
      
      Vector::push_back<address>(&mut payees, @0x7da0f75c03c29b87e5020726fa87799b);
      Vector::push_back<u64>(&mut amounts, 1304071220);
      
      Vector::push_back<address>(&mut payees, @0xe2cbfef1291d2b4ba4bcd885aa5d0ea2);
      Vector::push_back<u64>(&mut amounts, 1405035425);
      
      Vector::push_back<address>(&mut payees, @0x8c384a0e13ae0146b7523e0d3f61aade);
      Vector::push_back<u64>(&mut amounts, 3128995917);
      
      Vector::push_back<address>(&mut payees, @0x18f68861b5135f9403697f38b071a224);
      Vector::push_back<u64>(&mut amounts, 360061857);
      
      Vector::push_back<address>(&mut payees, @0x0be09c08e90ef1f16f47c260361c4083);
      Vector::push_back<u64>(&mut amounts, 1751736848);
      
      Vector::push_back<address>(&mut payees, @0x3b0756f858acbac83e93ec547662f212);
      Vector::push_back<u64>(&mut amounts, 2581795677);
      
      Vector::push_back<address>(&mut payees, @0x564efb7f46385bb208dcb1a1fa35af50);
      Vector::push_back<u64>(&mut amounts, 1968044607);
      
      Vector::push_back<address>(&mut payees, @0xc6b2f8f04e93ed57d79bfe25ed5d4679);
      Vector::push_back<u64>(&mut amounts, 360489028);
      
      Vector::push_back<address>(&mut payees, @0x3da8baa9781ac7c81141086328a18e6d);
      Vector::push_back<u64>(&mut amounts, 2105708071);
      
      Vector::push_back<address>(&mut payees, @0x309dd5625ca4919040b19e855dcb1830);
      Vector::push_back<u64>(&mut amounts, 309767743);
      
      Vector::push_back<address>(&mut payees, @0xd8c92ba28f2b666e65b6d84b49e0687c);
      Vector::push_back<u64>(&mut amounts, 2896990273);
      
      Vector::push_back<address>(&mut payees, @0xa94b0d050931d3266958b01fdcdb9a5f);
      Vector::push_back<u64>(&mut amounts, 2619682853);
      
      Vector::push_back<address>(&mut payees, @0xf7e52a701b995ed934f90aec5f0445b2);
      Vector::push_back<u64>(&mut amounts, 111887859);
      
      Vector::push_back<address>(&mut payees, @0x8561ac55040290230eade692b27cebb6);
      Vector::push_back<u64>(&mut amounts, 321439759);
      
      Vector::push_back<address>(&mut payees, @0x74ffec7f2075c9499ea8ece51e61a2fa);
      Vector::push_back<u64>(&mut amounts, 2373992004);
      
      Vector::push_back<address>(&mut payees, @0xd48ab09f3b76199d08763ade68a20f2a);
      Vector::push_back<u64>(&mut amounts, 1312201959);
      
      Vector::push_back<address>(&mut payees, @0xe367a0b3cf8b289021e971801595b8d0);
      Vector::push_back<u64>(&mut amounts, 958201230);
      
      Vector::push_back<address>(&mut payees, @0x33ffe6dbba1ec1ea29441c04acabeeaa);
      Vector::push_back<u64>(&mut amounts, 660279703);
      
      Vector::push_back<address>(&mut payees, @0x2942480bec5e3e7acfb23f3d8c556759);
      Vector::push_back<u64>(&mut amounts, 1470839623);
      
      Vector::push_back<address>(&mut payees, @0x4f00d1aea3cb34dcc7712d8076f49c72);
      Vector::push_back<u64>(&mut amounts, 505948476);
      
      Vector::push_back<address>(&mut payees, @0x8c75af87eef71efd3931a490128fbae8);
      Vector::push_back<u64>(&mut amounts, 2267483019);
      
      Vector::push_back<address>(&mut payees, @0xe897ce8edecc42472de53ed91bc40d2d);
      Vector::push_back<u64>(&mut amounts, 186735010);
      
      Vector::push_back<address>(&mut payees, @0x03ce125aa323e54d84c98f9267e19ba1);
      Vector::push_back<u64>(&mut amounts, 186735010);
      
      Vector::push_back<address>(&mut payees, @0x9d1ad001bb1a77d6deebee8eb206596c);
      Vector::push_back<u64>(&mut amounts, 5321375433);
      
      Vector::push_back<address>(&mut payees, @0xba0a294a1f1783664870f59759b8196c);
      Vector::push_back<u64>(&mut amounts, 780945005);
      
      Vector::push_back<address>(&mut payees, @0x5bc976e3de1e06981f1650f2e55b2fdc);
      Vector::push_back<u64>(&mut amounts, 4886770879);
      
      Vector::push_back<address>(&mut payees, @0x3b46aae6af492da480b54f3291f1f615);
      Vector::push_back<u64>(&mut amounts, 672541213);
      
      Vector::push_back<address>(&mut payees, @0x79d43b848bf53c5667320bfdc35b5e97);
      Vector::push_back<u64>(&mut amounts, 102003843);
      
      Vector::push_back<address>(&mut payees, @0xb0d946069e0aa6a04b7f9ba1459f014a);
      Vector::push_back<u64>(&mut amounts, 141139668);
      
      Vector::push_back<address>(&mut payees, @0x212d2a49cc77e85c6cf55cba69019330);
      Vector::push_back<u64>(&mut amounts, 2833436379);
      
      Vector::push_back<address>(&mut payees, @0x21a6c8382e1aa25acceb73828b5aaeb7);
      Vector::push_back<u64>(&mut amounts, 2740123156);
      
      Vector::push_back<address>(&mut payees, @0x18be19b27fd89449f7e2fa8ecc3e9072);
      Vector::push_back<u64>(&mut amounts, 583026392);
      
      Vector::push_back<address>(&mut payees, @0xbc6f878c1ee0ca73c76983a2848c55ef);
      Vector::push_back<u64>(&mut amounts, 2627342447);
      
      Vector::push_back<address>(&mut payees, @0x45a517866fea45155306ef9ca27c3d18);
      Vector::push_back<u64>(&mut amounts, 2232335369);
      
      Vector::push_back<address>(&mut payees, @0x66a7a4d0a8436ec6c5c0028171ea36f8);
      Vector::push_back<u64>(&mut amounts, 3229342417);
      
      Vector::push_back<address>(&mut payees, @0x6970ab659da3b07904faceefa990c3ee);
      Vector::push_back<u64>(&mut amounts, 2200544147);
      
      Vector::push_back<address>(&mut payees, @0x1dc00ba10fe062f5eb942681dc51b8a4);
      Vector::push_back<u64>(&mut amounts, 1148950920);
      
      Vector::push_back<address>(&mut payees, @0x624228cd0e7accb1c881d7f5c1de2f99);
      Vector::push_back<u64>(&mut amounts, 159799012);
      
      Vector::push_back<address>(&mut payees, @0x3a44a04b10ecac2c153cdd4471f5ed84);
      Vector::push_back<u64>(&mut amounts, 126737147);
      
      Vector::push_back<address>(&mut payees, @0x70e5e93a5dfa51a485061bb4d920345c);
      Vector::push_back<u64>(&mut amounts, 916781741);
      
      Vector::push_back<address>(&mut payees, @0x87a3f098b430c9f7945b170c1329cd3a);
      Vector::push_back<u64>(&mut amounts, 1151652629);
      
      Vector::push_back<address>(&mut payees, @0xaf0af133760e7004c9c6709f28e33123);
      Vector::push_back<u64>(&mut amounts, 1345480592);
      
      Vector::push_back<address>(&mut payees, @0x838783b4c7eb4e5774581ccf17fb520f);
      Vector::push_back<u64>(&mut amounts, 604426726);
      
      Vector::push_back<address>(&mut payees, @0x3bc8f03ab6281ad21ffb837d6a7087a5);
      Vector::push_back<u64>(&mut amounts, 2284241957);
      
      Vector::push_back<address>(&mut payees, @0x420a7f71a4d32e12a4afcc78b2187932);
      Vector::push_back<u64>(&mut amounts, 1767189139);
      
      Vector::push_back<address>(&mut payees, @0x7e92808e93a8712eb42169cce1d05165);
      Vector::push_back<u64>(&mut amounts, 1983738609);
      
      Vector::push_back<address>(&mut payees, @0xf8486337d6daaee4f9447ab5bbbeeaa9);
      Vector::push_back<u64>(&mut amounts, 436021748);
      
      Vector::push_back<address>(&mut payees, @0xb92065dee2fd3fc8aab0b09a02eccc0e);
      Vector::push_back<u64>(&mut amounts, 409029295);
      
      Vector::push_back<address>(&mut payees, @0xa8083c27206027b91e44e87960cf29cd);
      Vector::push_back<u64>(&mut amounts, 77144350);
      
      Vector::push_back<address>(&mut payees, @0x012338b54ba4625adcc313394d87819c);
      Vector::push_back<u64>(&mut amounts, 1492004627);
      
      Vector::push_back<address>(&mut payees, @0x1b374b6a02c7756ecca208882ab595f6);
      Vector::push_back<u64>(&mut amounts, 2064160248);
      
      Vector::push_back<address>(&mut payees, @0xfde0d9f17aac89025128bf93d63eb24e);
      Vector::push_back<u64>(&mut amounts, 1531075079);
      
      Vector::push_back<address>(&mut payees, @0x190a4da3806aa068a2800b55202610b0);
      Vector::push_back<u64>(&mut amounts, 539972449);
      
      Vector::push_back<address>(&mut payees, @0xbea003633af9b78435bc0b3fe126cc34);
      Vector::push_back<u64>(&mut amounts, 192732504);
      
      Vector::push_back<address>(&mut payees, @0xd88b85766c5ae80b8df9142c4c60ec93);
      Vector::push_back<u64>(&mut amounts, 42297540);
      
      Vector::push_back<address>(&mut payees, @0xdee8b784c09c92477d1ded97828f0a3a);
      Vector::push_back<u64>(&mut amounts, 677107689);
      
      Vector::push_back<address>(&mut payees, @0xfb8911465fd98d696d071222e108b4ae);
      Vector::push_back<u64>(&mut amounts, 281888265);
      
      Vector::push_back<address>(&mut payees, @0x6d9fa1f3ad5254a131f0979dbf3536bf);
      Vector::push_back<u64>(&mut amounts, 1373268980);
      
      Vector::push_back<address>(&mut payees, @0x4fd92b5f6f162ae75e313c79b543569b);
      Vector::push_back<u64>(&mut amounts, 2199459035);
      
      Vector::push_back<address>(&mut payees, @0x707f6a3ec98665e0fa1b8fa4fccfe43e);
      Vector::push_back<u64>(&mut amounts, 841065417);
      
      Vector::push_back<address>(&mut payees, @0x8c199eb0864f1816c51efdfe4e0735a1);
      Vector::push_back<u64>(&mut amounts, 651171445);
      
      Vector::push_back<address>(&mut payees, @0x007c78cbc00cb5072a18468f456cf37c);
      Vector::push_back<u64>(&mut amounts, 217291901);
      
      Vector::push_back<address>(&mut payees, @0x64cc45cc5eb3a442a7e827aaf3be1bd2);
      Vector::push_back<u64>(&mut amounts, 150493961);
      
      Vector::push_back<address>(&mut payees, @0xa5b889e73517feb6ad838b8f3dda3a53);
      Vector::push_back<u64>(&mut amounts, 706522572);
      
      Vector::push_back<address>(&mut payees, @0xbb5df71f7b3f210fe65d1544011d8256);
      Vector::push_back<u64>(&mut amounts, 757850897);
      
      Vector::push_back<address>(&mut payees, @0xc0a164a9b35e28fdeb8cf5716617aded);
      Vector::push_back<u64>(&mut amounts, 706506653);
      
      Vector::push_back<address>(&mut payees, @0x8e5d31869951193c7eff55646b5e6275);
      Vector::push_back<u64>(&mut amounts, 1051365391);
      
      Vector::push_back<address>(&mut payees, @0x5f5d7a667a32d2b222abec582b0a4b71);
      Vector::push_back<u64>(&mut amounts, 739591138);
      
      Vector::push_back<address>(&mut payees, @0x26a02e71afa943b38feb4505e044d3db);
      Vector::push_back<u64>(&mut amounts, 673920759);
      
      Vector::push_back<address>(&mut payees, @0x21b48df727add6d7eb6535a6a1d798ed);
      Vector::push_back<u64>(&mut amounts, 440479662);
      
      Vector::push_back<address>(&mut payees, @0x5362e7dfa82f40e95979b1434839fb06);
      Vector::push_back<u64>(&mut amounts, 130020101);
      
      Vector::push_back<address>(&mut payees, @0xc2f8d9e6f56c90c0d84add716bda419c);
      Vector::push_back<u64>(&mut amounts, 177874799);
      
      Vector::push_back<address>(&mut payees, @0x94e394fc39c32e2fe3b860be1909adb3);
      Vector::push_back<u64>(&mut amounts, 570944721);
      
      Vector::push_back<address>(&mut payees, @0x2ba33df6aff43bf1657ed6c62456d738);
      Vector::push_back<u64>(&mut amounts, 1091475427);
      
      Vector::push_back<address>(&mut payees, @0xcf979e2f500957f6f65c44fc7c895fd3);
      Vector::push_back<u64>(&mut amounts, 1095656858);
      
      Vector::push_back<address>(&mut payees, @0x6775f83c3221e1828664d9f9f72ec299);
      Vector::push_back<u64>(&mut amounts, 871051980);
      
      Vector::push_back<address>(&mut payees, @0x3e9ba68d01ea00973de1e13786b15b8d);
      Vector::push_back<u64>(&mut amounts, 1161030781);
      
      Vector::push_back<address>(&mut payees, @0x2f935200e3ae7af3cd26622914a3e6b8);
      Vector::push_back<u64>(&mut amounts, 1277976376);
      
      Vector::push_back<address>(&mut payees, @0x19c63156ed98c4c2d811640ca26c7168);
      Vector::push_back<u64>(&mut amounts, 1481337683);
      
      Vector::push_back<address>(&mut payees, @0xc989d6aff63238aff15d7e0f85fb649c);
      Vector::push_back<u64>(&mut amounts, 63446311);
      
      Vector::push_back<address>(&mut payees, @0x7d235226b3be86534cc0dc22f07057b3);
      Vector::push_back<u64>(&mut amounts, 105743852);
      
      Vector::push_back<address>(&mut payees, @0xbe0ed478a4c8b2a251c9e9b3a7f6cecd);
      Vector::push_back<u64>(&mut amounts, 2080363188);
      
      Vector::push_back<address>(&mut payees, @0x0dc4c653af0cf3d0cf6a362875e08560);
      Vector::push_back<u64>(&mut amounts, 792385236);
      
      Vector::push_back<address>(&mut payees, @0xcad8ecf44f7ab46269cbe65c380dcd7a);
      Vector::push_back<u64>(&mut amounts, 111031044);
      
      Vector::push_back<address>(&mut payees, @0x1aecc6c0a4fcb6b60cbb0451cf7e9189);
      Vector::push_back<u64>(&mut amounts, 717014905);
      
      Vector::push_back<address>(&mut payees, @0xa5b75480d3684aaf25eafcc27b4e14ac);
      Vector::push_back<u64>(&mut amounts, 546532024);
      
      Vector::push_back<address>(&mut payees, @0x991cd317a3377fa503d015daabebb222);
      Vector::push_back<u64>(&mut amounts, 170291003);
      
      Vector::push_back<address>(&mut payees, @0xbe2a79018cb8ba8cd00a76f57acfb8eb);
      Vector::push_back<u64>(&mut amounts, 170291003);
      
      Vector::push_back<address>(&mut payees, @0x0965e50fc1a4595a1943d04c1cf80d1e);
      Vector::push_back<u64>(&mut amounts, 114968416);
      
      Vector::push_back<address>(&mut payees, @0xa8a0f3d2a1300dd76ada5897690f2f44);
      Vector::push_back<u64>(&mut amounts, 2612211960);
      
      Vector::push_back<address>(&mut payees, @0x15afa8ecd28e0aceb5aae4fcf2d875a5);
      Vector::push_back<u64>(&mut amounts, 265192413);
      
      Vector::push_back<address>(&mut payees, @0x0cd95aaf74ad2d64863955e313d7e0b5);
      Vector::push_back<u64>(&mut amounts, 303488124);
      
      Vector::push_back<address>(&mut payees, @0x36844de45800c6b74759641f8bdc5c06);
      Vector::push_back<u64>(&mut amounts, 95169466);
      
      Vector::push_back<address>(&mut payees, @0x5f83259b09309cc5fd8f1255ace9acb0);
      Vector::push_back<u64>(&mut amounts, 95169466);
      
      Vector::push_back<address>(&mut payees, @0x572180fc136c8d6894663bdaa8692b5e);
      Vector::push_back<u64>(&mut amounts, 95169466);
      
      Vector::push_back<address>(&mut payees, @0x78e0a5c5528cf0435b8da6a734f04740);
      Vector::push_back<u64>(&mut amounts, 95169466);
      
      Vector::push_back<address>(&mut payees, @0xf77098d9ad27a2b1dd0e5af1fdd39686);
      Vector::push_back<u64>(&mut amounts, 95169466);
      
      Vector::push_back<address>(&mut payees, @0x60624e9f5540f8f3b87a17cadda97a60);
      Vector::push_back<u64>(&mut amounts, 330258510);
      
      Vector::push_back<address>(&mut payees, @0x14e74a5ab5d18d754645bcccffa1549e);
      Vector::push_back<u64>(&mut amounts, 330258510);
      
      Vector::push_back<address>(&mut payees, @0x31f9fa057cfdbc9c74ff5148215b8ee8);
      Vector::push_back<u64>(&mut amounts, 236033918);
      
      Vector::push_back<address>(&mut payees, @0xe593f97c954e3b171dfe806047525212);
      Vector::push_back<u64>(&mut amounts, 246338339);
      
      Vector::push_back<address>(&mut payees, @0x7633613f7dbcb48cd059a28d1d204bed);
      Vector::push_back<u64>(&mut amounts, 299075283);
      
      Vector::push_back<address>(&mut payees, @0xa2cf4447a0366e3e759941372bd58254);
      Vector::push_back<u64>(&mut amounts, 241186128);
      
      Vector::push_back<address>(&mut payees, @0xc28e0d23f558443f857639ab5f0400d3);
      Vector::push_back<u64>(&mut amounts, 330393492);
      
      Vector::push_back<address>(&mut payees, @0x412cb2c20862cf52ca6f0ec10c41fb46);
      Vector::push_back<u64>(&mut amounts, 241186128);
      
      Vector::push_back<address>(&mut payees, @0xe001da67b36ed1f0bb9fb9136d4d3d27);
      Vector::push_back<u64>(&mut amounts, 304227493);
      
      Vector::push_back<address>(&mut payees, @0x063e3e8591d629e5ec3b0c8ee38b18ee);
      Vector::push_back<u64>(&mut amounts, 298940300);
      
      Vector::push_back<address>(&mut payees, @0xd93363d4327c6a5e31460e7e08f28b30);
      Vector::push_back<u64>(&mut amounts, 111031044);
      
      Vector::push_back<address>(&mut payees, @0xf7628effd01ed47257bc2ae511156376);
      Vector::push_back<u64>(&mut amounts, 105743852);
      
      Vector::push_back<address>(&mut payees, @0x6530d26b82e956e2223592f8fcab6773);
      Vector::push_back<u64>(&mut amounts, 132179815);
      
      Vector::push_back<address>(&mut payees, @0x1477143c64fcacfe202b3ce54ce3d1f0);
      Vector::push_back<u64>(&mut amounts, 121605430);
      
      Vector::push_back<address>(&mut payees, @0x79140ee9da907d996970512083f7b754);
      Vector::push_back<u64>(&mut amounts, 121605430);
      
      Vector::push_back<address>(&mut payees, @0x81508f1da5725acb6a9543b079fdff22);
      Vector::push_back<u64>(&mut amounts, 132179815);
      
      Vector::push_back<address>(&mut payees, @0xe3b25060c607f3860cfc5f9f439ddbab);
      Vector::push_back<u64>(&mut amounts, 132179815);
      
      Vector::push_back<address>(&mut payees, @0xac8c15091ef74c88b21f1ed100b0c41e);
      Vector::push_back<u64>(&mut amounts, 121605430);
      
      Vector::push_back<address>(&mut payees, @0xb1d65558c142476aa662ded0e558dd28);
      Vector::push_back<u64>(&mut amounts, 79307889);
      
      Vector::push_back<address>(&mut payees, @0x2f708bb40e873b800a8baa37fbd9dec3);
      Vector::push_back<u64>(&mut amounts, 95169466);
      
      Vector::push_back<address>(&mut payees, @0x5dbdce4469734d7e4c493f82c697b65e);
      Vector::push_back<u64>(&mut amounts, 79307889);
      
      Vector::push_back<address>(&mut payees, @0x398aca6d1776d9198aacb58a3e54739b);
      Vector::push_back<u64>(&mut amounts, 95169466);
      
      Vector::push_back<address>(&mut payees, @0xa916bd714d340580454f1402f6331998);
      Vector::push_back<u64>(&mut amounts, 95169466);
      
      Vector::push_back<address>(&mut payees, @0x85739d6e8311282c1311066d0ddedb49);
      Vector::push_back<u64>(&mut amounts, 79307889);
      
      Vector::push_back<address>(&mut payees, @0x5561386d49c0fb0cc02677f7eef9e5d0);
      Vector::push_back<u64>(&mut amounts, 549809378);
      
      Vector::push_back<address>(&mut payees, @0xe1c6a5305b14303f6e0ec944abde98e1);
      Vector::push_back<u64>(&mut amounts, 1079629550);
      
      Vector::push_back<address>(&mut payees, @0x26409326e1c1dc3e9ea7e05830011732);
      Vector::push_back<u64>(&mut amounts, 1236639687);
      
      Vector::push_back<address>(&mut payees, @0xb4e86dc0bf0826d5e1688c4f33bddbe8);
      Vector::push_back<u64>(&mut amounts, 3482845504);
      
      Vector::push_back<address>(&mut payees, @0x2d22e43c133e7c7bb591b8969eac9773);
      Vector::push_back<u64>(&mut amounts, 807401018);
      
      Vector::push_back<address>(&mut payees, @0x710fadc7f76f5d8b03a13a0652d32067);
      Vector::push_back<u64>(&mut amounts, 1251360309);
      
      Vector::push_back<address>(&mut payees, @0x955b4bc0d3d9bb0c828ed5159153a2d5);
      Vector::push_back<u64>(&mut amounts, 740863993);
      
      Vector::push_back<address>(&mut payees, @0xb893c75d9bd71fa4c3d8db80733982f7);
      Vector::push_back<u64>(&mut amounts, 2043044518);
      
      Vector::push_back<address>(&mut payees, @0x2993bb2aba2df994dfeae947dcbb093c);
      Vector::push_back<u64>(&mut amounts, 567384147);
      
      Vector::push_back<address>(&mut payees, @0x75f96fdf941c32b0885df7cf4045694d);
      Vector::push_back<u64>(&mut amounts, 1916037294);
      
      Vector::push_back<address>(&mut payees, @0x745c23c306e8389bc5b9903b57534c62);
      Vector::push_back<u64>(&mut amounts, 2212318682);
      
      Vector::push_back<address>(&mut payees, @0xa6e49b895161b694055c4f606a7b76ef);
      Vector::push_back<u64>(&mut amounts, 1134753197);
      
      Vector::push_back<address>(&mut payees, @0xf93810ede1d786ae616045980cb3593c);
      Vector::push_back<u64>(&mut amounts, 212795372);
      
      Vector::push_back<address>(&mut payees, @0x836f25d105ac03cd45344ce4fa08c506);
      Vector::push_back<u64>(&mut amounts, 749659857);
      
      Vector::push_back<address>(&mut payees, @0x8a123eff5292e53a48307d6d9b61598a);
      Vector::push_back<u64>(&mut amounts, 41217684);
      
      Vector::push_back<address>(&mut payees, @0x519b2f57991329298ce3747ca5fff38b);
      Vector::push_back<u64>(&mut amounts, 1906923692);
      
      Vector::push_back<address>(&mut payees, @0xaa78c3bc1b11b4e594e60c8a79211b6c);
      Vector::push_back<u64>(&mut amounts, 686639854);
      
      Vector::push_back<address>(&mut payees, @0x723d686c39f140725029998909d28a87);
      Vector::push_back<u64>(&mut amounts, 2890439660);
      
      Vector::push_back<address>(&mut payees, @0x46eab336f65114d9eef10c6df0bf1580);
      Vector::push_back<u64>(&mut amounts, 3236155337);
      
      Vector::push_back<address>(&mut payees, @0xbade1d1dbd56280fd7e6e3497e99bd81);
      Vector::push_back<u64>(&mut amounts, 2281346649);
      
      Vector::push_back<address>(&mut payees, @0xa8eec46c77c57afa2e15de7ca24b684b);
      Vector::push_back<u64>(&mut amounts, 159469687);
      
      Vector::push_back<address>(&mut payees, @0x58275e8a2f12ed4f7a97780b73a0e1c5);
      Vector::push_back<u64>(&mut amounts, 1240420333);
      
      Vector::push_back<address>(&mut payees, @0x649ab0c973c91499d6d9af73e9dc7717);
      Vector::push_back<u64>(&mut amounts, 1270999223);
      
      Vector::push_back<address>(&mut payees, @0x2784171e14d5862750e0e32c2164d23e);
      Vector::push_back<u64>(&mut amounts, 1423906132);
      
      Vector::push_back<address>(&mut payees, @0xe7ad4b7bb92f5298f89d7326717250ea);
      Vector::push_back<u64>(&mut amounts, 332349577);
      
      Vector::push_back<address>(&mut payees, @0x831c7329a926754730580c665e7825df);
      Vector::push_back<u64>(&mut amounts, 940745811);
      
      Vector::push_back<address>(&mut payees, @0x48ad6e428e2029946fc71a23a5180b42);
      Vector::push_back<u64>(&mut amounts, 347640469);
      
      Vector::push_back<address>(&mut payees, @0xdb3729f10e7da352755b48ae26bd2a7c);
      Vector::push_back<u64>(&mut amounts, 51522105);
      
      Vector::push_back<address>(&mut payees, @0xd62bee0189da956e197008a20a7b446c);
      Vector::push_back<u64>(&mut amounts, 93282428);
      
      Vector::push_back<address>(&mut payees, @0x8c8d5795fee9e58d73da6c5b546b0ffa);
      Vector::push_back<u64>(&mut amounts, 840932303);
      
      Vector::push_back<address>(&mut payees, @0x50eb8c8512279f645ef6fb16ba30a4f0);
      Vector::push_back<u64>(&mut amounts, 462846396);
      
      Vector::push_back<address>(&mut payees, @0xc0511e6352cb85e58ce7452906cbc668);
      Vector::push_back<u64>(&mut amounts, 228568917);
      
      Vector::push_back<address>(&mut payees, @0x4c5320d476cecebd453f8385c3333b97);
      Vector::push_back<u64>(&mut amounts, 471417550);
      
      Vector::push_back<address>(&mut payees, @0x83f52e3a0b3e4cc7086a3b00c26df82f);
      Vector::push_back<u64>(&mut amounts, 933102587);
      
      Vector::push_back<address>(&mut payees, @0xec658df70a5c05bf814bf26556048e31);
      Vector::push_back<u64>(&mut amounts, 1454889296);
      
      Vector::push_back<address>(&mut payees, @0xb4f885cff35a888d321e5c60881d6092);
      Vector::push_back<u64>(&mut amounts, 1844577888);
      
      Vector::push_back<address>(&mut payees, @0xd64cd8d9b7c7a0e9ee65a4bb6ed61208);
      Vector::push_back<u64>(&mut amounts, 1636195897);
      
      Vector::push_back<address>(&mut payees, @0x1da515dbfc4fc04da1af3926530c1c7d);
      Vector::push_back<u64>(&mut amounts, 343274572);
      
      Vector::push_back<address>(&mut payees, @0x78aa01e6f203faa97977ea2054c8488c);
      Vector::push_back<u64>(&mut amounts, 2016786692);
      
      Vector::push_back<address>(&mut payees, @0x80283ec400d6d4aa9f5fc9c51f993093);
      Vector::push_back<u64>(&mut amounts, 1978378247);
      
      Vector::push_back<address>(&mut payees, @0x27da50221a08d567719c8bb9e412f124);
      Vector::push_back<u64>(&mut amounts, 907364381);
      
      Vector::push_back<address>(&mut payees, @0x6a5422ccbb07f7e967a452e7d9e8cc5d);
      Vector::push_back<u64>(&mut amounts, 272181341);
      
      Vector::push_back<address>(&mut payees, @0xfe8d9265c0b49dd6c613fa06630a66b7);
      Vector::push_back<u64>(&mut amounts, 86702672);
      
      Vector::push_back<address>(&mut payees, @0xba43db6e18804e26c835371d55fce7a6);
      Vector::push_back<u64>(&mut amounts, 46369894);
      
      Vector::push_back<address>(&mut payees, @0xc0e3de592e1a61500b167578a8438d27);
      Vector::push_back<u64>(&mut amounts, 56674315);
      
      Vector::push_back<address>(&mut payees, @0x538b13be8a2775cef9366245c2cc47af);
      Vector::push_back<u64>(&mut amounts, 51522105);
      
      Vector::push_back<address>(&mut payees, @0xacc1e92a7b9039884e8987aef7bb7e31);
      Vector::push_back<u64>(&mut amounts, 87587578);
      
      Vector::push_back<address>(&mut payees, @0xa2d42a5997f3b24780519f7c28ac95ac);
      Vector::push_back<u64>(&mut amounts, 483629974);
      
      Vector::push_back<address>(&mut payees, @0x2642852d93480f477c437eee0f50f7a2);
      Vector::push_back<u64>(&mut amounts, 148739997);
      
      Vector::push_back<address>(&mut payees, @0xdbd26955f8261dc3cfc03b30d2bf307e);
      Vector::push_back<u64>(&mut amounts, 915127266);
      
      Vector::push_back<address>(&mut payees, @0xd775495887169e998c3e33ca5c7e684c);
      Vector::push_back<u64>(&mut amounts, 46369894);
      
      Vector::push_back<address>(&mut payees, @0x5f93da3538ea70372f9daaa867708408);
      Vector::push_back<u64>(&mut amounts, 1860762808);
      
      Vector::push_back<address>(&mut payees, @0x83a1bc40a9cede48422ae0572f634981);
      Vector::push_back<u64>(&mut amounts, 1947180106);
      
      Vector::push_back<address>(&mut payees, @0x19ea51bfcc62d946adf8ef78b40a4c47);
      Vector::push_back<u64>(&mut amounts, 726425306);
      
      Vector::push_back<address>(&mut payees, @0x6118b429b463553991671852c65512be);
      Vector::push_back<u64>(&mut amounts, 1838998655);
      
      Vector::push_back<address>(&mut payees, @0xdb1c9d02beea49f1738a04fa40671050);
      Vector::push_back<u64>(&mut amounts, 1697620583);
      
      Vector::push_back<address>(&mut payees, @0x956c5f53631d26def8b906adcd993abe);
      Vector::push_back<u64>(&mut amounts, 1525840916);
      
      Vector::push_back<address>(&mut payees, @0x2e8da900c9367947037d749ca9617b42);
      Vector::push_back<u64>(&mut amounts, 1759464492);
      
      Vector::push_back<address>(&mut payees, @0xf5db9b8eabb03a649b24acca54715485);
      Vector::push_back<u64>(&mut amounts, 1572890483);
      
      Vector::push_back<address>(&mut payees, @0x0709c82fd51c53c3c61d4608c39cd7e6);
      Vector::push_back<u64>(&mut amounts, 1641136472);
      
      Vector::push_back<address>(&mut payees, @0xff0eff19212725acf514405f85a0f18c);
      Vector::push_back<u64>(&mut amounts, 1532575879);
      
      Vector::push_back<address>(&mut payees, @0xbeb649e0e66aeb73525ec8e9f096e380);
      Vector::push_back<u64>(&mut amounts, 1680102397);
      
      Vector::push_back<address>(&mut payees, @0x2eec9d2d76b1fe2f2303fadd2547fdda);
      Vector::push_back<u64>(&mut amounts, 1638946490);
      
      Vector::push_back<address>(&mut payees, @0x5677d9940f731b76cfdeb0e9b5ec1c8f);
      Vector::push_back<u64>(&mut amounts, 1498997594);
      
      Vector::push_back<address>(&mut payees, @0x7ca0528017da53eb1b4805c89cbe23ad);
      Vector::push_back<u64>(&mut amounts, 1523513156);
      
      Vector::push_back<address>(&mut payees, @0xbf000ae19aca68a99a0df18023bdfd22);
      Vector::push_back<u64>(&mut amounts, 476128022);
      
      Vector::push_back<address>(&mut payees, @0x17bbd0e9ba88b569ca5e3bd3c6f04952);
      Vector::push_back<u64>(&mut amounts, 564041821);
      
      Vector::push_back<address>(&mut payees, @0xd7ee8ab8ab084aa216b2ebf68f6d4dda);
      Vector::push_back<u64>(&mut amounts, 1035265882);
      
      Vector::push_back<address>(&mut payees, @0x07bdb49e5d74ff6572df53fab90c3ff9);
      Vector::push_back<u64>(&mut amounts, 1603951164);
      
      Vector::push_back<address>(&mut payees, @0xe4ac4864b0010b1487bed46bebd50bda);
      Vector::push_back<u64>(&mut amounts, 589213908);
      
      Vector::push_back<address>(&mut payees, @0x54613a145a86ce469cb7b378b872ece9);
      Vector::push_back<u64>(&mut amounts, 2224950282);
      
      Vector::push_back<address>(&mut payees, @0x3bc00dd091f45914b2443f16e05f9cdc);
      Vector::push_back<u64>(&mut amounts, 550383705);
      
      Vector::push_back<address>(&mut payees, @0xf64a082292a3f8550a2af2af9ee85024);
      Vector::push_back<u64>(&mut amounts, 720776730);
      
      Vector::push_back<address>(&mut payees, @0xec9c969fed0a6db49335b1dd12bf5888);
      Vector::push_back<u64>(&mut amounts, 830143601);
      
      Vector::push_back<address>(&mut payees, @0x8480b037ad6a589323e5eaebccdb59a6);
      Vector::push_back<u64>(&mut amounts, 1787805214);
      
      Vector::push_back<address>(&mut payees, @0x95f0842cb15e6295cd98cf5e00afc52f);
      Vector::push_back<u64>(&mut amounts, 631294493);
      
      Vector::push_back<address>(&mut payees, @0x716085770aed571d00191494e932cac5);
      Vector::push_back<u64>(&mut amounts, 877677165);
      
      Vector::push_back<address>(&mut payees, @0x2000075f5ed34e0eb33894c670159f51);
      Vector::push_back<u64>(&mut amounts, 177285240);
      
      Vector::push_back<address>(&mut payees, @0x3ab513ce463edc6a1bf56a562b86de60);
      Vector::push_back<u64>(&mut amounts, 1822745916);
      
      Vector::push_back<address>(&mut payees, @0x17550894edcfcbae27d75baa740953e3);
      Vector::push_back<u64>(&mut amounts, 1607911804);
      
      Vector::push_back<address>(&mut payees, @0xe39de4e9449160791bf607ee8146efa0);
      Vector::push_back<u64>(&mut amounts, 222600009);
      
      Vector::push_back<address>(&mut payees, @0x6b8856cd55814941ac486cd0f296ceb6);
      Vector::push_back<u64>(&mut amounts, 758397070);
      
      Vector::push_back<address>(&mut payees, @0x030ff379751eb2ae44f39024cdb3b3f6);
      Vector::push_back<u64>(&mut amounts, 142283003);
      
      Vector::push_back<address>(&mut payees, @0x2fea4857cc15a9f0c7d93dbf2f1ec059);
      Vector::push_back<u64>(&mut amounts, 2521198997);
      
      Vector::push_back<address>(&mut payees, @0x535495dcf82a8b82747ecaeec8e1358d);
      Vector::push_back<u64>(&mut amounts, 308464450);
      
      Vector::push_back<address>(&mut payees, @0x54d5d5dd28c358060e7600191ec8f515);
      Vector::push_back<u64>(&mut amounts, 158275270);
      
      Vector::push_back<address>(&mut payees, @0xda966e67f444ad8ab33a5deb6a944f5d);
      Vector::push_back<u64>(&mut amounts, 493363300);
      
      Vector::push_back<address>(&mut payees, @0x5a9457ab699ff3fc93ba872dd3364fbd);
      Vector::push_back<u64>(&mut amounts, 276689818);
      
      Vector::push_back<address>(&mut payees, @0x434f84cb777c9d1a5e6bba62cfec9582);
      Vector::push_back<u64>(&mut amounts, 105873541);
      
      Vector::push_back<address>(&mut payees, @0x7a3126cb658f1edbbc80118d2fd5e64e);
      Vector::push_back<u64>(&mut amounts, 1432717373);
      
      Vector::push_back<address>(&mut payees, @0xc300c43254c50f0a32e2979091be1a6f);
      Vector::push_back<u64>(&mut amounts, 1015782429);
      
      Vector::push_back<address>(&mut payees, @0xac05b9222b0de585fcf26368e3885b0a);
      Vector::push_back<u64>(&mut amounts, 1443157099);
      
      Vector::push_back<address>(&mut payees, @0x6f4328ef1f4bb770cdfa38069f47b44e);
      Vector::push_back<u64>(&mut amounts, 40332777);
      
      Vector::push_back<address>(&mut payees, @0x8f4b25b5a78bc35ccbca053cbbb84181);
      Vector::push_back<u64>(&mut amounts, 985741359);
      
      Vector::push_back<address>(&mut payees, @0x28ebd03c039943b2051beffd0a7b2e99);
      Vector::push_back<u64>(&mut amounts, 254414899);
      
      Vector::push_back<address>(&mut payees, @0x8af37485acffe60786e689fb71ab80a7);
      Vector::push_back<u64>(&mut amounts, 2855258334);
      
      Vector::push_back<address>(&mut payees, @0x3cab9d404eea12cd123affc451fd053c);
      Vector::push_back<u64>(&mut amounts, 1575252669);
      
      Vector::push_back<address>(&mut payees, @0x85998e81c8f5aadd3104b4997449948c);
      Vector::push_back<u64>(&mut amounts, 1572401017);
      
      Vector::push_back<address>(&mut payees, @0x06432c22c1c8ad9c5b1062dbe4a2fb5c);
      Vector::push_back<u64>(&mut amounts, 815875844);
      
      Vector::push_back<address>(&mut payees, @0x5d34710942722a0435f4385bf56dff4f);
      Vector::push_back<u64>(&mut amounts, 1209947645);
      
      Vector::push_back<address>(&mut payees, @0x051617d6d35bcc844efde8ae75ccb39a);
      Vector::push_back<u64>(&mut amounts, 984084646);
      
      Vector::push_back<address>(&mut payees, @0x46d29312267e26f421d4d2e0fe51a424);
      Vector::push_back<u64>(&mut amounts, 1365913345);
      
      Vector::push_back<address>(&mut payees, @0x19e647dff35e75aff667dd586b3376f0);
      Vector::push_back<u64>(&mut amounts, 45374374);
      
      Vector::push_back<address>(&mut payees, @0x0d3abf0a018d5e68cb0985a48e84c0bd);
      Vector::push_back<u64>(&mut amounts, 455025692);
      
      Vector::push_back<address>(&mut payees, @0x728aeaaa2f6450f9d9b8d0264765bb41);
      Vector::push_back<u64>(&mut amounts, 1955150002);
      
      Vector::push_back<address>(&mut payees, @0xaae11ab13e30621769686ab9dccb20f7);
      Vector::push_back<u64>(&mut amounts, 333343733);
      
      Vector::push_back<address>(&mut payees, @0xd83a2272671364eb1a64bfca1877120b);
      Vector::push_back<u64>(&mut amounts, 159707643);
      
      Vector::push_back<address>(&mut payees, @0xcb8e458af457b658af11ac39daa5504f);
      Vector::push_back<u64>(&mut amounts, 261906840);
      
      Vector::push_back<address>(&mut payees, @0x67daf9339d4af96868702cc5005c1fef);
      Vector::push_back<u64>(&mut amounts, 184573816);
      
      Vector::push_back<address>(&mut payees, @0x75b4caed3ab3520a04359349a653642f);
      Vector::push_back<u64>(&mut amounts, 95790346);
      
      Vector::push_back<address>(&mut payees, @0xb580cdc740297610a16d0614b151ab3c);
      Vector::push_back<u64>(&mut amounts, 745048105);
      
      Vector::push_back<address>(&mut payees, @0xf2a447b06d46e956c36f5898520b5080);
      Vector::push_back<u64>(&mut amounts, 1112586748);
      
      Vector::push_back<address>(&mut payees, @0xdcd9b6cd17645561d0d5187bac6907ca);
      Vector::push_back<u64>(&mut amounts, 1711597727);
      
      Vector::push_back<address>(&mut payees, @0x9cde64546440800c8eee94cde1f77e91);
      Vector::push_back<u64>(&mut amounts, 937977369);
      
      Vector::push_back<address>(&mut payees, @0xe7c33ccf4ffa35bdd5e99daf38d79d08);
      Vector::push_back<u64>(&mut amounts, 52125037);
      
      Vector::push_back<address>(&mut payees, @0x6f77f46e3c36e688865cdf5944801179);
      Vector::push_back<u64>(&mut amounts, 206481952);
      
      Vector::push_back<address>(&mut payees, @0x8cf072085457f10f046935312bb7c976);
      Vector::push_back<u64>(&mut amounts, 654983830);
      
      Vector::push_back<address>(&mut payees, @0xe057f02fbb1ba40ac6b04d65ca528765);
      Vector::push_back<u64>(&mut amounts, 1213231165);
      
      Vector::push_back<address>(&mut payees, @0x8cbe324c7c2789e597dc1187633c3416);
      Vector::push_back<u64>(&mut amounts, 1185836375);
      
      Vector::push_back<address>(&mut payees, @0xc45ab39876cbe1abdf79f68381224c7d);
      Vector::push_back<u64>(&mut amounts, 487184285);
      
      Vector::push_back<address>(&mut payees, @0xa5140b763cb22aa488898dbea4b223fe);
      Vector::push_back<u64>(&mut amounts, 2343382112);
      
      Vector::push_back<address>(&mut payees, @0x399b11e89d48b1befdb0e21bf0ed941e);
      Vector::push_back<u64>(&mut amounts, 729597364);
      
      Vector::push_back<address>(&mut payees, @0xd628ec522f2a6c1f03ef5ebfdd572117);
      Vector::push_back<u64>(&mut amounts, 200718067);
      
      Vector::push_back<address>(&mut payees, @0xc49137de0b4edaf38a0080d61c958f29);
      Vector::push_back<u64>(&mut amounts, 226809552);
      
      Vector::push_back<address>(&mut payees, @0x0721c94cd361ed5adf494112b829f8d6);
      Vector::push_back<u64>(&mut amounts, 334922185);
      
      Vector::push_back<address>(&mut payees, @0x4de146cb54b98d98524f16f74b8f3839);
      Vector::push_back<u64>(&mut amounts, 498302289);
      
      Vector::push_back<address>(&mut payees, @0x532e99cc0607c6af3782a63a123ea838);
      Vector::push_back<u64>(&mut amounts, 238380226);
      
      Vector::push_back<address>(&mut payees, @0xf6415fd06977f07a3b9b83e87ce955b2);
      Vector::push_back<u64>(&mut amounts, 1992946680);
      
      Vector::push_back<address>(&mut payees, @0xde29e94fa347311a6f4934166154b96d);
      Vector::push_back<u64>(&mut amounts, 1039711770);
      
      Vector::push_back<address>(&mut payees, @0xfd73bdd87e2e6a402c83f2a995129509);
      Vector::push_back<u64>(&mut amounts, 700966790);
      
      Vector::push_back<address>(&mut payees, @0x8ba989a1682b6ce65f735fd38622d307);
      Vector::push_back<u64>(&mut amounts, 1049407288);
      
      Vector::push_back<address>(&mut payees, @0x290c3ec6f47e4c5777aa9e11ecfb430a);
      Vector::push_back<u64>(&mut amounts, 1076444487);
      
      Vector::push_back<address>(&mut payees, @0x453a846b8d60714c658da8f9a7f7d7ea);
      Vector::push_back<u64>(&mut amounts, 1286130066);
      
      Vector::push_back<address>(&mut payees, @0xa30b8cafcd41e4d2a971866f27b8342a);
      Vector::push_back<u64>(&mut amounts, 1286941497);
      
      Vector::push_back<address>(&mut payees, @0xa0d6eab8e5732282566e799d65dd3fbe);
      Vector::push_back<u64>(&mut amounts, 912930072);
      
      Vector::push_back<address>(&mut payees, @0xa68c92651fda52506a2edb9ee88cf785);
      Vector::push_back<u64>(&mut amounts, 41700029);
      
      Vector::push_back<address>(&mut payees, @0xdc5ccdbff611d7b4604907298ac19f36);
      Vector::push_back<u64>(&mut amounts, 1495994298);
      
      Vector::push_back<address>(&mut payees, @0xf540a42f8cefe9ada28ebdbff7e56766);
      Vector::push_back<u64>(&mut amounts, 714261885);
      
      Vector::push_back<address>(&mut payees, @0xf01c1dcf1c2cbed2dbe743e371c488b0);
      Vector::push_back<u64>(&mut amounts, 911641097);
      
      Vector::push_back<address>(&mut payees, @0xc058820ea38dfb802e4f07d87044050c);
      Vector::push_back<u64>(&mut amounts, 1313259527);
      
      Vector::push_back<address>(&mut payees, @0x9b572b1a420fa30ab57913e1af63ba95);
      Vector::push_back<u64>(&mut amounts, 1161517287);
      
      Vector::push_back<address>(&mut payees, @0xb1100c048fd0d300e8682cab7659bff4);
      Vector::push_back<u64>(&mut amounts, 1083566745);
      
      Vector::push_back<address>(&mut payees, @0xfd36e77bd7a945fe7e105c2c2ed58806);
      Vector::push_back<u64>(&mut amounts, 230989870);
      
      Vector::push_back<address>(&mut payees, @0x787c725c8812f38f406b7ee9e5b855c2);
      Vector::push_back<u64>(&mut amounts, 731271531);
      
      Vector::push_back<address>(&mut payees, @0x7f12ddb267e84a3cca69ea85c82603cf);
      Vector::push_back<u64>(&mut amounts, 585493642);
      
      Vector::push_back<address>(&mut payees, @0x1ae86b633961b008b6cb3bd8c6791a4c);
      Vector::push_back<u64>(&mut amounts, 2348853874);
      
      Vector::push_back<address>(&mut payees, @0x886403cfd4c591583a0b4e2522880444);
      Vector::push_back<u64>(&mut amounts, 397343941);
      
      Vector::push_back<address>(&mut payees, @0xb860cb66c2a1e1489f2ba4bd48ede333);
      Vector::push_back<u64>(&mut amounts, 1005265804);
      
      Vector::push_back<address>(&mut payees, @0xf08ce5c69f4db0e4f17489c7050a1a5c);
      Vector::push_back<u64>(&mut amounts, 571668682);
      
      Vector::push_back<address>(&mut payees, @0x3eb544fccdf90e7ce227dae23acda703);
      Vector::push_back<u64>(&mut amounts, 749229364);
      
      Vector::push_back<address>(&mut payees, @0xad4fd0fb234a90475701840300809cb9);
      Vector::push_back<u64>(&mut amounts, 656814709);
      
      Vector::push_back<address>(&mut payees, @0x18c19018f3f1f1df1e1d1422927cdaa4);
      Vector::push_back<u64>(&mut amounts, 162111608);
      
      Vector::push_back<address>(&mut payees, @0x4b6e51650b6f4d442abd2add499dda54);
      Vector::push_back<u64>(&mut amounts, 109462578);
      
      Vector::push_back<address>(&mut payees, @0x7ec6f4d40a4e14ab983bc80888ca6275);
      Vector::push_back<u64>(&mut amounts, 204462279);
      
      Vector::push_back<address>(&mut payees, @0x80f46c1062e5b6bc192981da00987d7c);
      Vector::push_back<u64>(&mut amounts, 406827857);
      
      Vector::push_back<address>(&mut payees, @0x8db7ecf1e459f8664d38d4628cbf8917);
      Vector::push_back<u64>(&mut amounts, 1182627485);
      
      Vector::push_back<address>(&mut payees, @0xaa7b724a51a8bd8e55208fef969209b3);
      Vector::push_back<u64>(&mut amounts, 1059449822);
      
      Vector::push_back<address>(&mut payees, @0xeda246f2314d89167bcbbc3e7b64c377);
      Vector::push_back<u64>(&mut amounts, 924376323);
      
      Vector::push_back<address>(&mut payees, @0xced73e78289a247eefaf466b9f97680b);
      Vector::push_back<u64>(&mut amounts, 2376041861);
      
      Vector::push_back<address>(&mut payees, @0x7091d550b8a20a2e74d4a3b6125c66a9);
      Vector::push_back<u64>(&mut amounts, 1075923948);
      
      Vector::push_back<address>(&mut payees, @0x9966b3e24a6aebc0233d9888d07f40aa);
      Vector::push_back<u64>(&mut amounts, 1815617595);
      
      Vector::push_back<address>(&mut payees, @0xd948a4d5eb9b1ef59c0b3c6422fab977);
      Vector::push_back<u64>(&mut amounts, 1417941837);
      
      Vector::push_back<address>(&mut payees, @0x0e22b7e222c97cb3e1b91399ab12132a);
      Vector::push_back<u64>(&mut amounts, 2002609948);
      
      Vector::push_back<address>(&mut payees, @0x180d81b98372ce4850742a7f344b9c86);
      Vector::push_back<u64>(&mut amounts, 2330946694);
      
      Vector::push_back<address>(&mut payees, @0x43154bd76f5fc25d24d5e65de4c22792);
      Vector::push_back<u64>(&mut amounts, 3649997396);
      
      Vector::push_back<address>(&mut payees, @0xae28484002dad3c5deb1e8452f3693b6);
      Vector::push_back<u64>(&mut amounts, 122356867);
      
      Vector::push_back<address>(&mut payees, @0xb7521a5178eafcca928164a895f8d09d);
      Vector::push_back<u64>(&mut amounts, 378008233);
      
      Vector::push_back<address>(&mut payees, @0xe10c9c5d34e606131164d927126dff2a);
      Vector::push_back<u64>(&mut amounts, 1546045984);
      
      Vector::push_back<address>(&mut payees, @0x0a9ab55844654ec974820fa3101348f0);
      Vector::push_back<u64>(&mut amounts, 44440973);
      
      Vector::push_back<address>(&mut payees, @0x78a9edccea0e496d0f606491f40e8cf5);
      Vector::push_back<u64>(&mut amounts, 351749388);
      
      Vector::push_back<address>(&mut payees, @0x49f9136d3744000348ce072f6b7183a0);
      Vector::push_back<u64>(&mut amounts, 420491324);
      
      Vector::push_back<address>(&mut payees, @0x97d94167eb035720531530314ebe107b);
      Vector::push_back<u64>(&mut amounts, 390113380);
      
      Vector::push_back<address>(&mut payees, @0x631fb10a92479db4736eaaf01918c2da);
      Vector::push_back<u64>(&mut amounts, 493631547);
      
      Vector::push_back<address>(&mut payees, @0x09a638835af960e5ddeed681b7d33ea1);
      Vector::push_back<u64>(&mut amounts, 2509661718);
      
      Vector::push_back<address>(&mut payees, @0x239420d342c8cfce5ad58cff2921919e);
      Vector::push_back<u64>(&mut amounts, 1016696878);
      
      Vector::push_back<address>(&mut payees, @0x779cffc131c2d4209e23d73b53d22f26);
      Vector::push_back<u64>(&mut amounts, 1240539374);
      
      Vector::push_back<address>(&mut payees, @0x1cfba7ab0cb0ca79f3cc6d0aca6d60fa);
      Vector::push_back<u64>(&mut amounts, 1118648913);
      
      Vector::push_back<address>(&mut payees, @0xf095afad764212f5d16eaddfed0bada9);
      Vector::push_back<u64>(&mut amounts, 1700624988);
      
      Vector::push_back<address>(&mut payees, @0x6f77f942ec10e916b676ecb34f5d9bf7);
      Vector::push_back<u64>(&mut amounts, 1145516134);
      
      Vector::push_back<address>(&mut payees, @0x69daa80519ec5340710904c7f073226b);
      Vector::push_back<u64>(&mut amounts, 763441848);
      
      Vector::push_back<address>(&mut payees, @0x9dd360c8ab4e7552bc927cc209a3db37);
      Vector::push_back<u64>(&mut amounts, 325185409);
      
      Vector::push_back<address>(&mut payees, @0x7677bc51b9a1691366067575ef721db3);
      Vector::push_back<u64>(&mut amounts, 706427283);
      
      Vector::push_back<address>(&mut payees, @0x209b065eda47969d367e1effb1902eaf);
      Vector::push_back<u64>(&mut amounts, 341629865);
      
      Vector::push_back<address>(&mut payees, @0xe32f5f3d059f131efcc223d833ebd2c7);
      Vector::push_back<u64>(&mut amounts, 882455884);
      
      Vector::push_back<address>(&mut payees, @0x06ba3c0e24b8569b0a8265e0385270bf);
      Vector::push_back<u64>(&mut amounts, 166168334);
      
      Vector::push_back<address>(&mut payees, @0xdb26aa9bd043fe9ac1e10c3520af0aaf);
      Vector::push_back<u64>(&mut amounts, 1070053156);
      
      Vector::push_back<address>(&mut payees, @0xb83856d2e52bc3604799327264f4f66c);
      Vector::push_back<u64>(&mut amounts, 721831061);
      
      Vector::push_back<address>(&mut payees, @0x3f749ccb08b2186119dd214fcb7293de);
      Vector::push_back<u64>(&mut amounts, 1004151165);
      
      Vector::push_back<address>(&mut payees, @0x1a3b4b148b5e6ff2ea33fb302f09f5f0);
      Vector::push_back<u64>(&mut amounts, 895388341);
      
      Vector::push_back<address>(&mut payees, @0xe451cb114db874c070b2ec519217303e);
      Vector::push_back<u64>(&mut amounts, 467214641);
      
      Vector::push_back<address>(&mut payees, @0x95a0af6f256494f29ea278daec0307ad);
      Vector::push_back<u64>(&mut amounts, 479314971);
      
      Vector::push_back<address>(&mut payees, @0x2866b28dbdef5c67704b2e8698304d95);
      Vector::push_back<u64>(&mut amounts, 1032484774);
      
      Vector::push_back<address>(&mut payees, @0xd5cad17350a4a651385aa9eebcb47fea);
      Vector::push_back<u64>(&mut amounts, 2185666625);
      
      Vector::push_back<address>(&mut payees, @0x88ef844f6a1c76c58bd28d83d2fafcc8);
      Vector::push_back<u64>(&mut amounts, 1108349367);
      
      Vector::push_back<address>(&mut payees, @0x655d5c25d1dad48e4c2399c05e97fe0a);
      Vector::push_back<u64>(&mut amounts, 355865016);
      
      Vector::push_back<address>(&mut payees, @0x3ef2f086541562131bfdaf2d28e081ff);
      Vector::push_back<u64>(&mut amounts, 421715343);
      
      Vector::push_back<address>(&mut payees, @0x12f2299900541b3767927cea6da239f0);
      Vector::push_back<u64>(&mut amounts, 94437067);
      
      Vector::push_back<address>(&mut payees, @0xac9f9957d4fb9abc9e1deb1866f77e3b);
      Vector::push_back<u64>(&mut amounts, 741321648);
      
      Vector::push_back<address>(&mut payees, @0x8b37e5bc5fa8b7f5e81a32077402ce2d);
      Vector::push_back<u64>(&mut amounts, 327474063);
      
      Vector::push_back<address>(&mut payees, @0x55b444afde145dcd1900f811d636c3a3);
      Vector::push_back<u64>(&mut amounts, 533492173);
      
      Vector::push_back<address>(&mut payees, @0x79cbf36a9c5bf9b25db6d3c5a6561df9);
      Vector::push_back<u64>(&mut amounts, 821689308);
      
      Vector::push_back<address>(&mut payees, @0x2f232e5f21429483425e610dde60b7a6);
      Vector::push_back<u64>(&mut amounts, 269334217);
      
      Vector::push_back<address>(&mut payees, @0x3712bfc5dfabdf476e7e588509dcc0f6);
      Vector::push_back<u64>(&mut amounts, 447267417);
      
      Vector::push_back<address>(&mut payees, @0xf8251792d46856ae422670a62fda4dbb);
      Vector::push_back<u64>(&mut amounts, 666434554);
      
      Vector::push_back<address>(&mut payees, @0xeb27cb61f08d684df66bd04b6cd4d338);
      Vector::push_back<u64>(&mut amounts, 154491551);
      
      Vector::push_back<address>(&mut payees, @0xa822636e67354f58062f9a32460e40b6);
      Vector::push_back<u64>(&mut amounts, 367307971);
      
      Vector::push_back<address>(&mut payees, @0x9d6b0a67ebaef670f8950d68e000b5c9);
      Vector::push_back<u64>(&mut amounts, 316931435);
      
      Vector::push_back<address>(&mut payees, @0x90ebaf8ce02020248afdb988bfba95dc);
      Vector::push_back<u64>(&mut amounts, 344417542);
      
      Vector::push_back<address>(&mut payees, @0x85757bec5903ea4cb965724fee942c3e);
      Vector::push_back<u64>(&mut amounts, 254433900);
      
      Vector::push_back<address>(&mut payees, @0x5084bd369cdc3f6343211aefe05f62bb);
      Vector::push_back<u64>(&mut amounts, 141887909);
      
      Vector::push_back<address>(&mut payees, @0xa2d1f8b8b54f77315b1f1be18d662c72);
      Vector::push_back<u64>(&mut amounts, 265348354);
      
      Vector::push_back<address>(&mut payees, @0x5985c4dabf0e28f4aeffaec67d2cce64);
      Vector::push_back<u64>(&mut amounts, 439810629);
      
      Vector::push_back<address>(&mut payees, @0x0ab2b508199b6c8892efebd1fff792b7);
      Vector::push_back<u64>(&mut amounts, 473717556);
      
      Vector::push_back<address>(&mut payees, @0xd3d636395f9d9d05b8fc6c339ae8af79);
      Vector::push_back<u64>(&mut amounts, 437118647);
      
      Vector::push_back<address>(&mut payees, @0xf0d097311ee5c1b1a912eb2181688693);
      Vector::push_back<u64>(&mut amounts, 431367053);
      
      Vector::push_back<address>(&mut payees, @0x5e3e2d2f6aed0d2f6f410c1bd3f2f5e0);
      Vector::push_back<u64>(&mut amounts, 445870520);
      
      Vector::push_back<address>(&mut payees, @0x46d300ba50e4e90517aafda7e57a06cb);
      Vector::push_back<u64>(&mut amounts, 1019616506);
      
      Vector::push_back<address>(&mut payees, @0x63318830c712e33075021d47c42927c4);
      Vector::push_back<u64>(&mut amounts, 715359323);
      
      Vector::push_back<address>(&mut payees, @0x3b08bf965fcc28baeb13d8104fb3e6fe);
      Vector::push_back<u64>(&mut amounts, 621109067);
      
      Vector::push_back<address>(&mut payees, @0x0776c9866af5da3264ec911f46329c13);
      Vector::push_back<u64>(&mut amounts, 812558910);
      
      Vector::push_back<address>(&mut payees, @0x64c662a5d392a711b3c6df4c31549cdb);
      Vector::push_back<u64>(&mut amounts, 636392500);
      
      Vector::push_back<address>(&mut payees, @0x5f3796c875ce6cafb1013204db71dacd);
      Vector::push_back<u64>(&mut amounts, 346477606);
      
      Vector::push_back<address>(&mut payees, @0xe5c9d64c04a9b012c0bb568c015caab2);
      Vector::push_back<u64>(&mut amounts, 1090482449);
      
      Vector::push_back<address>(&mut payees, @0x9f4105e6ee58b733384f9ebef61a35ae);
      Vector::push_back<u64>(&mut amounts, 1451658408);
      
      Vector::push_back<address>(&mut payees, @0xa1f0831eeb8bd84ce705c349b6d6b587);
      Vector::push_back<u64>(&mut amounts, 2359709750);
      
      Vector::push_back<address>(&mut payees, @0x86c199d41855be7686e0c1d137d02af5);
      Vector::push_back<u64>(&mut amounts, 1503386898);
      
      Vector::push_back<address>(&mut payees, @0xbc39137a7f7aeb370fb3a1b037385b93);
      Vector::push_back<u64>(&mut amounts, 2136892467);
      
      Vector::push_back<address>(&mut payees, @0xf845508240bfd5f0babaffdbb8f24aab);
      Vector::push_back<u64>(&mut amounts, 656228906);
      
      Vector::push_back<address>(&mut payees, @0x69565c28652a2fee56e7e986a3616aa4);
      Vector::push_back<u64>(&mut amounts, 497756748);
      
      Vector::push_back<address>(&mut payees, @0x4883881c1e476ebd94919910f629888b);
      Vector::push_back<u64>(&mut amounts, 1142038368);
      
      Vector::push_back<address>(&mut payees, @0xa4597bab3a398a886ecbebcc8385e06e);
      Vector::push_back<u64>(&mut amounts, 286785686);
      
      Vector::push_back<address>(&mut payees, @0x63a98fce42921411420a94ad8a9a5c11);
      Vector::push_back<u64>(&mut amounts, 105547311);
      
      Vector::push_back<address>(&mut payees, @0x7fc541799cb6c013668209eeccf456f1);
      Vector::push_back<u64>(&mut amounts, 226433258);
      
      Vector::push_back<address>(&mut payees, @0xbb1d9d66577686d1dcaa12e8a76212e3);
      Vector::push_back<u64>(&mut amounts, 732219112);
      
      Vector::push_back<address>(&mut payees, @0x5f1aa1618e239ad002cddbac80a6ed02);
      Vector::push_back<u64>(&mut amounts, 1177587954);
      
      Vector::push_back<address>(&mut payees, @0xea968c11e3bb5e0b2df2d03ba5ca45c5);
      Vector::push_back<u64>(&mut amounts, 373179719);
      
      Vector::push_back<address>(&mut payees, @0x5d62152a629ed26c16f044991a25b49e);
      Vector::push_back<u64>(&mut amounts, 1788428976);
      
      Vector::push_back<address>(&mut payees, @0xdc039766ffffad2022b86e2d35859c88);
      Vector::push_back<u64>(&mut amounts, 299398742);
      
      Vector::push_back<address>(&mut payees, @0x5689f7be578feb649d525174a7ee2654);
      Vector::push_back<u64>(&mut amounts, 277415270);
      
      Vector::push_back<address>(&mut payees, @0xa076822ba5f0f7000422556f1934c831);
      Vector::push_back<u64>(&mut amounts, 681499038);
      
      Vector::push_back<address>(&mut payees, @0xf2dccd7072a28a30ac9c3b2ae5ff63b9);
      Vector::push_back<u64>(&mut amounts, 600517895);
      
      Vector::push_back<address>(&mut payees, @0xc4e9abe0b0366861c83ecfbbd3e3a8b5);
      Vector::push_back<u64>(&mut amounts, 175218639);
      
      Vector::push_back<address>(&mut payees, @0xa6b0216a6429acce52ab25bf7d1b2de9);
      Vector::push_back<u64>(&mut amounts, 216649744);
      
      Vector::push_back<address>(&mut payees, @0x7945992524a089845d5f21865a11d2f5);
      Vector::push_back<u64>(&mut amounts, 306909917);
      
      Vector::push_back<address>(&mut payees, @0x5745e28134b5fd97e1fd388e7d4cf778);
      Vector::push_back<u64>(&mut amounts, 197036412);
      
      Vector::push_back<address>(&mut payees, @0xcc6fb5e313d726f0dd804c8aeea28eef);
      Vector::push_back<u64>(&mut amounts, 349654123);
      
      Vector::push_back<address>(&mut payees, @0xcbdf867ec79a7ba2c744859f98ccdd71);
      Vector::push_back<u64>(&mut amounts, 942848108);
      
      Vector::push_back<address>(&mut payees, @0x58585c164a9595009706f874b1933dd2);
      Vector::push_back<u64>(&mut amounts, 1166324759);
      
      Vector::push_back<address>(&mut payees, @0xaa26bf48c28b25ae248e53af41a4e014);
      Vector::push_back<u64>(&mut amounts, 185781665);
      
      Vector::push_back<address>(&mut payees, @0xcd14b1aa029fc57248dd6e24d67c8bdd);
      Vector::push_back<u64>(&mut amounts, 425394901);
      
      Vector::push_back<address>(&mut payees, @0x43db5e93ef28e3427d13fdfd5651267a);
      Vector::push_back<u64>(&mut amounts, 307850073);
      
      Vector::push_back<address>(&mut payees, @0x9114bcb1f3dd30ea6510c2c5dd73ad97);
      Vector::push_back<u64>(&mut amounts, 1119698277);
      
      Vector::push_back<address>(&mut payees, @0x3e87037af0626a46d29e484f5ec549a2);
      Vector::push_back<u64>(&mut amounts, 864687324);
      
      Vector::push_back<address>(&mut payees, @0xbae7fc9077c526b42252885adfd38635);
      Vector::push_back<u64>(&mut amounts, 709561741);
      
      Vector::push_back<address>(&mut payees, @0xf52bb52d01db98cb0f0f5f0d6946b060);
      Vector::push_back<u64>(&mut amounts, 305264184);
      
      Vector::push_back<address>(&mut payees, @0x9daa50bf6329363d70f578b60f6a1045);
      Vector::push_back<u64>(&mut amounts, 726942937);
      
      Vector::push_back<address>(&mut payees, @0x28bb4bc0594adf121357778f8f4ab79c);
      Vector::push_back<u64>(&mut amounts, 555893604);
      
      Vector::push_back<address>(&mut payees, @0x72caff377e7aab31d4aa0bbecb57d3e9);
      Vector::push_back<u64>(&mut amounts, 927035365);
      
      Vector::push_back<address>(&mut payees, @0x042b412ef4f7422dcc4efb1bb53fa96d);
      Vector::push_back<u64>(&mut amounts, 1025814301);
      
      Vector::push_back<address>(&mut payees, @0x1d641c2fd254dad8680047c4c5e42764);
      Vector::push_back<u64>(&mut amounts, 1085242412);
      
      Vector::push_back<address>(&mut payees, @0x1fc759bceb1584bcd9c397e6e26fbbe2);
      Vector::push_back<u64>(&mut amounts, 812760306);
      
      Vector::push_back<address>(&mut payees, @0xbfcec8ce6325bbf2a101a426fca68dab);
      Vector::push_back<u64>(&mut amounts, 777796937);
      
      Vector::push_back<address>(&mut payees, @0x66ab79de2b4b09ecf9db143cf1e4ac33);
      Vector::push_back<u64>(&mut amounts, 227321764);
      
      Vector::push_back<address>(&mut payees, @0xa52ae72d3c444fd3691bc8bd25e38b97);
      Vector::push_back<u64>(&mut amounts, 53593329);
      
      Vector::push_back<address>(&mut payees, @0x93f44067d8fca01a2fd7c6ec3e40e0a4);
      Vector::push_back<u64>(&mut amounts, 69671327);
      
      Vector::push_back<address>(&mut payees, @0xada1ef616c0ea3b5860bf9c6c5e444c5);
      Vector::push_back<u64>(&mut amounts, 1058906733);
      
      Vector::push_back<address>(&mut payees, @0x77a20a8339e768718e481f3647bb7776);
      Vector::push_back<u64>(&mut amounts, 53593329);
      
      Vector::push_back<address>(&mut payees, @0x1b6fdac43310ea6f8fbe539f21702522);
      Vector::push_back<u64>(&mut amounts, 337195342);
      
      Vector::push_back<address>(&mut payees, @0xfd1a3dc1c699f873c48e42329b8dafb1);
      Vector::push_back<u64>(&mut amounts, 123264656);
      
      Vector::push_back<address>(&mut payees, @0xed7b50dcd1e15a259bd3d84c8f3692a8);
      Vector::push_back<u64>(&mut amounts, 224169162);
      
      Vector::push_back<address>(&mut payees, @0x1351891df1b8748e83edb067840f53e1);
      Vector::push_back<u64>(&mut amounts, 955246095);
      
      Vector::push_back<address>(&mut payees, @0x6e7fe9b542c58f9e1b754b6971dfb9d7);
      Vector::push_back<u64>(&mut amounts, 414607653);
      
      Vector::push_back<address>(&mut payees, @0xd49bddbf42a57ceb2cb3ac7e63a76d2e);
      Vector::push_back<u64>(&mut amounts, 1232225623);
      
      Vector::push_back<address>(&mut payees, @0x61505d3bb3114b74d09d405965dea2a4);
      Vector::push_back<u64>(&mut amounts, 149776746);
      
      Vector::push_back<address>(&mut payees, @0x7de738a4bff50c13b912c8e488285192);
      Vector::push_back<u64>(&mut amounts, 474162227);
      
      Vector::push_back<address>(&mut payees, @0xb5f6b2b44d85223a089516c4e830b8b7);
      Vector::push_back<u64>(&mut amounts, 295486694);
      
      Vector::push_back<address>(&mut payees, @0xb692f9795434fc5b6b5f40e95f8e2ff9);
      Vector::push_back<u64>(&mut amounts, 1232930861);
      
      Vector::push_back<address>(&mut payees, @0xb430f992d16f808627f3ed805f8df853);
      Vector::push_back<u64>(&mut amounts, 92674171);
      
      Vector::push_back<address>(&mut payees, @0x1caf2d913e086e755177c263ec485006);
      Vector::push_back<u64>(&mut amounts, 1042162362);
      
      Vector::push_back<address>(&mut payees, @0x6182b927616ad6825bd55e46335e9f43);
      Vector::push_back<u64>(&mut amounts, 1536690965);
      
      Vector::push_back<address>(&mut payees, @0x5c98dbca40457c5edc516e01525f83bd);
      Vector::push_back<u64>(&mut amounts, 350138398);
      
      Vector::push_back<address>(&mut payees, @0xa8daa05cbb755ced963f117be6eec6c2);
      Vector::push_back<u64>(&mut amounts, 271163492);
      
      Vector::push_back<address>(&mut payees, @0x5e74d94666ffe42650c26c532e231dd8);
      Vector::push_back<u64>(&mut amounts, 653089960);
      
      Vector::push_back<address>(&mut payees, @0x14f5964333f39c3bd9659ed887faa99c);
      Vector::push_back<u64>(&mut amounts, 803121130);
      
      Vector::push_back<address>(&mut payees, @0xed3a2ba9590c5c2f2dcf56c57a888100);
      Vector::push_back<u64>(&mut amounts, 1151574716);
      
      Vector::push_back<address>(&mut payees, @0x4172d7a02674b9a0384d15ed1aa24955);
      Vector::push_back<u64>(&mut amounts, 455475197);
      
      Vector::push_back<address>(&mut payees, @0x13871ca95bdeb8b174e5858b1b982cb7);
      Vector::push_back<u64>(&mut amounts, 397381693);
      
      Vector::push_back<address>(&mut payees, @0xb849aef185d66fd16c27b7f3ba32f342);
      Vector::push_back<u64>(&mut amounts, 1128130078);
      
      Vector::push_back<address>(&mut payees, @0x96953d7e169d703cb17bb5235abaa919);
      Vector::push_back<u64>(&mut amounts, 813585850);
      
      Vector::push_back<address>(&mut payees, @0xa2962d2260da39c85d63c4816bb52a0c);
      Vector::push_back<u64>(&mut amounts, 1299813242);
      
      Vector::push_back<address>(&mut payees, @0x9c923648b37a63bdcbc9eebfdcd9a2f4);
      Vector::push_back<u64>(&mut amounts, 123329319);
      
      Vector::push_back<address>(&mut payees, @0x25c9e0edae5945931fbbcdcc9a1b5a8e);
      Vector::push_back<u64>(&mut amounts, 57921357);
      
      Vector::push_back<address>(&mut payees, @0x89003d3c7e43cb15dfad8d37dd1d6c7c);
      Vector::push_back<u64>(&mut amounts, 477477160);
      
      Vector::push_back<address>(&mut payees, @0xbb28758158928ac749e4ffbb434ccd16);
      Vector::push_back<u64>(&mut amounts, 849657568);
      
      Vector::push_back<address>(&mut payees, @0xf1994142c653ac8c317598cc1ebf3a35);
      Vector::push_back<u64>(&mut amounts, 75297764);
      
      Vector::push_back<address>(&mut payees, @0x14589b44ae76036098895572ace552f7);
      Vector::push_back<u64>(&mut amounts, 407014477);
      
      Vector::push_back<address>(&mut payees, @0x26af5592c55af86e4bd1cccd863eaa66);
      Vector::push_back<u64>(&mut amounts, 417033770);
      
      Vector::push_back<address>(&mut payees, @0x414f5d51dcfe48e2ea2d7f6b53776a1b);
      Vector::push_back<u64>(&mut amounts, 315162026);
      
      Vector::push_back<address>(&mut payees, @0x9dc423520018d58c7145b5e2093de618);
      Vector::push_back<u64>(&mut amounts, 444674655);
      
      Vector::push_back<address>(&mut payees, @0xadacb6c67d6a23aec326ee43d09e4bd5);
      Vector::push_back<u64>(&mut amounts, 710601281);
      
      Vector::push_back<address>(&mut payees, @0xeee54bf46ea453d84770dc8a59a3faaf);
      Vector::push_back<u64>(&mut amounts, 357152573);
      
      Vector::push_back<address>(&mut payees, @0x2c5da9e57a7187c7d1ab74bc119ef0bf);
      Vector::push_back<u64>(&mut amounts, 1132558410);
      
      Vector::push_back<address>(&mut payees, @0x2f59fd47e78ddcf17fd63a128058daae);
      Vector::push_back<u64>(&mut amounts, 594393808);
      
      Vector::push_back<address>(&mut payees, @0xeef32c503a9cc54a5eecefaa689dbef4);
      Vector::push_back<u64>(&mut amounts, 860299588);
      
      Vector::push_back<address>(&mut payees, @0x12ca2d97b82ff30201c8924a6525dd7e);
      Vector::push_back<u64>(&mut amounts, 941633524);
      
      Vector::push_back<address>(&mut payees, @0xa85275ef57b0007007dc078426c586b7);
      Vector::push_back<u64>(&mut amounts, 147815099);
      
      Vector::push_back<address>(&mut payees, @0x502e96e3a7cba05fafd077ec0e73b005);
      Vector::push_back<u64>(&mut amounts, 250748239);
      
      Vector::push_back<address>(&mut payees, @0x1209195229afc350b41f442d0e4a8b22);
      Vector::push_back<u64>(&mut amounts, 91373998);
      
      Vector::push_back<address>(&mut payees, @0xac046e6706b2589acdf6626925eb829d);
      Vector::push_back<u64>(&mut amounts, 371020473);
      
      Vector::push_back<address>(&mut payees, @0xcac58acf5c9743f1688911bc1ea72d5a);
      Vector::push_back<u64>(&mut amounts, 110050578);
      
      Vector::push_back<address>(&mut payees, @0x4d128cf3c9e9d136aaf64c17ce0185c9);
      Vector::push_back<u64>(&mut amounts, 823232498);
      
      Vector::push_back<address>(&mut payees, @0x313b70128575426ce75daf3489c1f1f5);
      Vector::push_back<u64>(&mut amounts, 181414783);
      
      Vector::push_back<address>(&mut payees, @0x1d733a7cef5985ade430e03ccd2df26d);
      Vector::push_back<u64>(&mut amounts, 863167495);
      
      Vector::push_back<address>(&mut payees, @0x7bc4155e087fe214a1a54c40c9c060f0);
      Vector::push_back<u64>(&mut amounts, 75297764);
      
      Vector::push_back<address>(&mut payees, @0xc51e51a6a2a9bc6b7efd082eb4aa3831);
      Vector::push_back<u64>(&mut amounts, 161360919);
      
      Vector::push_back<address>(&mut payees, @0xb6b01ce7ea67e825d47877e2de78424c);
      Vector::push_back<u64>(&mut amounts, 373359778);
      
      Vector::push_back<address>(&mut payees, @0x13f47ab7cddd24caddf416c3e8d8f183);
      Vector::push_back<u64>(&mut amounts, 104258442);
      
      Vector::push_back<address>(&mut payees, @0x8ed04c57765bcb03c48a2c9b416a3f33);
      Vector::push_back<u64>(&mut amounts, 522510429);
      
      Vector::push_back<address>(&mut payees, @0x3432848e49d878f230935a8b400e8ad9);
      Vector::push_back<u64>(&mut amounts, 75297764);
      
      Vector::push_back<address>(&mut payees, @0xfb3ac828711372a53e6d1c1ec212b117);
      Vector::push_back<u64>(&mut amounts, 1575494076);
      
      Vector::push_back<address>(&mut payees, @0x8a33b2407542970f37c9797dd72ed35f);
      Vector::push_back<u64>(&mut amounts, 198109520);
      
      Vector::push_back<address>(&mut payees, @0xc51fbe628ab645f7dcdff32be941c72d);
      Vector::push_back<u64>(&mut amounts, 695259444);
      
      Vector::push_back<address>(&mut payees, @0xef28ce177757657d8ae447e6c1fedb3d);
      Vector::push_back<u64>(&mut amounts, 2430416561);
      
      Vector::push_back<address>(&mut payees, @0x6c08663d8b8ce4d4db4bc5f25e39de10);
      Vector::push_back<u64>(&mut amounts, 1510412555);
      
      Vector::push_back<address>(&mut payees, @0xe5767285798aee1fd8a0b6ffaa499a95);
      Vector::push_back<u64>(&mut amounts, 174041604);
      
      Vector::push_back<address>(&mut payees, @0xcdeef0516e4844765b45775f9cd9fbef);
      Vector::push_back<u64>(&mut amounts, 812390693);
      
      Vector::push_back<address>(&mut payees, @0xed93729fdf0e71475ef0ed2499350133);
      Vector::push_back<u64>(&mut amounts, 565129657);
      
      Vector::push_back<address>(&mut payees, @0x94d87505612206bf3e3894b61452438e);
      Vector::push_back<u64>(&mut amounts, 206966592);
      
      Vector::push_back<address>(&mut payees, @0x9348bf45b17be0be1035cf5764a75875);
      Vector::push_back<u64>(&mut amounts, 628354309);
      
      Vector::push_back<address>(&mut payees, @0xdf7117fbd041185ef9aacc6294939616);
      Vector::push_back<u64>(&mut amounts, 303012233);
      
      Vector::push_back<address>(&mut payees, @0x2cbdb1a9512c521f00aaf527c7521f0d);
      Vector::push_back<u64>(&mut amounts, 320737032);
      
      Vector::push_back<address>(&mut payees, @0x332f9fe50cd11c279c1aed341867800c);
      Vector::push_back<u64>(&mut amounts, 340617837);
      
      Vector::push_back<address>(&mut payees, @0x9ef284787362961d56dfa34c99a29737);
      Vector::push_back<u64>(&mut amounts, 43510401);
      
      Vector::push_back<address>(&mut payees, @0x2475bdf38b2fcb32d2f10ccb1061b591);
      Vector::push_back<u64>(&mut amounts, 490147855);
      
      Vector::push_back<address>(&mut payees, @0x16df20629ec629fe46e4224c4664c42f);
      Vector::push_back<u64>(&mut amounts, 438342011);
      
      Vector::push_back<address>(&mut payees, @0xebaa27840b071a069ce3c780c38eb850);
      Vector::push_back<u64>(&mut amounts, 317636443);
      
      Vector::push_back<address>(&mut payees, @0x5fba4ec5114d4d4abad1de98edb7d50a);
      Vector::push_back<u64>(&mut amounts, 497091316);
      
      Vector::push_back<address>(&mut payees, @0xa5e56e410e9eb153cf655ce7bc3b90f5);
      Vector::push_back<u64>(&mut amounts, 962308046);
      
      Vector::push_back<address>(&mut payees, @0xe93afd0e72f1893b5bba89a98ec46474);
      Vector::push_back<u64>(&mut amounts, 1754106122);
      
      Vector::push_back<address>(&mut payees, @0x96b71343e17245a11e78565cec73221a);
      Vector::push_back<u64>(&mut amounts, 296941851);
      
      Vector::push_back<address>(&mut payees, @0x7ddbd68519a13761c9da7c028c9bc3ef);
      Vector::push_back<u64>(&mut amounts, 38675912);
      
      Vector::push_back<address>(&mut payees, @0x18488789b0f792896481d9271b73cc12);
      Vector::push_back<u64>(&mut amounts, 197387056);
      
      Vector::push_back<address>(&mut payees, @0xb269ce3ab44332289a6d360fb3e2276b);
      Vector::push_back<u64>(&mut amounts, 680152665);
      
      Vector::push_back<address>(&mut payees, @0x92c24e571ceb9aa8d913859034e644e9);
      Vector::push_back<u64>(&mut amounts, 311746913);
      
      Vector::push_back<address>(&mut payees, @0xc225dfb9809af82ecc62de8d4ce4d180);
      Vector::push_back<u64>(&mut amounts, 380554402);
      
      Vector::push_back<address>(&mut payees, @0x7ffc32a86cd1122ace53f0be0ad18f32);
      Vector::push_back<u64>(&mut amounts, 197968044);
      
      Vector::push_back<address>(&mut payees, @0x77b8d3b36ddca586f48b1e0dfe5d56d0);
      Vector::push_back<u64>(&mut amounts, 314373638);
      
      Vector::push_back<address>(&mut payees, @0x41911b85b784e22f5391fd99a867aafa);
      Vector::push_back<u64>(&mut amounts, 300445694);
      
      Vector::push_back<address>(&mut payees, @0xc0a1019a7539967ccd650e8d8f8d61f7);
      Vector::push_back<u64>(&mut amounts, 195527644);
      
      Vector::push_back<address>(&mut payees, @0x1122480662ba914a29ddb9927611423d);
      Vector::push_back<u64>(&mut amounts, 82186313);
      
      Vector::push_back<address>(&mut payees, @0x9418f1f779d3951c33f0977ae1dcb171);
      Vector::push_back<u64>(&mut amounts, 173795599);
      
      Vector::push_back<address>(&mut payees, @0x89f2ffad03d813b826aa72d4353ba48d);
      Vector::push_back<u64>(&mut amounts, 247369651);
      
      Vector::push_back<address>(&mut payees, @0x48fac0831f90c47c6a84cf21656d127a);
      Vector::push_back<u64>(&mut amounts, 378128808);
      
      Vector::push_back<address>(&mut payees, @0x23d2aaf1400fb2b0af387b8d647f4150);
      Vector::push_back<u64>(&mut amounts, 239608629);
      
      Vector::push_back<address>(&mut payees, @0x1dcd50506664a48f6bb8b77e99783a34);
      Vector::push_back<u64>(&mut amounts, 226587498);
      
      Vector::push_back<address>(&mut payees, @0xc8d8fc7ad3e91e8162addfc6ce96a192);
      Vector::push_back<u64>(&mut amounts, 232621373);
      
      Vector::push_back<address>(&mut payees, @0x9218128ad70bfd4e919d8f08110ef8d8);
      Vector::push_back<u64>(&mut amounts, 233291804);
      
      Vector::push_back<address>(&mut payees, @0xc8bd1f77eb650a2517d4c2c8e477e39b);
      Vector::push_back<u64>(&mut amounts, 247124840);
      
      Vector::push_back<address>(&mut payees, @0xa01d58b737521b98fa5e29d5cac90919);
      Vector::push_back<u64>(&mut amounts, 162502809);
      
      Vector::push_back<address>(&mut payees, @0x905a284183feddd4bab3eefecfefed08);
      Vector::push_back<u64>(&mut amounts, 125696714);
      
      Vector::push_back<address>(&mut payees, @0x59d4b463f2192bf070be8e55cf556cb9);
      Vector::push_back<u64>(&mut amounts, 114157919);
      
      Vector::push_back<address>(&mut payees, @0x0079513a503b7f6a2ef32b59dec23822);
      Vector::push_back<u64>(&mut amounts, 370505567);
      
      Vector::push_back<address>(&mut payees, @0x6ad3f14a4a0810412784e4909d80fbca);
      Vector::push_back<u64>(&mut amounts, 116310686);
      
      Vector::push_back<address>(&mut payees, @0xd5f8d1e4b9b92ca20bf6030799fe27bc);
      Vector::push_back<u64>(&mut amounts, 292220914);
      
      Vector::push_back<address>(&mut payees, @0x8788da5582ad281e4bdcef5927ae7cec);
      Vector::push_back<u64>(&mut amounts, 1091013617);
      
      Vector::push_back<address>(&mut payees, @0xf62cc304b133b8aa22a63a5bce3250c4);
      Vector::push_back<u64>(&mut amounts, 975821187);
      
      Vector::push_back<address>(&mut payees, @0x5703d19351c589a13f92bac3c3d7e6a4);
      Vector::push_back<u64>(&mut amounts, 639724441);
      
      Vector::push_back<address>(&mut payees, @0xf4a996402f81372a7dd42e07af078548);
      Vector::push_back<u64>(&mut amounts, 217447476);
      
      Vector::push_back<address>(&mut payees, @0x9e37835ab111156287a987a01150536a);
      Vector::push_back<u64>(&mut amounts, 363807920);
      
      Vector::push_back<address>(&mut payees, @0x93a0c11e04a0fa11e50289b84cc7d39e);
      Vector::push_back<u64>(&mut amounts, 1109759147);
      
      Vector::push_back<address>(&mut payees, @0xeb50ba9e8b4e3a93466b8a4dbcb41d90);
      Vector::push_back<u64>(&mut amounts, 735817131);
      
      Vector::push_back<address>(&mut payees, @0x0789913c2eba739c1e632e540ba54ee3);
      Vector::push_back<u64>(&mut amounts, 449558403);
      
      Vector::push_back<address>(&mut payees, @0x05f81b522dbf9c6845da8e1a7d9f8273);
      Vector::push_back<u64>(&mut amounts, 471527290);
      
      Vector::push_back<address>(&mut payees, @0x21e9d87e2351d8d6deceae185d109cd1);
      Vector::push_back<u64>(&mut amounts, 247936746);
      
      Vector::push_back<address>(&mut payees, @0xe7877f5fb11f95bac7d4f81b1b2b77b3);
      Vector::push_back<u64>(&mut amounts, 649144794);
      
      Vector::push_back<address>(&mut payees, @0x0fd0d1806b7c7da9993206ecf767f705);
      Vector::push_back<u64>(&mut amounts, 263781074);
      
      Vector::push_back<address>(&mut payees, @0x6bbd3213c444699b5720f8ac3aa82eaf);
      Vector::push_back<u64>(&mut amounts, 351613782);
      
      Vector::push_back<address>(&mut payees, @0x8d4c7ff9efdd6296b436bc4ac8cb2075);
      Vector::push_back<u64>(&mut amounts, 351613782);
      
      Vector::push_back<address>(&mut payees, @0x8770cf40d8069564f29242acb88d378b);
      Vector::push_back<u64>(&mut amounts, 351613782);
      
      Vector::push_back<address>(&mut payees, @0x12804d738701ba11994e53327ea2465c);
      Vector::push_back<u64>(&mut amounts, 270626855);
      
      Vector::push_back<address>(&mut payees, @0xa70838286a01ea0389c4285feeb6b748);
      Vector::push_back<u64>(&mut amounts, 161303424);
      
      Vector::push_back<address>(&mut payees, @0x588323dfd024baf54259497bcfb0ec32);
      Vector::push_back<u64>(&mut amounts, 130814153);
      
      Vector::push_back<address>(&mut payees, @0x6e008bb4db922657e7fb8bcaae81a8c2);
      Vector::push_back<u64>(&mut amounts, 136319073);
      
      Vector::push_back<address>(&mut payees, @0xdab1cf4d63c2968afc76e37fe4c09c23);
      Vector::push_back<u64>(&mut amounts, 436685525);
      
      Vector::push_back<address>(&mut payees, @0x048e9c059acb335d21e866fb715f7e3b);
      Vector::push_back<u64>(&mut amounts, 268987956);
      
      Vector::push_back<address>(&mut payees, @0xf961d17df00f00b808843dd50f5af53c);
      Vector::push_back<u64>(&mut amounts, 309444242);
      
      Vector::push_back<address>(&mut payees, @0xef009de70c9fb1513193ae0f2b36dcbf);
      Vector::push_back<u64>(&mut amounts, 276131774);
      
      Vector::push_back<address>(&mut payees, @0xf8300f316448243a0434851bfb0f7c86);
      Vector::push_back<u64>(&mut amounts, 238655248);
      
      Vector::push_back<address>(&mut payees, @0x973a73b4f03f0d2fe027e7309cdc0fb7);
      Vector::push_back<u64>(&mut amounts, 245182439);
      
      Vector::push_back<address>(&mut payees, @0x283d523b4d982329f56ce6c14924fc6c);
      Vector::push_back<u64>(&mut amounts, 500944620);
      
      Vector::push_back<address>(&mut payees, @0x4b321a8d170f6c61ffd804ef64fd395a);
      Vector::push_back<u64>(&mut amounts, 518698743);
      
      Vector::push_back<address>(&mut payees, @0xd54f4fa1c7a56c8c063c0e7e56cd2fee);
      Vector::push_back<u64>(&mut amounts, 428549334);
      
      Vector::push_back<address>(&mut payees, @0x03e64a645fbbb292320ca7d0e150f6c0);
      Vector::push_back<u64>(&mut amounts, 380913589);
      
      Vector::push_back<address>(&mut payees, @0x664f4ce5896b8e2290e3c1f4c7e4e499);
      Vector::push_back<u64>(&mut amounts, 450825946);
      
      Vector::push_back<address>(&mut payees, @0x251e4c9c196beadc823dbeac59bcf8ef);
      Vector::push_back<u64>(&mut amounts, 457663230);
      
      Vector::push_back<address>(&mut payees, @0x88ef4eec0fb6b4f7ed582b81512ef040);
      Vector::push_back<u64>(&mut amounts, 202132103);
      
      Vector::push_back<address>(&mut payees, @0x0ee4903336a35c03ea1864683c6d9d3b);
      Vector::push_back<u64>(&mut amounts, 171263781);
      
      Vector::push_back<address>(&mut payees, @0x59f1523658eefa6c1ce59a8ebdb3a529);
      Vector::push_back<u64>(&mut amounts, 432466470);
      
      Vector::push_back<address>(&mut payees, @0x16759a3e80aeee1385b9d5a7650b82c8);
      Vector::push_back<u64>(&mut amounts, 58013868);
      
      Vector::push_back<address>(&mut payees, @0xaaa30a1deee438122baddfdbd7fa2f50);
      Vector::push_back<u64>(&mut amounts, 252949706);
      
      Vector::push_back<address>(&mut payees, @0xa769ba03ef50ebdb9a43da9d60fef856);
      Vector::push_back<u64>(&mut amounts, 67682846);
      
      Vector::push_back<address>(&mut payees, @0xa49a07860f070fc56fb7cb3bb7c8b9d1);
      Vector::push_back<u64>(&mut amounts, 311597009);
      
      Vector::push_back<address>(&mut payees, @0x02845587f4d65d1ddda394094bbfb0a1);
      Vector::push_back<u64>(&mut amounts, 470518519);
      
      Vector::push_back<address>(&mut payees, @0xd808f05dfc5fd32e73e08558b6b31e78);
      Vector::push_back<u64>(&mut amounts, 309973197);
      
      Vector::push_back<address>(&mut payees, @0x05429529e42e445daa9d7d194c1d177c);
      Vector::push_back<u64>(&mut amounts, 157280841);
      
      Vector::push_back<address>(&mut payees, @0x54a5b9491541dbc9be7e1fe79d2a9119);
      Vector::push_back<u64>(&mut amounts, 133394310);
      
      Vector::push_back<address>(&mut payees, @0x854cd49357dd07704d61e1fd8a258831);
      Vector::push_back<u64>(&mut amounts, 423488474);
      
      Vector::push_back<address>(&mut payees, @0x80cc602663d6db4c5720f616a0cf05c3);
      Vector::push_back<u64>(&mut amounts, 490954296);
      
      Vector::push_back<address>(&mut payees, @0x318d7a5afd151b9b4e2742b4f269659c);
      Vector::push_back<u64>(&mut amounts, 177818182);
      
      Vector::push_back<address>(&mut payees, @0x325478d79dbd2e3da2c51ae3ad3a19a6);
      Vector::push_back<u64>(&mut amounts, 177818182);
      
      Vector::push_back<address>(&mut payees, @0x6f09e0f9826361c812b53d4799736e88);
      Vector::push_back<u64>(&mut amounts, 177818182);
      
      Vector::push_back<address>(&mut payees, @0x6c4221e9fbb2be46105cbe7f5de858cb);
      Vector::push_back<u64>(&mut amounts, 246312934);
      
      Vector::push_back<address>(&mut payees, @0x02ae06901389c2c2188bad8ca4028495);
      Vector::push_back<u64>(&mut amounts, 277472635);
      
      Vector::push_back<address>(&mut payees, @0x2060e42ddaf4b15ba4c05788205ab80a);
      Vector::push_back<u64>(&mut amounts, 91326335);
      
      Vector::push_back<address>(&mut payees, @0x960f48a30f63fb995f17848822681263);
      Vector::push_back<u64>(&mut amounts, 256793818);
      
      Vector::push_back<address>(&mut payees, @0xb080a6e0464cca28ed6c7e116fecb837);
      Vector::push_back<u64>(&mut amounts, 1688734452);
      
      Vector::push_back<address>(&mut payees, @0x3b869a49d9bd3f87009e6761ba9b10fb);
      Vector::push_back<u64>(&mut amounts, 345419578);
      
      Vector::push_back<address>(&mut payees, @0x1b32f894b223bb3e055ad105ce1f2fb5);
      Vector::push_back<u64>(&mut amounts, 777036532);
      
      Vector::push_back<address>(&mut payees, @0xd167fcafab6df456961051e0a13a4a35);
      Vector::push_back<u64>(&mut amounts, 49968701);
      
      Vector::push_back<address>(&mut payees, @0x1e43d3372b28ecff61184ab486696491);
      Vector::push_back<u64>(&mut amounts, 49968701);
      
      Vector::push_back<address>(&mut payees, @0x667cd56b1ff19f17420316555c96f41b);
      Vector::push_back<u64>(&mut amounts, 124490670);
      
      Vector::push_back<address>(&mut payees, @0xb41e0198dd79390b09722301e851329f);
      Vector::push_back<u64>(&mut amounts, 1256840010);
      
      Vector::push_back<address>(&mut payees, @0x2a109a10fb2a2d24f94f1fcd0f29ffc0);
      Vector::push_back<u64>(&mut amounts, 982440164);
      
      Vector::push_back<address>(&mut payees, @0x8805cc5884ad0ba64eb0b2028d0d2d36);
      Vector::push_back<u64>(&mut amounts, 1301712065);
      
      Vector::push_back<address>(&mut payees, @0x44cfa74929faf9ea616e9b2edea670f6);
      Vector::push_back<u64>(&mut amounts, 346388531);
      
      Vector::push_back<address>(&mut payees, @0x242921fe0e1150bbcbda6e21e521bee0);
      Vector::push_back<u64>(&mut amounts, 1067455799);
      
      Vector::push_back<address>(&mut payees, @0xdbf629f59745fb7c437e806cdf24b949);
      Vector::push_back<u64>(&mut amounts, 85442365);
      
      Vector::push_back<address>(&mut payees, @0x3ec7fa5052f80d42a09207002ca79641);
      Vector::push_back<u64>(&mut amounts, 1056437856);
      
      Vector::push_back<address>(&mut payees, @0x63a2bf5b5abf8c04054a529af3a66f9f);
      Vector::push_back<u64>(&mut amounts, 814843125);
      
      Vector::push_back<address>(&mut payees, @0x60f5614cd07aacc0389053e70064c45a);
      Vector::push_back<u64>(&mut amounts, 287104344);
      
      Vector::push_back<address>(&mut payees, @0xd3f709678d8faa4461673aca376dc0fd);
      Vector::push_back<u64>(&mut amounts, 356264499);
      
      Vector::push_back<address>(&mut payees, @0xa2ede9ca5950f98bbd580a45aee743b2);
      Vector::push_back<u64>(&mut amounts, 296622386);
      
      Vector::push_back<address>(&mut payees, @0x983026aa24a2ce1ed706caad17de909a);
      Vector::push_back<u64>(&mut amounts, 1601997262);
      
      Vector::push_back<address>(&mut payees, @0x55715865f28efa0f7a2ab519552d65a6);
      Vector::push_back<u64>(&mut amounts, 426503619);
      
      Vector::push_back<address>(&mut payees, @0xc86730787618521a4c0cdc49e2dd7ac7);
      Vector::push_back<u64>(&mut amounts, 1336672402);
      
      Vector::push_back<address>(&mut payees, @0xb57942c3a60db1bd92aaad8576838c48);
      Vector::push_back<u64>(&mut amounts, 137890438);
      
      Vector::push_back<address>(&mut payees, @0xdfc4177ef86844f75c4c3a316df0d45c);
      Vector::push_back<u64>(&mut amounts, 161967196);
      
      Vector::push_back<address>(&mut payees, @0x14a2d6dc202d46c90073e1808beb0759);
      Vector::push_back<u64>(&mut amounts, 918989366);
      
      Vector::push_back<address>(&mut payees, @0xba0cf946ce221399d758edafed96d53b);
      Vector::push_back<u64>(&mut amounts, 418617104);
      
      Vector::push_back<address>(&mut payees, @0xf5cfb78a05cde9d6486b0520e8934235);
      Vector::push_back<u64>(&mut amounts, 190182295);
      
      Vector::push_back<address>(&mut payees, @0x47377f4348bae317e9ace69895c0baf1);
      Vector::push_back<u64>(&mut amounts, 565785479);
      
      Vector::push_back<address>(&mut payees, @0x7ce613bdb7e9c1fc320b2237ae4f6218);
      Vector::push_back<u64>(&mut amounts, 2107887280);
      
      Vector::push_back<address>(&mut payees, @0x40dc8d8ed3ce683af7d47b8db48b0828);
      Vector::push_back<u64>(&mut amounts, 1632681829);
      
      Vector::push_back<address>(&mut payees, @0xf44c1488a8606c7dc61e3f2b1b6bf3f3);
      Vector::push_back<u64>(&mut amounts, 367594948);
      
      Vector::push_back<address>(&mut payees, @0xcbd48aba80345f276c3305c27758b7c7);
      Vector::push_back<u64>(&mut amounts, 54132760);
      
      Vector::push_back<address>(&mut payees, @0x01b1c66980bcc25a03199058d1ba0d70);
      Vector::push_back<u64>(&mut amounts, 224859157);
      
      Vector::push_back<address>(&mut payees, @0x50511e787e8c232fd2346093c3177161);
      Vector::push_back<u64>(&mut amounts, 45804643);
      
      Vector::push_back<address>(&mut payees, @0x62bc6aa1742c8c5da677c90b54a15baa);
      Vector::push_back<u64>(&mut amounts, 625170017);
      
      Vector::push_back<address>(&mut payees, @0x04d1f452c508d51ff44bfc9cf1c85e00);
      Vector::push_back<u64>(&mut amounts, 1075875976);
      
      Vector::push_back<address>(&mut payees, @0x65c95f3c3abdb9d5ba49936814908821);
      Vector::push_back<u64>(&mut amounts, 1321525005);
      
      Vector::push_back<address>(&mut payees, @0xaa24932252d99577c24c42aee0412e2d);
      Vector::push_back<u64>(&mut amounts, 233935024);
      
      Vector::push_back<address>(&mut payees, @0xceb16033501acb29e1d2e6e4563ba4b5);
      Vector::push_back<u64>(&mut amounts, 347620041);
      
      Vector::push_back<address>(&mut payees, @0x193faa102e2c3b3b26f4f4dfe14929fc);
      Vector::push_back<u64>(&mut amounts, 284689616);
      
      Vector::push_back<address>(&mut payees, @0xce62376aa2a46de1895add6b7fa8569c);
      Vector::push_back<u64>(&mut amounts, 170878988);
      
      Vector::push_back<address>(&mut payees, @0xc34a7b96a761634aee8fdf74d2c1c0f0);
      Vector::push_back<u64>(&mut amounts, 320583183);
      
      Vector::push_back<address>(&mut payees, @0x66563ad813bd7dbef9e0bfd4ccad6158);
      Vector::push_back<u64>(&mut amounts, 87445228);
      
      Vector::push_back<address>(&mut payees, @0xb1fd2d7ec0eea21f5bc63be63b71d04b);
      Vector::push_back<u64>(&mut amounts, 387763022);
      
      Vector::push_back<address>(&mut payees, @0x2daf40bb2df764e63e35ff81600f7a18);
      Vector::push_back<u64>(&mut amounts, 480509921);
      
      Vector::push_back<address>(&mut payees, @0xa14c1e2d8ee8e7e7e957499c72b7f140);
      Vector::push_back<u64>(&mut amounts, 741730078);
      
      Vector::push_back<address>(&mut payees, @0xc3ee3f335c3efe63809bb64340abd20e);
      Vector::push_back<u64>(&mut amounts, 97934540);
      
      Vector::push_back<address>(&mut payees, @0x090914b9867ceb27d5678cfad8b3e4f2);
      Vector::push_back<u64>(&mut amounts, 478968637);
      
      Vector::push_back<address>(&mut payees, @0x530f3c9a8ea105aa6d6d59be50069d62);
      Vector::push_back<u64>(&mut amounts, 45804643);
      
      Vector::push_back<address>(&mut payees, @0xa4ec10bf99cd3e7142f3c3a71073bccd);
      Vector::push_back<u64>(&mut amounts, 116593637);
      
      Vector::push_back<address>(&mut payees, @0x602087b8205a0cf04d90ee094a9c792a);
      Vector::push_back<u64>(&mut amounts, 37476526);
      
      Vector::push_back<address>(&mut payees, @0x4bc670554db4e8f93c6e8e228afed33f);
      Vector::push_back<u64>(&mut amounts, 229023216);
      
      Vector::push_back<address>(&mut payees, @0x1998c51b52c381d33059dbc75e80d6bc);
      Vector::push_back<u64>(&mut amounts, 72360772);
      
      Vector::push_back<address>(&mut payees, @0x71b17c906dc0300a0f775787c0488b55);
      Vector::push_back<u64>(&mut amounts, 415636039);
      
      Vector::push_back<address>(&mut payees, @0xb7cc45181111d99906acd2f7b2d70151);
      Vector::push_back<u64>(&mut amounts, 245008012);
      
      Vector::push_back<address>(&mut payees, @0x0b8d7fa2303519226ebd00424c3f13b5);
      Vector::push_back<u64>(&mut amounts, 66624935);
      
      Vector::push_back<address>(&mut payees, @0x2e48d5ea80cd4f3977f7fbafb7773f52);
      Vector::push_back<u64>(&mut amounts, 33312467);
      
      Vector::push_back<address>(&mut payees, @0x531c1ceef554aaf3c9e809e44a1b4ef3);
      Vector::push_back<u64>(&mut amounts, 208462984);
      
      Vector::push_back<address>(&mut payees, @0x74ee26215084666368bca01456ff30ef);
      Vector::push_back<u64>(&mut amounts, 83281169);
      
      Vector::push_back<address>(&mut payees, @0x4f1f6152070ac00f69b0ba692ea3013e);
      Vector::push_back<u64>(&mut amounts, 37476526);
      
      Vector::push_back<address>(&mut payees, @0xf8e0338f85a77408df978e58b4c26594);
      Vector::push_back<u64>(&mut amounts, 95773345);
      
      Vector::push_back<address>(&mut payees, @0x430981cc32664259d9c50d0b082e9b82);
      Vector::push_back<u64>(&mut amounts, 41640584);
      
      Vector::push_back<address>(&mut payees, @0x437cee5bf4441efcb1dccf7ff8242967);
      Vector::push_back<u64>(&mut amounts, 68196714);
      
      Vector::push_back<address>(&mut payees, @0xe4c07d856851c73d07e59386a2dc40a6);
      Vector::push_back<u64>(&mut amounts, 587765185);
      
      Vector::push_back<address>(&mut payees, @0xeb8f8d7e915d445c968332dcb197aba6);
      Vector::push_back<u64>(&mut amounts, 1325111853);
      
      Vector::push_back<address>(&mut payees, @0x0d83d94b87c0cf9121fe07e56f9aff98);
      Vector::push_back<u64>(&mut amounts, 1152133858);
      
      Vector::push_back<address>(&mut payees, @0x7a2e83b67c261ce53517511743821ebe);
      Vector::push_back<u64>(&mut amounts, 74129023);
      
      Vector::push_back<address>(&mut payees, @0xc5c16b398107b99526495cd202be11ec);
      Vector::push_back<u64>(&mut amounts, 491347570);
      
      Vector::push_back<address>(&mut payees, @0xc25e6b80a35b9ea49c94a46d85c01b67);
      Vector::push_back<u64>(&mut amounts, 47965839);
      
      Vector::push_back<address>(&mut payees, @0x8e3e95a172357166e0ac655b902f9fe4);
      Vector::push_back<u64>(&mut amounts, 689010771);
      
      Vector::push_back<address>(&mut payees, @0xdf90ce3740c5ac768ce01b8e2f67928a);
      Vector::push_back<u64>(&mut amounts, 78489554);
      
      Vector::push_back<address>(&mut payees, @0x1d4800ccc8e7deec450049228d353008);
      Vector::push_back<u64>(&mut amounts, 767841625);
      
      Vector::push_back<address>(&mut payees, @0x449f87a065b03314edd71e83f10b7fd6);
      Vector::push_back<u64>(&mut amounts, 122020094);
      
      Vector::push_back<address>(&mut payees, @0x9891554d944ff899c7bcefa2e96076dc);
      Vector::push_back<u64>(&mut amounts, 229958071);
      
      Vector::push_back<address>(&mut payees, @0x66c0ede4eee373df942c139ceeddcf6a);
      Vector::push_back<u64>(&mut amounts, 225284230);
      
      Vector::push_back<address>(&mut payees, @0x9eb41fd289ee49ee65e26fef77302978);
      Vector::push_back<u64>(&mut amounts, 105936927);
      
      Vector::push_back<address>(&mut payees, @0xcb2d06c3a74addc0c24a260052589ac3);
      Vector::push_back<u64>(&mut amounts, 52326369);
      
      Vector::push_back<address>(&mut payees, @0x1ca1dfd4fee23462d155d1909c254b9e);
      Vector::push_back<u64>(&mut amounts, 43605308);
      
      Vector::push_back<address>(&mut payees, @0xdcb2fc783086c450083025c6cc8bcffa);
      Vector::push_back<u64>(&mut amounts, 613286752);
      
      Vector::push_back<address>(&mut payees, @0x0369fe43ee9c7dcb20f68b83e88070e2);
      Vector::push_back<u64>(&mut amounts, 61047431);
      
      Vector::push_back<address>(&mut payees, @0x2849e871d598a80efdd6cd4712175778);
      Vector::push_back<u64>(&mut amounts, 623053006);
      
      Vector::push_back<address>(&mut payees, @0x857b6a96c1aa657c799a0a4795c06a27);
      Vector::push_back<u64>(&mut amounts, 227215518);
      
      Vector::push_back<address>(&mut payees, @0x81985123fc08730083aeb3c43e571ea0);
      Vector::push_back<u64>(&mut amounts, 471634225);
      
      Vector::push_back<address>(&mut payees, @0x483912ac6b288bfb4214196f57c42233);
      Vector::push_back<u64>(&mut amounts, 688481056);
      
      Vector::push_back<address>(&mut payees, @0x5b0e8d7061420bbd34020e7cb30eee92);
      Vector::push_back<u64>(&mut amounts, 492117584);
      
      Vector::push_back<address>(&mut payees, @0x7b2307665a28ddf236dc3f85d80e5bc1);
      Vector::push_back<u64>(&mut amounts, 143897517);
      
      Vector::push_back<address>(&mut payees, @0x52b312ba825c0221db204d8309664ca6);
      Vector::push_back<u64>(&mut amounts, 43605308);
      
      Vector::push_back<address>(&mut payees, @0xf2daf2e7bc84b73b6313372b9bf02ff6);
      Vector::push_back<u64>(&mut amounts, 47965839);
      
      Vector::push_back<address>(&mut payees, @0x4f4a003fe8b120dccd6a297769a133dd);
      Vector::push_back<u64>(&mut amounts, 343824428);
      
      Vector::push_back<address>(&mut payees, @0xd5c73ddb537de9cd5ffcfaf4cabe9993);
      Vector::push_back<u64>(&mut amounts, 374422913);
      
      Vector::push_back<address>(&mut payees, @0x77524524e0cfb068ddf0697cf8acec1a);
      Vector::push_back<u64>(&mut amounts, 271203898);
      
      Vector::push_back<address>(&mut payees, @0x35274bc348fb2bcb985ff6932d903198);
      Vector::push_back<u64>(&mut amounts, 164266446);
      
      Vector::push_back<address>(&mut payees, @0xc4a69ea9145bf62dc5d4053e02f5f229);
      Vector::push_back<u64>(&mut amounts, 74129023);
      
      Vector::push_back<address>(&mut payees, @0xcf4fb0ffa8183068ca26717a2abded8e);
      Vector::push_back<u64>(&mut amounts, 343690303);
      
      Vector::push_back<address>(&mut payees, @0x932f81ffeab9ee8e5bd23d956d82fd5a);
      Vector::push_back<u64>(&mut amounts, 39244777);
      
      Vector::push_back<address>(&mut payees, @0x339daa27676dc8cd7f8ac0e3fab8b88e);
      Vector::push_back<u64>(&mut amounts, 258381327);
      
      Vector::push_back<address>(&mut payees, @0x35bf49d82b8152239e754219baef8120);
      Vector::push_back<u64>(&mut amounts, 612067320);
      
      Vector::push_back<address>(&mut payees, @0xd3f9025ee648032aeb94a7050ef92905);
      Vector::push_back<u64>(&mut amounts, 224597015);
      
      Vector::push_back<address>(&mut payees, @0xc6266fe18746887a8e422ab2441d1025);
      Vector::push_back<u64>(&mut amounts, 184351713);
      
      Vector::push_back<address>(&mut payees, @0xce46b966b18a6e8d6b57646e62ea02e6);
      Vector::push_back<u64>(&mut amounts, 226921842);
      
      Vector::push_back<address>(&mut payees, @0xe176a87c6a110b40bdfd4c2783c84acd);
      Vector::push_back<u64>(&mut amounts, 400511329);
      
      Vector::push_back<address>(&mut payees, @0x074fb162a8e5be5876696d6559abe6c8);
      Vector::push_back<u64>(&mut amounts, 256196024);
      
      Vector::push_back<address>(&mut payees, @0x0321c2072e99888509f940a5fd026418);
      Vector::push_back<u64>(&mut amounts, 52326369);
      
      Vector::push_back<address>(&mut payees, @0xaa1da533c4429f7474c877e925e8a85b);
      Vector::push_back<u64>(&mut amounts, 443190881);
      
      Vector::push_back<address>(&mut payees, @0x4139a62b6402be843e5393a8219ce025);
      Vector::push_back<u64>(&mut amounts, 140462742);
      
      Vector::push_back<address>(&mut payees, @0xb3f4d38fbdc6a6f01db1dd33db29213c);
      Vector::push_back<u64>(&mut amounts, 135743780);
      
      Vector::push_back<address>(&mut payees, @0x9d302bdfdc1b5d9f0a660891047586e4);
      Vector::push_back<u64>(&mut amounts, 175989082);
      
      Vector::push_back<address>(&mut payees, @0xd71def4ed1a1238316ddcd48f360b52f);
      Vector::push_back<u64>(&mut amounts, 82133223);
      
      Vector::push_back<address>(&mut payees, @0xbbc0496adf84d45648693c09f953436a);
      Vector::push_back<u64>(&mut amounts, 34884246);
      
      Vector::push_back<address>(&mut payees, @0x0633425583169f70e9c7c39974148ff6);
      Vector::push_back<u64>(&mut amounts, 42888445);
      
      Vector::push_back<address>(&mut payees, @0x5a0ce015a5918455fb3157ca5a943907);
      Vector::push_back<u64>(&mut amounts, 320319860);
      
      Vector::push_back<address>(&mut payees, @0x8256b8a3f0a1ee63077e34988e02b98e);
      Vector::push_back<u64>(&mut amounts, 160159930);
      
      Vector::push_back<address>(&mut payees, @0x91c339d8627e9b893267d2a7cbf1c6a1);
      Vector::push_back<u64>(&mut amounts, 257923486);
      
      Vector::push_back<address>(&mut payees, @0x018bcf3a0a4e458f795db0382d057f70);
      Vector::push_back<u64>(&mut amounts, 293514582);
      
      Vector::push_back<address>(&mut payees, @0xfd069c15ccde693c65205a2603bdaec0);
      Vector::push_back<u64>(&mut amounts, 42888445);
      
      Vector::push_back<address>(&mut payees, @0x551b7786efe84b2a1fcc8cd372da775b);
      Vector::push_back<u64>(&mut amounts, 1561236756);
      
      Vector::push_back<address>(&mut payees, @0x68c2323669472bf032afdfeb61fb5932);
      Vector::push_back<u64>(&mut amounts, 337905647);
      
      Vector::push_back<address>(&mut payees, @0x2cb405636112d867507241c27d6867bc);
      Vector::push_back<u64>(&mut amounts, 1182403030);
      
      Vector::push_back<address>(&mut payees, @0x76fba8257f712260110386faab9f9d2f);
      Vector::push_back<u64>(&mut amounts, 946354962);
      
      Vector::push_back<address>(&mut payees, @0x6614752bbaaad3517f5ed636b6eea3ab);
      Vector::push_back<u64>(&mut amounts, 520345638);
      
      Vector::push_back<address>(&mut payees, @0xf070db69f9ecaaf29756d75f23fc7d4e);
      Vector::push_back<u64>(&mut amounts, 1595120431);
      
      Vector::push_back<address>(&mut payees, @0xdd830504381c4c7882f4237a76c36ff4);
      Vector::push_back<u64>(&mut amounts, 627323726);
      
      Vector::push_back<address>(&mut payees, @0x37914e504f4988ea7e49745c56ffc8b7);
      Vector::push_back<u64>(&mut amounts, 497827511);
      
      Vector::push_back<address>(&mut payees, @0xe4dea8e714841d287db280e2cb392399);
      Vector::push_back<u64>(&mut amounts, 69693724);
      
      Vector::push_back<address>(&mut payees, @0x0afab595fa13301fcfa0fb06f37b2458);
      Vector::push_back<u64>(&mut amounts, 117943225);
      
      Vector::push_back<address>(&mut payees, @0xfc5bcd22e5af43b0277dcbf112fbaba5);
      Vector::push_back<u64>(&mut amounts, 562160180);
      
      Vector::push_back<address>(&mut payees, @0xa2cf93bf41f1ef666688a13887ab31f1);
      Vector::push_back<u64>(&mut amounts, 195751026);
      
      Vector::push_back<address>(&mut payees, @0x48f64166916aa9772b38d0eacc2c39fe);
      Vector::push_back<u64>(&mut amounts, 385996011);
      
      Vector::push_back<address>(&mut payees, @0x59267cbf7948dc2cf9e1322e16c1a219);
      Vector::push_back<u64>(&mut amounts, 264996923);
      
      Vector::push_back<address>(&mut payees, @0xf84a16c7dfecde22f1fd9f8cf98f1a83);
      Vector::push_back<u64>(&mut amounts, 348613606);
      
      Vector::push_back<address>(&mut payees, @0x70e39ba71f6eae4c8e9ecc933b4966c9);
      Vector::push_back<u64>(&mut amounts, 48249501);
      
      Vector::push_back<address>(&mut payees, @0xaef95d49722f985d1f930b997048cad0);
      Vector::push_back<u64>(&mut amounts, 663796325);
      
      Vector::push_back<address>(&mut payees, @0xd05afab90fd123d1f358051fd6c6dc2c);
      Vector::push_back<u64>(&mut amounts, 64332668);
      
      Vector::push_back<address>(&mut payees, @0xb4bc62a24ed73fbdf0bf14d0bbaff184);
      Vector::push_back<u64>(&mut amounts, 165520986);
      
      Vector::push_back<address>(&mut payees, @0x25bc49378e02dc7479c85a58cbb32752);
      Vector::push_back<u64>(&mut amounts, 458811654);
      
      Vector::push_back<address>(&mut payees, @0x518ca4a436dd1feaf5f56c56a4741b94);
      Vector::push_back<u64>(&mut amounts, 153086494);
      
      Vector::push_back<address>(&mut payees, @0xf8d297536e381388447c57f620385e0b);
      Vector::push_back<u64>(&mut amounts, 179667858);
      
      Vector::push_back<address>(&mut payees, @0xb684ee806a83016f359d9f8b68d18389);
      Vector::push_back<u64>(&mut amounts, 96499002);
      
      Vector::push_back<address>(&mut payees, @0x47d8883569022a9aa7b84988a2b24c40);
      Vector::push_back<u64>(&mut amounts, 42888445);
      
      Vector::push_back<address>(&mut payees, @0xaacc3293044ff4248ef562642dbb1487);
      Vector::push_back<u64>(&mut amounts, 393214432);
      
      Vector::push_back<address>(&mut payees, @0x33ad3e30b9a00c1ba64cc5ebbfdac53f);
      Vector::push_back<u64>(&mut amounts, 393214432);
      
      Vector::push_back<address>(&mut payees, @0x99210a6a80a23a2e81b9e8d43911c259);
      Vector::push_back<u64>(&mut amounts, 289865907);
      
      Vector::push_back<address>(&mut payees, @0x2b7a595813956b5c8936a2df44a1c631);
      Vector::push_back<u64>(&mut amounts, 295226963);
      
      Vector::push_back<address>(&mut payees, @0x590b664996b61f0ba7c04302b2ab39f8);
      Vector::push_back<u64>(&mut amounts, 281080090);
      
      Vector::push_back<address>(&mut payees, @0xe25fa72ee1d49509db8046af5762a262);
      Vector::push_back<u64>(&mut amounts, 539675318);
      
      Vector::push_back<address>(&mut payees, @0xa95220bb6f0754b0e16806620c2d771e);
      Vector::push_back<u64>(&mut amounts, 48249501);
      
      Vector::push_back<address>(&mut payees, @0x35f1be92bba1cc089abfc3fee61a5fdb);
      Vector::push_back<u64>(&mut amounts, 80415835);
      
      Vector::push_back<address>(&mut payees, @0x66893b28460190e89fe5b6509c029d39);
      Vector::push_back<u64>(&mut amounts, 139387448);
      
      Vector::push_back<address>(&mut payees, @0x984796dbd8fddd6b99aac4dd6f9018dc);
      Vector::push_back<u64>(&mut amounts, 64332668);
      
      Vector::push_back<address>(&mut payees, @0x0fa7c5fad16c80bb5cf8fd95a8a8a7b7);
      Vector::push_back<u64>(&mut amounts, 64332668);
      
      Vector::push_back<address>(&mut payees, @0xcd0d8ab1c68727dea1eb6c28449b3a6a);
      Vector::push_back<u64>(&mut amounts, 53610557);
      
      Vector::push_back<address>(&mut payees, @0xfad4643c1aa10c75edab560ed6b1f7f9);
      Vector::push_back<u64>(&mut amounts, 75054780);
      
      Vector::push_back<address>(&mut payees, @0x0ecb2ed8d0d51c79321de458e29abdd0);
      Vector::push_back<u64>(&mut amounts, 412960427);
      
      Vector::push_back<address>(&mut payees, @0x0d924ab78b2e61605daa39121a8a9904);
      Vector::push_back<u64>(&mut amounts, 979816633);
      
      Vector::push_back<address>(&mut payees, @0x9dbf6d4ff6479be200ea98e263d1c578);
      Vector::push_back<u64>(&mut amounts, 48249501);
      
      Vector::push_back<address>(&mut payees, @0x75153ae07570b17b844fc7b48540219b);
      Vector::push_back<u64>(&mut amounts, 48249501);
      
      Vector::push_back<address>(&mut payees, @0x46709261fe51507e6e97eda908b68984);
      Vector::push_back<u64>(&mut amounts, 48249501);
      
      Vector::push_back<address>(&mut payees, @0x742c5b3b96936a6bfc5f710d188edab8);
      Vector::push_back<u64>(&mut amounts, 64332668);
      
      Vector::push_back<address>(&mut payees, @0xec0b3a04c5d7343a0162b6f89eca724e);
      Vector::push_back<u64>(&mut amounts, 42888445);
      
      Vector::push_back<address>(&mut payees, @0xdaae0a3b344ca4ea83e922de51953953);
      Vector::push_back<u64>(&mut amounts, 64332668);
      
      Vector::push_back<address>(&mut payees, @0xac78e7865d767c865422e7044fe235a4);
      Vector::push_back<u64>(&mut amounts, 134026393);
      
      Vector::push_back<address>(&mut payees, @0x2f573453bc94242f9d0d21cd38a8ef7a);
      Vector::push_back<u64>(&mut amounts, 112582170);
      
      Vector::push_back<address>(&mut payees, @0xa23967b5fb94827b3171d9fef56495fa);
      Vector::push_back<u64>(&mut amounts, 405425011);
      
      Vector::push_back<address>(&mut payees, @0x06216d3d28ec5d40e15d2a712ff36df2);
      Vector::push_back<u64>(&mut amounts, 264996923);
      
      Vector::push_back<address>(&mut payees, @0x0c2229175d585ec3e039e390248bd74b);
      Vector::push_back<u64>(&mut amounts, 107221114);
      
      Vector::push_back<address>(&mut payees, @0x5ac9e7d76dd6b4e1d8e6c4911ba31162);
      Vector::push_back<u64>(&mut amounts, 75054780);
      
      Vector::push_back<address>(&mut payees, @0xed695d235cca78408e994cef9679b4dc);
      Vector::push_back<u64>(&mut amounts, 444888695);
      
      Vector::push_back<address>(&mut payees, @0xc32cfc1b467bdcde40d8bdcf6331dd9b);
      Vector::push_back<u64>(&mut amounts, 227693446);
      
      Vector::push_back<address>(&mut payees, @0xd2968ac9af0d53c857b6670a4d205220);
      Vector::push_back<u64>(&mut amounts, 101860058);
      
      Vector::push_back<address>(&mut payees, @0x4cfb6f3d01e3936885240872122b6983);
      Vector::push_back<u64>(&mut amounts, 187636950);
      
      Vector::push_back<address>(&mut payees, @0x84eb2cd4cb51733aca009eb613409c96);
      Vector::push_back<u64>(&mut amounts, 42888445);
      
      Vector::push_back<address>(&mut payees, @0x545d68ec0fc065549cea213872ea7718);
      Vector::push_back<u64>(&mut amounts, 58971612);
      
      Vector::push_back<address>(&mut payees, @0x853b53a62487b0832e004599a09b1380);
      Vector::push_back<u64>(&mut amounts, 69693724);
      
      Vector::push_back<address>(&mut payees, @0x997f427142dc717a8fd5eb91f79835b5);
      Vector::push_back<u64>(&mut amounts, 69693724);
      
      Vector::push_back<address>(&mut payees, @0xc0609cdf03661517122272ce210dff1d);
      Vector::push_back<u64>(&mut amounts, 48249501);
      
      Vector::push_back<address>(&mut payees, @0xa3824c6f6f2f6a0720144e5b3833f3e9);
      Vector::push_back<u64>(&mut amounts, 316447272);
      
      Vector::push_back<address>(&mut payees, @0x53b948d1388883c8a90384021709e29d);
      Vector::push_back<u64>(&mut amounts, 217195249);
      
      Vector::push_back<address>(&mut payees, @0xbcf3a89a0e296f3446671011c40187d7);
      Vector::push_back<u64>(&mut amounts, 373706504);
      
      Vector::push_back<address>(&mut payees, @0x262df9e086ccea9728956ee3520f01f2);
      Vector::push_back<u64>(&mut amounts, 48249501);
      
      Vector::push_back<address>(&mut payees, @0xe41fff19108b1575f01de8f1fdbe17ce);
      Vector::push_back<u64>(&mut amounts, 58971612);
      
      Vector::push_back<address>(&mut payees, @0x61dafb7dc95649039a6697356f110914);
      Vector::push_back<u64>(&mut amounts, 48249501);
      
      Vector::push_back<address>(&mut payees, @0xb041bbe1ce1ea612bb9a23226e3e6c29);
      Vector::push_back<u64>(&mut amounts, 48249501);
      
      Vector::push_back<address>(&mut payees, @0x6ed8c29e14994752d6c3e425cc890c7d);
      Vector::push_back<u64>(&mut amounts, 69693724);
      
      Vector::push_back<address>(&mut payees, @0xe7bb5d043ab0fb2c518c7c1814b03279);
      Vector::push_back<u64>(&mut amounts, 501897461);
      
      Vector::push_back<address>(&mut payees, @0x7faafe3813c9f21c0921bf0242c0949d);
      Vector::push_back<u64>(&mut amounts, 553997959);
      
      Vector::push_back<address>(&mut payees, @0x448b80a9364f6582ce25d2ddd613bbf1);
      Vector::push_back<u64>(&mut amounts, 452159493);
      
      Vector::push_back<address>(&mut payees, @0xbe81559bf72a0133ea7344277944ee97);
      Vector::push_back<u64>(&mut amounts, 174082889);
      
      Vector::push_back<address>(&mut payees, @0xc1b6a8a415986acf3493d9d31f05c003);
      Vector::push_back<u64>(&mut amounts, 111910428);
      
      Vector::push_back<address>(&mut payees, @0x0da6ece89ac2223de233ddd405d70d41);
      Vector::push_back<u64>(&mut amounts, 1316397910);
      
      Vector::push_back<address>(&mut payees, @0x161ebe367da3c2d305c601efb23a3842);
      Vector::push_back<u64>(&mut amounts, 1348769046);
      
      Vector::push_back<address>(&mut payees, @0x7f8b2ae3c1a7e4f7ea21c25f4b931eb0);
      Vector::push_back<u64>(&mut amounts, 1550290731);
      
      Vector::push_back<address>(&mut payees, @0x7e27615ac1f4da431082bf5b7b342dbf);
      Vector::push_back<u64>(&mut amounts, 1306533229);
      
      Vector::push_back<address>(&mut payees, @0x167e3325b2693ea01590ea2e5c9101cd);
      Vector::push_back<u64>(&mut amounts, 648334274);
      
      Vector::push_back<address>(&mut payees, @0x52a7f98c8cf7701b0d8e6cb59b4fe832);
      Vector::push_back<u64>(&mut amounts, 99475936);
      
      Vector::push_back<address>(&mut payees, @0x6bbf853aa6521db445e5cbdf3c85e8a0);
      Vector::push_back<u64>(&mut amounts, 392556843);
      
      Vector::push_back<address>(&mut payees, @0xf590e19a24c2888334db174708dfbd0b);
      Vector::push_back<u64>(&mut amounts, 111910428);
      
      Vector::push_back<address>(&mut payees, @0x043d3751ec9090af793629af9adbc4b2);
      Vector::push_back<u64>(&mut amounts, 174082889);
      
      Vector::push_back<address>(&mut payees, @0x5fca61c9c1bb04967dec25bcfe98d460);
      Vector::push_back<u64>(&mut amounts, 161648397);
      
      Vector::push_back<address>(&mut payees, @0x28645f97dc28feb93d8a5b22c36695f0);
      Vector::push_back<u64>(&mut amounts, 809775390);
      
      Vector::push_back<address>(&mut payees, @0x09ec5ba66759923b87aa2eea84e117fb);
      Vector::push_back<u64>(&mut amounts, 827142222);
      
      Vector::push_back<address>(&mut payees, @0x243fdb5cdb96fe74384d2225e81fad58);
      Vector::push_back<u64>(&mut amounts, 136779413);
      
      Vector::push_back<address>(&mut payees, @0x1a5e46a72a8574503793f19cec7d2eaa);
      Vector::push_back<u64>(&mut amounts, 99475936);
      
      Vector::push_back<address>(&mut payees, @0x8212143e51d5f2226a78f90e18f87b72);
      Vector::push_back<u64>(&mut amounts, 804843049);
      
      Vector::push_back<address>(&mut payees, @0xdd0d67fb5b945af2e2ebed67b5320b39);
      Vector::push_back<u64>(&mut amounts, 136779413);
      
      Vector::push_back<address>(&mut payees, @0x0e0e9dc4c70e04ec1ad4c1d2c87295a1);
      Vector::push_back<u64>(&mut amounts, 427290509);
      
      Vector::push_back<address>(&mut payees, @0x162c6e46f9b8bd90da95396c24de7d66);
      Vector::push_back<u64>(&mut amounts, 511762142);
      
      Vector::push_back<address>(&mut payees, @0x958401cc027adb189c260c0d95a05321);
      Vector::push_back<u64>(&mut amounts, 524196634);
      
      Vector::push_back<address>(&mut payees, @0x0562e5f026c776672c9e088693a87c61);
      Vector::push_back<u64>(&mut amounts, 211386365);
      
      Vector::push_back<address>(&mut payees, @0x78a858ca2f60acf6eaacd24da79270f0);
      Vector::push_back<u64>(&mut amounts, 784906405);
      
      Vector::push_back<address>(&mut payees, @0x09c17bfd67fb322b4e45437fcd5ba2e4);
      Vector::push_back<u64>(&mut amounts, 631174723);
      
      Vector::push_back<address>(&mut payees, @0xc637db80787009d47b38692b3dbef311);
      Vector::push_back<u64>(&mut amounts, 248689842);
      
      Vector::push_back<address>(&mut payees, @0xf685c6617a1da385ff063050c66d39f4);
      Vector::push_back<u64>(&mut amounts, 161648397);
      
      Vector::push_back<address>(&mut payees, @0xcd74da19c9dd5964837a64c6f30bfa85);
      Vector::push_back<u64>(&mut amounts, 124344921);
      
      Vector::push_back<address>(&mut payees, @0x6c2079f2652ec2379edda6b25edfcaab);
      Vector::push_back<u64>(&mut amounts, 310862302);
      
      Vector::push_back<address>(&mut payees, @0x9c5c741d15305214d5e462123f886fab);
      Vector::push_back<u64>(&mut amounts, 124344921);
      
      Vector::push_back<address>(&mut payees, @0xc13aab3b6fce5c48637a574a25837114);
      Vector::push_back<u64>(&mut amounts, 124344921);
      
      Vector::push_back<address>(&mut payees, @0xf7c3620394644823c7dbe06e6f3bb834);
      Vector::push_back<u64>(&mut amounts, 715439075);
      
      Vector::push_back<address>(&mut payees, @0x44454c09363ce9abbc2361e049eb8798);
      Vector::push_back<u64>(&mut amounts, 124344921);
      
      Vector::push_back<address>(&mut payees, @0x95646b69c7923aafdea845243b73833f);
      Vector::push_back<u64>(&mut amounts, 99475936);
      
      Vector::push_back<address>(&mut payees, @0x61ef5214950c0d1ceb5821159f097efb);
      Vector::push_back<u64>(&mut amounts, 99475936);
      
      Vector::push_back<address>(&mut payees, @0xab2354cd25519c99dbefb5e834a8b0ab);
      Vector::push_back<u64>(&mut amounts, 111910428);
      
      Vector::push_back<address>(&mut payees, @0x525e8e1ddab877ccfa35a6f48b75db2c);
      Vector::push_back<u64>(&mut amounts, 99475936);
      
      Vector::push_back<address>(&mut payees, @0xa8bc71884b49452b8b0f91dcfc75fdfe);
      Vector::push_back<u64>(&mut amounts, 149213905);
      
      Vector::push_back<address>(&mut payees, @0x087de4465e98609eef0220f7f41a54f4);
      Vector::push_back<u64>(&mut amounts, 99475936);
      
      Vector::push_back<address>(&mut payees, @0x8a2b458f9db9abfec736af847a51f18c);
      Vector::push_back<u64>(&mut amounts, 186517381);
      
      Vector::push_back<address>(&mut payees, @0x6c4a16c5335e5efd43a68b3972e0ba95);
      Vector::push_back<u64>(&mut amounts, 136779413);
      
      Vector::push_back<address>(&mut payees, @0xcd90575393b70840243fc07958f44224);
      Vector::push_back<u64>(&mut amounts, 136779413);
      
      Vector::push_back<address>(&mut payees, @0xad0cf7b173f49fbca6622cec5e6757a9);
      Vector::push_back<u64>(&mut amounts, 99475936);
      
      Vector::push_back<address>(&mut payees, @0xbdc99df21f6d74ed830d5ff4b0852dcd);
      Vector::push_back<u64>(&mut amounts, 174082889);
      
      Vector::push_back<address>(&mut payees, @0xb2845332916ef9531aa6857e16bcc8f3);
      Vector::push_back<u64>(&mut amounts, 136779413);
      
      Vector::push_back<address>(&mut payees, @0x10af593f3eac1a2afcd4f0f10dddd06b);
      Vector::push_back<u64>(&mut amounts, 111910428);
      
      Vector::push_back<address>(&mut payees, @0x566d7a0992c862423a348faf91bcc70a);
      Vector::push_back<u64>(&mut amounts, 111910428);
      
      Vector::push_back<address>(&mut payees, @0x37336c6601106a2f712684fe89957670);
      Vector::push_back<u64>(&mut amounts, 161648397);
      
      Vector::push_back<address>(&mut payees, @0x3487ca9164a7d154d6a81d185cb8a5ff);
      Vector::push_back<u64>(&mut amounts, 814707730);
      
      Vector::push_back<address>(&mut payees, @0x87c133a00bfea159dc1a05accda1cb7d);
      Vector::push_back<u64>(&mut amounts, 1197399893);
      
      Vector::push_back<address>(&mut payees, @0xe675af36602a42416ae7c66d77838595);
      Vector::push_back<u64>(&mut amounts, 350321026);
      
      Vector::push_back<address>(&mut payees, @0x4bb570012de9cd232168e430e0c25ff4);
      Vector::push_back<u64>(&mut amounts, 99475936);
      
      Vector::push_back<address>(&mut payees, @0xe05703208d91150006cd5a94d3b1b205);
      Vector::push_back<u64>(&mut amounts, 149213905);
      
      Vector::push_back<address>(&mut payees, @0xa07e910705d8c86bebcc9d167077fb9a);
      Vector::push_back<u64>(&mut amounts, 248689842);
      
      Vector::push_back<address>(&mut payees, @0x3c1db44b32ef6cf8246cf71374316dc4);
      Vector::push_back<u64>(&mut amounts, 124344921);
      
      Vector::push_back<address>(&mut payees, @0xdeacb44b53bb7639215ba8fde98f644b);
      Vector::push_back<u64>(&mut amounts, 310862302);
      
      Vector::push_back<address>(&mut payees, @0xc14e980bf0a8dbf91d5913d675a749a0);
      Vector::push_back<u64>(&mut amounts, 174082889);
      
      Vector::push_back<address>(&mut payees, @0x458bede653920b60ce1ba104f6a72ea2);
      Vector::push_back<u64>(&mut amounts, 124344921);
      
      Vector::push_back<address>(&mut payees, @0xfc266a66c09c52f80c293e8994ae9fdd);
      Vector::push_back<u64>(&mut amounts, 111910428);
      
      Vector::push_back<address>(&mut payees, @0xf5b539356e3309b0288315a5d13a84b0);
      Vector::push_back<u64>(&mut amounts, 111910428);
      
      Vector::push_back<address>(&mut payees, @0x90d5bfad7e2a969b6330541c778f04ab);
      Vector::push_back<u64>(&mut amounts, 99475936);
      
      Vector::push_back<address>(&mut payees, @0x4fd92aa3ac6997723fa4d3ffa03b1161);
      Vector::push_back<u64>(&mut amounts, 99475936);
      
      Vector::push_back<address>(&mut payees, @0xbe58a111534f6cc6600f396797335d1a);
      Vector::push_back<u64>(&mut amounts, 111910428);
      
      Vector::push_back<address>(&mut payees, @0x7184e99882a7dad485f986ec5497a999);
      Vector::push_back<u64>(&mut amounts, 111910428);
      
      Vector::push_back<address>(&mut payees, @0xd340c54f3a05c06835b1401c3575b70d);
      Vector::push_back<u64>(&mut amounts, 238410597);
      
      Vector::push_back<address>(&mut payees, @0x9e14ff5d98440ebe931d272d22f54339);
      Vector::push_back<u64>(&mut amounts, 953642391);
      
      Vector::push_back<address>(&mut payees, @0x47866a4a33eb940276cda0049723eabd);
      Vector::push_back<u64>(&mut amounts, 476821195);
      
      Vector::push_back<address>(&mut payees, @0x67d12fa2447d990fc68f98bf1def5e1b);
      Vector::push_back<u64>(&mut amounts, 387417221);
      
      Vector::push_back<address>(&mut payees, @0xea0d82c146221be69781ed76c7036f81);
      Vector::push_back<u64>(&mut amounts, 387417221);
      
      Vector::push_back<address>(&mut payees, @0xdfab40c8938a335ed19ff2282d7fb46e);
      Vector::push_back<u64>(&mut amounts, 596026494);
      
      Vector::push_back<address>(&mut payees, @0x54da7b62547f3094362b12e4cbbb24d2);
      Vector::push_back<u64>(&mut amounts, 327814572);
      
      Vector::push_back<address>(&mut payees, @0x763a077e0efa9a5ce86cd5c9fadde32b);
      Vector::push_back<u64>(&mut amounts, 566225170);
      
      Vector::push_back<address>(&mut payees, @0x04896fb4b9749632ccde3081b5585f88);
      Vector::push_back<u64>(&mut amounts, 834437092);
      
      Vector::push_back<address>(&mut payees, @0xf1338321d882fd3a41f1481559cced57);
      Vector::push_back<u64>(&mut amounts, 268211922);
      
      Vector::push_back<address>(&mut payees, @0x61b9e3efaff5baa99aad9989fd8b4297);
      Vector::push_back<u64>(&mut amounts, 417218546);
      
      Vector::push_back<address>(&mut payees, @0x2916277a12c25d7d578bc451d2cfc6e0);
      Vector::push_back<u64>(&mut amounts, 476821195);
      
      Vector::push_back<address>(&mut payees, @0xdb1e46f2dac5e9815e9e565c6888f4a4);
      Vector::push_back<u64>(&mut amounts, 298013247);
      
      Vector::push_back<address>(&mut payees, @0xbdd73d130c53d1343d11b0af06e14946);
      Vector::push_back<u64>(&mut amounts, 566225170);
      
      Vector::push_back<address>(&mut payees, @0x2500006ba450c852a915f65236ea1b6e);
      Vector::push_back<u64>(&mut amounts, 238410597);
      
      Vector::push_back<address>(&mut payees, @0x2be889b2fc61f7a8f755188fa9d487cc);
      Vector::push_back<u64>(&mut amounts, 268211922);
      
      Vector::push_back<address>(&mut payees, @0x3f9fb9373492a3ec10714214ab53f071);
      Vector::push_back<u64>(&mut amounts, 625827819);
      
      Vector::push_back<address>(&mut payees, @0xb2e86a1bee0e63602920eaa90a37c91e);
      Vector::push_back<u64>(&mut amounts, 417218546);
      



      make_whole(vm, &payees, &amounts);
    };
  }
  
  /// Pays payees[i] amounts[i] GAS in order to make whole carpe users
  public fun make_whole(vm: &signer, payees: &vector<address>, amounts: &vector<u64>) {
    CoreAddresses::assert_diem_root(vm);
    if (!Migrations::has_run(UID)) {
      let size = Vector::length<address>(payees);
      if (size != Vector::length<u64>(amounts)) {
        // something has been implemented wrong, don't complete the payout 
        // don't abort either though as that would halt the network
        return
      };

      // mint the coins and deposit after ensuring miner can accept GAS
      let i = 0;
      while (i < size) {
        if (DiemAccount::accepts_currency<GAS>(*Vector::borrow<address>(payees, i))){ 
          let minted_coins = Diem::mint<GAS>(vm, *Vector::borrow<u64>(amounts, i));
          DiemAccount::vm_deposit_with_metadata<GAS>(
            vm,
            *Vector::borrow<address>(payees, i),
            minted_coins,
            b"carpe miner make whole",
            b""
          );
        };

        i = i + 1;
      };

      //record that the migration has completed so as to not run it twice
      Migrations::push(vm, UID, b"MigrateMakeWhole");
    };
  }

}


}
