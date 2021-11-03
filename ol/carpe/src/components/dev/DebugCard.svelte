<script lang="ts">
  import type { CarpeError } from "../../carpeError";
  import { errors } from "../../carpeError";

  import { responses } from "../../debug"; // TODO: Make this read only

  let home = "";
  let account = "";

  let result_string = "";
  let this_error: CarpeError;

  responses.subscribe((value) => {
    this_error = undefined;
    result_string = value;
  });

  errors.subscribe((value) => {
    result_string = "";
    if (value != undefined) {
      this_error = value;
    }
  });
</script>

<main>
  <div class="uk-margin uk-card uk-card-default uk-card-body uk-width-1-2@m">
    <h5 class="uk-card-title uk-text-light uk-text-muted uk-text-uppercase">Debug Requests</h5>

    <!-- <table class="uk-table uk-table-divider">
      <thead>
        <tr>
          <th>Path</th>
          <th>Address</th>
          <th>Mnem</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>{home}</td>
          <td>{account}</td>
        </tr>
      </tbody>
    </table> -->

    <!-- <h4></h4> -->
    <p>
      {#if result_string.length !== 0}
        RESULT:
        <br />
        {result_string}
      {/if}
      <br />
      {#if this_error != undefined}
        ERROR:
        <br />
        message: {this_error.msg}
        uid: {this_error.uid}
      {/if}
    </p>
  </div>
</main>
