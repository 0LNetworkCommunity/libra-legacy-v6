<script>
  let headers = ["a", "b", "c"]
  let valSet = [
    {a: 1, b: 2, c: 3},
    {a: 1, b: 2, c: 3},
  ]
</script>
<main>
  validators

  <div class="uk-overflow-auto">
    <table
      class="uk-table uk-table-small uk-table-divider uk-table-responsive "
    >
      <thead>
        <tr>
          {#each headers as head}
            <th>{head}</th>
          {/each}
        </tr>
      </thead>
      <tbody>
        {#each valSet as val}
          <tr>
            <td>{val.a}</td>
            <td>{val.b}</td>
            <td>{val.c}</td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
</main>
