<script>
    export let stats;
    function print_percent(num) {
        return (num * 100).toFixed(0) + "%";
    }
</script>

<style>
    .audit-container {
        margin: auto;
        max-width: 400px;
    }
</style>

<div class="audit-container">
    <table class="uk-table">
        <tr>
            <td>Has Recurring Autopay</td>
            <td class="uk-text-right">{stats.count_vals_with_autopay}</td>
            <td class="uk-text-right">{print_percent(stats.percent_vals_with_autopay)}</td>
        </tr>
        <tr>
            <td>Has Operator Account</td>
            <td class="uk-text-right">{stats.count_vals_with_operator}</td>
            <td class="uk-text-right">{print_percent(stats.percent_vals_with_operator)}</td>
        </tr>
        <tr>
            <td>Has Operator Positive Balance</td>
            <td class="uk-text-right">{stats.count_positive_balance_operators}</td>
            <td class="uk-text-right">{print_percent(stats.percent_positive_balance_operators)}</td>
        </tr>
    </table>        
</div>