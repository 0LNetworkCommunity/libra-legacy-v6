//! `chain_info`

use diem_types::account_address::AccountAddress;

use super::{chain_view::ValidatorView, node::Node};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Clone, Debug, Deserialize, Serialize)]
///
pub struct PayeeStats {
    ///
    pub address: AccountAddress,
    ///
    pub note: String,
    ///
    pub balance: f64,
    ///
    pub payers: u64,
    ///
    pub average_percent: f64,
    ///
    pub sum_percentage: u64,
    ///
    pub all_percentage: f64,
}

impl Node {
    /// Get all percentage recurring payees stats
    pub fn get_autopay_watch_list(&self, vals: Vec<ValidatorView>) -> Option<Vec<PayeeStats>> {
        let mut payees: HashMap<AccountAddress, PayeeSums> = HashMap::new();
        let mut total: u64 = 0;

        struct PayeeSums {
            pub amount: u64,
            pub payers: u64,
        }

        // iterate over all validators
        for val in vals.iter() {
            if let Some(ap) = &val.autopay {
                // iterate over all autopay instructions
                let mut val_payees: HashMap<AccountAddress, u64> = HashMap::new();
                for payment in ap.payments.iter() {
                    if payment.is_percent_of_change() {
                        total += payment.amt;
                        *val_payees.entry(payment.payee).or_insert(0) += payment.amt;
                    }
                }
                // sum payers and amount
                for (payee, amount) in val_payees.iter() {
                    let payee_sums = payees.get_mut(&payee);
                    match payee_sums {
                        Some(p) => {
                            p.amount = p.amount + amount;
                            p.payers = p.payers + 1;
                        }
                        None => {
                            payees.insert(
                                *payee,
                                PayeeSums {
                                    amount: *amount,
                                    payers: 1,
                                },
                            );
                        }
                    }
                }
            }
        }

        // collect payees stats
        let dict = self.load_account_dictionary();
        let ret = payees
            .iter()
            .map(|(payee, stat)| PayeeStats {
                note: dict.get_note_for_address(*payee),
                address: *payee,
                payers: stat.payers,
                average_percent: stat.amount as f64 / stat.payers as f64,
                balance: self.get_account_balance(*payee).unwrap_or(0.0),
                sum_percentage: stat.amount,
                all_percentage: (stat.amount * 10000) as f64 / total as f64,
            })
            .collect();
        Some(ret)
    }
}
