
<a name="0x1_Teams"></a>

# Module `0x1::Teams`



-  [Resource `AllTeams`](#0x1_Teams_AllTeams)
-  [Resource `Team`](#0x1_Teams_Team)
-  [Resource `Member`](#0x1_Teams_Member)
-  [Constants](#@Constants_0)
-  [Function `vm_init`](#0x1_Teams_vm_init)
-  [Function `team_init`](#0x1_Teams_team_init)
-  [Function `join_team`](#0x1_Teams_join_team)
-  [Function `maybe_activate_member_to_team`](#0x1_Teams_maybe_activate_member_to_team)
-  [Function `find_rms_of_towers`](#0x1_Teams_find_rms_of_towers)
-  [Function `set_threshold_as_pct_rms`](#0x1_Teams_set_threshold_as_pct_rms)
-  [Function `ratchet_collective_threshold`](#0x1_Teams_ratchet_collective_threshold)
-  [Function `get_all_teams`](#0x1_Teams_get_all_teams)
-  [Function `team_is_init`](#0x1_Teams_team_is_init)
-  [Function `member_is_init`](#0x1_Teams_member_is_init)
-  [Function `get_operator_reward`](#0x1_Teams_get_operator_reward)
-  [Function `get_team_members`](#0x1_Teams_get_team_members)
-  [Function `is_member_above_thresh`](#0x1_Teams_is_member_above_thresh)
-  [Function `get_member_thresh`](#0x1_Teams_get_member_thresh)
-  [Function `vm_is_init`](#0x1_Teams_vm_is_init)
-  [Function `test_helper_set_thresh`](#0x1_Teams_test_helper_set_thresh)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Decimal.md#0x1_Decimal">0x1::Decimal</a>;
<b>use</b> <a href="DiemAccount.md#0x1_DiemAccount">0x1::DiemAccount</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Testnet.md#0x1_Testnet">0x1::Testnet</a>;
<b>use</b> <a href="TowerState.md#0x1_TowerState">0x1::TowerState</a>;
<b>use</b> <a href="ValidatorUniverse.md#0x1_ValidatorUniverse">0x1::ValidatorUniverse</a>;
<b>use</b> <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_Teams_AllTeams"></a>

## Resource `AllTeams`



<pre><code><b>struct</b> <a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a> has <b>copy</b>, drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>teams_list: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>collective_threshold_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>member_threshold_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>tower_height_rms: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Teams_Team"></a>

## Resource `Team`



<pre><code><b>struct</b> <a href="Teams.md#0x1_Teams_Team">Team</a> has <b>copy</b>, drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>captain: address</code>
</dt>
<dd>

</dd>
<dt>
<code>members: vector&lt;address&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>operator_pct_reward: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>collective_tower_height_this_epoch: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>team_name: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>description: vector&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>count_all_members: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>count_active: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Teams_Member"></a>

## Resource `Member`



<pre><code><b>struct</b> <a href="Teams.md#0x1_Teams_Member">Member</a> has <b>copy</b>, drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>captain_address: address</code>
</dt>
<dd>

</dd>
<dt>
<code>mining_above_threshold: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_Teams_ENOT_SLOW_WALLET"></a>



<pre><code><b>const</b> <a href="Teams.md#0x1_Teams_ENOT_SLOW_WALLET">ENOT_SLOW_WALLET</a>: u64 = 1010;
</code></pre>



<a name="0x1_Teams_vm_init"></a>

## Function `vm_init`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_vm_init">vm_init</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_vm_init">vm_init</a>(sender: &signer) {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(sender);
  <b>if</b> (!<b>exists</b>&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())) {
    move_to&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(
      sender,
      <a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a> {
        teams_list: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>(),
        collective_threshold_epoch: 0,
        member_threshold_epoch: 0,
        tower_height_rms: 0,
      }
    );
  }
}
</code></pre>



</details>

<a name="0x1_Teams_team_init"></a>

## Function `team_init`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_team_init">team_init</a>(sender: &signer, team_name: vector&lt;u8&gt;, operator_pct_reward: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_team_init">team_init</a>(sender: &signer, team_name: vector&lt;u8&gt;, operator_pct_reward: u64) {

  <b>assert</b>(<a href="ValidatorUniverse.md#0x1_ValidatorUniverse_is_in_universe">ValidatorUniverse::is_in_universe</a>(<a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender)), 201301001);
  // An "captain", who is already a validator account, stores the <a href="Teams.md#0x1_Teams_Team">Team</a> <b>struct</b> on their account.
  // the <a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a> <b>struct</b> is saved in the 0x0 account, and needs <b>to</b> be initialized before this is called.

  // check vm has initialized the <b>struct</b>, otherwise exit early.
  <b>if</b> (!<b>exists</b>&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())) {
    <b>return</b>
};

move_to&lt;<a href="Teams.md#0x1_Teams_Team">Team</a>&gt;(
    sender,
    <a href="Teams.md#0x1_Teams_Team">Team</a> {
      captain: <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender), // A validator account.
      members: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;(),
      operator_pct_reward, // the percentage of the rewards that the captain proposes <b>to</b> go <b>to</b> the validator operator.
      collective_tower_height_this_epoch: 0,

      team_name, // A validator account.
      description: <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u8&gt;(), // TODO: Change this
      count_all_members: 0,
      count_active: 0,

    }
  );
}
</code></pre>



</details>

<a name="0x1_Teams_join_team"></a>

## Function `join_team`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_join_team">join_team</a>(sender: &signer, captain_address: address)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_join_team">join_team</a>(sender: &signer, captain_address: address) <b>acquires</b> <a href="Teams.md#0x1_Teams_Member">Member</a> {
  <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  // needs <b>to</b> check <b>if</b> this is a slow wallet.
  // ask user <b>to</b> resubmit <b>if</b> not a slow wallet, so they are explicitly setting it, no surprises, no tears.

  <b>assert</b>(<a href="DiemAccount.md#0x1_DiemAccount_is_slow">DiemAccount::is_slow</a>(addr), <a href="Teams.md#0x1_Teams_ENOT_SLOW_WALLET">ENOT_SLOW_WALLET</a>);


  // bob wants <b>to</b> switch <b>to</b> a different <a href="Teams.md#0x1_Teams_Team">Team</a>.
  <b>if</b> (<b>exists</b>&lt;<a href="Teams.md#0x1_Teams_Member">Member</a>&gt;(addr)) {
    <b>let</b> member_state = borrow_global_mut&lt;<a href="Teams.md#0x1_Teams_Member">Member</a>&gt;(addr);
    // <b>update</b> the membership list of the former captain
    member_state.captain_address = captain_address;
    // TODO: Do we need <b>to</b> reset mining_above_threshold <b>if</b> they are switching?
  } <b>else</b> { // first time joining a <a href="Teams.md#0x1_Teams_Team">Team</a>.
    move_to&lt;<a href="Teams.md#0x1_Teams_Member">Member</a>&gt;(sender, <a href="Teams.md#0x1_Teams_Member">Member</a> {
      captain_address,
      mining_above_threshold: <b>false</b>,
    });
  };
}
</code></pre>



</details>

<a name="0x1_Teams_maybe_activate_member_to_team"></a>

## Function `maybe_activate_member_to_team`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_maybe_activate_member_to_team">maybe_activate_member_to_team</a>(miner_sig: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_maybe_activate_member_to_team">maybe_activate_member_to_team</a>(miner_sig: &signer) <b>acquires</b> <a href="Teams.md#0x1_Teams_Member">Member</a>, <a href="Teams.md#0x1_Teams_Team">Team</a>, <a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a> {
  <b>let</b> miner_addr = <a href="../../../../../../move-stdlib/docs/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(miner_sig);

  // check <b>if</b> user has a team preference
  <b>if</b> (!<b>exists</b>&lt;<a href="Teams.md#0x1_Teams_Member">Member</a>&gt;(miner_addr)) { <b>return</b> };

  <b>let</b> member_state = borrow_global&lt;<a href="Teams.md#0x1_Teams_Member">Member</a>&gt;(miner_addr);

  // Find the user team preference.
  <b>let</b> all_teams = borrow_global&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  <b>let</b> miner_height = <a href="TowerState.md#0x1_TowerState_get_tower_height">TowerState::get_tower_height</a>(miner_addr);
  <b>if</b> (miner_height &gt; all_teams.member_threshold_epoch) {
    <b>let</b> team_state = borrow_global_mut&lt;<a href="Teams.md#0x1_Teams_Team">Team</a>&gt;(member_state.captain_address);

    <b>let</b> v = *&team_state.members;
    <b>let</b> already_there = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_contains">Vector::contains</a>&lt;address&gt;(&v, &miner_addr);

    <b>if</b> (!already_there) {
      <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> v, miner_addr);
      team_state.members = v;
    }
  }
}
</code></pre>



</details>

<a name="0x1_Teams_find_rms_of_towers"></a>

## Function `find_rms_of_towers`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_find_rms_of_towers">find_rms_of_towers</a>(vm: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_find_rms_of_towers">find_rms_of_towers</a>(vm: &signer): u64 <b>acquires</b> <a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);
  <b>let</b> miner_list = <a href="TowerState.md#0x1_TowerState_get_miner_list">TowerState::get_miner_list</a>();
  <b>let</b> len = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_length">Vector::length</a>&lt;address&gt;(&miner_list);

  // 1. sum the squares
  <b>let</b> sum_squares = 0;

  <b>let</b> i = 0;
  <b>while</b> (i &lt; len)  {
    <b>let</b> addr = <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&miner_list, i);
    <b>let</b> count = <a href="TowerState.md#0x1_TowerState_get_tower_height">TowerState::get_tower_height</a>(*addr);

    sum_squares = sum_squares + (count*count);
    i = i + 1;
  };

  // 2. divide by len
  <b>let</b> divided = sum_squares / len;

  // 3. take square root
  <b>let</b> d = <a href="Decimal.md#0x1_Decimal_new">Decimal::new</a>(<b>true</b>, (divided <b>as</b> u128) , 0);
  <b>let</b> rms = <a href="Decimal.md#0x1_Decimal_sqrt">Decimal::sqrt</a>(&d);

  <b>let</b> trunc = <a href="Decimal.md#0x1_Decimal_trunc">Decimal::trunc</a>(&rms);
  <b>let</b> (_, int, frac) = <a href="Decimal.md#0x1_Decimal_unwrap">Decimal::unwrap</a>(&trunc);

  // after truncation the fractional part should be 0
  <b>if</b> (frac &gt; 0) { <b>return</b> 0 };

  <b>if</b> (int &gt; 0) {
    // <b>let</b> rms = 10;
    <b>let</b> s = borrow_global_mut&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
    s.tower_height_rms = (int <b>as</b> u64);

    <b>return</b> *&s.tower_height_rms
  };

  0
}
</code></pre>



</details>

<a name="0x1_Teams_set_threshold_as_pct_rms"></a>

## Function `set_threshold_as_pct_rms`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_set_threshold_as_pct_rms">set_threshold_as_pct_rms</a>(vm: &signer): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_set_threshold_as_pct_rms">set_threshold_as_pct_rms</a>(vm: &signer): u64 <b>acquires</b> <a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a> {

  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);

  <b>let</b> s = borrow_global_mut&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  // TODO: decide the final threshold. Using 25% of RMS for simplicity
  <b>let</b> thresh = s.tower_height_rms / 4;

  s.member_threshold_epoch = thresh;

  *&s.member_threshold_epoch
}
</code></pre>



</details>

<a name="0x1_Teams_ratchet_collective_threshold"></a>

## Function `ratchet_collective_threshold`



<pre><code><b>fun</b> <a href="Teams.md#0x1_Teams_ratchet_collective_threshold">ratchet_collective_threshold</a>(vm: &signer, current_epoch: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Teams.md#0x1_Teams_ratchet_collective_threshold">ratchet_collective_threshold</a>(vm: &signer, current_epoch: u64): u64 <b>acquires</b> <a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a> {
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);

  <b>let</b> ratchet = 10; //todo

  <b>let</b> s = borrow_global_mut&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());

  // safety mechanism, no single account should have enough tower height <b>to</b> be able <b>to</b> enter validator set.
  // the minimum threshold should be 1 + the maximum number of proofs able <b>to</b> be mined from start of network
  <b>let</b> min_thresh = current_epoch * 72;
  <b>if</b> (s.collective_threshold_epoch &lt; min_thresh) {
    s.collective_threshold_epoch = min_thresh;
  };

  s.collective_threshold_epoch = s.collective_threshold_epoch + ratchet;

  *&s.collective_threshold_epoch

}
</code></pre>



</details>

<a name="0x1_Teams_get_all_teams"></a>

## Function `get_all_teams`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_get_all_teams">get_all_teams</a>(): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_get_all_teams">get_all_teams</a>(): vector&lt;address&gt; <b>acquires</b> <a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())) {
    <b>let</b> list = borrow_global&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
    <b>return</b> *&list.teams_list
  } <b>else</b> {
    <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
  }
}
</code></pre>



</details>

<a name="0x1_Teams_team_is_init"></a>

## Function `team_is_init`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_team_is_init">team_is_init</a>(captain: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_team_is_init">team_is_init</a>(captain: address): bool {
  <b>exists</b>&lt;<a href="Teams.md#0x1_Teams_Team">Team</a>&gt;(captain)
}
</code></pre>



</details>

<a name="0x1_Teams_member_is_init"></a>

## Function `member_is_init`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_member_is_init">member_is_init</a>(member: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_member_is_init">member_is_init</a>(member: address): bool {
  <b>exists</b>&lt;<a href="Teams.md#0x1_Teams_Member">Member</a>&gt;(member)
}
</code></pre>



</details>

<a name="0x1_Teams_get_operator_reward"></a>

## Function `get_operator_reward`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_get_operator_reward">get_operator_reward</a>(captain: address): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_get_operator_reward">get_operator_reward</a>(captain: address):u64 <b>acquires</b> <a href="Teams.md#0x1_Teams_Team">Team</a> {
  <b>if</b> (<a href="Teams.md#0x1_Teams_team_is_init">team_is_init</a>(captain)) {
    <b>let</b> s = borrow_global_mut&lt;<a href="Teams.md#0x1_Teams_Team">Team</a>&gt;(captain);
    <b>return</b> *&s.operator_pct_reward
  };
  0
}
</code></pre>



