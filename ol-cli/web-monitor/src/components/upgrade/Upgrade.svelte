<script>
  let versions = [
    {
      hash: "xyz",
      vote_count: 10,
    },
  ];
</script>

<main>
  <div class="uk-child-width-expand@s" uk-grid>
    <div class="uk-grid-item-match">
      <div class="uk-card uk-card-default uk-card-body">
        <h3>Proposals</h3>
        <p>Lorem ipsum dolor sit amet.</p>
      </div>
    </div>
    <div>
      <h3>Historical</h3>
      <div class="uk-overflow-auto">
        <table
          class="uk-table uk-table-small uk-table-divider uk-table-responsive"
          uk-accordion
        >
          <thead>
            <tr>
              <th />
              <th>Hash</th>
              <th>Votes</th>
            </tr>
          </thead>
          <tbody>
            {#each versions as v, i}
              <tr>
                <td>{i + 1}</td>
                <td>{v.hash}</td>
                <td>{v.vote_ount}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  </div>
</main>
