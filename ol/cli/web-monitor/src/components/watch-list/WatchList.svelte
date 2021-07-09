<script>
    export let data;
   
    let sortableColumns = [
        { label: "#payers", sortKey: "payers" },
        { label: "average %", sortKey: "average_percent" },
        { label: "balance", sortKey: "balance" },
        { label: "sum %", sortKey: "sum_percentage" },
        { label: "% of all", sortKey: "all_percentage" },
    ];
    let sortOption = "balance";
    let sortOrder = 1;
    
    let watch_list = null;
    $: if (data && data.chain_view && data.chain_view.autopay_watch_list) {
        watch_list = data.chain_view.autopay_watch_list.sort((a, b) => (a[sortOption] > b[sortOption]) ? sortOrder : -sortOrder);
    }
    
    function thOnClick(key) {
        if (sortOption == key) {
        sortOrder = -sortOrder;
        }
        sortOption = key;
    }

    function formatBalance(balance) {
        return balance.toLocaleString('en-ES', {
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        });
    }

    function print_percent(num) {
        return (num / 100).toFixed(2) + "%";
    }
</script>

<div class="uk-card uk-card-default uk-card-body uk-margin-bottom">
    <h3 class="uk-card-title uk-text-center uk-text-uppercase uk-text-muted uk-text-large">
        Autopay Watch List
    </h3>
    {#if watch_list}
        <div>
            <table class="uk-table">
                <thead>
                    <tr>
                        <th class="uk-text-center">payee</th>
                        {#each sortableColumns as col}
                            <th class="uk-text-right" on:click={() => thOnClick(col.sortKey)}>
                            <span class="disable-select">{col.label}</span>
                            {#if sortOption == col.sortKey}
                                {#if sortOrder == 1}
                                <span uk-icon="icon: triangle-up"></span>
                                {:else}
                                <span uk-icon="icon: triangle-down"></span>
                                {/if}
                            {/if}
                            </th>
                        {/each}
                    </tr>
                </thead>
                <tbody>
                    {#each watch_list as {payee, balance, payers, average_percent, sum_percentage, all_percentage}}
                        <tr>
                            <td class="uk-visible@s uk-text-center">{payee}</td>
                            <td class="uk-hidden@s uk-text-truncate">{payee}</td>
                            <td class="uk-text-right">{payers}</td>
                            <td class="uk-text-right">{print_percent(average_percent)}</td>
                            <td class="uk-text-right">{formatBalance(balance)}</td>
                            <td class="uk-text-right">{print_percent(sum_percentage)}</td>
                            <td class="uk-text-right">{print_percent(all_percentage)}</td>
                        </tr>
                    {/each}
                </tbody>
            </table>
        </div>
    {/if}
</div>