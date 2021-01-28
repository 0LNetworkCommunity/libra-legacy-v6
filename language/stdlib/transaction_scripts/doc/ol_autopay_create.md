
<a name="autopay_create_instruction"></a>

# Script `autopay_create_instruction`





<pre><code><b>use</b> <a href="../../modules/doc/AutoPay.md#0x1_AutoPay">0x1::AutoPay</a>;
<b>use</b> <a href="../../modules/doc/Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="ol_autopay_create.md#autopay_create_instruction">autopay_create_instruction</a>(sender: &signer, payee: address, end_epoch: u64, percentage: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ol_autopay_create.md#autopay_create_instruction">autopay_create_instruction</a>(
  sender: &signer,
  payee: address,
  end_epoch: u64,
  percentage: u64,
) {
  <b>let</b> account = <a href="../../modules/doc/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);
  <b>assert</b>(<a href="../../modules/doc/AutoPay.md#0x1_AutoPay_is_enabled">AutoPay::is_enabled</a>(account), 0);
  <a href="../../modules/doc/AutoPay.md#0x1_AutoPay_create_instruction">AutoPay::create_instruction</a>(
    sender,
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
