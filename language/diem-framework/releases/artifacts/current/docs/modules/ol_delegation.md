
<a name="0x1_TeamsScripts"></a>

# Module `0x1::TeamsScripts`



-  [Function `create_team`](#0x1_TeamsScripts_create_team)


<pre><code><b>use</b> <a href="Teams.md#0x1_Teams">0x1::Teams</a>;
</code></pre>



<a name="0x1_TeamsScripts_create_team"></a>

## Function `create_team`



<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_delegation.md#0x1_TeamsScripts_create_team">create_team</a>(sender: signer, team_name: vector&lt;u8&gt;, operator_pct_reward: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>script</b>) <b>fun</b> <a href="ol_delegation.md#0x1_TeamsScripts_create_team">create_team</a>(
    sender: signer,
    team_name: vector&lt;u8&gt;,
    operator_pct_reward: u64,
) {
  <a href="Teams.md#0x1_Teams_team_init">Teams::team_init</a>(&sender, team_name, operator_pct_reward);
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/diem/dip/blob/main/dips/dip-2.md
[ROLE]: https://github.com/diem/dip/blob/main/dips/dip-2.md#roles
[PERMISSION]: https://github.com/diem/dip/blob/main/dips/dip-2.md#permissions
