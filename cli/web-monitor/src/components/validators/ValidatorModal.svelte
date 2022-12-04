<script>
    import AutoPay from "../autopay/AutoPay.svelte";
    export let validator;
    export let id;
    function get_operator_account(validator) {
        let config = validator.validator_config;
        return config && config.operator_account
            ? config.operator_account
            : "Not Found";
    }
    function has_operator_balance(validator) {
        let config = validator.validator_config;
        return config && (config.operator_has_balance != null)
            ? config.operator_has_balance
                ? "Yes"
                : "No"
            : "Not Found";
    }
    function can_create_account(validator) {
        console.log(validator.epochs_since_last_account_creation);
        const epochs_to_wait = 13; // TODO fetch #days from the chain (EPOCHS_UNTIL_ACCOUNT_CREATION)
        if (validator.epochs_since_last_account_creation > epochs_to_wait) {
            return "Yes";
        }

        let diff = epochs_to_wait - validator.epochs_since_last_account_creation;
        return "No (" + diff + " epoch" + (diff == 1 ? "" : "s") + " to enable)";
    }
</script>

<style>
    #validator-modal-body {
        width: auto !important;
        max-width: 1200px !important;
    }
</style>

{#if validator}
  <div id="{id ? id : 'validator-modal'}" uk-modal>
      <div id="validator-modal-body" class="uk-modal-dialog uk-modal-body">
          <button class="uk-modal-close-default" type="button" uk-close></button>
          <h2 class="uk-modal-title uk-text-muted">Validator Info</h2>
          <table class="uk-table">
            <thead>
                <tr>
                    <th></th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <tr>
                  <td class="uk-table-expand">account address</td>
                  <td>{validator.account_address}</td>
                </tr>
                <tr>
                    <td>fullnode network address</td>
                    <td class="uk-text-break">{validator.vfn_full_ip}</td>
                </tr>
                <tr>
                    <td>validator network address</td>
                    <td>{validator.validator_full_ip}</td>
                </tr>
                <tr>
                    <td>epochs validating and mining</td>
                    <td>{validator.epochs_validating_and_mining}</td>
                </tr>
                <tr>
                    <td>operator account</td>
                    <td>{get_operator_account(validator)}</td>
                </tr>
                <tr>
                    <td>operator has positive balance</td>
                    <td>{has_operator_balance(validator)}</td>
                </tr>
                <tr>
                    <td>can create account</td>
                    <td>{can_create_account(validator)}</td>
                </tr>
            </tbody>
          </table>
          <AutoPay account={validator}/>
      </div>
  </div>
{/if}