</details>

<a name="0x1_Teams_get_team_members"></a>

## Function `get_team_members`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_get_team_members">get_team_members</a>(captain: address): vector&lt;address&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_get_team_members">get_team_members</a>(captain: address):vector&lt;address&gt; <b>acquires</b> <a href="Teams.md#0x1_Teams_Team">Team</a> {
  <b>if</b> (<a href="Teams.md#0x1_Teams_team_is_init">team_is_init</a>(captain)) {
    <b>let</b> s = borrow_global_mut&lt;<a href="Teams.md#0x1_Teams_Team">Team</a>&gt;(captain);
    <b>return</b> *&s.members
  };
  <a href="../../../../../../move-stdlib/docs/Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;address&gt;()
}
</code></pre>



</details>

<a name="0x1_Teams_is_member_above_thresh"></a>

## Function `is_member_above_thresh`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_is_member_above_thresh">is_member_above_thresh</a>(miner: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_is_member_above_thresh">is_member_above_thresh</a>(miner: address):bool <b>acquires</b> <a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a> {
  <b>let</b> c = <a href="TowerState.md#0x1_TowerState_get_tower_height">TowerState::get_tower_height</a>(miner);
  (c &gt; <a href="Teams.md#0x1_Teams_get_member_thresh">get_member_thresh</a>())
}
</code></pre>



