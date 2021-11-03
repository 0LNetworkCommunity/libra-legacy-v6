<script>
  import { get } from "svelte/store";
  import { proofState, tower } from "../../miner";

  tower.subscribe((s) => {
    let percent = 0;
    var bar = document.getElementById("js-progressbar");

    var animate = setInterval(function () {
      let ps = get(proofState);
      console.log(ps);
      // window.alert(JSON.stringify(ps));
      if (ps && ps.time_start > 0) {
        let duration = ps.previous_duration;
        console.log(duration)
        let since_start = Date.now() - ps.time_start;
        console.log(ps.time_start);
        console.log(since_start);
        percent = since_start / duration;
        console.log(percent);
        bar.value = percent;
      if (bar.value >= bar.max) {
        clearInterval(animate);
      }
    } else {
      bar.value = 0
    }
    }, 1000);
  })
</script>

<main>
  <progress id="js-progressbar" class="uk-progress" value="0" max="1" />
</main>
