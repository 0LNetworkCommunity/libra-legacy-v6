<script>
    export let validator;
</script>

{#if validator}
  <div id="validator-modal" uk-modal>
      <div class="uk-modal-dialog uk-modal-body">
          <button class="uk-modal-close-default" type="button" uk-close></button>
          <h2 class="uk-modal-title">Validator Info</h2>
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
                  <td class="hash">{validator.account_address}</td>
                </tr>
                <tr>
                    <td>fullnode network address</td>
                    <td class="uk-text-break">{validator.full_node_ip}</td>
                </tr>
                <tr>
                    <td>validator network address</td>
                    <td>{validator.validator_ip}</td>
                </tr>
                <tr>
                    <td>epochs validating and mining</td>
                    <td>{validator.epochs_validating_and_mining}</td>
                </tr>
                <tr>
                  <td>can create account</td>
                  <td>{validator.epochs_since_last_account_creation > 7}</td> <!--TODO move to the serve side?-->
              </tr>
            </tbody>
          </table>
      </div>
  </div>
{/if}

