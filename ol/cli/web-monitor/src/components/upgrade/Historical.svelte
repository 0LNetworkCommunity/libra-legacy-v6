<script>

    let versions = [
    {
      hash: "xyz",
      vote_count: 0,
    },
  ];
</script>
<main>
  <div>
    <h3 class="uk-text-muted uk-text-center uk-text-uppercase uk-text-small">
      Historical Upgrades
    </h3>
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
              <td class="hash">{v.hash}</td>
              <td>{v.vote_count}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </div>
</main>
