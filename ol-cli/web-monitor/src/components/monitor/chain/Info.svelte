<script lang="ts">

  let epoch: number = 0;
  let round: number = 0;
  let waypoint: string = undefined;
</script>

<div class="uk-card uk-card-default uk-card-body">
  <h3 class="uk-card-title uk-text-center uk-text-uppercase uk-text-muted">
    Chain
  </h3>

  <table class="uk-table">
    <tbody>
      <tr>
        <td>Epoch</td>
        <td> {epoch} </td>
      </tr>
      <tr>
        <td>Round</td>
        <td>{round}</td>
      </tr>
      <tr>
        <td>Waypoint</td>
        <td>{waypoint}</td>
      </tr>
    </tbody>
  </table>
</div>
