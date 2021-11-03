import { writable } from 'svelte/store';

export const responses = writable("");
// export const errors = writable("");

// always clear error when a response is updated
// responses.subscribe(_ => {
//   errors.set("")
// })

// // same for reponses
// errors.subscribe(_ => {
//   responses.set("")
// })