</details>

<a name="0x1_Teams_get_member_thresh"></a>

## Function `get_member_thresh`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_get_member_thresh">get_member_thresh</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_get_member_thresh">get_member_thresh</a>():u64 <b>acquires</b> <a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a> {
  <b>if</b> (<b>exists</b>&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())) {
    <b>let</b> s = borrow_global_mut&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
    <b>return</b> *&s.member_threshold_epoch
  };
  0
}
</code></pre>



</details>

<a name="0x1_Teams_vm_is_init"></a>

## Function `vm_is_init`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_vm_is_init">vm_is_init</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_vm_is_init">vm_is_init</a>(): bool {
  <b>exists</b>&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>())
}
</code></pre>



</details>

<a name="0x1_Teams_test_helper_set_thresh"></a>

## Function `test_helper_set_thresh`



<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_test_helper_set_thresh">test_helper_set_thresh</a>(vm: &signer, thresh: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Teams.md#0x1_Teams_test_helper_set_thresh">test_helper_set_thresh</a>(vm: &signer,  thresh: u64) <b>acquires</b> <a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a> {
  <b>assert</b>(<a href="Testnet.md#0x1_Testnet_is_testnet">Testnet::is_testnet</a>(), <a href="../../../../../../move-stdlib/docs/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(130118));
  <a href="CoreAddresses.md#0x1_CoreAddresses_assert_vm">CoreAddresses::assert_vm</a>(vm);

  <b>let</b> s = borrow_global_mut&lt;<a href="Teams.md#0x1_Teams_AllTeams">AllTeams</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_VM_RESERVED_ADDRESS">CoreAddresses::VM_RESERVED_ADDRESS</a>());
  s.member_threshold_epoch = thresh;
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
