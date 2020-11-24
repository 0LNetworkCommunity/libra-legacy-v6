
<a name="autopay_create_instruction_tx"></a>

# Script `autopay_create_instruction_tx`





<pre><code><b>use</b> <a href="../../modules/doc/AutoPay.md#0x1_AutoPay">0x1::AutoPay</a>;
<b>use</b> <a href="../../modules/doc/Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="autopay_create_0l.md#autopay_create_instruction_tx">autopay_create_instruction_tx</a>(sender: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="autopay_create_0l.md#autopay_create_instruction_tx">autopay_create_instruction_tx</a>(sender: &signer) {
  <b>let</b> account = <a href="../../modules/doc/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>let</b> uid = 1;
  <b>let</b> payee = 0x02;
  <b>let</b> end_epoch = 14;
  <b>let</b> percentage = 1;
  <b>assert</b>(<a href="../../modules/doc/AutoPay.md#0x1_AutoPay_is_enabled">AutoPay::is_enabled</a>(account), 0);
  <a href="../../modules/doc/AutoPay.md#0x1_AutoPay_create_instruction">AutoPay::create_instruction</a>(
    sender,
    uid,
    payee,
    end_epoch,
    percentage,
  );
}
</code></pre>



</details>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
