import { invoke } from '@tauri-apps/api/tauri';
import { writable, get } from 'svelte/store';
import { raise_error } from './carpeError';
import { responses } from './debug';
import { Networks, setNetwork } from './networks';
export interface AccountEntry {
  account: string,
  authkey: string,
  nickname: string,
  balance: number,
}



export const new_account = function (account: string, authkey: string, nickname: string): AccountEntry {

  return {
    account: account,
    authkey: authkey,
    nickname: nickname,
    balance: 0,
  }
};

export const signingAccount = writable<AccountEntry>(new_account("", "", ""));

export const mnem = writable("");

// export const account = writable("");
// export const authkey = writable("");
export const all_accounts = writable<AccountEntry[]>([]);

export function getAllAccounts() {
  invoke('get_all_accounts')
    .then((result: object) => all_accounts.set(result.accounts))
    .catch((error) => raise_error(error));
}


export function findOneAccount(account: string): AccountEntry {
  let list = get(all_accounts);
  let found = list.find((i) => i.account == account)
  return found
}

export async function setAccount(an_address: string) {
  let a = findOneAccount(an_address);
  signingAccount.set(a);

  await invoke("switch_profile", {
    account: a.account,
  })
    .then((res) => {
      responses.set(res);
      // for testnet
      setNetwork(Networks.Rex);
    })
    .catch((e) => raise_error(e));
}