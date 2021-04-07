  <div class="uk-overflow-auto">
    <table
      class="uk-table uk-table-small uk-table-divider uk-table-responsive"
      uk-accordion
    >
      <thead>
        <tr>
          <th />
          <th>Account</th>
          <th>Voting Power</th>
          <th>Proofs in Epoch</th>
          <th>Can Create Account</th>
        </tr>
      </thead>
      <tbody>
        {#each set as val, i}
          <tr></tr>
            <td>{i + 1}</td>
            <td>{val.account_address}</td>
            <td>{val.voting_power}</td>
            <td>{val.count_proofs_in_epoch}</td>
            <td>{can_create_account(val)}</td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>