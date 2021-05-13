
<a name="autopay_create_instruction"></a>

# Script `autopay_create_instruction`



-  [Constants](#@Constants_0)


<pre><code><b>use</b> <a href="../../modules/doc/AutoPay.md#0x1_AutoPay2">0x1::AutoPay2</a>;
<b>use</b> <a href="../../modules/doc/Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="../../modules/doc/Signer.md#0x1_Signer">0x1::Signer</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="autopay_create_instruction_EAUTOPAY_NOT_ENABLED"></a>



<pre><code><b>const</b> <a href="ol_autopay_create.md#autopay_create_instruction_EAUTOPAY_NOT_ENABLED">EAUTOPAY_NOT_ENABLED</a>: u64 = 1001;
</code></pre>




<pre><code><b>public</b> <b>fun</b> <a href="ol_autopay_create.md#autopay_create_instruction">autopay_create_instruction</a>(sender: &signer, uid: u64, in_type: u8, payee: address, end_epoch: u64, percentage: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ol_autopay_create.md#autopay_create_instruction">autopay_create_instruction</a>(
  sender: &signer,
  uid: u64,
  in_type: u8,
  payee: address,
  end_epoch: u64,
  percentage: u64,
) {
  <b>let</b> account = <a href="../../modules/doc/Signer.md#0x1_Signer_address_of">Signer::address_of</a>(sender);

  <b>if</b> (!<a href="../../modules/doc/AutoPay.md#0x1_AutoPay2_is_enabled">AutoPay2::is_enabled</a>(account)) {
    <a href="../../modules/doc/AutoPay.md#0x1_AutoPay2_enable_autopay">AutoPay2::enable_autopay</a>(sender);
    <b>assert</b>(<a href="../../modules/doc/AutoPay.md#0x1_AutoPay2_is_enabled">AutoPay2::is_enabled</a>(account), <a href="../../modules/doc/Errors.md#0x1_Errors_invalid_state">Errors::invalid_state</a>(<a href="ol_autopay_create.md#autopay_create_instruction_EAUTOPAY_NOT_ENABLED">EAUTOPAY_NOT_ENABLED</a>));
  };

  <a href="../../modules/doc/AutoPay.md#0x1_AutoPay2_create_instruction">AutoPay2::create_instruction</a>(
    sender,
    uid,
    in_type,
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
