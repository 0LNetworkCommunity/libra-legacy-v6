<script lang="ts">
import { signingAccount } from "../../accounts";


  let authkey;
  signingAccount.subscribe(a => authkey = a.authkey)

</script>

<main>
    <!-- This is the modal -->
    <div id="modal-example" class="uk-modal-container" uk-modal>
        <div class="uk-modal-dialog uk-modal-body">
            <h2 class="uk-modal-title">Onboarding</h2>
            <p>Your account doesn't yet exist on chain. So far you have created the keys.</p>
            <h4> Give your Authkey to someone who already has an account, to send the account onboarding transaction.</h4>
            <h3> AUTH KEY: </h3>
            <span> {authkey} <span>

            <p class="uk-text-right">
                <button class="uk-button uk-button-default uk-modal-close" type="button">Close</button>
            </p>
        </div>
    </div>
</main>
